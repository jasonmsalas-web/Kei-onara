#!/bin/bash

# Version increment script for Kei-onara! app
# This script increments the MARKETING_VERSION by 0.001

PROJECT_FILE="Kei-onara!.xcodeproj/project.pbxproj"

# Function to increment version
increment_version() {
    local version=$1
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    local patch=$(echo $version | cut -d. -f3)
    
    # Convert patch to integer, increment by 1, then convert back to string
    local new_patch=$((10#$patch + 1))
    
    # Format with leading zeros if needed
    printf "%s.%s.%03d" $major $minor $new_patch
}

# Get current version from project file
current_version=$(grep "MARKETING_VERSION = " "$PROJECT_FILE" | head -1 | sed 's/.*MARKETING_VERSION = //' | sed 's/;//')

echo "Current version: $current_version"

# Increment version
new_version=$(increment_version $current_version)

echo "New version: $new_version"

# Update the project file
sed -i '' "s/MARKETING_VERSION = $current_version;/MARKETING_VERSION = $new_version;/g" "$PROJECT_FILE"

echo "Version updated to $new_version in $PROJECT_FILE"

# Also increment CURRENT_PROJECT_VERSION
current_build=$(grep "CURRENT_PROJECT_VERSION = " "$PROJECT_FILE" | head -1 | sed 's/.*CURRENT_PROJECT_VERSION = //' | sed 's/;//')
new_build=$((current_build + 1))

echo "Build number: $current_build -> $new_build"

sed -i '' "s/CURRENT_PROJECT_VERSION = $current_build;/CURRENT_PROJECT_VERSION = $new_build;/g" "$PROJECT_FILE"

echo "Build number updated to $new_build in $PROJECT_FILE" 