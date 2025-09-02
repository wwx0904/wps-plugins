# Windows 打包脚本文件结构

```
install-tauri/
├── setup-and-build-windows.bat          # 🚀 完整环境配置和打包脚本
├── quick-build-windows.bat              # ⚡ 快速打包脚本（环境已配置）
├── build-windows.bat                     # 📦 传统 Windows 打包脚本
├── build.sh                             # 🐧 macOS/Linux 构建脚本
├── WINDOWS_BUILD.md                     # 📖 Windows 打包技术文档
├── WINDOWS_SCRIPT_GUIDE.md              # 📚 脚本使用指南
├── PACKAGE_INFO.md                      # 📋 打包信息文档
├── .github/
│   └── workflows/
│       └── build.yml                    # 🤖 GitHub Actions 自动打包
├── src-tauri/                           # 🔧 Rust 后端源码
├── src/                                 # 📱 Vue 前端源码
└── ...                                  # 其他项目文件
```

## 🎯 脚本选择指南

### 🔧 setup-and-build-windows.bat
**用途**: 第一次使用，环境未配置
**功能**: 自动安装所有必需的软件和工具
**适合**: 新环境、团队成员、自动化部署

### ⚡ quick-build-windows.bat  
**用途**: 日常打包，环境已配置
**功能**: 快速检查环境和打包
**适合**: 开发者、频繁打包

### 📦 build-windows.bat
**用途**: 传统打包流程
**功能**: 基础的打包功能
**适合**: 特殊需求、手动控制

## 🚀 推荐使用流程

### 团队协作流程
1. 将整个项目文件夹分发给团队成员
2. 每人运行 `setup-and-build-windows.bat` 配置环境
3. 日常使用 `quick-build-windows.bat` 打包
4. 统一的开发和打包环境

### 个人开发流程
1. 首次：`setup-and-build-windows.bat`
2. 日常：`quick-build-windows.bat`
3. 发布：配置 GitHub Actions 自动打包

### 自动化部署流程
1. 配置 GitHub Actions
2. 推送代码自动打包所有平台
3. 发布 Release 自动生成下载链接

## 📋 脚本功能对比

| 功能 | setup-and-build | quick-build | build-windows |
|------|------------------|-------------|----------------|
| 自动安装依赖 | ✅ | ❌ | ❌ |
| 环境检查 | ✅ | ✅ | ✅ |
| Git 集成 | ✅ | ❌ | ❌ |
| 一键打包 | ✅ | ✅ | ✅ |
| 桌面快捷方式 | ✅ | ❌ | ❌ |
| 日志记录 | ✅ | ❌ | ❌ |
| 错误处理 | ✅ | ✅ | ✅ |
| 用户交互 | ✅ | ⚡ | ⚡ |

## 🎉 开始使用

选择适合你需求的脚本，开始 Windows 打包之旅！