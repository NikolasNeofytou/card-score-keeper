.PHONY: help install clean build run run-web run-mobile docker-build docker-run docker-up docker-down docker-logs test format lint

# Default target
help:
	@echo "Card Game Scorekeeper - Make Commands"
	@echo "======================================"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make install        - Install Flutter dependencies"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Development Commands:"
	@echo "  make run            - Run web app (default)"
	@echo "  make run-web        - Run web app with hot-reload"
	@echo "  make run-mobile     - Run on mobile device"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build          - Build production web app"
	@echo "  make build-web      - Build production web app"
	@echo "  make build-mobile   - Build mobile APK"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make docker-build   - Build Docker image"
	@echo "  make docker-run     - Run Docker container"
	@echo "  make docker-up      - Start with docker-compose"
	@echo "  make docker-down    - Stop docker-compose"
	@echo "  make docker-logs    - View docker logs"
	@echo "  make docker-dev     - Run in development mode"
	@echo ""
	@echo "Quality Commands:"
	@echo "  make test           - Run tests"
	@echo "  make format         - Format code"
	@echo "  make lint           - Analyze code"
	@echo ""

# Setup commands
install:
	@echo "Installing Flutter dependencies..."
	flutter pub get

clean:
	@echo "Cleaning build artifacts..."
	flutter clean
	rm -f pubspec.lock

# Development commands
run: run-web

run-web:
	@echo "Starting web application..."
	flutter run -d chrome --web-port=5000

run-mobile:
	@echo "Starting mobile application..."
	flutter run

# Build commands
build: build-web

build-web:
	@echo "Building web application..."
	flutter build web --release
	@echo "Build complete! Output in: build/web"

build-mobile:
	@echo "Building mobile APK..."
	flutter build apk --release
	@echo "Build complete! Output in: build/app/outputs/flutter-apk/"

# Docker commands
docker-build:
	@echo "Building Docker image..."
	docker build -t card-scorekeeper .

docker-run:
	@echo "Running Docker container..."
	docker run -d -p 8080:80 --name card-scorekeeper card-scorekeeper
	@echo "App running at: http://localhost:8080"

docker-up:
	@echo "Starting with docker-compose..."
	docker-compose up --build -d
	@echo "App running at: http://localhost:8080"

docker-down:
	@echo "Stopping docker-compose..."
	docker-compose down

docker-logs:
	@echo "Viewing docker logs..."
	docker-compose logs -f

docker-dev:
	@echo "Starting development server with docker..."
	docker-compose --profile dev up
	@echo "App running at: http://localhost:5000"

# Quality commands
test:
	@echo "Running tests..."
	flutter test

format:
	@echo "Formatting code..."
	dart format lib/ test/

lint:
	@echo "Analyzing code..."
	flutter analyze

# Combined commands
setup: clean install

rebuild: clean install build

dev: install run-web

prod: install build-web docker-build docker-run

# All-in-one deployment
deploy: clean install build-web docker-build docker-up
	@echo "Deployment complete!"
	@echo "Access the app at: http://localhost:8080"
