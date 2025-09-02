# AI赢标助手-WPS环境切换工具 打包信息

## 📦 打包完成 ✅

### 基本信息
- **应用名称**: AI赢标助手-WPS环境切换工具
- **版本**: 1.0.0
- **平台**: macOS
- **架构**: Universal (Intel + Apple Silicon)
- **文件大小**: 6.9 MB
- **打包时间**: 2025-08-29 17:55

### 文件位置
```
/Users/wuwenxin/Desktop/qlm/word_plugin/buildPkg/install-tauri/src-tauri/target/release/bundle/macos/AI赢标助手-WPS环境切换工具.app
```

### 功能特性
✅ WPS插件环境切换
✅ 跨平台WPS缓存清理
✅ 智能hosts文件配置（支持macOS权限请求）
✅ 完整的工作流程：清理缓存 → 配置hosts → 应用配置 → 启动WPS
✅ 现代化Vue3 + Element Plus界面
✅ Tauri跨平台桌面应用框架

### 系统要求
- macOS 10.13+
- 支持Intel和Apple Silicon Mac

### 使用说明
1. 双击启动应用
2. 选择需要的环境配置
3. 点击"应用配置并启动WPS"
4. 按照提示完成配置

### 打包命令
```bash
npm run tauri build
```

### 注意事项
- 首次配置hosts文件时需要管理员权限
- 应用会自动检测重复配置并跳过
- 支持WPS、WPP、ET等多种WPS组件