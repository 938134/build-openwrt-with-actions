#!/bin/bash

set -e

# 添加额外的软件包，echo 方式和git clone 方式二选一即可
#echo 'src-git kenzok8 https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
#echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default
#echo 'src-git UA3F https://github.com/SunBK201/UA3F.git' >>feeds.conf.default
#git clone https://github.com/kenzok8/openwrt-packages.git package/openwrt-packages
#git clone https://github.com/kenzok8/small.git package/small
#git clone https://github.com/SunBK201/UA3F.git package/UA3F
# 更新 feeds（必须在操作 feeds 文件前）
# 🎯 关键步骤：添加和配置 iStore
echo "📚 添加 iStore 软件源..."
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default

echo "📚 更新所有软件源..."
./scripts/feeds update -a

echo "📚 安装所有软件包..."
./scripts/feeds install -a

echo "📚 确保 iStore 应用商店已安装..."
./scripts/feeds install -d y -p istore luci-app-store

echo "=== 开始自定义配置 ==="
# 基础配置
sed -i 's/192.168.1.1/192.168.9.1/g' package/base-files/files/bin/config_generate
# 编辑默认的主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
# 编辑默认的luci显示的固件名称
#sed -i 's/OpenWrt/ZWRT/g' package/base-files/files/bin/config_generate
#sed -i 's/ImmortalWrt/ZWRT/g' package/base-files/files/bin/config_generate
# 应用 AC2 设备支持补丁
echo "🔧 应用 BeeconMini SEED AC2 设备支持补丁..."
if [ -d "../beeconmini-seed-ac2/patches" ]; then
    for patch in ../beeconmini-seed-ac2/patches/*.patch; do
        if [ -f "$patch" ]; then
            echo "应用补丁: $(basename "$patch")"
            # 使用 --forward 选项，如果补丁已应用则忽略，不视为错误
            if patch -p1 --forward --no-backup-if-mismatch --fuzz=10 < "$patch" 2>/dev/null; then
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

echo "🎉 基础配置完成！"
