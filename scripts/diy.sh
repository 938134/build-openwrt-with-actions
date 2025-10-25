#!/bin/bash

set -e

echo "🚀 开始自定义配置..."

# 基础配置
configure_basic() {
    echo "📝 配置基础设置..."
    
    # 修改 LAN IP
    if [ -f "package/base-files/files/bin/config_generate" ]; then
        sed -i 's/192.168.1.1/192.168.9.1/g' package/base-files/files/bin/config_generate
        echo "✅ LAN IP 修改为 192.168.9.1"
    fi
    
    # 添加第三方软件源
    #echo 'src-git UA3F https://github.com/SunBK201/UA3F.git' >> feeds.conf.default
    #echo "✅ 添加 UA3F 软件源"
}

# 安装第三方插件
#install_plugins() {
    #echo "📦 安装第三方插件..."
    
    # AdGuardHome
    #if [ ! -d "package/ADGH" ]; then
    #    git clone -q https://github.com/stevenjoezhang/luci-app-adguardhome.git package/ADGH
    #    echo "✅ 安装 AdGuardHome"
    #fi
#}

# 应用设备补丁
apply_device_patches() {
    echo "🔧 应用设备补丁..."
    
    if [ -f "scripts/apply-ac2-patches.sh" ]; then
        chmod +x scripts/apply-ac2-patches.sh
        ./scripts/apply-ac2-patches.sh
    else
        echo "⚠️  未找到设备补丁脚本"
    fi
}

main() {
    echo "📁 工作目录: $(pwd)"
    echo "📊 磁盘空间:"
    df -h .
    
    configure_basic
    install_plugins
    apply_device_patches
    
    echo "🎉 自定义配置完成!"
}

main "$@"