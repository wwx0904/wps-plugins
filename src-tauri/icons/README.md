# 图标文件

请将以下文件放置在此目录：

- `32x32.png` - 32x32像素PNG图标
- `128x128.png` - 128x128像素PNG图标  
- `128x128@2x.png` - 256x256像素PNG图标（高DPI显示）
- `icon.icns` - macOS应用图标
- `icon.ico` - Windows应用图标

这些图标将用于应用的不同平台和显示场景。

## 生成图标的建议工具
- macOS: 使用 `iconutil` 工具生成 .icns 文件
- Windows: 使用在线工具或 ImageMagick 生成 .ico 文件
- 通用: 可以使用 Tauri 的图标生成工具