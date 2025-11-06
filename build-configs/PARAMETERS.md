# 配置参数详解

本文档详细说明所有可用的配置参数。

## 基础参数

### name (必填)
- **类型**: `string`
- **说明**: 应用名称，用于生成可执行文件名
- **示例**: `"vinted"`, `"myapp"`

### url (必填)
- **类型**: `string`
- **说明**: 要打包的网址或本地文件路径
- **示例**:
  - `"https://www.example.com/"`
  - `"http://localhost:3000/"`
  - `"file:///path/to/local.html"` (需要配合 `useLocalFile: true`)

### icon (必填)
- **类型**: `string`
- **说明**: 应用图标路径（相对于项目根目录）
- **格式要求**:
  - macOS: 自动转换为 `.icns`
  - Windows: 自动转换为 `.ico`
  - Linux: 使用 `.png`（推荐 512x512）
- **示例**: `"./icons/app.png"`, `"./111.jpg"`

### width (必填)
- **类型**: `number`
- **说明**: 窗口宽度（像素）
- **默认值**: `1200`
- **示例**: `1920`, `1200`, `800`

### height (必填)
- **类型**: `number`
- **说明**: 窗口高度（像素）
- **默认值**: `780`
- **示例**: `1080`, `800`, `600`

## 平台配置

### platforms (必填)
配置各平台的构建选项。

```json
"platforms": {
  "macos": {
    "enabled": true,
    "targets": ["universal", "intel", "apple"]
  },
  "windows": {
    "enabled": true,
    "targets": ["x64", "arm64"]
  },
  "linux": {
    "enabled": false,
    "targets": ["deb", "appimage", "rpm"]
  }
}
```

#### macOS targets
- `"universal"` - Intel + Apple Silicon 通用版本（推荐）
- `"intel"` - 仅 Intel 芯片
- `"apple"` - 仅 Apple Silicon (M1/M2/M3)

#### Windows targets
- `"x64"` - 64位 Intel/AMD 处理器
- `"arm64"` - ARM64 处理器

#### Linux targets
- `"deb"` - Debian/Ubuntu 包
- `"appimage"` - AppImage 格式
- `"rpm"` - RedHat/Fedora 包

## 可选参数 (options)

### 窗口相关

#### title
- **类型**: `string`
- **说明**: 窗口标题（支持中文）
- **默认值**: 与 `name` 相同
- **示例**: `"我的应用"`, `"My App"`

#### resizable
- **类型**: `boolean`
- **说明**: 窗口是否可调整大小
- **默认值**: `true`

#### fullscreen
- **类型**: `boolean`
- **说明**: 启动时全屏
- **默认值**: `false`

#### maximize
- **类型**: `boolean`
- **说明**: 启动时最大化
- **默认值**: `false`

#### hideTitleBar
- **类型**: `boolean`
- **说明**: 隐藏标题栏（沉浸式界面）
- **默认值**: `false`
- **注意**: 仅 macOS 有效

#### alwaysOnTop
- **类型**: `boolean`
- **说明**: 窗口始终置顶
- **默认值**: `false`

### 外观相关

#### darkMode
- **类型**: `boolean`
- **说明**: 强制使用暗色模式
- **默认值**: `false`
- **注意**: 仅 macOS 有效

#### appVersion
- **类型**: `string`
- **说明**: 应用版本号
- **默认值**: `"1.0.0"`
- **格式**: 遵循语义化版本 `主版本.次版本.修订号`
- **示例**: `"1.2.3"`, `"2.0.0"`

### 功能相关

#### disabledWebShortcuts
- **类型**: `boolean`
- **说明**: 禁用网页快捷键
- **默认值**: `false`
- **用途**: 防止网页快捷键与系统快捷键冲突

#### activationShortcut
- **类型**: `string`
- **说明**: 唤醒应用的全局快捷键
- **默认值**: `""` (不启用)
- **格式**:
  - macOS: `"CmdOrCtrl+Shift+A"`
  - Windows: `"Ctrl+Shift+A"`
- **示例**: `"CmdOrCtrl+Shift+P"`

#### userAgent
- **类型**: `string`
- **说明**: 自定义 User-Agent
- **默认值**: `""` (使用系统默认)
- **用途**: 模拟特定浏览器或设备
- **示例**:
  ```
  "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15"
  ```

#### proxyUrl
- **类型**: `string`
- **说明**: API 代理地址
- **默认值**: `""` (不使用代理)
- **格式**: `"http://proxy.example.com:8080"`
- **用途**:
  - 绕过 CORS 限制
  - 使用代理服务器
- **示例**: `"http://localhost:8080"`

### 系统托盘

#### showSystemTray
- **类型**: `boolean`
- **说明**: 显示系统托盘图标
- **默认值**:
  - macOS: `false`
  - Windows/Linux: `true`

#### systemTrayIcon
- **类型**: `string`
- **说明**: 托盘图标路径
- **默认值**: `""` (使用应用图标)
- **格式**:
  - macOS: PNG 或 ICO (推荐 16x16 或 22x22)
  - Windows/Linux: 使用应用图标
- **示例**: `"./icons/tray.png"`

#### startToTray
- **类型**: `boolean`
- **说明**: 启动时最小化到托盘
- **默认值**: `false`
- **前提**: `showSystemTray` 必须为 `true`

#### hideOnClose
- **类型**: `boolean`
- **说明**: 关闭窗口时隐藏而不是退出
- **默认值**:
  - macOS: `true`
  - 其他: `false`

### 高级功能

#### inject
- **类型**: `string[]`
- **说明**: 注入自定义 CSS/JS 文件
- **默认值**: `[]`
- **用途**:
  - 修改页面样式
  - 添加自定义功能
  - 隐藏广告
- **示例**:
  ```json
  "inject": [
    "./custom.css",
    "./custom.js"
  ]
  ```

#### useLocalFile
- **类型**: `boolean`
- **说明**: 使用本地文件打包
- **默认值**: `false`
- **用途**: 打包本地 HTML 文件
- **配合**: `url` 设置为本地文件路径

#### incognito
- **类型**: `boolean`
- **说明**: 以隐私模式启动
- **默认值**: `false`
- **用途**:
  - 不保存 Cookie
  - 不保存浏览历史
  - 不保存缓存

#### wasm
- **类型**: `boolean`
- **说明**: 启用 WebAssembly 支持
- **默认值**: `false`
- **用途**: 支持 Flutter Web 等 WASM 应用

#### enableDragDrop
- **类型**: `boolean`
- **说明**: 启用拖放功能
- **默认值**: `false`
- **用途**: 支持文件拖放到应用

#### multiInstance
- **类型**: `boolean`
- **说明**: 允许多实例运行
- **默认值**: `false` (单实例)
- **用途**:
  - `false`: 只能运行一个实例
  - `true`: 可以同时运行多个实例

### 构建相关

#### multiArch
- **类型**: `boolean`
- **说明**: 构建 macOS 通用版本
- **默认值**: `false`
- **注意**: 仅 macOS，推荐在 platforms.macos.targets 中设置

#### debug
- **类型**: `boolean`
- **说明**: 调试模式构建
- **默认值**: `false`
- **用途**:
  - 输出详细日志
  - 不压缩代码
  - 保留调试符号

#### installerLanguage
- **类型**: `string`
- **说明**: 安装程序语言
- **默认值**: `"en-US"`
- **平台**: 仅 Windows
- **可选值**:
  - `"en-US"` - 英语
  - `"zh-CN"` - 简体中文
  - `"zh-TW"` - 繁体中文
  - `"ja-JP"` - 日语

#### keepBinary
- **类型**: `boolean`
- **说明**: 保留原始二进制文件
- **默认值**: `false`
- **用途**: 调试或手动分发

## 完整示例

### 最小配置

```json
{
  "name": "myapp",
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

### 完整配置（带系统托盘）

```json
{
  "name": "myapp",
  "url": "https://example.com/",
  "icon": "./icons/app.png",
  "width": 1920,
  "height": 1080,
  "platforms": {
    "macos": { "enabled": true, "targets": ["universal"] },
    "windows": { "enabled": true, "targets": ["x64", "arm64"] },
    "linux": { "enabled": false, "targets": [] }
  },
  "options": {
    "title": "我的应用",
    "resizable": true,
    "fullscreen": false,
    "showSystemTray": true,
    "systemTrayIcon": "./icons/tray.png",
    "hideOnClose": true,
    "activationShortcut": "CmdOrCtrl+Shift+A",
    "userAgent": "Mozilla/5.0 ...",
    "inject": ["./custom.css"]
  }
}
```

### 代理配置示例

```json
{
  "name": "proxy-app",
  "url": "https://api.example.com/",
  "icon": "./icon.png",
  "width": 1200,
  "height": 800,
  "platforms": {
    "macos": { "enabled": true, "targets": ["universal"] },
    "windows": { "enabled": true, "targets": ["x64"] },
    "linux": { "enabled": false, "targets": [] }
  },
  "options": {
    "proxyUrl": "http://localhost:8080",
    "userAgent": "Custom User Agent"
  }
}
```

### 隐私模式配置

```json
{
  "name": "private-browser",
  "url": "https://example.com/",
  "icon": "./icon.png",
  "width": 1200,
  "height": 800,
  "platforms": {
    "macos": { "enabled": true, "targets": ["universal"] },
    "windows": { "enabled": true, "targets": ["x64"] },
    "linux": { "enabled": false, "targets": [] }
  },
  "options": {
    "incognito": true,
    "disabledWebShortcuts": true,
    "multiInstance": true
  }
}
```

## 注意事项

1. **必填参数**: `name`, `url`, `icon`, `width`, `height`, `platforms`
2. **平台特定**:
   - `hideTitleBar`: 仅 macOS
   - `darkMode`: 仅 macOS
   - `installerLanguage`: 仅 Windows
3. **依赖关系**:
   - `startToTray` 需要 `showSystemTray: true`
   - `systemTrayIcon` 需要 `showSystemTray: true`
4. **路径格式**:
   - 相对路径从项目根目录开始
   - 使用 `/` 或 `./` 开头
   - 示例: `"./icons/app.png"`

## 参数优先级

1. 命令行参数 > 配置文件
2. options 中的参数会覆盖顶层参数
3. 平台特定设置优先于全局设置

## 常见问题

### Q: 如何设置代理？
```json
"options": {
  "proxyUrl": "http://proxy.example.com:8080"
}
```

### Q: 如何隐藏标题栏？
```json
"options": {
  "hideTitleBar": true
}
```
注意：仅 macOS 有效

### Q: 如何添加自定义样式？
```json
"options": {
  "inject": ["./custom.css", "./custom.js"]
}
```

### Q: 如何设置全局快捷键？
```json
"options": {
  "activationShortcut": "CmdOrCtrl+Shift+A"
}
```

### Q: 如何启用系统托盘？
```json
"options": {
  "showSystemTray": true,
  "hideOnClose": true
}
```
