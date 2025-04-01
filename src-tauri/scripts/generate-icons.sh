#!/bin/bash

# Source icon path
SOURCE_ICON="icons/bitte-icon-superellipse.png"

# iOS icon sizes
IOS_SIZES=(
    "20pt:40x40"
    "29pt:58x58"
    "40pt:80x80"
    "60pt:120x120"
    "76pt:152x152"
    "83.5pt:167x167"
    "1024pt:1024x1024"
)

# Android icon sizes
ANDROID_SIZES=(
    "mdpi:48x48"
    "hdpi:72x72"
    "xhdpi:96x96"
    "xxhdpi:144x144"
    "xxxhdpi:192x192"
)

# Generate iOS icons
echo "Generating iOS icons..."
for size in "${IOS_SIZES[@]}"; do
    name="${size%%:*}"
    dimensions="${size##*:}"
    output="icons/ios/Icon-${name}.png"
    if [[ $name == "20pt" || $name == "29pt" || $name == "40pt" || $name == "60pt" || $name == "76pt" || $name == "83.5pt" ]]; then
        output="icons/ios/Icon-${name}@2x.png"
    fi
    echo "Generating $output ($dimensions)"
    convert "$SOURCE_ICON" -resize "$dimensions" "$output"
done

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