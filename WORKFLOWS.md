# Workflows 说明

本项目有 3 个 GitHub Actions workflows，各有不同的用途。

## 📋 Workflows 对比

| Workflow               | 触发方式                    | 配置方式      | 版本管理      | 产物保存        | 适用场景                |
| ---------------------- | --------------------------- | ------------- | ------------- | --------------- | ----------------------- |
| **release-build.yaml** | Tag (`配置名-v版本号`)      | JSON 配置文件 | ✅ 语义化版本 | Release (永久)  | ✅ **正式发布**（推荐） |
| **auto-build.yaml**    | Commit message (`#配置名#`) | JSON 配置文件 | ❌ 时间戳     | Artifacts (7天) | 快速测试                |
| **my_tag.yaml**        | Tag (`v*.*.*`)              | 硬编码在 YAML | ✅ 版本号     | Release (永久)  | ⚠️ 已弃用               |

## 🎯 推荐使用：release-build.yaml

### 为什么推荐？

1. ✅ **有版本概念**：`vinted-v1.0.0`
2. ✅ **配置灵活**：通过 JSON 文件管理
3. ✅ **多应用支持**：每个应用独立版本
4. ✅ **永久保存**：产物保存在 Release
5. ✅ **清晰明确**：Tag 名称即包含配置和版本

### 使用方法

```bash
# 1. 创建配置文件（如果还没有）
cat > build-configs/vinted.json << 'EOF'
{
  "name": "vinted",
  "url": "http://45.77.62.32:8989/",
  "icon": "./111.jpg",
  "width": 1920,
  "height": 1080,
  "platforms": {
    "macos": { "enabled": true, "targets": ["universal"] },
    "windows": { "enabled": true, "targets": ["x64", "arm64"] },
    "linux": { "enabled": false, "targets": [] }
  }
}
EOF

# 2. 创建并推送 tag
git tag vinted-v1.0.0 -m "Release vinted v1.0.0"
git push origin vinted-v1.0.0

# 3. 查看构建
# 访问：https://github.com/你的用户名/Pake/actions

# 4. 下载安装包
# 访问：https://github.com/你的用户名/Pake/releases
```

详细说明：[RELEASE_GUIDE.md](RELEASE_GUIDE.md)

## 🧪 可选使用：auto-build.yaml

### 适用场景

- 快速测试功能
- 不需要正式版本号
- 临时构建（7天后自动删除）

### 使用方法

```bash
# 提交代码时在 message 中包含 #配置名#
git commit -m "#vinted#测试新功能"
git push origin main

# 产物在 Actions 的 Artifacts 中，保留 7 天
```

详细说明：[AUTO_BUILD_GUIDE.md](AUTO_BUILD_GUIDE.md)

## ⚠️ 已弃用：my_tag.yaml

### 为什么弃用？

1. ❌ **配置硬编码**：参数写死在 YAML 中
2. ❌ **不支持多应用**：只能打包固定的一个应用
3. ❌ **难以维护**：添加新应用需要修改 YAML

### 迁移方案

**从 my_tag.yaml 迁移到 release-build.yaml**：

```bash
# 旧方式（my_tag.yaml）
git tag v1.0.0 -m "Release"
git push origin v1.0.0

# 新方式（release-build.yaml）
# 1. 创建配置文件
cp build-configs/vinted.json build-configs/myapp.json
# 2. 修改配置
vim build-configs/myapp.json
# 3. 推送新格式的 tag
git tag myapp-v1.0.0 -m "Release myapp"
git push origin myapp-v1.0.0
```

## 📊 详细对比

### release-build.yaml（✅ 推荐）

**触发条件**：

```bash
git tag vinted-v1.0.0      # ✅ 触发
git tag myapp-v2.3.1       # ✅ 触发
git tag v1.0.0             # ❌ 不触发（缺少配置名）
```

**配置示例**：

```json
{
  "name": "vinted",
  "url": "http://45.77.62.32:8989/",
  "icon": "./111.jpg",
  "width": 1920,
  "height": 1080,
  "platforms": {
    "macos": { "enabled": true, "targets": ["universal"] },
    "windows": { "enabled": true, "targets": ["x64", "arm64"] }
  }
}
```

**产物示例**：

- Release 名称：`vinted v1.0.0`
- 文件名：
  - `vinted_v1.0.0_macos_universal.dmg`
  - `vinted_v1.0.0_windows_x64.msi`
  - `vinted_v1.0.0_windows_arm64.msi`

### auto-build.yaml（可选）

**触发条件**：

```bash
git commit -m "#vinted#测试"     # ✅ 触发
git commit -m "#myapp#更新"      # ✅ 触发
git commit -m "普通提交"          # ❌ 不触发
```

**产物示例**：

- Artifact 名称：`vinted-macos-universal`
- 文件名：
  - `vinted_20250106_123456_macos_universal.dmg`
  - `vinted_20250106_123456_windows_x64.msi`
  - `vinted_20250106_123456_windows_arm64.msi`

### my_tag.yaml（⚠️ 已弃用）

**触发条件**：

```bash
git tag v1.0.0      # ✅ 触发
git tag v2.3.1      # ✅ 触发
```

**问题**：

- URL、图标、尺寸等参数硬编码在 YAML 中
- 只能打包一个固定的应用
- 修改参数需要修改 workflow 文件

## 🚀 快速开始

### 场景 1：正式发布新版本

```bash
# 使用 release-build.yaml
git tag vinted-v1.0.0 -m "正式发布 v1.0.0"
git push origin vinted-v1.0.0
```

### 场景 2：快速测试功能

```bash
# 使用 auto-build.yaml
git commit -m "#vinted#测试导出功能"
git push origin main
```

### 场景 3：发布多个应用

```bash
# 创建多个配置文件
build-configs/
├── vinted.json
├── myapp.json
└── another.json

# 分别发布
git tag vinted-v1.0.0 -m "发布 vinted"
git push origin vinted-v1.0.0

git tag myapp-v2.0.0 -m "发布 myapp"
git push origin myapp-v2.0.0

git tag another-v1.5.0 -m "发布 another"
git push origin another-v1.5.0
```

## 📁 文件位置

```
.github/workflows/
├── release-build.yaml    # ✅ 推荐使用
├── auto-build.yaml       # 可选使用
└── my_tag.yaml          # ⚠️ 已弃用（可删除）
```

## 🔧 维护建议

1. **删除旧 workflow**（可选）：

   ```bash
   git rm .github/workflows/my_tag.yaml
   git commit -m "remove deprecated workflow"
   git push origin main
   ```

2. **使用统一的配置系统**：
   - 所有应用配置放在 `build-configs/`
   - 使用 `release-build.yaml` 正式发布
   - 使用 `auto-build.yaml` 快速测试

3. **版本号规范**：
   - 遵循语义化版本：`v主版本.次版本.修订号`
   - 每个应用独立版本管理

## 📚 相关文档

- [发布指南](RELEASE_GUIDE.md) - release-build.yaml 详细说明
- [自动构建指南](AUTO_BUILD_GUIDE.md) - auto-build.yaml 详细说明
- [配置文件格式](build-configs/README.md) - JSON 配置说明
- [构建系统说明](BUILD_SYSTEM.md) - 整体系统架构

## 💡 最佳实践

| 阶段         | 推荐 Workflow      | Tag 格式        | 说明                       |
| ------------ | ------------------ | --------------- | -------------------------- |
| **开发测试** | auto-build.yaml    | 无需 tag        | Commit message: `#配置名#` |
| **内部预览** | release-build.yaml | `vinted-v0.1.0` | 使用 0.x.x 版本号          |
| **正式发布** | release-build.yaml | `vinted-v1.0.0` | 使用 1.x.x 版本号          |
| **Bug 修复** | release-build.yaml | `vinted-v1.0.1` | 递增修订号                 |
| **新功能**   | release-build.yaml | `vinted-v1.1.0` | 递增次版本号               |
| **重大更新** | release-build.yaml | `vinted-v2.0.0` | 递增主版本号               |

## 🎯 总结

1. ✅ **推荐使用 release-build.yaml** - 有版本管理，永久保存
2. 🧪 **可选使用 auto-build.yaml** - 快速测试，临时构建
3. ⚠️ **不再使用 my_tag.yaml** - 功能被 release-build.yaml 替代

**Tag 命名规范**：`配置名-v版本号`

**示例**：

```bash
vinted-v1.0.0
myapp-v2.3.1
example-v0.5.0
```

现在开始使用新的构建系统吧！🚀
