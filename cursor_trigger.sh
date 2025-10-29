#!/bin/bash

# Simple trigger script for Cursor to increment version
# This script is called when changes are accepted in Cursor

echo "🎯 Cursor Trigger: Incrementing version by 0.001"

# Run the auto increment script
./auto_increment_version.sh

# Stage the changes
git add "Kei-onara!.xcodeproj/project.pbxproj"

echo "✅ Version incremented and staged for commit"
echo "📝 Changes ready for commit" 