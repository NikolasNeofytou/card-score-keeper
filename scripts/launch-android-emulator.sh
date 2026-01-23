#!/bin/bash

# Launch Android emulator and run Flutter app
# Usage: ./launch-android-emulator.sh [device_id]

DEVICE_ID=${1:-"emulator-5554"}

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

function write_step() {
    echo -e "${CYAN}🚀 $1${NC}"
}

function write_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function write_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

function write_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flutter is installed
write_step "Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    write_success "Flutter found"
else
    write_error "Flutter not found. Please install Flutter first."
    exit 1
fi

# Check available emulators
write_step "Checking available emulators..."
emulators=$(flutter emulators)
if [[ $emulators == *"No emulators available"* ]]; then
    write_error "No Android emulators found. Please create one using Android Studio."
    exit 1
fi

# Check if emulator is already running
write_step "Checking if emulator is running..."
devices=$(flutter devices)
if [[ $devices == *"$DEVICE_ID"* ]]; then
    write_success "Emulator $DEVICE_ID is already running"
else
    write_warning "Emulator $DEVICE_ID not found in running devices"
    write_step "Starting emulator..."
    
    # Try to start the emulator (this might take a while)
    flutter emulators --launch Medium_Phone_API_36.0 &
    
    # Wait a bit for emulator to start
    write_step "Waiting for emulator to start..."
    sleep 15
    
    # Check again
    devices=$(flutter devices)
    if [[ $devices == *"$DEVICE_ID"* ]]; then
        write_success "Emulator started successfully"
    else
        write_error "Failed to start emulator"
        exit 1
    fi
fi

# Run Flutter app
write_step "Running Flutter app on $DEVICE_ID..."
flutter run -d "$DEVICE_ID"

if [ $? -eq 0 ]; then
    write_success "App launched successfully!"
else
    write_error "Failed to launch app"
fi