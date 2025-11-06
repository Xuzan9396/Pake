#!/bin/bash
set -e

# Build from config script
# Usage: ./scripts/build-from-config.sh <config-name>

if [ -z "$1" ]; then
  echo "Usage: $0 <config-name>"
  echo "Example: $0 vinted"
  echo ""
  echo "Available configs:"
  ls build-configs/*.json | xargs -n 1 basename | sed 's/.json$//'
  exit 1
fi

CONFIG_NAME="$1"
CONFIG_FILE="build-configs/${CONFIG_NAME}.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "📦 Building from config: $CONFIG_NAME"
echo ""

# Read config values
NAME=$(jq -r '.name' "$CONFIG_FILE")
URL=$(jq -r '.url' "$CONFIG_FILE")
ICON=$(jq -r '.icon' "$CONFIG_FILE")
WIDTH=$(jq -r '.width' "$CONFIG_FILE")
HEIGHT=$(jq -r '.height' "$CONFIG_FILE")

echo "Configuration:"
echo "  Name: $NAME"
echo "  URL: $URL"
echo "  Icon: $ICON"
echo "  Size: ${WIDTH}x${HEIGHT}"
echo ""

# Check if icon exists
if [ ! -f "$ICON" ]; then
  echo "Error: Icon file not found: $ICON"
  exit 1
fi

# Build CLI
echo "🔨 Building CLI..."
pnpm run cli:build

# Determine platform and targets
PLATFORM=$(uname -s)
case "$PLATFORM" in
  Darwin)
    PLATFORM_KEY="macos"
    ;;
  Linux)
    PLATFORM_KEY="linux"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PLATFORM_KEY="windows"
    ;;
  *)
    echo "Error: Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

# Check if platform is enabled
ENABLED=$(jq -r ".platforms.${PLATFORM_KEY}.enabled" "$CONFIG_FILE")
if [ "$ENABLED" != "true" ]; then
  echo "Error: $PLATFORM_KEY builds are disabled in config"
  exit 1
fi

# Get targets
TARGETS=$(jq -r ".platforms.${PLATFORM_KEY}.targets[]" "$CONFIG_FILE" | head -n 1)

echo "🚀 Building for $PLATFORM_KEY (target: $TARGETS)..."
echo ""

# Build app
if [ "$PLATFORM_KEY" == "macos" ]; then
  PAKE_CREATE_APP=1 node dist/cli.js "$URL" \
    --name "$NAME" \
    --icon "$ICON" \
    --width "$WIDTH" \
    --height "$HEIGHT" \
    --targets "$TARGETS"
else
  node dist/cli.js "$URL" \
    --name "$NAME" \
    --icon "$ICON" \
    --width "$WIDTH" \
    --height "$HEIGHT" \
    --targets "$TARGETS"
fi

echo ""
echo "✅ Build completed!"
echo ""

# Show output location
case "$PLATFORM_KEY" in
  macos)
    echo "📦 Output: $(pwd)/${NAME}.app"
    ;;
  windows)
    echo "📦 Output: $(pwd)/${NAME}.msi"
    ;;
  linux)
    echo "📦 Output: $(pwd)/${NAME}.deb or ${NAME}.AppImage"
    ;;
esac
