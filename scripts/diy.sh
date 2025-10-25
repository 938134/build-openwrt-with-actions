#!/bin/bash

set -e

echo "=== 开始 diy.sh ==="
echo "当前目录: $(pwd)"
echo "目录内容:"
ls -la

# 基础配置
echo "📝 配置基础设置..."

# 修改 LAN IP
if [ -f "package/base-files/files/bin/config_generate" ]; then
    sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate
    echo "✅ LAN IP 修改为 192.168.1.2"
else
    echo "⚠️  package/base-files/files/bin/config_generate 文件不存在"
fi

# 添加第三方软件源
echo 'src-git UA3F https://github.com/SunBK201/UA3F.git' >> feeds.conf.default
echo "✅ 添加 UA3F 软件源"

# 安装 AdGuardHome
if [ ! -d "package/ADGH" ]; then
    echo "📦 安装 AdGuardHome..."
    git clone -q https://github.com/stevenjoezhang/luci-app-adguardhome.git package/ADGH
    echo "✅ AdGuardHome 安装完成"
else
    echo "✅ AdGuardHome 已存在"
fi

# 应用设备补丁
if [ -f "scripts/apply-ac2-patches.sh" ]; then
    echo "🔧 应用设备补丁..."
    chmod +x scripts/apply-ac2-patches.sh
    ./scripts/apply-ac2-patches.sh
else
    echo "❌ 设备补丁脚本不存在: scripts/apply-ac2-patches.sh"
    echo "当前 scripts 目录内容:"
    ls -la scripts/ || echo "scripts 目录不存在"
fi

echo "=== diy.sh 完成 ==="