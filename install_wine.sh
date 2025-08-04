#!/bin/bash

# 脚本：在 macOS 上安装 Wine 稳定版

# 检查 Homebrew 是否已安装
if ! command -v brew &>/dev/null; then
    echo "错误：Homebrew 未安装，请先安装 Homebrew"
    exit 1
fi

# 尝试安装 wine@stable
echo "尝试安装 wine@stable..."
brew install --cask --no-quarantine wine@stable
if [ $? -ne 0 ]; then
    echo "警告：wine@stable 不可用，尝试安装 wine-stable..."
    brew install --cask --no-quarantine wine-stable
    if [ $? -ne 0 ]; then
        echo "错误：wine-stable 安装失败，请检查 Homebrew 或网络连接"
        exit 1
    fi
fi

# 验证 Wine 安装
echo "验证 Wine 安装..."
if command -v wine &>/dev/null; then
    echo "Wine 安装成功，版本：$(wine --version)"
else
    echo "错误：Wine 未正确安装，请检查 /Applications/Wine Stable.app"
    exit 1
fi

echo "Wine 稳定版安装完成！"