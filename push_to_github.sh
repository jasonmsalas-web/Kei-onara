#!/bin/bash

# Script to push Kei-onara! to GitHub
# This will prompt for GitHub credentials

set -e

echo "🚀 Pushing code to GitHub..."
echo "📦 Repository: https://github.com/jasonmsalas-web/Kei-onara"
echo ""
echo "You'll be prompted for your GitHub username and password."
echo ""
echo "For security, use a Personal Access Token instead of your password:"
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Generate a new token (classic)"
echo "3. Select scope: repo (full control of private repositories)"
echo "4. Copy the token and use it as your password"
echo ""
read -p "Press Enter to continue..."

git push -u origin main

echo ""
echo "✅ Successfully backed up to GitHub!"
echo "🔗 View your repository: https://github.com/jasonmsalas-web/Kei-onara"
