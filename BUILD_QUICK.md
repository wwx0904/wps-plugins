# 快速构建指南

## Mac平台构建

```bash
# 进入项目目录
cd buildPkg/install-tauri

# 快速构建
npm run tauri:build

# 或使用构建脚本
./build-all.sh

# 查看产物
open src-tauri/target/release/bundle/macos/
```

## Windows平台构建

```cmd
# 在Windows机器上执行
cd buildPkg\install-tauri

# 快速构建
npm run tauri:build

# 查看产物
explorer src-tauri\target\release\bundle\msi\
```

## CI/CD构建

推送到GitHub会自动触发构建：
- Mac版本：`.app` 和 `.dmg`
- Windows版本：`.msi`

## 发布流程

1. 更新版本号：`src-tauri/tauri.conf.json` 中的 `version`
2. 提交代码：`git commit -m "release: v1.0.0"`
3. 推送到main分支：`git push origin main`
4. GitHub Actions自动构建并创建Release