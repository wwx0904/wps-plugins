# Windows 自动打包脚本使用指南

## 🚀 脚本功能

我为你创建了两个 Windows 脚本，可以自动化完成环境配置和打包：

### 📄 脚本文件

1. **`setup-and-build-windows.bat`** - 完整的环境配置和打包脚本
2. **`quick-build-windows.bat`** - 快速打包脚本（环境已配置时使用）

## 🎯 推荐使用流程

### 第一次使用（环境未配置）

#### 🔄 步骤 1：下载项目文件
将整个 `install-tauri` 文件夹复制到你的 Windows 电脑上

#### 🔧 步骤 2：运行完整配置脚本
```batch
# 右键以管理员身份运行
setup-and-build-windows.bat
```

这个脚本会自动：
- ✅ 检查管理员权限
- ✅ 安装 Visual Studio Build Tools（必需的编译环境）
- ✅ 安装 Rust 编程语言
- ✅ 安装 Node.js 和 npm
- ✅ 安装 Git（可选）
- ✅ 安装 Tauri CLI
- ✅ 安装 NSIS（Windows 打包工具）
- ✅ 克隆项目代码（可选）
- ✅ 自动打包应用

#### 📦 步骤 3：选择操作
脚本运行后会提供选项：
1. **克隆/下载项目代码** - 如果需要从 Git 仓库下载
2. **打包现有项目** - 如果项目文件已存在
3. **退出**

#### 🎉 步骤 4：获取打包结果
打包成功后，脚本会：
- 显示打包产物位置
- 询问是否打开输出目录
- 询问是否创建桌面快捷方式

### 日常使用（环境已配置）

如果已经运行过完整配置脚本，后续可以直接使用快速打包脚本：

```batch
# 右键以管理员身份运行
quick-build-windows.bat
```

## 📦 打包产物

打包成功后，你会在以下位置找到文件：

### MSI 安装包（推荐）
```
src-tauri\target\release\bundle\msi\
├── AI赢标助手-WPS环境切换工具_1.0.0_x64_en-US.msi
└── AI赢标助手-WPS环境切换工具_1.0.0_x64_zh-CN.msi
```

### 便携版 EXE
```
src-tauri\target\release\bundle\nsis\
└── AI赢标助手-WPS环境切换工具-x64_1.0.0.exe
```

## ⚠️ 重要注意事项

### 1. 管理员权限
- **必须**以管理员身份运行脚本
- 右键点击脚本文件 → 选择"以管理员身份运行"

### 2. 网络连接
- 脚本需要下载软件包，确保网络连接正常
- 如果下载失败，可以手动安装对应软件

### 3. 重启要求
- 安装某些软件后可能需要重启计算机
- 脚本会提示你何时需要重启

### 4. 防火墙和杀毒软件
- 某些杀毒软件可能会阻止脚本运行
- 如果遇到问题，暂时关闭杀毒软件或添加信任

### 5. 磁盘空间
- 确保至少有 5GB 可用空间
- 主要用于安装开发工具和依赖包

## 🔧 故障排除

### 常见问题

1. **"winget 命令不存在"**
   - 更新 Windows 到最新版本
   - 或手动从 Microsoft Store 安装 App Installer

2. **"Visual Studio Build Tools 安装失败"**
   - 手动下载：https://visualstudio.microsoft.com/visual-cpp-build-tools/
   - 安装时选择 "C++ build tools"

3. **"Rust 环境变量未生效"**
   - 重启计算机
   - 或重新打开命令提示符

4. **"权限被拒绝"**
   - 确保以管理员身份运行
   - 检查用户账户控制(UAC)设置

5. **"网络连接失败"**
   - 检查网络连接
   - 尝试使用代理或更换网络

### 手动安装备用方案

如果自动脚本失败，可以手动安装：

1. **Visual Studio Build Tools**
   - 下载：https://visualstudio.microsoft.com/visual-cpp-build-tools/
   - 选择 "C++ build tools" 工作负载

2. **Rust**
   - 访问：https://rustup.rs/
   - 下载并运行安装程序

3. **Node.js**
   - 访问：https://nodejs.org/
   - 下载 LTS 版本

4. **Tauri CLI**
   ```batch
   npm install -g @tauri-apps/cli
   ```

## 📋 系统要求

- **操作系统**: Windows 7 或更高版本（64位）
- **内存**: 至少 4GB RAM
- **磁盘空间**: 至少 5GB 可用空间
- **网络**: 互联网连接（下载依赖包）

## 🎯 使用建议

1. **首次使用**：使用 `setup-and-build-windows.bat` 完整配置
2. **日常打包**：使用 `quick-build-windows.bat` 快速打包
3. **团队协作**：将脚本分发给团队成员，确保环境一致
4. **CI/CD**：结合 GitHub Actions 实现自动化打包

## 📞 技术支持

如果遇到问题：
1. 检查本文档的故障排除部分
2. 查看脚本生成的日志文件：`%TEMP%\ai-assistant-install.log`
3. 确保系统满足所有要求
4. 尝试手动安装缺失的组件

---

## 🎉 开始使用

现在你已经准备好在 Windows 上打包 AI赢标助手了！

1. 复制项目文件夹到 Windows 电脑
2. 右键以管理员身份运行 `setup-and-build-windows.bat`
3. 按照提示操作
4. 享受自动化的打包体验！