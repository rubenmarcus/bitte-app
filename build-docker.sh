#!/bin/bash

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local output_dir="src/download/$platform"

    echo "Building for $platform..."

    # Create output directory
    mkdir -p "$output_dir"

    # Build the Docker image if it doesn't exist
    if ! docker image inspect bitte-desktop-builder >/dev/null 2>&1; then
        docker build -t bitte-desktop-builder .
    fi

    # Create a volume for the output
    docker volume create bitte-desktop-output-$platform

    # Run the container and build for the specified platform
    docker run --rm \
        -v bitte-desktop-output-$platform:/output \
        bitte-desktop-builder $platform

    # Copy the built files from the container to your local machine
    docker run --rm \
        -v bitte-desktop-output-$platform:/output \
        -v "$(pwd):/local" \
        alpine cp -r /output/* "/local/$output_dir/"

    echo "Build complete for $platform! Check $output_dir for the built files."
}

# Build for all platforms
build_platform "linux"
build_platform "windows"
build_platform "android"

echo "All builds complete! Check the src/download directory for the built files."