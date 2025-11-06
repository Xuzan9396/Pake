# Build Configurations

This directory contains build configuration files for packaging different applications with Pake.

## Configuration File Format

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
