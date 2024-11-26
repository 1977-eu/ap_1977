#!/bin/bash
cd "$(dirname "$0")"

# Create fonts directory if it doesn't exist
mkdir -p assets/fonts

# Download Noto Emoji font
curl -L "https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoEmoji-Regular.ttf" -o "assets/fonts/NotoEmoji-Regular.ttf"
