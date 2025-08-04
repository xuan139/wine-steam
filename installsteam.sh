#!/bin/bash

# 脚本：在 macOS 上通过 Wine 安装并运行 Steam

# 定义目标目录和 Wine 前缀
TARGET_DIR="/Volumes/Windows/System/Steam"
export WINEPREFIX="/Volumes/Windows/System/Steam"

# 检查 Wine 是否已安装
if ! command -v wine &>/dev/null; then
    echo "错误：Wine 未安装，尝试调用 Wine 安装脚本..."
    # 指定要调用的 Wine 安装脚本路径（请根据实际路径修改）
    WINE_INSTALL_SCRIPT="$HOME/install_wine.sh"
    if [ -f "$WINE_INSTALL_SCRIPT" ]; then
        echo "运行 Wine 安装脚本：$WINE_INSTALL_SCRIPT"
        bash "$WINE_INSTALL_SCRIPT"
        if [ $? -ne 0 ]; then
            echo "错误：Wine 安装脚本执行失败，请手动安装 Wine 稳定版"
            exit 1
        fi
        # 再次检查 Wine 是否安装成功
        if ! command -v wine &>/dev/null; then
            echo "错误：Wine 安装后仍未找到，请检查安装脚本"
            exit 1
        fi
    else
        echo "错误：Wine 安装脚本 $WINE_INSTALL_SCRIPT 不存在，请手动安装 Wine 稳定版"
        exit 1
    fi
else
    echo "Wine 已安装，版本：$(wine --version)"
fi

# 检查目标目录是否已存在
if [ -d "$TARGET_DIR" ]; then
    echo "目录 $TARGET_DIR 已存在，无需创建"
else
    echo "目录 $TARGET_DIR 不存在，正在创建..."
    mkdir -p "$TARGET_DIR"
    if [ $? -eq 0 ]; then
        echo "目录 $TARGET_DIR 创建成功"
    else
        echo "错误：创建目录 $TARGET_DIR 失败，请检查权限或路径"
        exit 1
    fi
fi

# 初始化 Wine 前缀
echo "初始化 Wine 前缀 $WINEPREFIX ..."
wineboot --init
if [ $? -ne 0 ]; then
    echo "错误：Wine 前缀初始化失败，请检查 Wine 配置"
    exit 1
fi

# 切换到目标目录
cd "$TARGET_DIR" || { echo "错误：无法切换到 $TARGET_DIR"; exit 1; }

# 下载 Steam 安装程序
echo "下载 SteamSetup.exe ..."
curl -o SteamSetup.exe https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe
if [ $? -ne 0 ]; then
    echo "错误：下载 SteamSetup.exe 失败，请检查网络连接"
    exit 1
fi

# 安装 Steam
echo "运行 SteamSetup.exe ..."
wine SteamSetup.exe
if [ $? -ne 0 ]; then
    echo "错误：Steam 安装失败，请检查 Wine 或安装文件"
    exit 1
fi

# 检查 Steam.exe 是否存在
STEAM_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Steam/Steam.exe"
echo "检查 Steam 安装文件：$STEAM_EXE"
ls -l "$STEAM_EXE"
if [ ! -f "$STEAM_EXE" ]; then
    echo "错误：Steam.exe 未找到，安装可能失败"
    exit 1
fi

# 运行 Steam
echo "启动 Steam ..."
wine "$STEAM_EXE" -no-cef-sandbox -console
if [ $? -ne 0 ]; then
    echo "错误：Steam 启动失败，请检查 Wine 配置或 DXVK 设置"
    exit 1
fi

echo "Steam 安装并启动完成！"