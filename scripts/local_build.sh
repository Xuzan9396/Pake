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
ARCH=$2           # 可选架构参数
AUTO_DMG=$3       # 可选：自动打包 DMG（dmg/msi）

if [ -z "$CONFIG_FILE" ]; then
  echo -e "${RED}❌ Error: Config file not specified${NC}"
  echo ""
  echo "Usage: $0 <config-file> [arch] [format]"
  echo ""
  echo "Examples:"
  echo "  $0 kpi_drojian.json                    # Build .app only"
  echo "  $0 kpi_drojian.json apple              # Build ARM64 .app"
  echo "  $0 kpi_drojian.json apple dmg          # Build ARM64 and package as DMG"
  echo "  $0 kpi_drojian.json universal dmg      # Build Universal and package as DMG"
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

# 读取 options (所有参数)
TITLE=$(jq -r '.options.title // ""' "$CONFIG_PATH")
RESIZABLE=$(jq -r '.options.resizable // true' "$CONFIG_PATH")
FULLSCREEN=$(jq -r '.options.fullscreen // false' "$CONFIG_PATH")
MAXIMIZE=$(jq -r '.options.maximize // false' "$CONFIG_PATH")
HIDE_TITLE_BAR=$(jq -r '.options.hideTitleBar // false' "$CONFIG_PATH")
ALWAYS_ON_TOP=$(jq -r '.options.alwaysOnTop // false' "$CONFIG_PATH")
APP_VERSION=$(jq -r '.options.appVersion // "1.0.0"' "$CONFIG_PATH")
DARK_MODE=$(jq -r '.options.darkMode // false' "$CONFIG_PATH")
DISABLED_WEB_SHORTCUTS=$(jq -r '.options.disabledWebShortcuts // false' "$CONFIG_PATH")
ACTIVATION_SHORTCUT=$(jq -r '.options.activationShortcut // ""' "$CONFIG_PATH")
USER_AGENT=$(jq -r '.options.userAgent // ""' "$CONFIG_PATH")
SHOW_SYSTEM_TRAY=$(jq -r '.options.showSystemTray // false' "$CONFIG_PATH")
SYSTEM_TRAY_ICON=$(jq -r '.options.systemTrayIcon // ""' "$CONFIG_PATH")
USE_LOCAL_FILE=$(jq -r '.options.useLocalFile // false' "$CONFIG_PATH")
MULTI_ARCH=$(jq -r '.options.multiArch // false' "$CONFIG_PATH")
DEBUG=$(jq -r '.options.debug // false' "$CONFIG_PATH")
INJECT=$(jq -r '.options.inject // [] | join(",")' "$CONFIG_PATH")
PROXY_URL=$(jq -r '.options.proxyUrl // ""' "$CONFIG_PATH")
INSTALLER_LANGUAGE=$(jq -r '.options.installerLanguage // "en-US"' "$CONFIG_PATH")
HIDE_ON_CLOSE=$(jq -r '.options.hideOnClose // false' "$CONFIG_PATH")
INCOGNITO=$(jq -r '.options.incognito // false' "$CONFIG_PATH")
WASM=$(jq -r '.options.wasm // false' "$CONFIG_PATH")
ENABLE_DRAG_DROP=$(jq -r '.options.enableDragDrop // false' "$CONFIG_PATH")
KEEP_BINARY=$(jq -r '.options.keepBinary // false' "$CONFIG_PATH")
MULTI_INSTANCE=$(jq -r '.options.multiInstance // false' "$CONFIG_PATH")
START_TO_TRAY=$(jq -r '.options.startToTray // false' "$CONFIG_PATH")

echo "  Name:     $NAME"
echo "  URL:      $URL"
echo "  Icon:     $ICON"
echo "  Size:     ${WIDTH}x${HEIGHT}"
[ "$TITLE" != "" ] && echo "  Title:    $TITLE"
[ "$DEBUG" = "true" ] && echo "  Debug:    ${YELLOW}Enabled${NC}"
[ "$PROXY_URL" != "" ] && echo "  Proxy:    $PROXY_URL"
[ "$USER_AGENT" != "" ] && echo "  UA:       ${USER_AGENT:0:50}..."
[ "$HIDE_TITLE_BAR" = "true" ] && echo "  TitleBar: ${YELLOW}Hidden${NC}"
[ "$SHOW_SYSTEM_TRAY" = "true" ] && echo "  Tray:     ${YELLOW}Enabled${NC}"
[ "$INJECT" != "" ] && echo "  Inject:   $INJECT"
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
    # 如果用户指定了架构，使用指定的；否则使用配置文件中的第一个
    if [ -n "$ARCH" ]; then
      TARGET="$ARCH"
    else
      # 从配置文件读取第一个 macOS target
      TARGET=$(jq -r '.platforms.macos.targets[0]' "$CONFIG_PATH")
      if [ "$TARGET" = "null" ] || [ -z "$TARGET" ]; then
        TARGET="universal"
      fi
    fi
    BUILD_ENV="PAKE_CREATE_APP=1"
    OUTPUT_TYPE=".app"
    ;;
  Linux)
    PLATFORM_NAME="Linux"
    TARGET="${ARCH:-deb}"
    BUILD_ENV=""
    OUTPUT_TYPE=".deb"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PLATFORM_NAME="Windows"
    TARGET="${ARCH:-x64}"
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

# 构建 CLI 参数数组
CLI_ARGS=(
  "$URL"
  --name "$NAME"
  --icon "$ICON"
  --width "$WIDTH"
  --height "$HEIGHT"
  --targets "$TARGET"
)

# 添加所有可选参数
[ "$TITLE" != "" ] && CLI_ARGS+=(--title "$TITLE")
[ "$RESIZABLE" = "false" ] && CLI_ARGS+=(--no-resizable)
[ "$FULLSCREEN" = "true" ] && CLI_ARGS+=(--fullscreen)
[ "$MAXIMIZE" = "true" ] && CLI_ARGS+=(--maximize)
[ "$HIDE_TITLE_BAR" = "true" ] && CLI_ARGS+=(--hide-title-bar)
[ "$ALWAYS_ON_TOP" = "true" ] && CLI_ARGS+=(--always-on-top)
[ "$APP_VERSION" != "1.0.0" ] && CLI_ARGS+=(--app-version "$APP_VERSION")
[ "$DARK_MODE" = "true" ] && CLI_ARGS+=(--dark-mode)
[ "$DISABLED_WEB_SHORTCUTS" = "true" ] && CLI_ARGS+=(--disabled-web-shortcuts)
[ "$ACTIVATION_SHORTCUT" != "" ] && CLI_ARGS+=(--activation-shortcut "$ACTIVATION_SHORTCUT")
[ "$USER_AGENT" != "" ] && CLI_ARGS+=(--user-agent "$USER_AGENT")
[ "$SHOW_SYSTEM_TRAY" = "true" ] && CLI_ARGS+=(--show-system-tray)
[ "$SYSTEM_TRAY_ICON" != "" ] && CLI_ARGS+=(--system-tray-icon "$SYSTEM_TRAY_ICON")
[ "$USE_LOCAL_FILE" = "true" ] && CLI_ARGS+=(--use-local-file)
[ "$MULTI_ARCH" = "true" ] && CLI_ARGS+=(--multi-arch)
[ "$DEBUG" = "true" ] && CLI_ARGS+=(--debug)
[ "$INJECT" != "" ] && CLI_ARGS+=(--inject "$INJECT")
[ "$PROXY_URL" != "" ] && CLI_ARGS+=(--proxy-url "$PROXY_URL")
[ "$INSTALLER_LANGUAGE" != "en-US" ] && CLI_ARGS+=(--installer-language "$INSTALLER_LANGUAGE")
[ "$HIDE_ON_CLOSE" = "true" ] && CLI_ARGS+=(--hide-on-close)
[ "$INCOGNITO" = "true" ] && CLI_ARGS+=(--incognito)
[ "$WASM" = "true" ] && CLI_ARGS+=(--wasm)
[ "$ENABLE_DRAG_DROP" = "true" ] && CLI_ARGS+=(--enable-drag-drop)
[ "$KEEP_BINARY" = "true" ] && CLI_ARGS+=(--keep-binary)
[ "$MULTI_INSTANCE" = "true" ] && CLI_ARGS+=(--multi-instance)
[ "$START_TO_TRAY" = "true" ] && CLI_ARGS+=(--start-to-tray)

echo "Build command:"
echo "  node dist/cli.js ${CLI_ARGS[@]}"
echo ""

# 构建应用
if [ "$PLATFORM" = "Darwin" ]; then
  PAKE_CREATE_APP=1 node dist/cli.js "${CLI_ARGS[@]}"
else
  node dist/cli.js "${CLI_ARGS[@]}"
fi

# 检查构建结果
echo ""
echo -e "${BLUE}📁 Searching for build output...${NC}"

case "$PLATFORM" in
  Darwin)
    # 查找 .app 文件
    APP_FILES=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.app" -type d 2>/dev/null)
    if [ -n "$APP_FILES" ]; then
      echo -e "${GREEN}✅ App build completed!${NC}"
      echo ""

      APP_PATH=$(echo "$APP_FILES" | head -n 1)
      APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
      echo "Generated .app:"
      echo "  📦 $(basename "$APP_PATH") ($APP_SIZE)"
      echo ""

      # 检查是否自动打包 DMG
      CREATE_DMG=false
      if [ "$AUTO_DMG" = "dmg" ]; then
        CREATE_DMG=true
      else
        # 询问是否打包成 DMG
        echo -e "${YELLOW}Package as DMG? (y/N)${NC}"
        read -n 1 -r RESPONSE
        echo ""
        if [[ $RESPONSE =~ ^[Yy]$ ]]; then
          CREATE_DMG=true
        fi
      fi

      if [ "$CREATE_DMG" = true ]; then
        echo ""
        echo -e "${BLUE}📦 Creating DMG...${NC}"

        # 确定 DMG 名称
        if [ -n "$ARCH" ]; then
          DMG_NAME="${NAME}_${TARGET}.dmg"
        else
          DMG_NAME="${NAME}.dmg"
        fi

        # 创建临时目录
        mkdir -p dmg_temp
        cp -R "$APP_PATH" dmg_temp/

        # 创建 DMG
        hdiutil create -volname "$NAME" -srcfolder dmg_temp -ov -format UDZO "$DMG_NAME"

        # 清理临时目录
        rm -rf dmg_temp

        if [ -f "$DMG_NAME" ]; then
          DMG_SIZE=$(du -sh "$DMG_NAME" | cut -f1)
          echo ""
          echo -e "${GREEN}✅ DMG created!${NC}"
          echo "  📦 $DMG_NAME ($DMG_SIZE)"
          echo ""
          echo -e "${GREEN}To install: open \"$DMG_NAME\"${NC}"
        else
          echo -e "${RED}❌ DMG creation failed${NC}"
        fi
      else
        echo ""
        echo -e "${GREEN}To run: open \"$APP_PATH\"${NC}"
        echo -e "${BLUE}To create DMG manually:${NC}"
        echo "  hdiutil create -volname \"$NAME\" -srcfolder \"$APP_PATH\" -ov -format UDZO \"${NAME}.dmg\""
      fi
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
