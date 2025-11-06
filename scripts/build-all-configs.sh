#!/bin/bash
set -e

# Build all configs script
# Usage: ./scripts/build-all-configs.sh

echo "📦 Building all configurations..."
echo ""

# Get all config files
CONFIG_FILES=(build-configs/*.json)

if [ ${#CONFIG_FILES[@]} -eq 0 ]; then
  echo "Error: No config files found in build-configs/"
  exit 1
fi

TOTAL=${#CONFIG_FILES[@]}
CURRENT=0
FAILED=()

for config_file in "${CONFIG_FILES[@]}"; do
  CURRENT=$((CURRENT + 1))
  CONFIG_NAME=$(basename "$config_file" .json)

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 Building [$CURRENT/$TOTAL]: $CONFIG_NAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if ./scripts/build-from-config.sh "$CONFIG_NAME"; then
    echo ""
    echo "✅ $CONFIG_NAME: Success"
  else
    echo ""
    echo "❌ $CONFIG_NAME: Failed"
    FAILED+=("$CONFIG_NAME")
  fi

  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Build Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total: $TOTAL"
echo "Success: $((TOTAL - ${#FAILED[@]}))"
echo "Failed: ${#FAILED[@]}"

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "❌ Failed configs:"
  for failed in "${FAILED[@]}"; do
    echo "  - $failed"
  done
  exit 1
else
  echo ""
  echo "✅ All builds completed successfully!"
fi
