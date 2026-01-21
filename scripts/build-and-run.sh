#!/bin/bash
# Card Game Scorekeeper - Build and Run Script (Bash)
# This script handles both Flutter setup and running the application

set -e

MODE="${1:-web}"  # Options: web, mobile, docker
DEVICE="${2:-}"
CLEAN=false
BUILD=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN=true
            shift
            ;;
        --build)
            BUILD=true
            shift
            ;;
    esac
done

echo -e "\033[36mCard Game Scorekeeper - Build and Run Script\033[0m"
echo -e "\033[36m=============================================\033[0m"

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo -e "\033[31mError: Flutter is not installed or not in PATH\033[0m"
        echo -e "\033[33mPlease install Flutter from: https://flutter.dev/docs/get-started/install\033[0m"
        return 1
    fi
    return 0
}

# Clean build artifacts
clean_build() {
    echo -e "\n\033[33mCleaning build artifacts...\033[0m"
    flutter clean
    rm -f pubspec.lock
    echo -e "\033[32mClean complete!\033[0m"
}

# Get Flutter dependencies
get_dependencies() {
    echo -e "\n\033[33mGetting Flutter dependencies...\033[0m"
    flutter pub get
    echo -e "\033[32mDependencies installed successfully!\033[0m"
}

# Run Flutter web
start_web_app() {
    echo -e "\n\033[33mStarting Flutter web application...\033[0m"
    echo -e "\033[36mOpening at: http://localhost:5000\033[0m"
    flutter run -d chrome --web-port=5000
}

# Build Flutter web
build_web_app() {
    echo -e "\n\033[33mBuilding Flutter web application...\033[0m"
    flutter build web --release
    echo -e "\033[32mWeb build complete! Output in: build/web\033[0m"
}

# Run Flutter mobile
start_mobile_app() {
    echo -e "\n\033[33mStarting Flutter mobile application...\033[0m"
    
    if [ -n "$DEVICE" ]; then
        echo -e "\033[36mRunning on device: $DEVICE\033[0m"
        flutter run -d "$DEVICE"
    else
        # List available devices
        echo -e "\033[36mAvailable devices:\033[0m"
        flutter devices
        echo -e "\n\033[33mStarting on default device...\033[0m"
        flutter run
    fi
}

# Run with Docker
start_docker() {
    echo -e "\n\033[33mStarting with Docker...\033[0m"
    
    if ! command -v docker &> /dev/null; then
        echo -e "\033[31mError: Docker is not installed!\033[0m"
        echo -e "\033[33mPlease install Docker from: https://www.docker.com/get-started\033[0m"
        exit 1
    fi
    
    echo -e "\033[33mBuilding Docker image...\033[0m"
    docker-compose up --build
}

# Main execution
if [ "$MODE" != "docker" ]; then
    if ! check_flutter; then
        exit 1
    fi
fi

# Clean if requested
if [ "$CLEAN" = true ]; then
    clean_build
fi

# Get dependencies (unless running docker-only)
if [ "$MODE" != "docker" ]; then
    get_dependencies
fi

# Execute based on mode
case "$MODE" in
    web)
        if [ "$BUILD" = true ]; then
            build_web_app
        else
            start_web_app
        fi
        ;;
    mobile)
        start_mobile_app
        ;;
    docker)
        start_docker
        ;;
    *)
        echo -e "\033[31mInvalid mode: $MODE\033[0m"
        echo -e "\033[33mValid modes: web, mobile, docker\033[0m"
        echo -e "\n\033[36mExamples:\033[0m"
        echo -e "\033[37m  ./build-and-run.sh web\033[0m"
        echo -e "\033[37m  ./build-and-run.sh web --build\033[0m"
        echo -e "\033[37m  ./build-and-run.sh mobile chrome\033[0m"
        echo -e "\033[37m  ./build-and-run.sh docker\033[0m"
        echo -e "\033[37m  ./build-and-run.sh web --clean\033[0m"
        exit 1
        ;;
esac

echo -e "\n\033[32mScript completed!\033[0m"
