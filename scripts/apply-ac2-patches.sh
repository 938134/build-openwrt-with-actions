#!/bin/bash

set -e

echo "=== 开始 apply-ac2-patches.sh ==="
echo "当前目录: $(pwd)"

# 检查设备目录
if [ ! -d "beeconmini-seed-ac2" ]; then
    echo "❌ beeconmini-seed-ac2 目录不存在"
    echo "当前目录内容:"
    ls -la
    exit 1
fi

echo "✅ 找到设备目录"

# 复制驱动
echo "📦 安装 RTL8373 驱动..."
if [ -d "beeconmini-seed-ac2/rtl8373" ]; then
    mkdir -p package/kernel/rtl8373
    cp -r beeconmini-seed-ac2/rtl8373/* package/kernel/rtl8373/
    echo "✅ RTL8373 驱动复制完成"
else
    echo "❌ RTL8373 驱动目录不存在"
fi

# 复制设备树
echo "📄 安装设备树文件..."
if [ -f "beeconmini-seed-ac2/dts/mt7981b-beeconmini-seed-ac2.dts" ]; then
    mkdir -p target/linux/mediatek/dts
    cp beeconmini-seed-ac2/dts/mt7981b-beeconmini-seed-ac2.dts target/linux/mediatek/dts/
    echo "✅ 设备树文件复制完成"
else
    echo "❌ 设备树文件不存在"
fi

# 应用网络配置补丁
echo "🌐 配置网络设置..."
NETWORK_FILE="target/linux/mediatek/filogic/base-files/etc/board.d/02_network"
if [ -f "$NETWORK_FILE" ]; then
    if ! grep -q "beeconmini,seed-ac2" "$NETWORK_FILE"; then
        # 添加接口配置
        sed -i '/zyxel,ex5601-t0-ubootmod)/a\
\tbeeconmini,seed-ac2)\
\t\tucidef_set_interfaces_lan_wan eth0 eth1\
\t\t;;' "$NETWORK_FILE"
        
        # 添加 MAC 地址配置
        sed -i '/yuncore,ax835)/a\
\tbeeconmini,seed-ac2)\
\t\tlan_mac=$(mtd_get_mac_binary "art" 0x0)\
\t\twan_mac=$(macaddr_add "$lan_mac" 1)\
\t\t;;' "$NETWORK_FILE"
        
        echo "✅ 网络配置更新完成"
    else
        echo "✅ 网络配置已存在"
    fi
else
    echo "⚠️  网络配置文件不存在: $NETWORK_FILE"
fi

# 应用升级脚本补丁
echo "🔄 配置升级脚本..."
UPGRADE_FILE="target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh"
if [ -f "$UPGRADE_FILE" ]; then
    if ! grep -q "beeconmini,seed-ac2" "$UPGRADE_FILE"; then
        # 添加升级支持
        sed -i '/case "$board" in/a\
\tbeeconmini,seed-ac2)\
\t\tCI_KERNPART="kernel"\
\t\tCI_ROOTPART="rootfs"\
\t\tCI_DATAPART="rootfs_data"\
\t\temmc_do_upgrade "$1"\
\t\t;;' "$UPGRADE_FILE"
        
        # 添加配置备份支持
        sed -i '/case "$board" in/a\
\tbeeconmini,seed-ac2|\\' "$UPGRADE_FILE"
        
        echo "✅ 升级脚本更新完成"
    else
        echo "✅ 升级配置已存在"
    fi
else
    echo "⚠️  升级文件不存在: $UPGRADE_FILE"
fi

# 应用设备定义补丁
echo "📋 添加设备定义..."
IMAGE_FILE="target/linux/mediatek/image/filogic.mk"
if [ -f "$IMAGE_FILE" ]; then
    if ! grep -q "beeconmini_seed-ac2" "$IMAGE_FILE"; then
        sed -i '/TARGET_DEVICES += bananapi_bpi-r3/a\
\
define Device/beeconmini_seed-ac2\
  DEVICE_VENDOR := BeeconMini\
  DEVICE_MODEL := SEED AC2\
  DEVICE_DTS := mt7981b-beeconmini-seed-ac2\
  DEVICE_DTS_DIR := ../dts\
  DEVICE_PACKAGES := kmod-fs-f2fs kmod-fs-ext4 mkf2fs e2fsprogs kmod-switch-rtl8373 kmod-mt7981-firmware mt7981-wo-firmware\
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata\
endef\
TARGET_DEVICES += beeconmini_seed-ac2' "$IMAGE_FILE"
        
        echo "✅ 设备定义添加完成"
    else
        echo "✅ 设备定义已存在"
    fi
else
    echo "⚠️  设备定义文件不存在: $IMAGE_FILE"
fi

echo "=== apply-ac2-patches.sh 完成 ==="