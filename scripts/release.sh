#!/bin/bash

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Please provide a version number (e.g. ./scripts/release.sh 1.0.0)"
    exit 1
fi

VERSION=$1

# Update version in package.json
pnpm version $VERSION

# Update version in tauri.conf.json
sed -i '' "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" src-tauri/tauri.conf.json

# Create git tag
git add package.json src-tauri/tauri.conf.json
git commit -m "Release v$VERSION"
git tag -a "v$VERSION" -m "Release v$VERSION"

echo "Release v$VERSION prepared!"
echo "To trigger the release build, push the changes and tag:"
echo "git push && git push --tags"