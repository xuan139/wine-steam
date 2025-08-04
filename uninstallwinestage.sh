#!/bin/bash

# 脚本：在 macOS 上卸载 Wine Staging 并清理残留文件，验证删除

# 检查当前 Wine 版本
echo "检查当前 Wine 版本..."
if command -v wine &>/dev/null; then
    WINE_VERSION=$(wine --version)
    echo "当前 Wine 版本：$WINE_VERSION"
    if [[ "$WINE_VERSION" != *"Staging"* ]]; then
        echo "警告：当前安装的 Wine 不是 Staging 版本，可能无需卸载"
    fi
else
    echo "未找到 Wine 命令，可能尚未安装 Wine 或已卸载"
fi

# 检查 Homebrew 是否安装
if ! command -v brew &>/dev/null; then
    echo "Homebrew 未安装，跳过 Homebrew 卸载，检查 WineHQ .pkg 安装..."
else
    echo "Homebrew 已安装，检查 wine-staging 是否通过 Homebrew 安装..."
    if brew list wine@staging &>/dev/null; then
        echo "找到 Homebrew 安装的 wine@staging，正在卸载..."
        brew uninstall wine@staging
        if [ $? -eq 0 ]; then
            echo "wine@staging 已通过 Homebrew 卸载"
        else
            echo "错误：wine@staging 卸载失败，请检查 Homebrew 状态"
            exit 1
        fi
    else
        echo "未找到通过 Homebrew 安装的 wine@staging，可能通过 WineHQ .pkg 或其他方式安装"
    fi

    # 检查并卸载 winetricks
    if brew list winetricks &>/dev/null; then
        echo "找到 Homebrew 安装的 winetricks，正在卸载..."
        brew uninstall winetricks
        if [ $? -eq 0 ]; then
            echo "winetricks 已通过 Homebrew 卸载"
        else
            echo "错误：winetricks 卸载失败，请检查 Homebrew 状态"
            exit 1
        fi
    else
        echo "未找到通过 Homebrew 安装的 winetricks"
    fi

    # 清理 Homebrew 缓存和依赖
    echo "清理 Homebrew 缓存和依赖..."
    brew autoremove
    brew cleanup

    # 移除 gcenx/wine 仓库（包含 wine-crossover 等）
    if brew tap | grep -q "gcenx/wine"; then
        echo "找到 gcenx/wine 仓库，正在移除..."
        brew untap gcenx/wine
        if [ $? -eq 0 ]; then
            echo "gcenx/wine 仓库已移除"
        else
            echo "错误：移除 gcenx/wine 仓库失败"
            exit 1
        fi
    fi
fi

# 检查 WineHQ .pkg 安装的 Wine Staging
if [ -d "/Applications/Wine Staging.app" ]; then
    echo "找到 /Applications/Wine Staging.app，正在删除..."
    sudo rm -rf "/Applications/Wine Staging.app"
    if [ $? -eq 0 ]; then
        echo "Wine Staging 应用程序删除成功"
    else
        echo "错误：删除 Wine Staging 应用程序失败，请检查权限"
        exit 1
    fi
else
    echo "未找到 /Applications/Wine Staging.app"
fi

# 删除 Wine 命令行工具和库
echo "删除 Wine 命令行工具和库..."
sudo rm -rf /usr/local/bin/wine* 2>/dev/null
sudo rm -rf /usr/local/lib/wine 2>/dev/null
sudo rm -rf /usr/local/share/wine 2>/dev/null
sudo rm -rf /opt/local/bin/wine* 2>/dev/null
sudo rm -rf /opt/local/lib/wine 2>/dev/null
sudo rm -rf /opt/homebrew/bin/wine* 2>/dev/null
sudo rm -rf /opt/homebrew/lib/wine 2>/dev/null

# 删除特定残留文件和目录（基于警告输出）
echo "删除残留的 Wine 相关文件和目录..."
sudo rm -rf /opt/homebrew/var/homebrew/linked/winetricks 2>/dev/null
sudo rm -rf /opt/homebrew/Library/Taps/gcenx 2>/dev/null
sudo rm -rf /opt/homebrew/Caskroom/wine@staging 2>/dev/null
sudo rm -rf /opt/homebrew/opt/winetricks 2>/dev/null
sudo rm -rf /opt/homebrew/Cellar/winetricks 2>/dev/null
sudo rm -rf /opt/homebrew/share/man/man1/winetricks.1 2>/dev/null
# mingw-w64 的 wine 相关头文件需要单独处理，避免影响其他工具
echo "注意：保留 /opt/homebrew/Cellar/mingw-w64/.../wine*.h 文件，因为它们属于 mingw-w64 工具链"
# 如果确定需要删除 mingw-w64 的 wine 头文件，取消以下注释
# sudo rm -rf /opt/homebrew/Cellar/mingw-w64/13.0.0/toolchain-i686/i686-w64-mingw32/include/wine*.h 2>/dev/null
# sudo rm -rf /opt/homebrew/Cellar/mingw-w64/13.0.0/toolchain-x86_64/x86_64-w64-mingw32/include/wine*.h 2>/dev/null

# 删除 Wine 用户配置文件
echo "删除 Wine 用户配置文件..."
rm -rf ~/.wine 2>/dev/null
rm -rf ~/Library/Application\ Support/Wine 2>/dev/null
rm -rf ~/Applications/Wine\ Staging.app 2>/dev/null
rm -rf /Volumes/Windows/System/Steam 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Wine 用户配置文件删除成功"
else
    echo "警告：删除 Wine 用户配置文件时可能遇到问题，请手动检查"
fi

# 验证步骤
echo "开始验证 Wine Staging 是否完全卸载..."

# 1. 检查 wine 命令是否可用
echo "验证 1：检查 wine 命令..."
if command -v wine &>/dev/null; then
    echo "错误：wine 命令仍存在，版本：$(wine --version)"
    echo "请检查以下路径：/usr/local/bin, /opt/local/bin, /opt/homebrew/bin"
    exit 1
else
    echo "成功：wine 命令已移除"
fi

# 2. 检查 Wine 相关文件
echo "验证 2：检查 Wine 相关文件..."
WINE_FILES=$(find /usr/local /opt/local /opt/homebrew -name "wine*" -not -path "*/mingw-w64/*" 2>/dev/null)
if [ -n "$WINE_FILES" ]; then
    echo "警告：找到以下 Wine 相关文件："
    echo "$WINE_FILES"
    echo "请手动删除以上文件或运行：sudo rm -rf <path>"
    exit 1
else
    echo "成功：未找到 Wine 相关文件（已排除 mingw-w64 头文件）"
fi

# 3. 检查 Wine Staging 应用程序
echo "验证 3：检查 /Applications/Wine Staging.app..."
if [ -d "/Applications/Wine Staging.app" ]; then
    echo "错误：/Applications/Wine Staging.app 仍存在"
    echo "请手动删除：sudo rm -rf /Applications/Wine\\ Staging.app"
    exit 1
else
    echo "成功：/Applications/Wine Staging.app 已移除"
fi

# 4. 检查 Wine 用户配置文件
echo "验证 4：检查 Wine 用户配置文件..."
if [ -d ~/.wine ] || [ -d ~/Library/Application\ Support/Wine ] || [ -d /Volumes/Windows/System/Steam ]; then
    echo "错误：找到以下 Wine 用户配置文件："
    [ -d ~/.wine ] && echo "~/.wine"
    [ -d ~/Library/Application\ Support/Wine ] && echo "~/Library/Application Support/Wine"
    [ -d /Volumes/Windows/System/Steam ] && echo "/Volumes/Windows/System/Steam"
    echo "请手动删除：rm -rf <path>"
    exit 1
else
    echo "成功：Wine 用户配置文件已移除"
fi

# 5. 检查 Wine 进程
echo "验证 5：检查 Wine 相关进程..."
if pgrep -f "wine" >/dev/null; then
    echo "错误：发现运行中的 Wine 进程："
    ps aux | grep -i wine | grep -v grep
    echo "请终止进程：killall wineserver; killall wine"
    exit 1
else
    echo "成功：未找到运行中的 Wine 进程"
fi

echo "Wine Staging 已完全卸载！"