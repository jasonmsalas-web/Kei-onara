#!/usr/bin/env python3
import re

with open('Kei-onara!.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Fix the CarPlay configuration - need to specify the delegate class
content = content.replace(
    'INFOPLIST_KEY_UISceneConfiguration_CarPlayApplicationSessionRoleApplication = "CarPlay";',
    'INFOPLIST_KEY_UISceneConfiguration_CarPlayApplicationSessionRoleApplication_delegateClassName = "$(PRODUCT_MODULE_NAME).CarPlaySceneDelegate";'
)

with open('Kei-onara!.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Fixed CarPlay scene delegate configuration")
