# Pake 打包步骤说明

## 环境准备

1. 确保已安装依赖：

```bash
pnpm i
```

2. 构建 CLI 工具：

```bash
pnpm run cli:build
```

## 打包小红书示例

### 基础稳定版（推荐）

仅打包当前系统架构（macOS ARM64）：

```bash
node dist/cli.js http://45.77.62.32:8989/ \
  --name vinted \
  --icon /Users/admin/go/rust/Pake/111.jpg \
  --width 1920 --height 1080 \
  --targets apple


  node dist/cli.js http://45.77.62.32:8989/ \
  --name vinted-debug \
  --icon /Users/admin/go/rust/Pake/111.jpg \
  --width 1920 --height 1080 \
  --targets apple \
  --debug


  node dist/cli.js http://127.0.0.1:8989/ \
  --name vinted-debug \
  --icon /Users/admin/go/rust/Pake/111.jpg \
  --width 1920 --height 1080 \
  --targets apple \
  --debug
```

**输出位置**：

- `.app` 文件：`src-tauri/target/aarch64-apple-darwin/release/bundle/macos/小红书.app`

### 常用参数组合

```bash
# 带系统托盘和沉浸式标题栏
node dist/cli.js https://www.xiaohongshu.com/ \
  --name 小红书 \
  --icon /Users/admin/go/rust/Pake/111.jpg \
  --targets apple \
  --width 1400 \
  --height 900 \
  --hide-title-bar \
  --show-system-tray

# 打包通用版（Intel + Apple Silicon）
node dist/cli.js https://www.xiaohongshu.com/ \
  --name 小红书 \
  --icon /Users/admin/go/rust/Pake/111.jpg \
  --targets universal \
  --width 1400 \
  --height 900
```

## 可用参数清单

### 窗口设置

- `--name` - 应用名称
- `--icon` - 自定义图标路径（支持 jpg/png/ico/icns）
- `--width` - 窗口宽度（默认 1200）
- `--height` - 窗口高度（默认 780）
- `--title` - 窗口标题文字
- `--hide-title-bar` - 隐藏标题栏（沉浸式，仅 macOS）
- `--fullscreen` - 全屏启动
- `--maximize` - 最大化启动
- `--always-on-top` - 窗口始终置顶

### 平台和架构

- `--targets apple` - macOS Apple Silicon（M1/M2/M3）
- `--targets intel` - macOS Intel
- `--targets universal` - macOS 通用版（同时支持两种架构）
- `--multi-arch` - 等同于 universal（旧参数）

### 系统托盘

- `--show-system-tray` - 显示系统托盘图标
- `--system-tray-icon` - 自定义托盘图标
- `--hide-on-close` - 关闭时隐藏而非退出（macOS 默认开启）
- `--start-to-tray` - 启动时直接最小化到托盘（需配合 --show-system-tray）

### 功能开关

- `--debug` - 开启开发者工具和调试模式
- `--incognito` - 隐私模式（不保存 cookies 和历史）
- `--wasm` - 启用 WebAssembly 支持
- `--enable-drag-drop` - 启用拖放功能
- `--multi-instance` - 允许多实例运行
- `--disabled-web-shortcuts` - 禁用网页快捷键

### 高级选项

- `--user-agent` - 自定义 User Agent
- `--activation-shortcut` - 全局激活快捷键（如 `CmdOrControl+Shift+P`）
- `--app-version` - 应用版本号（默认 1.0.0）
- `--dark-mode` - 强制深色模式（macOS）
- `--proxy-url` - 设置代理（如 `http://127.0.0.1:7890`）
- `--inject` - 注入自定义 CSS/JS 文件（如 `--inject ./style.css,./script.js`）
- `--use-local-file` - 打包本地 HTML 文件
- `--keep-binary` - 同时保留原始二进制文件
- `--installer-language` - Windows 安装程序语言（默认 en-US）

## 其他网站打包示例

```bash
# GitHub
node dist/cli.js https://github.com \
  --name GitHub \
  --width 1400 \
  --height 900 \
  --targets apple

# ChatGPT
node dist/cli.js https://chat.openai.com \
  --name ChatGPT \
  --width 1200 \
  --height 800 \
  --hide-title-bar \
  --targets apple

# 本地 HTML 文件
node dist/cli.js ./my-app/index.html \
  --name MyApp \
  --use-local-file \
  --targets apple
```

## 注意事项

1. **首次打包**：首次打包会下载依赖，可能需要较长时间
2. **DMG 失败**：如果 DMG 打包失败，直接使用生成的 .app 文件即可
3. **图标格式**：支持任意格式图标，Pake 会自动转换为对应平台格式
4. **多架构**：`--targets universal` 需要安装交叉编译工具链
5. **输出位置**：打包文件默认在 `src-tauri/target/[架构]/release/bundle/` 目录

## 快速命令

```bash
# 最简单的打包命令（会自动获取网站图标）
node dist/cli.js https://www.xiaohongshu.com/ --name 小红书 --targets apple

# 当前小红书稳定版
node dist/cli.js https://www.xiaohongshu.com/ --name 小红书 --icon /Users/admin/go/rust/Pake/111.jpg --targets apple
```

## 常见问题解决

### 下载/导出问题

**问题描述**：点击导出按钮后，数据直接在窗口显示而不是触发下载。

**原因**：Pake 需要识别链接为下载链接才会触发下载行为，否则会直接在应用内打开。

**解决方案**：

已在 `src-tauri/src/inject/event.js` 中添加以下路径检测规则：

```javascript
const DOWNLOAD_PATH_PATTERNS = [
  "/download/",
  "/files/",
  "/attachments/",
  "/assets/",
  "/releases/",
  "/dist/",
  "/cookies/export", // 导出 cookies
  "/cookies/download-template", // 下载模板
  "/export", // 通用导出路径
];
```

**如果还需要添加其他路径**：

1. 编辑 `src-tauri/src/inject/event.js` 文件的第 127-137 行
2. 在 `DOWNLOAD_PATH_PATTERNS` 数组中添加你的路径
3. 重新构建 CLI：`pnpm run cli:build`
4. 重新打包应用

**自定义注入方式**（适合无法修改源码的情况）：

```bash
# 创建自定义下载脚本
cat > /path/to/custom-download.js << 'EOF'
document.addEventListener('click', function(e) {
  const target = e.target.closest('a');
  if (!target || !target.href) return;

  // 添加你的导出路径检测
  if (target.href.includes('/your-export-path')) {
    e.preventDefault();
    const filename = 'export_' + new Date().getTime() + '.xlsx';
    window.__TAURI__.core.invoke('download_file', {
      params: { url: target.href, filename, language: navigator.language }
    });
  }
}, true);
EOF

# 使用 inject 参数打包
node dist/cli.js YOUR_URL \
  --name AppName \
  --targets apple \
  --inject /path/to/custom-download.js
```

### 当前项目导出位置

根据后端路由配置，以下路径会自动触发下载：

- `/cookies/download-template` - 下载模板
- `/cookies/export` - 导出数据
- 任何包含 `/export` 的路径

**已实现的拦截机制**：

1. **window.location 拦截** - 捕获直接导航到导出 URL
2. **fetch API 拦截** - 拦截现代 AJAX 请求，返回空响应防止数据显示
3. **XMLHttpRequest 拦截** - 拦截传统 AJAX 请求
4. **路径模式匹配** - 自动识别导出 URL 并触发 Tauri 下载

**测试方法**：

1. 打包调试版本查看详细日志：

```bash
PAKE_CREATE_APP=1 node dist/cli.js http://45.77.62.32:8989/ \
  --name vinted-debug \
  --icon /Users/admin/go/rust/Pake/111.jpg \
  --width 1920 --height 1080 \
  --targets apple \
  --debug
```

2. 打开应用后按 `Cmd+Shift+I` 打开开发者工具

3. 在 Console 面板查看拦截日志：
   - `Intercepted fetch to export URL:` - fetch 拦截
   - `Intercepted XHR to export URL:` - XHR 拦截
   - `Intercepted download URL:` - 导航拦截

4. 在 Network 面板查看导出请求和响应头

5. 检查 `~/Downloads` 目录是否有下载文件

**常见问题**：

- 如果日志显示"Intercepted"但文件未下载，检查 Tauri 通知权限
- 如果没有任何拦截日志，说明前端使用了其他方式触发导出
- 查看 Network 面板确认实际请求的 URL 格式
