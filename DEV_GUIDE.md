# 开发环境启动指南

## 🚀 开发服务器已启动！

你的 AI赢标助手开发环境现在正在运行：

**📍 应用地址**: http://localhost:1420/

## 🎯 可用的启动命令

### macOS/Linux 开发启动
```bash
# 方法1: 使用专用脚本（推荐）
npm run start

# 方法2: 使用 npm 命令
npm run tauri:dev

# 方法3: 直接运行脚本
./start-dev.sh
```

### Windows 开发启动
```batch
# 方法1: 使用专用脚本（推荐）
npm run start:windows

# 方法2: 使用 npm 命令
npm run tauri:dev

# 方法3: 直接运行脚本
start-dev-windows.bat
```

## 🔧 环境配置

### 永久解决方案（已设置）
Rust 环境变量已添加到你的 shell 配置中：
- `~/.zshrc` 文件已更新
- 下次打开终端时会自动加载 Rust 环境

### 临时解决方案
如果遇到环境变量问题，可以手动加载：
```bash
source "$HOME/.cargo/env"
npm run tauri:dev
```

## 🛠️ 开发特性

### 热重载
- 前端代码修改会自动刷新
- Rust 代码修改需要重启服务器

### 开发工具
- Vue DevTools 可用
- Tauri 开发模式已启用
- 控制台日志已开启

## 📝 当前配置

应用现在包含以下环境配置：
- **AI_bsh**: bsh环境 (http://bsh.ai.qianlima.com/)
- **hostConfig**: 47.104.218.212 bsh.ai.qianlima.com

## 🎨 测试功能

你可以在开发环境中测试：
1. ✅ WPS 缓存清理
2. ✅ hosts 文件配置
3. ✅ WPS 插件配置应用
4. ✅ WPS 启动功能

## 🛑 停止服务器

在终端中按 `Ctrl+C` 停止开发服务器

## 🔍 故障排除

### 端口被占用
如果提示端口 1420 被占用：
```bash
# macOS/Linux
lsof -ti:1420 | xargs kill -9

# Windows
netstat -ano | findstr :1420
taskkill /f /pid <PID>
```

### 环境变量问题
如果提示找不到 Cargo：
```bash
source "$HOME/.cargo/env"
```

### 重新加载配置
如果修改了配置文件：
```bash
source ~/.zshrc
```

## 🎉 开始开发！

现在你可以：
1. 打开 http://localhost:1420/ 查看应用
2. 修改代码并实时查看变化
3. 测试所有功能
4. 准备打包发布

---

**提示**: 开发服务器会自动处理 hosts 配置的权限请求，你可以安全地测试完整功能。