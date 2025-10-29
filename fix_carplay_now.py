#!/usr/bin/env python3
import re

# Read project file
with open('Kei-onara!.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Find where to insert CarPlay scene configuration
# Look for existing scene configuration or create new one after SupportsMultipleScenes

# Add CarPlay configuration after UIApplicationSupportsMultipleScenes
carplay_config = '''				INFOPLIST_KEY_UISceneConfiguration_ApplicationSessionRole = "UIWindowSceneSessionRoleApplication";
				INFOPLIST_KEY_UISceneConfiguration_CarPlayApplicationSessionRoleApplication = "CarPlay";
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;'''

# Check if it already exists
if 'CarPlayApplicationSessionRole' not in content:
    # Add after UIApplicationSupportsMultipleScenes
    content = re.sub(
        r'(INFOPLIST_KEY_UIApplicationSupportsMultipleScenes = YES;)',
        r'\1\n				INFOPLIST_KEY_UISceneConfiguration_ApplicationSessionRole = "UIWindowSceneSessionRoleApplication";\n				INFOPLIST_KEY_UISceneConfiguration_CarPlayApplicationSessionRoleApplication = "CarPlay";',
        content
    )
    
    # Write back
    with open('Kei-onara!.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)
    
    print("✅ Added CarPlay scene configuration")
else:
    print("✅ CarPlay configuration already exists")

