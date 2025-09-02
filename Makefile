# AI赢标助手 WPS环境切换工具 - Tauri版本 Makefile

.PHONY: help install dev build build-release clean icons

# 默认目标
help:
	@echo "AI赢标助手 WPS环境切换工具 - Tauri版本"
	@echo ""
	@echo "可用命令："
	@echo "  make install      - 安装所有依赖"
	@echo "  make dev          - 启动开发模式"
	@echo "  make build        - 构建当前平台"
	@echo "  make build-release - 构建生产版本"
	@echo "  make clean        - 清理构建文件"
	@echo "  make icons        - 生成应用图标占位文件"
	@echo "  make check        - 检查环境依赖"

# 检查环境依赖
check:
	@echo "🔍 检查环境依赖..."
	@command -v node >/dev/null 2>&1 || { echo "❌ 未找到 Node.js"; exit 1; }
	@command -v npm >/dev/null 2>&1 || { echo "❌ 未找到 npm"; exit 1; }
	@command -v cargo >/dev/null 2>&1 || { echo "❌ 未找到 Rust/Cargo"; exit 1; }
	@echo "✅ 环境依赖检查通过"
	@echo "Node.js: $$(node --version)"
	@echo "npm: $$(npm --version)"
	@echo "Rust: $$(rustc --version)"

# 安装依赖
install: check
	@echo "📦 安装前端依赖..."
	npm install
	@echo "📦 安装Rust依赖..."
	cd src-tauri && cargo fetch
	@echo "✅ 依赖安装完成"

# 开发模式
dev: check
	@echo "🔧 启动开发模式..."
	npm run tauri:dev

# 构建当前平台
build: check
	@echo "🔨 构建当前平台..."
	npm run tauri:build
	@echo "✅ 构建完成！产物位置: dist/"

# 构建生产版本
build-release: check
	@echo "🔨 构建生产版本..."
	npm run build
	cd src-tauri && cargo build --release
	npm run tauri:build
	@echo "✅ 生产版本构建完成！"

# 清理构建文件
clean:
	@echo "🧹 清理构建文件..."
	npm run clean
	rm -rf node_modules/
	@echo "✅ 清理完成"

# 生成基础图标文件（占位）
icons:
	@echo "🎨 生成应用图标占位文件..."
	@mkdir -p src-tauri/icons
	@# 创建简单的占位图标（实际项目中需要替换为真正的图标）
	@touch src-tauri/icons/32x32.png
	@touch src-tauri/icons/128x128.png
	@touch src-tauri/icons/128x128@2x.png
	@touch src-tauri/icons/icon.icns
	@touch src-tauri/icons/icon.ico
	@echo "✅ 图标占位文件已创建，请替换为实际图标"

# 运行测试
test: check
	@echo "🧪 运行Rust测试..."
	cd src-tauri && cargo test
	@echo "✅ 测试完成"

# 检查代码格式
fmt:
	@echo "🎨 格式化代码..."
	npm run format || true
	cd src-tauri && cargo fmt
	@echo "✅ 代码格式化完成"

# 代码检查
lint:
	@echo "🔍 检查代码质量..."
	cd src-tauri && cargo clippy -- -D warnings
	@echo "✅ 代码检查完成"

# 查看构建产物
show-build:
	@echo "📁 构建产物："
	@find dist -name "*.app" -o -name "*.msi" 2>/dev/null || echo "未找到构建产物"

# 快速重建
rebuild: clean install build