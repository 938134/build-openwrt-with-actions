#!/bin/bash

set -e

echo "🔧 应用 BeeconMini SEED AC2 补丁..."

# 工具函数
check_path() {
    if [ ! -e "$1" ]; then
        echo "❌ 路径不存在: $1"
        return 1
    fi
    return 0
}

# 复制驱动
copy_driver() {
    echo "📦 安装 RTL8373 驱动..."
    
    local driver_src="beeconmini-seed-ac2/rtl8373"
    local driver_dst="package/kernel/rtl8373"
    
    if check_path "$driver_src"; then
        mkdir -p "$driver_dst"
        cp -r "$driver_src"/* "$driver_dst"/
        echo "✅ RTL8373 驱动安装完成"
    else
        echo "❌ RTL8373 驱动源目录不存在: $driver_src"
    fi
}

# 复制设备树
copy_dts() {
    echo "📄 安装设备树文件..."
    
    local dts_src="beeconmini-seed-ac2/dts/mt7981b-beeconmini-seed-ac2.dts"
    local dts_dst="target/linux/mediatek/dts"
    
    if check_path "$dts_src"; then
        mkdir -p "$dts_dst"
        cp "$dts_src" "$dts_dst"/
        echo "✅ 设备树文件安装完成"
    else
        echo "❌ 设备树文件不存在: $dts_src"
    fi
}

# 应用网络配置补丁
apply_network_patch() {
    echo "🌐 配置网络设置..."
    
    local network_file="target/linux/mediatek/filogic/base-files/etc/board.d/02_network"
    
    if [ -f "$network_file" ]; then
        # 添加接口配置
        if ! grep -q "beeconmini,seed-ac2" "$network_file"; then
            sed -i '/zyxel,ex5601-t0-ubootmod)/a\
\tbeeconmini,seed-ac2)\
\t\tucidef_set_interfaces_lan_wan eth0 eth1\
\t\t;;' "$network_file"
            
            # 添加 MAC 地址配置
            sed -i '/yuncore,ax835)/a\
\tbeeconmini,seed-ac2)\
\t\tlan_mac=$(mtd_get_mac_binary "art" 0x0)\
\t\twan_mac=$(macaddr_add "$lan_mac" 1)\
\t\t;;' "$network_file"
            
            echo "✅ 网络配置更新完成"
        else
            echo "✅ 网络配置已存在"
        fi
    else
        echo "⚠️  网络配置文件不存在: $network_file"
    fi
}

# 应用升级脚本补丁
apply_upgrade_patch() {
    echo "🔄 配置升级脚本..."
    
    local upgrade_file="target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh"
    
    if [ -f "$upgrade_file" ]; then
        if ! grep -q "beeconmini,seed-ac2" "$upgrade_file"; then
            # 添加升级支持
            sed -i '/case "$board" in/a\
\tbeeconmini,seed-ac2)\
\t\tCI_KERNPART="kernel"\
\t\tCI_ROOTPART="rootfs"\
\t\tCI_DATAPART="rootfs_data"\
\t\temmc_do_upgrade "$1"\
\t\t;;' "$upgrade_file"
            
            # 添加配置备份支持
            sed -i '/case "$board" in/a\
\tbeeconmini,seed-ac2|\\' "$upgrade_file"
            
            echo "✅ 升级脚本更新完成"
        else
            echo "✅ 升级配置已存在"
        fi
    else
        echo "⚠️  升级文件不存在: $upgrade_file"
    fi
}

# 应用设备定义补丁
apply_device_definition() {
    echo "📋 添加设备定义..."
    
    local image_file="target/linux/mediatek/image/filogic.mk"
    
    if [ -f "$image_file" ]; then
        if ! grep -q "beeconmini_seed-ac2" "$image_file"; then
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
TARGET_DEVICES += beeconmini_seed-ac2' "$image_file"
            
            echo "✅ 设备定义添加完成"
        else
            echo "✅ 设备定义已存在"
        fi
    else
        echo "⚠️  设备定义文件不存在: $image_file"
    fi
}

main() {
    echo "📁 当前目录: $(pwd)"
    
    copy_driver
    copy_dts
    apply_network_patch
    apply_upgrade_patch
    apply_device_definition
    
    echo "🎉 SEED AC2 补丁应用完成!"
}

main "$@"