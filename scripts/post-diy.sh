#!/bin/bash

set -e

echo "=== 开始 post-diy.sh ==="

# 配置主题
echo "🎨 配置主题..."
if [ -f "feeds/luci/collections/luci/Makefile" ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
    echo "✅ 主题修改完成: bootstrap -> argon"
else
    echo "⚠️  feeds/luci/collections/luci/Makefile 不存在"
fi

echo "=== post-diy.sh 完成 ==="