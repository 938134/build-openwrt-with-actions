#!/bin/bash

set -e

echo "Applying BeeconMini SEED AC2 patches..."

# 检查必要文件是否存在
check_file() {
    if [ ! -f "$1" ]; then
        echo "Error: File $1 not found!"
        return 1
    fi
    return 0
}

# 1. 复制 rtl8373 驱动
echo "Copying RTL8373 driver..."
mkdir -p package/kernel/rtl8373
cp ac2/rtl8373/Makefile package/kernel/rtl8373/
cp -r ac2/rtl8373/src package/kernel/rtl8373/

# 2. 复制设备树文件
echo "Copying device tree..."
cp ac2/dts/mt7981b-beeconmini-seed-ac2.dts target/linux/mediatek/dts/

# 3. 修改网络配置
NETWORK_FILE="target/linux/mediatek/filogic/base-files/etc/board.d/02_network"
if check_file "$NETWORK_FILE"; then
    echo "Modifying network configuration..."
    
    # 检查是否已经添加过
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
        
        echo "Network configuration updated"
    else
        echo "Network configuration already exists, skipping"
    fi
fi

# 4. 修改升级脚本
UPGRADE_FILE="target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh"
if check_file "$UPGRADE_FILE"; then
    echo "Modifying upgrade script..."
    
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
        
        echo "Upgrade script updated"
    else
        echo "Upgrade configuration already exists, skipping"
    fi
fi

# 5. 修改设备定义
IMAGE_FILE="target/linux/mediatek/image/filogic.mk"
if check_file "$IMAGE_FILE"; then
    echo "Modifying device definition..."
    
    if ! grep -q "beeconmini_seed-ac2" "$IMAGE_FILE"; then
        # 添加设备定义
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
        
        echo "Device definition updated"
    else
        echo "Device definition already exists, skipping"
    fi
fi

echo "All patches applied successfully!"