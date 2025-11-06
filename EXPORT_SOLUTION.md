# Tauri 2.0 导出下载问题解决方案

## 问题描述

在 Tauri 2.0 应用中，使用 `window.location.href` 跳转到导出 URL 时：
- ❌ CSV 数据直接在页面显示而不是下载
- ❌ 沙盒限制导致 JavaScript 拦截器无法执行
- ❌ Content-Disposition attachment 响应头被忽略

## 解决方案：后端返回 HTML 页面

采用**后端返回 HTML 页面 + JavaScript 触发下载**的方式，完美支持 Tauri 和普通浏览器。

---

## 一、Pake 项目修改（已完成）

### 保留的修改

**文件：`src-tauri/src/inject/event.js`**

只保留了下载路径模式的扩展（第 127-137 行）：

```javascript
const DOWNLOAD_PATH_PATTERNS = [
  "/download/",
  "/files/",
  "/attachments/",
  "/assets/",
  "/releases/",
  "/dist/",
  "/cookies/export",          // 新增
  "/cookies/download-template", // 新增
  "/export",                   // 新增
];
```

**作用**：用于检测 `<a>` 标签的下载链接，如果前端改用链接下载，这个配置会生效。

### 删除的修改

已删除以下不需要的代码（因为采用了后端解决方案）：
- ❌ 立即执行的页面拦截器
- ❌ window.location 拦截器
- ❌ fetch API 拦截器
- ❌ XMLHttpRequest 拦截器

---

## 二、后端代码修改（已完成）

### 修改的文件

**文件：`/Users/admin/go/empty/go/go_cookies/web/server.go`**

**行数：** 1367-1582

### 主要改动

1. **添加导入**（第 6 行）：
```go
import (
    // ...
    "encoding/base64"  // 新增
    // ...
)
```

2. **修改 handleExport 函数**：

#### 旧实现（直接返回 CSV）：
```go
// 设置响应头
c.Header("Content-Type", "text/csv; charset=utf-8")
c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))

// 直接写入 CSV 到响应
c.Writer.Write([]byte{0xEF, 0xBB, 0xBF})
writer := csv.NewWriter(c.Writer)
// ...
```

#### 新实现（返回 HTML 页面）：
```go
// 1. 生成 CSV 数据到内存 buffer
var buf bytes.Buffer
buf.Write([]byte{0xEF, 0xBB, 0xBF})
writer := csv.NewWriter(&buf)
// ... 写入数据 ...

// 2. Base64 编码
csvData := base64.StdEncoding.EncodeToString(buf.Bytes())

// 3. 返回 HTML 页面
html := fmt.Sprintf(`...HTML模板...`, filename, csvData, filename)
c.Header("Content-Type", "text/html; charset=utf-8")
c.String(http.StatusOK, html)
```

### HTML 页面功能

返回的 HTML 页面包含：

1. **友好的 UI**：
   - 显示"正在下载文件..."
   - 显示文件名
   - 提供"返回"按钮

2. **自动检测环境**：
   ```javascript
   if (window.__TAURI__) {
       // Tauri 环境：使用 invoke 命令
       window.__TAURI__.core.invoke('download_file_by_binary', {...})
   } else {
       // 普通浏览器：使用传统下载
       const link = document.createElement('a');
       link.href = 'data:text/csv;charset=utf-8;base64,' + csvData;
       link.download = filename;
       link.click();
   }
   ```

3. **自动返回**：
   - 下载成功后 1.5 秒自动返回上一页
   - 失败时显示错误信息

---

## 三、使用方法

### 1. 启动后端服务

```bash
cd /Users/admin/go/empty/go/go_cookies
go run main.go
```

### 2. 构建并启动 Pake 应用

```bash
cd /Users/admin/go/rust/Pake

# 构建 CLI（如果还没构建）
pnpm run cli:build

# 打包应用
PAKE_CREATE_APP=1 node dist/cli.js http://45.77.62.32:8989/ \
  --name vinted \
  --icon /Users/admin/go/rust/Pake/111.jpg \
  --width 1920 --height 1080 \
  --targets apple

# 打开应用
open /Users/admin/go/rust/Pake/vinted.app
```

### 3. 测试导出功能

1. 在应用中点击"导出"按钮
2. **期望结果**：
   - ✅ 页面跳转到导出页面
   - ✅ 显示"正在下载文件..."
   - ✅ CSV 文件自动下载到 `~/Downloads` 目录
   - ✅ 显示"下载成功！文件已保存到下载目录"
   - ✅ 1.5秒后自动返回上一页

---

## 四、优势

### ✅ 兼容性好
- 同时支持 Tauri 应用和普通浏览器
- 前端代码无需修改（保持 `window.location.href`）

### ✅ 用户体验好
- 显示友好的下载提示
- 自动返回上一页
- 错误提示清晰

### ✅ 实现简单
- 只需修改后端一个函数
- 不需要复杂的前端拦截逻辑
- 不需要修改 Tauri 配置

### ✅ 安全性
- 不需要禁用 CSP 或沙盒
- 使用 Tauri 官方的下载命令
- Base64 编码确保数据安全传输

---

## 五、故障排除

### 如果下载失败

1. **检查控制台日志**（Cmd+Option+I）：
   - 查看是否有 `[Export]` 开头的日志
   - 查看具体错误信息

2. **检查文件权限**：
   - 确保应用有权限访问 `~/Downloads` 目录
   - 在 macOS 系统设置中检查应用权限

3. **检查后端**：
   - 确保后端服务正常运行
   - 访问 `http://45.77.62.32:8989/cookies/export` 查看是否返回 HTML

### 普通浏览器测试

在普通浏览器（Chrome/Safari）中访问：
```
http://45.77.62.32:8989/cookies/export
```

应该会自动下载 CSV 文件（使用传统方式）。

---

## 六、文件清单

### Pake 项目

```
/Users/admin/go/rust/Pake/
├── src-tauri/src/inject/event.js    # 修改：添加导出路径到 DOWNLOAD_PATH_PATTERNS
├── BUILD.md                          # 打包文档（已更新）
└── EXPORT_SOLUTION.md                # 本文档（解决方案说明）
```

### 后端项目

```
/Users/admin/go/empty/go/go_cookies/
└── web/server.go                     # 修改：handleExport 函数（1367-1582行）
```

---

## 七、核心代码片段

### 后端核心逻辑

```go
// 生成 CSV 到内存
var buf bytes.Buffer
buf.Write([]byte{0xEF, 0xBB, 0xBF})
writer := csv.NewWriter(&buf)
// ... 写入数据 ...

// Base64 编码
csvData := base64.StdEncoding.EncodeToString(buf.Bytes())

// 返回 HTML 页面（包含自动下载脚本）
html := fmt.Sprintf(`<script>
if (window.__TAURI__) {
    // Tauri: 使用 invoke
    window.__TAURI__.core.invoke('download_file_by_binary', {...})
} else {
    // Browser: 使用传统方式
    const link = document.createElement('a');
    link.href = 'data:text/csv;base64,' + csvData;
    link.download = filename;
    link.click();
}
</script>`, csvData, filename)

c.String(http.StatusOK, html)
```

---

## 八、总结

/Users/admin/go/rust/Pake/src-tauri/src/app/invoke.rs 下载打包
