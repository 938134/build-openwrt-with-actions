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
            if patch -p1 --forward --no-backup-if-mismatch < "$patch" 2>/dev/null; then
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

# 生成默认配置
echo "⚙️ 生成默认配置..."
make defconfig

# 应用 AC2 配置
echo "🔧 应用 AC2 设备配置..."
if [ -f "../beeconmini-seed-ac2/config.ac2" ]; then
    cat ../beeconmini-seed-ac2/config.ac2 >> .config
    echo "✅ AC2 配置已添加"
    # 重新生成配置以确保一致性
    make defconfig
else
    echo "❌ config.ac2 文件不存在于 ../beeconmini-seed-ac2/"
    echo "当前目录结构:"
    ls -la ../beeconmini-seed-ac2/
    exit 1
fi

# 确保设备配置正确
echo "🔧 检查设备配置..."
if grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_beeconmini_seed-ac2=y" .config; then
    echo "✅ AC2 设备配置正确"
else
    echo "❌ AC2 设备配置缺失"
    echo "当前配置中相关的 AC2 配置:"
    grep -i "beeconmini\|ac2" .config || echo "未找到相关配置"
    exit 1
fi

echo "🎉 基础配置完成！"