#!/bin/bash

# Source image
SRC="AppIcon.png"

# Check for sips (macOS image tool)
if ! command -v sips &> /dev/null; then
  echo "sips command not found. This script requires macOS."
  exit 1
fi

# Icon sizes and filenames
declare -a icons=(
  "20x20@1x 20"
  "20x20@2x 40"
  "20x20@3x 60"
  "29x29@1x 29"
  "29x29@2x 58"
  "29x29@3x 87"
  "40x40@1x 40"
  "40x40@2x 80"
  "40x40@3x 120"
  "60x60@2x 120"
  "60x60@3x 180"
  "76x76@1x 76"
  "76x76@2x 152"
  "83.5x83.5@2x 167"
  "1024x1024@1x 1024"
)

# Remove old icons (except the master)
find . -type f -name "icon_*.png" -delete

# Generate icons
for entry in "${icons[@]}"; do
  IFS=' ' read -r name size <<< "$entry"
  out="icon_${name}.png"
  sips -z $size $size "$SRC" --out "$out"
done

# Generate Contents.json
cat > Contents.json <<EOL
{
  "images": [
    { "idiom": "iphone", "size": "20x20", "scale": "2x", "filename": "icon_20x20@2x.png" },
    { "idiom": "iphone", "size": "20x20", "scale": "3x", "filename": "icon_20x20@3x.png" },
    { "idiom": "iphone", "size": "29x29", "scale": "2x", "filename": "icon_29x29@2x.png" },
    { "idiom": "iphone", "size": "29x29", "scale": "3x", "filename": "icon_29x29@3x.png" },
    { "idiom": "iphone", "size": "40x40", "scale": "2x", "filename": "icon_40x40@2x.png" },
    { "idiom": "iphone", "size": "40x40", "scale": "3x", "filename": "icon_40x40@3x.png" },
    { "idiom": "iphone", "size": "60x60", "scale": "2x", "filename": "icon_60x60@2x.png" },
    { "idiom": "iphone", "size": "60x60", "scale": "3x", "filename": "icon_60x60@3x.png" },
    { "idiom": "ipad", "size": "20x20", "scale": "1x", "filename": "icon_20x20@1x.png" },
    { "idiom": "ipad", "size": "20x20", "scale": "2x", "filename": "icon_20x20@2x.png" },
    { "idiom": "ipad", "size": "29x29", "scale": "1x", "filename": "icon_29x29@1x.png" },
    { "idiom": "ipad", "size": "29x29", "scale": "2x", "filename": "icon_29x29@2x.png" },
    { "idiom": "ipad", "size": "40x40", "scale": "1x", "filename": "icon_40x40@1x.png" },
    { "idiom": "ipad", "size": "40x40", "scale": "2x", "filename": "icon_40x40@2x.png" },
    { "idiom": "ipad", "size": "76x76", "scale": "1x", "filename": "icon_76x76@1x.png" },
    { "idiom": "ipad", "size": "76x76", "scale": "2x", "filename": "icon_76x76@2x.png" },
    { "idiom": "ipad", "size": "83.5x83.5", "scale": "2x", "filename": "icon_83.5x83.5@2x.png" },
    { "idiom": "ios-marketing", "size": "1024x1024", "scale": "1x", "filename": "icon_1024x1024@1x.png" }
  ],
  "info": { "version": 1, "author": "xcode" }
}
EOL

echo "✅ All icons generated and Contents.json updated!" 