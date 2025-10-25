#!/bin/bash

set -e

echo "=== 开始自定义配置 ==="
echo "工作目录: $(pwd)"

# 基础配置
echo "📝 配置基础设置..."

# 修改 LAN IP
if [ -f "package/base-files/files/bin/config_generate" ]; then
    sed -i 's/192.168.1.1/192.168.9.1/g' package/base-files/files/bin/config_generate
    echo "✅ LAN IP 修改为 192.168.9.1"
else
    echo "⚠️  config_generate 文件不存在"
fi

# 检查 AC2 文件是否复制成功
echo "🔍 检查 AC2 文件..."
if [ -f "target/linux/mediatek/dts/mt7981b-beeconmini-seed-ac2.dts" ]; then
    echo "✅ AC2 设备树文件就绪"
else
    echo "❌ AC2 设备树文件缺失"
fi

if [ -d "package/kernel/rtl8373" ]; then
    echo "✅ RTL8373 驱动就绪"
else
    echo "❌ RTL8373 驱动缺失"
fi

# 更新 feeds（必须在操作 feeds 文件前）
echo "📚 更新软件源..."
./scripts/feeds update -a
./scripts/feeds install -a

# 配置主题（必须在 feeds 更新后）
echo "🎨 配置主题..."
if [ -f "feeds/luci/collections/luci/Makefile" ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
    echo "✅ 主题修改为 argon"
else
    echo "⚠️  主题文件不存在"
fi

# 验证最终配置
echo "🔍 验证配置..."
if [ -f ".config" ]; then
    echo "✅ 找到 .config 文件"
    
    # 检查设备选择
    if grep -q "CONFIG_TARGET_mediatek_filogic=y" .config; then
        echo "✅ 已选择 MediaTek Filogic 平台"
    fi
    
    if grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_beeconmini_seed-ac2=y" .config; then
        echo "✅ 已选择 BeeconMini SEED AC2 设备"
    else
        echo "⚠️  未选择 BeeconMini SEED AC2 设备"
    fi
else
    echo "❌ 未找到 .config 文件"
    exit 1
fi

echo "🎉 所有配置完成！开始编译..."