echo "🐳 [3/7] Building Docker images inside Minikube..."
eval $(minikube -p minikube docker-env)

# --- CORRECTED VERSION EXTRACTION ---

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