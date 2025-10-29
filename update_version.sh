#!/bin/bash

# Simple version update script for Kei-onara! app
# Usage: ./update_version.sh [increment|show]

PROJECT_FILE="Kei-onara!.xcodeproj/project.pbxproj"

show_version() {
    echo "=== Kei-onara! Version Information ==="
    current_version=$(grep "MARKETING_VERSION = " "$PROJECT_FILE" | head -1 | sed 's/.*MARKETING_VERSION = //' | sed 's/;//')
    current_build=$(grep "CURRENT_PROJECT_VERSION = " "$PROJECT_FILE" | head -1 | sed 's/.*CURRENT_PROJECT_VERSION = //' | sed 's/;//')
    echo "Marketing Version: $current_version"
    echo "Build Number: $current_build"
    echo "Full Version: $current_version ($current_build)"
}

case "$1" in
    "increment")
        echo "Incrementing version..."
        ./increment_version.sh
        echo ""
        show_version
        ;;
    "show"|"")
        show_version
        ;;
    *)
        echo "Usage: $0 [increment|show]"
        echo "  increment - Increment version by 0.001"
        echo "  show      - Show current version (default)"
        ;;
esac 