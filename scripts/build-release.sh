#!/bin/bash

# Create download directories
mkdir -p src/download/{windows,macos,linux,android}

# Function to build for a specific platform
build_platform() {
    local platform=$1
    echo "Building for $platform..."

    case $platform in
        "windows")
            pnpm tauri build
            cp src-tauri/target/release/bundle/msi/*.msi src/download/windows/
            ;;
        "macos")
            chmod +x ./scripts/build.sh
            ./scripts/build.sh
            cp src-tauri/target/release/bundle/dmg/*.dmg src/download/macos/
            ;;
        "linux")
            chmod +x ./scripts/build.sh
            ./scripts/build.sh
            cp src-tauri/target/release/bundle/deb/*.deb src/download/linux/
            ;;
        "android")
            # Initialize Android project if not already done
            if [ ! -d "src-tauri/android" ]; then
                pnpm tauri android init
            fi

            # Copy Android icons
            mkdir -p src-tauri/android/app/src/main/res
            cp -r src-tauri/icons/android/* src-tauri/android/app/src/main/res/

            # Build Android
            export GRADLE_OPTS="-Dorg.gradle.internal.http.connectionTimeout=180000 -Dorg.gradle.internal.http.socketTimeout=180000"
            export GRADLE_DEBUG=true
            pnpm tauri android build --verbose

            # Find and copy the APK
            APK_FILE=$(find src-tauri/target/android/app/build/outputs/apk -name "*.apk" -type f)
            if [ -n "$APK_FILE" ]; then
                cp "$APK_FILE" src/download/android/
            else
                echo "No APK file found!"
                ls -R src-tauri/target/android/app/build/outputs/apk
                exit 1
            fi
            ;;
        *)
            echo "Unknown platform: $platform"
            exit 1
            ;;
    esac
}

# Build for all platforms if no argument is provided
if [ $# -eq 0 ]; then
    build_platform "windows"
    build_platform "macos"
    build_platform "linux"
    build_platform "android"
else
    # Build for specific platform
    build_platform "$1"
fi

echo "Build complete! Files are in src/download/"