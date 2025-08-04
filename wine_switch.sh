#!/bin/bash

# 脚本：卸载 Wine 10.6 (Staging) 并安装 Wine 稳定版 (macOS)

# 检查当前 Wine 版本
echo "检查当前 Wine 版本..."
wine --version

# 步骤 1：卸载 Wine Staging
echo "正在卸载 Wine 10.6 (Staging)..."
if brew list wine-staging &>/dev/null; then
    brew uninstall wine-staging
else
    echo "未找到通过 Homebrew 安装的 Wine Staging，可能需要手动卸载"
    # 如果通过 WineHQ .pkg 安装，删除应用程序和相关文件
    sudo rm -rf /Applications/Wine\ Staging.app
    sudo rm -rf /usr/local/bin/wine*
    sudo rm -rf /usr/local/lib/wine
    sudo rm -rf /usr/local/share/wine
fi

# 清理 Homebrew 缓存和依赖
echo "清理 Homebrew 缓存和依赖..."
brew autoremove
brew cleanup

# 删除 Wine 配置和残留文件
echo "删除 Wine 用户配置文件..."
rm -rf ~/.wine
rm -rf ~/Library/Application\ Support/Wine
rm -rf ~/Applications/Wine\ Staging.app

# 验证 Wine 已卸载
echo "验证 Wine 是否已卸载..."
if ! command -v wine &>/dev/null; then
    echo "Wine 已成功卸载"
else
    echo "Wine 未完全卸载，请检查"
    wine --version
    exit 1
fi

# 步骤 2：安装 Wine 稳定版
echo "安装 Wine 稳定版..."

# 确保 Homebrew 已安装
if ! command -v brew &>/dev/null; then
    echo "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 添加 Homebrew cask-versions 仓库
brew tap homebrew/cask-versions

# 安装 Wine 稳定版
brew install --cask wine-stable

# 验证安装
echo "验证 Wine 稳定版安装..."
wine --version

# 步骤 3：初始化 Wine 配置
echo "初始化 Wine 配置..."
winecfg

echo "Wine 稳定版安装完成！"

# chmod +x wine_switch.sh
# ./wine_switch.sh