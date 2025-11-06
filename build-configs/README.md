# Build Configurations

# 快速测试 kpi_drojian
cd /Users/admin/go/rust/Pake
./scripts/local_build.sh kpi_drojian.json

# 构建完成后运行
open kpi_drojian.app  # macOS
🚀 使用方法（推荐）

完整流程

# 1. 确认配置文件存在
cat build-configs/vinted.json

# 2. 修改代码
vim src-tauri/src/inject/event.js

# 3. 提交代码
git add .
git commit -m "fix: 修复导出功能"
git push origin main

# 4. 创建并推送 tag
git tag vinted-v0.0.2 -m "Release vinted v0.0.2"
git push origin vinted-v0.0.2
# 5. 查看构建
# 访问：https://github.com/Xuzan9396/Pake/actions

# 6. 下载安装包
# 访问：https://github.com/Xuzan9396/Pake/releases/tag/vinted-v0.0.2



# 打包 vinted
git tag vinted-v0.0.3 -m "Release vinted"
git push origin vinted-v0.0.3
# → 只会读取 build-configs/vinted.json

# 打包 example
git tag example-v1.0.0 -m "Release example"
git push origin example-v1.0.0
# → 只会读取 build-configs/example.json

# 打包其他应用
git tag myapp-v2.0.0 -m "Release myapp"
git push origin myapp-v2.0.0
# → 只会读取 build-configs/myapp.json

重新发布步骤

# 1. 删除失败的 tag
git tag -d kpi_drojian-v0.0.1
git push origin :refs/tags/kpi_drojian-v0.0.1

# 2. 手动删除 GitHub Release
# 访问：https://github.com/Xuzan9396/Pake/releases/tag/kpi_drojian-v0.0.1
# 点击 "Delete" 删除

# 3. 重新创建 tag
git tag kpi_drojian-v0.0.1 -m "Release kpi_drojian v0.0.1"

# 4. 推送 tag
git push origin kpi_drojian-v0.0.1

git tag kpi_drojian-v0.0.1 -m "Release kpi_drojian v0.0.1"
git push origin kpi_drojian-v0.0.1

Each JSON file represents one application to package. The file name becomes the config ID.

### Basic Structure

```json
{
  "name": "app-name",                    // Application name (required)
  "url": "https://example.com/",         // URL to package (required)
  "icon": "./path/to/icon.png",          // Icon path (required)
  "width": 1200,                         // Window width (required)
  "height": 800,                         // Window height (required)
  "platforms": { ... },                  // Platform configurations (required)
  "options": { ... },                    // Optional settings
  "description": "App description"       // Optional description
}
```

### Platform Configuration

```json
"platforms": {
  "macos": {
    "enabled": true,                     // Enable macOS builds
    "targets": ["universal"]             // Targets: "universal", "intel", "apple"
  },
  "windows": {
    "enabled": true,                     // Enable Windows builds
    "targets": ["x64", "arm64"]          // Targets: "x64", "arm64"
  },
  "linux": {
    "enabled": false,                    // Enable Linux builds
    "targets": ["deb", "appimage"]       // Targets: "deb", "appimage", "rpm"
  }
}
```

### Optional Settings

```json
"options": {
  "fullscreen": false,                   // Start in fullscreen
  "resizable": true,                     // Allow window resize
  "transparent": false,                  // Transparent window
  "alwaysOnTop": false,                  // Always on top
  "hideTitleBar": false,                 // Hide title bar (macOS)
  "multiArch": false,                    // Build universal binary (macOS)
  "debug": false,                        // Debug build
  "inject": ["./custom.css", "./custom.js"]  // Inject custom files
}
```

## Icon Requirements

- **macOS**: `.icns` file (auto-generated from source if needed)
- **Windows**: `.ico` file (auto-generated from source if needed)
- **Linux**: `.png` file (512x512 recommended)

Place icons in the project root or specify relative path in config.

## Usage

### 1. Create Configuration File

Create a new JSON file in this directory (e.g., `myapp.json`):

```json
{
  "name": "myapp",
  "url": "https://myapp.com/",
  "icon": "./icons/myapp.png",
  "width": 1920,
  "height": 1080,
  "platforms": {
    "macos": {
      "enabled": true,
      "targets": ["universal"]
    },
    "windows": {
      "enabled": true,
      "targets": ["x64", "arm64"]
    },
    "linux": {
      "enabled": false,
      "targets": []
    }
  }
}
```

### 2. Build Locally

```bash
# Build single config
./scripts/build-from-config.sh myapp

# Build all configs
./scripts/build-all-configs.sh
```

### 3. Build via GitHub Actions

**Manual Trigger:**

- Go to Actions → "Build from Config"
- Select config file from dropdown
- Click "Run workflow"

**Automatic on Tag:**

- Create and push a tag: `git tag v1.0.0 && git push origin v1.0.0`
- All enabled configs will be built automatically
- Release will be created with all build artifacts

## Examples

### Minimal Configuration

```json
{
  "name": "simple-app",
  "url": "https://example.com/",
  "icon": "./icon.png",
  "width": 1200,
  "height": 800,
  "platforms": {
    "macos": { "enabled": true, "targets": ["universal"] },
    "windows": { "enabled": true, "targets": ["x64"] },
    "linux": { "enabled": false, "targets": [] }
  }
}
```

### Full Configuration

```json
{
  "name": "advanced-app",
  "url": "https://example.com/",
  "icon": "./icons/app.png",
  "width": 1920,
  "height": 1080,
  "platforms": {
    "macos": {
      "enabled": true,
      "targets": ["universal"]
    },
    "windows": {
      "enabled": true,
      "targets": ["x64", "arm64"]
    },
    "linux": {
      "enabled": true,
      "targets": ["deb", "appimage"]
    }
  },
  "options": {
    "fullscreen": false,
    "resizable": true,
    "transparent": false,
    "alwaysOnTop": false,
    "hideTitleBar": false,
    "multiArch": false,
    "debug": false,
    "inject": ["./custom.css"]
  },
  "description": "Advanced app with custom styling"
}
```

## Config Validation

Before building, ensure:

- ✅ Icon file exists at specified path
- ✅ URL is valid and accessible
- ✅ Width/height are reasonable (min: 400, max: 4096)
- ✅ At least one platform is enabled
- ✅ Platform targets are valid

## Tips

1. **Icon Path**: Use relative paths from project root (e.g., `./icons/app.png`)
2. **Platform Targets**: Only enable targets you actually need to reduce build time
3. **Testing**: Test locally before pushing tags
4. **Multiple Apps**: Create separate config files for each app you want to package
