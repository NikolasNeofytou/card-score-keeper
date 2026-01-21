# Deployment Configuration

This directory contains all deployment-related files for the Card Scorekeeper application.

## Files

- **Dockerfile** - Container build configuration for the Flutter web app
- **docker-compose.yml** - Multi-service deployment configuration
- **nginx.conf** - Nginx web server configuration
- **.dockerignore** - Files to exclude from Docker build context

## Usage

### Development with Docker
```bash
# From project root
cd deployment
docker-compose up --build

# Or using the build script
../scripts/build-and-run.sh docker
```

### Production Build
```bash
# Build production image
docker build -f deployment/Dockerfile -t card-scorekeeper .

# Run production container
docker run -p 8080:80 card-scorekeeper
```

### Nginx Configuration
The nginx.conf file is configured to:
- Serve the Flutter web build from /usr/share/nginx/html
- Handle single-page application routing
- Provide gzip compression
- Set appropriate headers for static assets

## Environment Variables
- `NGINX_HOST` - Server hostname (default: localhost)
- `NGINX_PORT` - Server port (default: 80)