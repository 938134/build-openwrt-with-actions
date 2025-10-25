# ImmortalWrt 自动编译 - BeeconMini SEED AC2

## 特性

- 🚀 基于 GitHub Actions 的自动编译
- 🔧 完整支持 BeeconMini SEED AC2 设备
- 📦 预配置常用插件和主题
- 📁 支持 files 大法保留配置

## 设备支持

### BeeconMini SEED AC2
- ✅ RTL8373 交换机驱动
- ✅ 完整设备树配置
- ✅ 网络和升级支持
- ✅ LED 和按键配置

## 使用方法

1. **Fork 本仓库**
2. **配置设备**：确保 `.config` 中选择正确的设备
3. **自定义配置**：在 `files/` 目录添加配置文件
4. **开始编译**：在 GitHub Actions 中启动工作流
5. **下载固件**：从 Artifacts 下载编译好的固件

## 文件说明

- `beeconmini-seed-ac2/` - AC2 专用文件（直接覆盖官方源码）
- `files/` - 自定义配置文件（files 大法）
- `diy.sh` - 自定义配置脚本
- `.config` - 编译配置文件

## 默认配置

- LAN IP: `192.168.1.2`
- 主题: `luci-theme-argon`
- 包含: AdGuardHome, UA3F 等插件

## 编译说明

项目使用直接文件覆盖的方式，将 AC2 专用文件替换官方文件，确保硬件支持完整。