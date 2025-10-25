#!/bin/bash

set -e

echo "🎯 执行后期配置..."

# 配置主题
configure_theme() {
    echo "🎨 配置主题..."
    
    local theme_files=(
        "feeds/luci/collections/luci/Makefile"
        "feeds/luci/collections/luci-nginx/Makefile"
        "feeds/luci/collections/luci-ssl/Makefile"
    )
    
    for file in "${theme_files[@]}"; do
        if [ -f "$file" ]; then
            if sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$file"; then
                echo "✅ 修改主题: $file"
            fi
        else
            echo "⚠️  文件不存在: $file"
        fi
    done
}

# 验证配置
validate_config() {
    echo "🔍 验证配置..."
    
    if [ -f ".config" ]; then
        echo "✅ 找到 .config 文件"
        # 检查是否选择了正确的设备
        if grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_beeconmini_seed-ac2=y" .config; then
            echo "✅ 已选择 BeeconMini SEED AC2 设备"
        else
            echo "⚠️  未选择 BeeconMini SEED AC2 设备"
        fi
    else
        echo "❌ 未找到 .config 文件"
        return 1
    fi
}

main() {
    configure_theme
    validate_config
    echo "🎉 后期配置完成!"
}

main "$@"