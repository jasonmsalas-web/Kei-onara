#!/bin/bash

# Cursor Auto Version Increment Script
# This script is called automatically by Cursor when changes are accepted
# It increments the version by 0.001 and commits the changes

echo "🚀 Cursor Auto Version Increment Started"

# Run the auto increment script
./auto_increment_version.sh

# Add the updated project file to git
git add "Kei-onara!.xcodeproj/project.pbxproj"

echo "✅ Version incremented and staged for commit"
echo "📝 Ready for commit with new version" 