# 自动打包使用指南

## 功能说明

通过 **commit message** 中的特殊标记自动触发打包，无需手动运行命令或推送 tag。

## 使用方法

### 1. 创建配置文件

在 `build-configs/` 目录创建你的应用配置：

```json
{
  "name": "vinted",
  "url": "http://45.77.62.32:8989/",
  "icon": "./111.jpg",
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

### 2. 提交代码触发打包

**Commit message 格式**：`#配置名#描述信息`

```bash
# 示例 1: 打包 vinted
git add .
git commit -m "#vinted#修复了导出功能"
git push origin main

# 示例 2: 打包 example
git add .
git commit -m "#example#更新了界面样式"
git push origin main

# 示例 3: 普通提交（不触发打包）
git commit -m "更新了 README"
git push origin main
```

### 3. 查看构建进度

1. **GitHub Actions 页面**：
   - 访问：https://github.com/你的用户名/Pake/actions
   - 查看 "Auto Build from Commit" workflow

2. **构建摘要**：
   - 点击运行的 workflow
   - 查看 "Build Summary" job
   - 可以看到每个平台的构建状态

3. **下载产物**：
   - 构建完成后，在 workflow 页面点击 "Artifacts"
   - 下载对应的安装包（保留 7 天）

## Commit Message 规则

### ✅ 正确的格式

```bash
#vinted#打包新版本
#vinted#修复bug
#myapp#添加新功能
#example#更新界面
```

### ❌ 错误的格式

```bash
vinted 打包新版本           # 缺少 ##
#vinted 打包新版本           # 只有一个 #
#vinted.json#打包            # 不要加 .json
# vinted #打包               # # 和配置名之间不要有空格
```

### 规则说明

1. **必须使用 `#配置名#` 格式**
2. **配置名**：build-configs/ 目录下的 JSON 文件名（不含 .json）
3. **描述信息**：可选，写在第二个 `#` 后面
4. **配置名允许**：字母、数字、下划线、连字符
5. **大小写敏感**：`#Vinted#` 和 `#vinted#` 是不同的

## Workflow 工作流程

```
1. 监听 push 到 main/dev 分支
   ↓
2. 检测 commit message 是否包含 #配置名#
   ↓
3. 提取配置名（例如：vinted）
   ↓
4. 读取 build-configs/vinted.json
   ↓
5. 并行构建：
   - macOS Universal (如果启用)
   - Windows x64 (如果启用)
   - Windows ARM64 (如果启用)
   ↓
6. 上传构建产物到 Artifacts（保留 7 天）
   ↓
7. 生成构建摘要
```

## 配置文件说明

### 最小配置

```json
{
  "name": "app-name",
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

### 字段说明

| 字段                        | 说明                         | 必填 | 示例                         |
| --------------------------- | ---------------------------- | ---- | ---------------------------- |
| `name`                      | 应用名称                     | ✅   | `"vinted"`                   |
| `url`                       | 要打包的网址                 | ✅   | `"http://45.77.62.32:8989/"` |
| `icon`                      | 图标路径（相对于项目根目录） | ✅   | `"./111.jpg"`                |
| `width`                     | 窗口宽度                     | ✅   | `1920`                       |
| `height`                    | 窗口高度                     | ✅   | `1080`                       |
| `platforms.macos.enabled`   | 是否构建 macOS               | ✅   | `true`                       |
| `platforms.macos.targets`   | macOS 架构                   | ✅   | `["universal"]`              |
| `platforms.windows.enabled` | 是否构建 Windows             | ✅   | `true`                       |
| `platforms.windows.targets` | Windows 架构                 | ✅   | `["x64", "arm64"]`           |

### 平台配置

**macOS targets**:

- `"universal"` - 包含 Intel + Apple Silicon（推荐）
- `"intel"` - 仅 Intel
- `"apple"` - 仅 Apple Silicon

**Windows targets**:

- `"x64"` - 64位 Intel/AMD
- `"arm64"` - ARM64 架构

## 使用示例

### 示例 1：打包单个应用

```bash
# 1. 确保配置文件存在
cat build-configs/vinted.json

# 2. 修改代码或配置
vim src-tauri/src/inject/event.js

# 3. 提交并触发打包
git add .
git commit -m "#vinted#优化了下载功能"
git push origin main

# 4. 查看构建
# 访问 GitHub Actions 页面
```

### 示例 2：打包多个应用

```bash
# 第一次提交：打包 vinted
git add .
git commit -m "#vinted#版本 1.0.0"
git push origin main

# 第二次提交：打包 myapp
git add .
git commit -m "#myapp#版本 1.0.0"
git push origin main
```

### 示例 3：只打包 macOS

修改配置文件：

```json
{
  "name": "myapp",
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

然后提交：

```bash
git commit -m "#myapp#只打包 macOS 版本"
git push origin main
```

## 常见问题

### Q1: 提交后没有触发构建？

**检查清单**：

1. ✅ Commit message 格式正确：`#配置名#`
2. ✅ 配置文件存在：`build-configs/配置名.json`
3. ✅ 推送到了 main 或 dev 分支
4. ✅ GitHub Actions 没有被禁用

### Q2: 构建失败？

**常见原因**：

1. 图标文件不存在或路径错误
2. URL 无法访问
3. 配置文件格式错误（JSON 语法）

**解决方法**：

1. 查看 Actions 日志
2. 检查配置文件：`jq . build-configs/vinted.json`
3. 验证图标存在：`ls -la 111.jpg`

### Q3: 如何下载构建产物？

1. 进入 GitHub Actions 运行页面
2. 滚动到页面底部 "Artifacts" 区域
3. 点击下载对应的包：
   - `配置名-macos-universal` - macOS DMG
   - `配置名-windows-x64` - Windows x64 MSI
   - `配置名-windows-arm64` - Windows ARM64 MSI

### Q4: 产物保留多久？

默认保留 **7 天**，过期后自动删除。如需长期保存，请及时下载。

### Q5: 能否自动创建 Release？

当前版本不自动创建 Release，只上传到 Artifacts。

如需创建 Release，可以：

1. 使用 tag 触发（`git tag v1.0.0 && git push origin v1.0.0`）
2. 手动从 Artifacts 下载后上传到 Releases

### Q6: 如何同时打包多个应用？

**方法 1**：多次提交

```bash
git commit -m "#app1#更新"
git push
git commit -m "#app2#更新" --allow-empty
git push
```

**方法 2**：使用 tag 触发（会打包所有配置）

```bash
git tag v1.0.0 && git push origin v1.0.0
```

## 对比：Auto Build vs Tag Build

| 特性     | Auto Build (commit message) | Tag Build      |
| -------- | --------------------------- | -------------- |
| 触发方式 | Commit message `#配置名#`   | 推送 tag       |
| 打包范围 | 单个配置                    | 所有配置       |
| 适用场景 | 快速测试、单独更新          | 正式发布       |
| 产物位置 | Artifacts (7天)             | Release (永久) |
| 使用频率 | 频繁使用                    | 正式版本       |

## 最佳实践

1. **开发阶段**：使用 Auto Build（commit message）
   - 快速迭代测试
   - 及时发现问题

2. **发布阶段**：使用 Tag Build
   - 正式版本号
   - 创建 Release
   - 永久保存产物

3. **配置管理**：
   - 为每个应用创建独立配置文件
   - 配置文件命名规范：小写字母+连字符
   - 及时更新配置中的版本信息

4. **图标管理**：
   - 统一放在 `icons/` 目录
   - 使用高质量图标（512x512 或更大）
   - 配置中使用相对路径

## 文件结构

```
Pake/
├── build-configs/          # 配置文件目录
│   ├── vinted.json        # vinted 应用配置
│   ├── example.json       # 示例配置
│   └── README.md          # 配置说明
├── icons/                 # 图标目录（可选）
│   ├── vinted.jpg
│   └── example.png
├── 111.jpg                # 项目根目录的图标
├── .github/workflows/
│   ├── auto-build.yaml    # 自动构建 workflow
│   └── my_tag.yaml        # Tag 触发 workflow（可选）
└── AUTO_BUILD_GUIDE.md    # 本文档
```

## 下一步

1. ✅ 创建配置文件：`build-configs/myapp.json`
2. ✅ 准备图标文件：`./icons/myapp.png`
3. ✅ 提交代码：`git commit -m "#myapp#首次打包"`
4. ✅ 查看构建：访问 GitHub Actions
5. ✅ 下载产物：从 Artifacts 下载

## 技术支持

遇到问题？

1. 查看 [配置文档](build-configs/README.md)
2. 查看 [GitHub Actions 日志](https://github.com/你的用户名/Pake/actions)
3. 检查 [Workflow 文件](.github/workflows/auto-build.yaml)
