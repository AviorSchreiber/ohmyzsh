#!/usr/bin/env bash

set -e

# Get the absolute path to the directory where this script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ASSETS_GITCONFIG="$SCRIPT_DIR/assets/.gitconfig"
TARGET_GITCONFIG="$HOME/.gitconfig"

# 1. Check if the asset file exists
if [ ! -f "$ASSETS_GITCONFIG" ]; then
    echo "❌ Error: Could not find .gitconfig at $ASSETS_GITCONFIG"
    exit 1
fi

# 2. Back up existing ~/.gitconfig if it exists and is not a symlink
if [ -f "$TARGET_GITCONFIG" ]; then
    echo "📦 Backing up existing ~/.gitconfig to ~/.gitconfig.bak..."
    cp "$TARGET_GITCONFIG" "$TARGET_GITCONFIG.bak"
fi

# 3. Copy the file to ~/.gitconfig
cp "$ASSETS_GITCONFIG" "$TARGET_GITCONFIG"
echo "✅ Copied $ASSETS_GITCONFIG -> $TARGET_GITCONFIG"

echo "🎉 Done!"