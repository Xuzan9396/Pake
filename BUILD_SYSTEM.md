# Pake Build System

This project uses a **configuration-driven build system** to package multiple web applications into desktop apps.

## Quick Start

### 1. Create Your Configuration

Create a JSON file in `build-configs/` directory:

```bash
# Create new config
cat > build-configs/myapp.json << 'EOF'
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
EOF
```

### 2. Build Locally

```bash
# Build single config
./scripts/build-from-config.sh myapp

# Build all configs
./scripts/build-all-configs.sh
```

### 3. Build via GitHub Actions

#### Manual Build (Single Config)

1. Go to **Actions** → **Build from Config**
2. Click **Run workflow**
3. Enter config name (e.g., `vinted`)
4. Click **Run workflow**

#### Automatic Build (All Configs)

1. Create and push a tag:

   ```bash
   git tag v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. GitHub Actions will automatically:
   - Build all enabled configs
   - Create a release
   - Upload all build artifacts

## Configuration File Format

See [`build-configs/README.md`](build-configs/README.md) for detailed configuration documentation.

### Minimal Example

```json
{
  "name": "app-name",
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

## Project Structure

```
.
├── build-configs/          # Build configuration files
│   ├── vinted.json        # Your vinted app config
│   ├── example.json       # Example config
│   └── README.md          # Config documentation
├── scripts/                # Build scripts
│   ├── build-from-config.sh    # Build single config
│   └── build-all-configs.sh    # Build all configs
├── .github/workflows/
│   ├── build-from-config.yaml  # New config-driven workflow
│   └── my_tag.yaml             # Old workflow (can be removed)
└── icons/                 # Icon files
    └── *.png/ico/icns
```

## Workflow Comparison

### Old Workflow (`my_tag.yaml`)

- ❌ Hardcoded parameters in YAML
- ❌ Only builds one app
- ❌ Difficult to maintain multiple apps

### New Workflow (`build-from-config.yaml`)

- ✅ Configuration-driven
- ✅ Supports multiple apps
- ✅ Easy to add new apps (just create a JSON file)
- ✅ Manual or automatic triggers
- ✅ Conditional platform builds

## Build Matrix

The workflow automatically creates a build matrix based on your configs:

```
For each config file:
  - macOS Universal (if enabled)
  - Windows x64 (if enabled)
  - Windows ARM64 (if enabled)
  - Linux deb (if enabled)
  - Linux AppImage (if enabled)
```

## Examples

### Example 1: Single App for macOS Only

```json
{
  "name": "mac-only-app",
  "url": "https://example.com/",
  "icon": "./icon.png",
  "width": 1200,
  "height": 800,
  "platforms": {
    "macos": {
      "enabled": true,
      "targets": ["universal"]
    },
    "windows": {
      "enabled": false,
      "targets": []
    },
    "linux": {
      "enabled": false,
      "targets": []
    }
  }
}
```

### Example 2: Cross-Platform App

```json
{
  "name": "cross-platform",
  "url": "https://example.com/",
  "icon": "./icon.png",
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
  }
}
```

### Example 3: Multiple Apps

Create multiple config files:

```bash
build-configs/
├── app1.json    # First app
├── app2.json    # Second app
└── app3.json    # Third app
```

Push a tag to build all three at once:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

## Migration from Old Workflow

### Step 1: Create Config for Existing App

```bash
# Your existing my_tag.yaml has these parameters:
# - URL: http://45.77.62.32:8989/
# - Name: vinted
# - Icon: ./111.jpg
# - Size: 1920x1080

# Already created: build-configs/vinted.json
```

### Step 2: Test Locally

```bash
./scripts/build-from-config.sh vinted
```

### Step 3: Remove Old Workflow (Optional)

```bash
git rm .github/workflows/my_tag.yaml
```

## Tips

1. **Icon Paths**: Use relative paths from project root
2. **Platform Selection**: Only enable platforms you need to save build time
3. **Testing**: Always test locally before pushing tags
4. **Config Naming**: Use descriptive names (e.g., `myapp` not `config1`)
5. **Version Control**: Commit all config files to git

## Troubleshooting

### Config file not found

```bash
# Check if config exists
ls build-configs/

# Check file name (no .json in command)
./scripts/build-from-config.sh myapp  # ✅ Correct
./scripts/build-from-config.sh myapp.json  # ❌ Wrong
```

### Icon not found

```bash
# Check icon path in config
jq -r '.icon' build-configs/myapp.json

# Verify icon exists
ls -la ./icons/myapp.png
```

### Platform disabled

Check config:

```bash
jq '.platforms' build-configs/myapp.json
```

Enable platform:

```json
{
  "platforms": {
    "macos": {
      "enabled": true, // <- Change to true
      "targets": ["universal"]
    }
  }
}
```

## Advanced Usage

### Custom Build Options

Add optional settings to config:

```json
{
  "name": "advanced-app",
  "url": "https://example.com/",
  "icon": "./icon.png",
  "width": 1920,
  "height": 1080,
  "platforms": { ... },
  "options": {
    "fullscreen": false,
    "resizable": true,
    "transparent": false,
    "alwaysOnTop": false,
    "hideTitleBar": false,
    "debug": false,
    "inject": ["./custom.css", "./custom.js"]
  }
}
```

### Conditional Builds

Build only specific configs:

```bash
# GitHub Actions: Manual trigger with config name
# or
# Locally: Build specific config
./scripts/build-from-config.sh config1
```

## Summary

| Feature            | Old Workflow      | New Workflow |
| ------------------ | ----------------- | ------------ |
| Config Method      | Hardcoded in YAML | JSON files   |
| Multiple Apps      | No                | Yes          |
| Easy to Maintain   | No                | Yes          |
| Manual Build       | No                | Yes          |
| Auto Build on Tag  | Yes               | Yes          |
| Platform Selection | All               | Per-config   |
| Icon Management    | Single            | Per-app      |

**Recommendation**: Use the new config-driven workflow for better flexibility and maintainability.
