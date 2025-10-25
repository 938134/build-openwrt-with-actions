#!/bin/bash

set -e

echo "=== 开始自定义配置 ==="

# 基础配置
echo "📝 配置基础设置..."
sed -i 's/192.168.1.1/192.168.9.1/g' package/base-files/files/bin/config_generate
echo "✅ LAN IP 修改为 192.168.9.1"

# 更新 feeds（必须在操作 feeds 文件前）
echo "📚 更新软件源..."
./scripts/feeds update -a
./scripts/feeds install -a

# 配置主题（必须在 feeds 更新后）
echo "🎨 配置主题..."
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
echo "✅ 主题修改为 argon"

echo "🎉 基础配置完成！"