#!/bin/bash
set -e

# --- FUNCTION TO UPDATE HOSTS FILE ---
# This function adds or updates an entry in the local hosts file.
# It handles Linux, macOS, and Windows (via shells like Git Bash).
update_hosts_file() {
    local ip_address="$1"
    local hostname="$2"
    local entry="${ip_address} ${hostname}"

    # Determine hosts file path based on the operating system
    local hosts_file
    if [ "$(uname)" == "Darwin" ] || [ "$(uname)" == "Linux" ]; then
        hosts_file="/etc/hosts"
    elif [[ "$(uname -s)" == MINGW* || "$(uname -s)" == CYGWIN* || "$(uname -s)" == MSYS* ]]; then
        hosts_file="/c/Windows/System32/drivers/etc/hosts"
    else
        echo "🔴 Unsupported OS for automatic hosts file update."
        echo "Please manually add this line to your hosts file: '${entry}'"
        return
    fi

    # Check for privileges and provide instructions if needed
    if ! sudo -n true 2>/dev/null; then
      if [[ "$(uname)" != "Darwin" && "$(uname)" != "Linux" ]]; then
         # On Windows, we can't elevate. The user must run the shell as Admin.
         echo "🔴 Permission Denied. This script needs to modify ${hosts_file}." >&2
         echo "Please re-run this script in a terminal with Administrator privileges." >&2
         exit 1
      fi
    fi

    # Check if the entry already exists and is correct
    if grep -q -E "^\s*${ip_address}\s+${hostname}\s*$" "${hosts_file}"; then
        echo "✅ Hosts entry for '${hostname}' is already correct."
        return
    fi

    # If hostname exists with a different IP, remove the old line
    if grep -q -E "\s${hostname}\s*$" "${hosts_file}"; then
        echo "🔄 Updating existing hosts entry for '${hostname}'..."
        sudo sed -i.bak -E "/\s+${hostname}\s*$/d" "${hosts_file}"
    else
        echo "➕ Adding new hosts entry for '${hostname}'..."
    fi

    # Add the new entry. Prompt for password here if not already cached.
    echo "${entry}" | sudo tee -a "${hosts_file}" > /dev/null
    echo "✅ Successfully set '${hostname}' to '${ip_address}' in your hosts file."
}

# --- MAIN SCRIPT EXECUTION ---

echo "🧹 [1/7] Deleting all existing Kubernetes resources..."
kubectl delete all --all || true
kubectl delete pvc --all || true
kubectl delete pv --all || true
kubectl delete ingress --all || true
kubectl delete secret --all || true
kubectl delete configmap --all || true

echo "🔐 [2/7] Creating postgres secrets..."
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_DB=service1db \
  --from-literal=POSTGRES_USER=kubernetes \
  --from-literal=POSTGRES_PASSWORD=kubernetes

kubectl create secret generic postgres-replica-secret \
  --from-literal=POSTGRES_USER=replica_user \
  --from-literal=POSTGRES_PASSWORD=replica_pass

echo "🐳 [3/7] Building Docker images inside Minikube..."
eval $(minikube -p minikube docker-env)

echo "🐳 [3/7] Building Docker images inside Minikube..."
eval $(minikube -p minikube docker-env)

# Extract service1 version from build.gradle
SERVICE1_BUILD_GRADLE="kuberneteslearning-service-1/build.gradle"
# Use awk for a more robust and portable way to parse the version
SERVICE1_VERSION=$(awk -F"['\"]" '/version\s*=/ {print $2}' "$SERVICE1_BUILD_GRADLE" | head -1)

if [ -z "$SERVICE1_VERSION" ]; then
  echo "⚠️ Warning: Could not read service1 version from build.gradle, using '1.0.0' tag."
  SERVICE1_VERSION="1.0.0"
fi
echo "🔖 Service1 Spring Boot version detected: $SERVICE1_VERSION"

# Extract service2 version from build.gradle
SERVICE2_BUILD_GRADLE="kuberneteslearning-service-2/build.gradle"
# Use awk for a more robust and portable way to parse the version
SERVICE2_VERSION=$(awk -F"['\"]" '/version\s*=/ {print $2}' "$SERVICE2_BUILD_GRADLE" | head -1)

if [ -z "$SERVICE2_VERSION" ]; then
  echo "⚠️ Warning: Could not read service2 version from build.gradle, using '1.0.0' tag."
  SERVICE2_VERSION="1.0.0"
fi
echo "🔖 Service2 Spring Boot version detected: $SERVICE2_VERSION"

# --- END OF CORRECTION ---


# Extract frontend version from package.json
FRONTEND_VERSION=$(jq -r '.version' kuberneteslearning-frontendservice/package.json)
if [ -z "$FRONTEND_VERSION" ] || [ "$FRONTEND_VERSION" == "null" ]; then
  echo "⚠️ Warning: Could not read frontend version from package.json, using 'latest' tag."
  FRONTEND_VERSION="latest"
fi
echo "🔖 Frontend version detected: $FRONTEND_VERSION"

# Build service1 image with extracted version
(cd kuberneteslearning-service-1 && docker build -t service1:$SERVICE1_VERSION .)

# Build service2 image with extracted version
(cd kuberneteslearning-service-2 && docker build -t service2:$SERVICE2_VERSION .)

# Build frontend image with the version tag
(cd kuberneteslearning-frontendservice && docker build -t kuberneteslearning-frontendservice:$FRONTEND_VERSION .)

echo "📦 [4/7] Applying all Kubernetes manifests from the 'k8s' directory..."
kubectl apply -f k8s/ --recursive

echo "⏳ [5/7] Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres,role=primary --timeout=300s
kubectl wait --for=condition=ready pod -l app=postgres,role=replica --timeout=300s
kubectl wait --for=condition=ready pod -l app=service1 --timeout=180s
kubectl wait --for=condition=ready pod -l app=service2 --timeout=180s
kubectl wait --for=condition=ready pod -l app=frontend --timeout=180s

echo "📊 [6/7] Displaying current cluster status..."
kubectl get pods
kubectl get svc
kubectl get ingress

# Get the Minikube IP address
MINIKUBE_IP=$(minikube ip)

echo "✍️  [7/7] Updating hosts file (may require your password)..."
update_hosts_file "$MINIKUBE_IP" "kubernetes.local"

echo ""
echo "✅ Deployment Complete!"
echo "--------------------------------------------------------"
echo "--> Access the application UI at: http://kubernetes.local"
echo ""
