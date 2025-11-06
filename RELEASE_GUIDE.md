# 发布指南

## 🎯 发布流程

使用 **Tag 命名规范** 触发自动构建和发布。

### Tag 命名格式

```
配置名-v版本号
```

**示例**：
```bash
vinted-v1.0.0      # vinted 应用，版本 1.0.0
vinted-v1.2.3      # vinted 应用，版本 1.2.3
myapp-v2.0.0       # myapp 应用，版本 2.0.0
example-v0.1.0     # example 应用，版本 0.1.0
```

## 📝 完整发布流程

### 1. 确保配置文件存在

```bash
# 检查配置文件
ls build-configs/vinted.json

# 查看配置内容
cat build-configs/vinted.json
```

### 2. 提交代码

```bash
# 修改代码
vim src-tauri/src/inject/event.js

# 提交修改
git add .
git commit -m "fix: 修复导出功能"
git push origin main
```

### 3. 创建并推送 Tag

```bash
# 创建 tag（配置名-v版本号）
git tag vinted-v1.0.0 -m "Release vinted v1.0.0"

# 推送 tag
git push origin vinted-v1.0.0
```

### 4. 等待构建完成

- 访问：https://github.com/你的用户名/Pake/actions
- 查看 "Release Build" workflow
- 约 15-20 分钟后构建完成

### 5. 下载安装包

- 访问：https://github.com/你的用户名/Pake/releases
- 找到对应的 Release
- 下载安装包：
  - macOS: `vinted_v1.0.0_macos_universal.dmg`
  - Windows x64: `vinted_v1.0.0_windows_x64.msi`
  - Windows ARM64: `vinted_v1.0.0_windows_arm64.msi`

## 🔢 版本号规范

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

```
主版本号.次版本号.修订号
```

**示例**：
- `v1.0.0` - 首次发布
- `v1.0.1` - Bug 修复
- `v1.1.0` - 新增功能（向后兼容）
- `v2.0.0` - 重大更新（可能不兼容）

## 📋 使用示例

### 示例 1：首次发布 vinted

```bash
# 1. 检查配置
cat build-configs/vinted.json

# 2. 创建 tag
git tag vinted-v1.0.0 -m "首次发布 vinted 应用"

# 3. 推送
git push origin vinted-v1.0.0
```

### 示例 2：修复 bug 后发布

```bash
# 1. 修复代码
vim src-tauri/src/inject/event.js

# 2. 提交
git add .
git commit -m "fix: 修复下载功能"
git push origin main

# 3. 发布新版本
git tag vinted-v1.0.1 -m "修复下载功能"
git push origin vinted-v1.0.1
```

### 示例 3：新增功能后发布

```bash
# 1. 开发新功能
# ... 开发代码 ...

# 2. 提交
git add .
git commit -m "feat: 添加导出模板功能"
git push origin main

# 3. 发布次版本
git tag vinted-v1.1.0 -m "添加导出模板功能"
git push origin vinted-v1.1.0
```

### 示例 4：发布多个应用

```bash
# 发布 vinted v1.0.0
git tag vinted-v1.0.0 -m "Release vinted"
git push origin vinted-v1.0.0

# 发布 myapp v2.0.0
git tag myapp-v2.0.0 -m "Release myapp"
git push origin myapp-v2.0.0
```

## 🎨 Release 内容

每个 Release 自动包含：

1. **版本信息**：应用名 + 版本号
2. **下载链接**：所有平台的安装包
3. **配置信息**：URL、窗口大小等
4. **安装说明**：macOS 和 Windows 的安装方法

## 🚀 快速命令

```bash
# 查看所有 tag
git tag -l

# 查看特定应用的 tag
git tag -l "vinted-*"

# 删除本地 tag
git tag -d vinted-v1.0.0

# 删除远程 tag
git push origin :refs/tags/vinted-v1.0.0

# 查看 tag 信息
git show vinted-v1.0.0
```

## 📊 版本管理最佳实践

### 1. 版本号递增

```bash
v1.0.0  →  v1.0.1  (Bug 修复)
v1.0.1  →  v1.1.0  (新功能)
v1.1.0  →  v2.0.0  (重大更新)
```

### 2. Tag Message 规范

```bash
# ✅ 好的 tag message
git tag vinted-v1.0.0 -m "Release vinted v1.0.0
- 修复导出功能
- 优化性能
- 更新依赖"

# ❌ 不好的 tag message
git tag vinted-v1.0.0 -m "更新"
```

### 3. 测试后再发布

```bash
# 1. 开发分支测试
git checkout dev
# ... 开发和测试 ...

# 2. 合并到主分支
git checkout main
git merge dev

# 3. 创建 tag
git tag vinted-v1.0.0 -m "Release notes"
git push origin vinted-v1.0.0
```

## ⚠️ 常见问题

### Q1: Tag 格式错误

```bash
# ❌ 错误格式
vinted-1.0.0        # 缺少 'v'
v1.0.0              # 缺少配置名
vinted_v1.0.0       # 使用下划线而不是连字符
vinted-v1.0         # 版本号不完整

# ✅ 正确格式
vinted-v1.0.0
myapp-v2.3.1
example-v0.1.0
```

### Q2: 配置文件不存在

```bash
# 错误：No such file: build-configs/myapp.json

# 解决：创建配置文件
cat > build-configs/myapp.json << 'EOF'
{
  "name": "myapp",
  "url": "https://example.com/",
  "icon": "./icons/myapp.png",
  "width": 1200,
  "height": 800,
  "platforms": {
    "macos": { "enabled": true, "targets": ["universal"] },
    "windows": { "enabled": true, "targets": ["x64", "arm64"] },
    "linux": { "enabled": false, "targets": [] }
  }
}
EOF

# 提交配置文件
git add build-configs/myapp.json
git commit -m "add myapp config"
git push origin main

# 重新推送 tag
git tag myapp-v1.0.0 -m "Release myapp"
git push origin myapp-v1.0.0
```

### Q3: 构建失败

**检查清单**：
1. 配置文件格式正确：`jq . build-configs/vinted.json`
2. 图标文件存在：`ls -la 111.jpg`
3. URL 可访问
4. GitHub Actions 日志查看具体错误

### Q4: 如何回滚版本

```bash
# 1. 删除错误的 tag
git tag -d vinted-v1.0.1
git push origin :refs/tags/vinted-v1.0.1

# 2. 删除 Release（手动在 GitHub 网页删除）

# 3. 修复代码后重新发布
git tag vinted-v1.0.1 -m "Fix and re-release"
git push origin vinted-v1.0.1
```

## 📂 项目结构

```
Pake/
├── build-configs/          # 配置文件
│   ├── vinted.json        # vinted 配置
│   └── myapp.json         # myapp 配置
├── .github/workflows/
│   └── release-build.yaml # Release 构建 workflow
└── RELEASE_GUIDE.md       # 本文档
```

## 🔄 Workflow 对比

| 特性 | auto-build.yaml | release-build.yaml |
|------|----------------|-------------------|
| 触发方式 | Commit message | Tag 推送 |
| 版本管理 | 无（时间戳） | 有（语义化版本） |
| 产物保存 | Artifacts (7天) | Release (永久) |
| 配置方式 | JSON 文件 | JSON 文件 |
| 适用场景 | 快速测试 | 正式发布 |

## 💡 推荐工作流

### 开发阶段
使用 `auto-build.yaml`（commit message 触发）：
```bash
git commit -m "#vinted#测试新功能"
git push origin main
```

### 发布阶段
使用 `release-build.yaml`（tag 触发）：
```bash
git tag vinted-v1.0.0 -m "正式发布"
git push origin vinted-v1.0.0
```

## 📚 相关文档

- [配置文件格式](build-configs/README.md)
- [自动构建指南](AUTO_BUILD_GUIDE.md)
- [构建系统说明](BUILD_SYSTEM.md)

## 🎯 总结

1. **Tag 命名**：`配置名-v版本号`（例如：`vinted-v1.0.0`）
2. **版本规范**：遵循语义化版本
3. **发布流程**：提交代码 → 创建 tag → 推送 tag → 等待构建
4. **产物下载**：GitHub Releases 页面永久保存

现在开始你的第一次发布吧！🚀
