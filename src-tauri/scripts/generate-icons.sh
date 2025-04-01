#!/bin/bash

# Source icon path
SOURCE_ICON="icons/bitte-icon-superellipse.png"

# Android icon sizes
ANDROID_SIZES=(
    "mdpi:48x48"
    "hdpi:72x72"
    "xhdpi:96x96"
    "xxhdpi:144x144"
    "xxxhdpi:192x192"
)

# Generate Android icons
echo "Generating Android icons..."
for size in "${ANDROID_SIZES[@]}"; do
    name="${size%%:*}"
    dimensions="${size##*:}"
    output="icons/android/${name}.png"
    echo "Generating $output ($dimensions)"
    convert "$SOURCE_ICON" -resize "$dimensions" "$output"
done

echo "Icon generation complete!"