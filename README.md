# AI赢标助手 - WPS环境切换工具 (Tauri版本)

轻量级的WPS插件环境切换工具，基于Tauri框架开发，体积小、性能优异。

## 功能特性

- 🎯 **环境切换**: 快速切换zdxy环境、本地开发环境等WPS插件配置
- 🚀 **轻量级**: 应用体积约10MB，比Electron方案减少90%+
- 🔧 **自动启动**: 配置完成后自动启动WPS应用
- 💾 **配置管理**: 智能管理WPS插件配置文件
- 🖥️ **跨平台**: 支持Windows、macOS、Linux

## 技术栈

- **前端**: Vue 3 + Element Plus + Vite
- **后端**: Rust (迁移自wpsPkg-go逻辑)
- **框架**: Tauri 1.5
- **打包**: 原生应用打包，支持Mac .app 和 Windows .exe

## 开发环境要求

### 必需环境
- **Node.js**: 16+ 
- **Rust**: 1.60+
- **Cargo**: 自动包含在Rust安装中

### 平台特定要求

#### Windows
- **Microsoft C++ Build Tools** 或 **Visual Studio**
- **WebView2** (Windows 10/11通常已预装)

#### macOS  
- **Xcode Command Line Tools**: `xcode-select --install`

#### Linux
- **系统依赖**:
  ```bash
  # Ubuntu/Debian
  sudo apt update
  sudo apt install libwebkit2gtk-4.0-dev build-essential curl wget libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev
  
  # Arch Linux
  sudo pacman -S webkit2gtk base-devel curl wget openssl gtk3 libappindicator-gtk3 librsvg
  ```

## 快速开始

### 1. 安装依赖
```bash
npm install
```

### 2. 开发模式
```bash
# 启动开发服务器
npm run tauri:dev

# 或使用构建脚本
./build.sh dev
```

### 3. 构建应用
```bash
# 构建当前平台
npm run tauri:build

# 或使用构建脚本
./build.sh build
```

构建产物位置：`dist/` （类似传统前端项目结构）

## 项目结构

```
install-tauri/
├── dist/                   # 构建产物目录（类似传统前端）
│   ├── macos/             #   Mac应用包 (.app)
│   └── dmg/              #   Mac安装包 (.dmg)
├── src/                    # Vue3前端代码
│   ├── App.vue            # 主应用组件
│   └── main.js            # Vue应用入口
├── src-tauri/             # Tauri后端代码
│   ├── src/
│   │   ├── main.rs        # Rust主程序入口
│   │   └── wps_config.rs  # WPS配置管理逻辑
│   ├── Cargo.toml         # Rust依赖配置
│   └── tauri.conf.json    # Tauri应用配置
├── package.json           # Node.js依赖和脚本
├── vite.config.js         # Vite构建配置
└── build.sh              # 构建脚本
```

## 配置说明

### WPS插件配置路径
- **Windows**: `%APPDATA%\\kingsoft\\wps\\jsaddons\\publish.xml`
- **macOS**: `~/Library/Containers/com.kingsoft.wpsoffice.mac/Data/.kingsoft/wps/jsaddons/publish.xml`
- **Linux**: `~/.local/share/Kingsoft/wps/jsaddons/publish.xml`

### 支持的环境
- **zdxy环境**: `http://zdxy.ai.qianlima.com/wuye/wordPlugin/wps/`
- **本地开发**: `http://wuye-dev.qianlima.com/`
- **清空配置**: 移除本地插件配置

## 与Go版本对比

| 特性 | Go版本 (wpsPkg-go) | Tauri版本 |
|------|-------------------|-----------|
| **界面** | 命令行交互 | 图形化界面 |
| **体积** | ~5MB | ~10MB |
| **用户体验** | CLI | 现代化GUI |
| **功能** | 完全相同 | 完全相同 |
| **跨平台** | ✅ | ✅ |

## 开发注意事项

1. **图标文件**: 需要在`src-tauri/icons/`目录放置应用图标文件
2. **代码签名**: macOS和Windows发布需要配置代码签名
3. **权限配置**: 文件系统访问权限已在`tauri.conf.json`中配置
4. **依赖同步**: Rust和Node.js依赖需要分别管理

## 构建和发布

### 开发构建
```bash
npm run tauri:dev
```

### 生产构建
```bash
npm run tauri:build
```

**构建产物位置**：`dist/` 

**快速访问**：
- Mac 应用: `dist/macos/AI赢标助手-WPS环境切换工具.app`
- Windows 应用: `dist/msi/AI赢标助手-WPS环境切换工具_1.0.0_x64_zh-CN.msi` (需在Windows环境构建)

### 便捷脚本
```bash
# 查看构建产物
make show-build

# 清理所有构建文件
npm run clean

# 快速重建
make rebuild
```

### 跨平台构建

**当前支持的输出格式**：
- **macOS**: `.app` 应用包（不生成dmg）
- **Windows**: `.msi` 安装包

**构建方式**：
```bash
# macOS 环境构建 Mac 应用
npm run tauri:build

# Windows 环境构建 Windows 应用  
npm run tauri:build

# 尝试跨平台构建（可能需要额外配置）
npm run tauri:build-all
```

由于Tauri的跨平台编译限制，推荐：
- **macOS 应用**: 在 macOS 系统上构建
- **Windows 应用**: 在 Windows 系统上构建

## 故障排除

### 常见问题

1. **Rust编译失败**
   - 确保Rust版本 ≥ 1.60
   - 更新依赖: `cargo update`

2. **前端构建失败**  
   - 清理node_modules: `rm -rf node_modules && npm install`
   - 检查Node.js版本 ≥ 16

3. **权限问题**
   - macOS: 可能需要授权访问WPS配置目录
   - Windows: 以管理员身份运行可能需要

## 许可证

MIT License

## 相关项目

- [wpsPkg-go](../wpsPkg-go/) - Go版本命令行工具
- [AI赢标助手主项目](../../) - Vue3+WPS插件主体