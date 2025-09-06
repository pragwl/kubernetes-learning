# Stage 1: Build the React application
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# This build uses .env.production to embed the placeholders
RUN npm run build

# Stage 2: Serve the application using Nginx
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html

# --- CRITICAL STEPS ---
# 1. Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
# 2. Make it executable
RUN chmod +x /entrypoint.sh

EXPOSE 80
# 3. Set it as the startup command
ENTRYPOINT ["/entrypoint.sh"]