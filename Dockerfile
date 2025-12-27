# Stage 1: Build Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec file (lock file is optional)
COPY pubspec.yaml ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Configure project for web
RUN flutter create . --platforms web

# Build web application
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Create custom nginx configuration
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 1024; \
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript; \
    location / { \
        try_files $uri $uri/ /index.html; \
        add_header Cache-Control "public, max-age=31536000" always; \
    } \
    location = /index.html { \
        add_header Cache-Control "no-cache, no-store, must-revalidate"; \
        add_header Pragma "no-cache"; \
        add_header Expires 0; \
    } \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
    error_page 404 /index.html; \
}' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
