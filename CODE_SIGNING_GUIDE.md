# macOS 代码签名配置指南

## 准备工作

1. **加入 Apple Developer Program**
   - 访问 [developer.apple.com](https://developer.apple.com/)
   - 注册开发者账号（每年 $99）

2. **创建证书**
   - 登录 [Developer Portal](https://developer.apple.com/account/)
   - 证书类型：Developer ID Application

3. **下载并安装证书**
   - 下载证书文件（.cer）
   - 双击安装到 Keychain

## 配置 Tauri

### 1. 更新 tauri.conf.json

```json
{
  "tauri": {
    "bundle": {
      "macOS": {
        "providerShortName": "你的开发者团队ID",
        "signingIdentity": "Developer ID Application: 你的名字 (团队ID)",
        "entitlements": "entitlements.plist"
      }
    }
  }
}
```

### 2. 创建 entitlements.plist 文件

在 `src-tauri` 目录下创建 `entitlements.plist`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.allow-dyld-environment-variables</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

### 3. 获取签名信息

在终端运行以下命令查看可用的签名身份：

```bash
security find-identity -v -p codesigning
```

## GitHub Actions 配置

### 1. 创建 Secrets

在 GitHub 仓库设置中添加以下 Secrets：
- `APPLE_CERTIFICATE` - 导出的 P12 证书（Base64 编码）
- `APPLE_CERTIFICATE_PASSWORD` - 证书密码
- `APPLE_DEVELOPER_TEAM_ID` - 团队 ID
- `APPLE_SIGNING_IDENTITY` - 签名身份

### 2. 导出证书

```bash
# 导出 P12 证书
security export -k ~/Library/Keychains/login.keychain-db \
  -t p12 -n "Developer ID Application: 你的名字 (团队ID)" \
  -o ~/Desktop/cert.p12 \
  -P证书密码

# Base64 编码
base64 -i ~/Desktop/cert.p12 | pbcopy
```

### 3. 更新 GitHub Actions 配置

```yaml
- name: Import Apple certificate
  uses: apple-actions/import-codesign-certs@v2
  with:
    p12-file-base64: ${{ secrets.APPLE_CERTIFICATE }}
    p12-password: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}

- name: Build the app
  env:
    APPLE_SIGNING_IDENTITY: ${{ secrets.APPLE_SIGNING_IDENTITY }}
    APPLE_DEVELOPER_TEAM_ID: ${{ secrets.APPLE_DEVELOPER_TEAM_ID }}
  run: npm run tauri:build
```

## 验证签名

构建完成后，可以验证应用是否已正确签名：

```bash
codesign -vvv --deep --strict /Applications/你的应用.app
```

## 注意事项

1. 证书有效期：Apple Developer ID 证书有效期为 1 年
2. 公证：为了更好的兼容性，可以考虑对应用进行公证
3. Team ID 必须正确填写，否则签名会失败