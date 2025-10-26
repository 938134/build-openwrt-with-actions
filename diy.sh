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

# 应用 AC2 设备支持补丁
echo "🔧 应用 BeeconMini SEED AC2 设备支持补丁..."
if [ -d "../beeconmini-seed-ac2/patches" ]; then
    for patch in ../beeconmini-seed-ac2/patches/*.patch; do
        if [ -f "$patch" ]; then
            echo "应用补丁: $(basename "$patch")"
            # 使用 --forward 选项，如果补丁已应用则忽略，不视为错误
            if patch -p1 --forward < "$patch" 2>/dev/null; then
                echo "✅ $(basename "$patch") 应用成功"
            else
                echo "⚠️  $(basename "$patch") 可能已应用或存在冲突，继续执行"
            fi
        fi
    done
    echo "✅ AC2 设备支持补丁应用完成"
else
    echo "❌ 补丁目录不存在: ../beeconmini-seed-ac2/patches"
    exit 1
fi

# 配置主题（必须在 feeds 更新后）
echo "🎨 配置主题..."
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
echo "✅ 主题修改为 argon"

# 确保设备配置正确
echo "🔧 检查设备配置..."
if grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_beeconmini_seed-ac2=y" .config; then
    echo "✅ AC2 设备配置正确"
else
    echo "❌ AC2 设备配置缺失，请检查 config.ac2"
    exit 1
fi

echo "🎉 基础配置完成！"