#!/bin/bash

# 测试 hosts 配置功能
echo "测试 macOS hosts 配置功能..."

# 检查当前 hosts 文件中是否已存在测试配置
if grep -q "47.104.218.212 zdxy.ai.qianlima.com" /etc/hosts; then
    echo "⚠️  测试配置已存在于 hosts 文件中"
    echo "📋 当前相关配置:"
    grep "47.104.218.212 zdxy.ai.qianlima.com" /etc/hosts
else
    echo "✅ 测试配置不存在于 hosts 文件中"
fi

echo ""
echo "🔧 现在可以测试应用中的 hosts 配置功能"
echo "📍 应用运行在: http://localhost:1420/"
echo ""
echo "测试步骤:"
echo "1. 选择 'AI_zdxy' 配置"
echo "2. 点击 '应用配置并启动WPS'"
echo "3. 观察是否弹出管理员权限请求"
echo "4. 检查配置是否成功添加到 /etc/hosts"