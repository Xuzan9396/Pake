#!/bin/bash
set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}📦 Pake Local Build Script${NC}"
echo ""

# 检查参数
CONFIG_FILE=$1
if [ -z "$CONFIG_FILE" ]; then
  echo -e "${RED}❌ Error: Config file not specified${NC}"
  echo ""
  echo "Usage: $0 <config-file>"
  echo "Example: $0 kpi_drojian.json"
  echo ""
  echo "Available configs:"
  ls "$PROJECT_DIR/build-configs/"*.json 2>/dev/null | xargs -n 1 basename | sed 's/^/  - /'
  exit 1
fi

# 移除 .json 后缀（如果有）
CONFIG_NAME="${CONFIG_FILE%.json}"

# 完整配置文件路径
CONFIG_PATH="$PROJECT_DIR/build-configs/${CONFIG_NAME}.json"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_PATH" ]; then
  echo -e "${RED}❌ Config file not found: $CONFIG_PATH${NC}"
  echo ""
  echo "Available configs:"
  ls "$PROJECT_DIR/build-configs/"*.json 2>/dev/null | xargs -n 1 basename
  exit 1
fi

echo -e "${GREEN}✓ Config found: ${CONFIG_NAME}.json${NC}"
echo ""

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
  echo -e "${RED}❌ jq is required but not installed${NC}"
  echo "Install with: brew install jq"
  exit 1
fi

# 读取配置
echo -e "${BLUE}📋 Reading configuration...${NC}"
NAME=$(jq -r '.name' "$CONFIG_PATH")
URL=$(jq -r '.url' "$CONFIG_PATH")
ICON=$(jq -r '.icon' "$CONFIG_PATH")
WIDTH=$(jq -r '.width' "$CONFIG_PATH")
HEIGHT=$(jq -r '.height' "$CONFIG_PATH")

echo "  Name:   $NAME"
echo "  URL:    $URL"
echo "  Icon:   $ICON"
echo "  Size:   ${WIDTH}x${HEIGHT}"
echo ""

# 检查图标文件
ICON_PATH="$PROJECT_DIR/$ICON"
ICON_FOUND=false

# 尝试不同的扩展名
for ext in "" ".png" ".jpg" ".jpeg" ".icns" ".ico"; do
  if [ -f "${ICON_PATH}${ext}" ]; then
    ICON_FOUND=true
    ACTUAL_ICON="${ICON_PATH}${ext}"
    echo -e "${GREEN}✓ Icon found: ${ICON}${ext}${NC}"
    break
  fi
done

if [ "$ICON_FOUND" = false ]; then
  echo -e "${YELLOW}⚠️  Warning: Icon not found at $ICON${NC}"
  echo "  Searched for: $ICON, ${ICON}.png, ${ICON}.jpg, ${ICON}.jpeg"
  echo "  Available icons in imgs/:"
  ls -1 "$PROJECT_DIR/imgs/" 2>/dev/null | head -5 || echo "  (directory not found)"
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo ""

# 检查依赖
cd "$PROJECT_DIR"
echo -e "${BLUE}📦 Checking dependencies...${NC}"
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  pnpm install
else
  echo -e "${GREEN}✓ Dependencies already installed${NC}"
fi
echo ""

# 构建 CLI
echo -e "${BLUE}🔨 Building CLI...${NC}"
pnpm run cli:build
echo ""

# 检测平台
PLATFORM=$(uname -s)
case "$PLATFORM" in
  Darwin)
    PLATFORM_NAME="macOS"
    TARGET="universal"
    BUILD_ENV="PAKE_CREATE_APP=1"
    OUTPUT_TYPE=".app"
    ;;
  Linux)
    PLATFORM_NAME="Linux"
    TARGET="deb"
    BUILD_ENV=""
    OUTPUT_TYPE=".deb"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PLATFORM_NAME="Windows"
    TARGET="x64"
    BUILD_ENV=""
    OUTPUT_TYPE=".msi"
    ;;
  *)
    echo -e "${RED}❌ Unsupported platform: $PLATFORM${NC}"
    exit 1
    ;;
esac

echo -e "${BLUE}🚀 Building for $PLATFORM_NAME (target: $TARGET)...${NC}"
echo ""

# 构建应用
if [ "$PLATFORM" = "Darwin" ]; then
  PAKE_CREATE_APP=1 node dist/cli.js "$URL" \
    --name "$NAME" \
    --icon "$ICON" \
    --width "$WIDTH" \
    --height "$HEIGHT" \
    --targets "$TARGET"
else
  node dist/cli.js "$URL" \
    --name "$NAME" \
    --icon "$ICON" \
    --width "$WIDTH" \
    --height "$HEIGHT" \
    --targets "$TARGET"
fi

# 检查构建结果
echo ""
echo -e "${BLUE}📁 Searching for build output...${NC}"

case "$PLATFORM" in
  Darwin)
    # 查找 .app 文件
    APP_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.app" -type d 2>/dev/null)
    if [ -n "$APP_FILES" ]; then
      echo -e "${GREEN}✅ Build completed!${NC}"
      echo ""
      echo "Generated files:"
      echo "$APP_FILES" | while read -r app; do
        SIZE=$(du -sh "$app" | cut -f1)
        echo "  📦 $(basename "$app") ($SIZE)"
      done
      echo ""
      echo -e "${GREEN}To run: open \"$(echo "$APP_FILES" | head -n 1)\"${NC}"
    else
      echo -e "${YELLOW}⚠️  No .app file found in project root${NC}"
      echo "Searching subdirectories..."
      find "$PROJECT_DIR" -name "*.app" -type d 2>/dev/null || echo "No .app files found"
    fi
    ;;
  Linux)
    # 查找 .deb 或 .AppImage 文件
    DEB_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.deb" -type f 2>/dev/null)
    APPIMAGE_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.AppImage" -type f 2>/dev/null)

    if [ -n "$DEB_FILES" ] || [ -n "$APPIMAGE_FILES" ]; then
      echo -e "${GREEN}✅ Build completed!${NC}"
      echo ""
      echo "Generated files:"
      [ -n "$DEB_FILES" ] && echo "$DEB_FILES" | while read -r file; do
        SIZE=$(du -sh "$file" | cut -f1)
        echo "  📦 $(basename "$file") ($SIZE)"
      done
      [ -n "$APPIMAGE_FILES" ] && echo "$APPIMAGE_FILES" | while read -r file; do
        SIZE=$(du -sh "$file" | cut -f1)
        echo "  📦 $(basename "$file") ($SIZE)"
      done
    else
      echo -e "${YELLOW}⚠️  No output files found${NC}"
    fi
    ;;
  *)
    # 查找 .msi 文件
    MSI_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.msi" -type f 2>/dev/null)
    if [ -n "$MSI_FILES" ]; then
      echo -e "${GREEN}✅ Build completed!${NC}"
      echo ""
      echo "Generated files:"
      echo "$MSI_FILES" | while read -r file; do
        SIZE=$(du -sh "$file" | cut -f1)
        echo "  📦 $(basename "$file") ($SIZE)"
      done
    else
      echo -e "${YELLOW}⚠️  No .msi file found${NC}"
    fi
    ;;
esac

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Build process completed for: $CONFIG_NAME${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
