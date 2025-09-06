#!/bin/sh
set -e

echo "Starting Nginx entrypoint script..."

ROOT_DIR=/usr/share/nginx/html

# Find the main JavaScript bundle and replace placeholders with runtime env variables
for file in $ROOT_DIR/static/js/main.*.js;
do
  echo "Processing $file ...";

  # Use a temporary file to avoid issues with in-place sed
  temp_file=$(mktemp)

  # Replace the placeholder with the actual value from the environment
  sed "s|REACT_APP_POST_MESSAGE_URL_PLACEHOLDER|${REACT_APP_POST_MESSAGE_URL}|g" "$file" > "$temp_file" && mv "$temp_file" "$file"
  sed "s|REACT_APP_GET_MESSAGES_URL_PLACEHOLDER|${REACT_APP_GET_MESSAGES_URL}|g" "$file" > "$temp_file" && mv "$temp_file" "$file"

  rm -f "$temp_file"
done

echo "Finished processing environment variables. Starting Nginx..."
nginx -g "daemon off;"