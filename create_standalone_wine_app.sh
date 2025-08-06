#!/bin/bash

# 創建包含 Wine 的獨立應用程序包
# 這個版本會將 Wine 二進制文件複製到 app 內部

set -e

# 顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 應用程序設置
APP_NAME="Wine Steam DXVK Standalone"
APP_DIR="$HOME/Downloads/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
FRAMEWORKS_DIR="${CONTENTS_DIR}/Frameworks"
WINE_DIR="${CONTENTS_DIR}/Wine"
WINEPREFIX_DIR="${WINE_DIR}/prefix"

print_info "開始創建獨立的 ${APP_NAME}.app..."

# 檢查 Wine 是否安裝
if [ ! -d "/Applications/Wine Staging.app" ]; then
    print_error "未找到 Wine Staging.app"
    print_info "請先安裝 Wine Staging: brew install --cask wine@staging"
    exit 1
fi

# 創建應用程序目錄結構
print_info "創建應用程序目錄結構..."
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"
mkdir -p "${FRAMEWORKS_DIR}"
mkdir -p "${WINE_DIR}/bin"
mkdir -p "${WINEPREFIX_DIR}"

# 複製 Wine 二進制文件和資源
print_info "複製 Wine 程序文件（這可能需要幾分鐘）..."

# 複製 Wine 的核心文件
if [ -d "/Applications/Wine Staging.app/Contents/Resources/wine" ]; then
    cp -R "/Applications/Wine Staging.app/Contents/Resources/wine" "${WINE_DIR}/"
    print_info "已複製 Wine 資源文件"
else
    print_error "未找到 Wine 資源文件"
    exit 1
fi

# 複製 Wine 的執行文件
if [ -d "/Applications/Wine Staging.app/Contents/MacOS" ]; then
    cp -R "/Applications/Wine Staging.app/Contents/MacOS/"* "${WINE_DIR}/bin/" 2>/dev/null || true
fi

# 創建 Info.plist
print_info "創建 Info.plist..."
cat > "${CONTENTS_DIR}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>wine-steam</string>
    <key>CFBundleIdentifier</key>
    <string>com.wine.steam.dxvk.standalone</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Wine Steam DXVK Standalone</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.games</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSAppleScriptEnabled</key>
    <false/>
</dict>
</plist>
EOF

# 創建主啟動腳本
print_info "創建啟動腳本..."
cat > "${MACOS_DIR}/launcher" << 'EOF'
#!/bin/bash

# 獲取應用程序包的路徑
APP_PATH="$(cd "$(dirname "$0")/../.." && pwd)"
CONTENTS_PATH="$APP_PATH/Contents"
WINE_PATH="$CONTENTS_PATH/Wine"
WINEPREFIX="$CONTENTS_PATH/Wine/prefix"

# 設置環境變數
export WINEPREFIX
export PATH="$WINE_PATH/wine/bin:$PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$WINE_PATH/wine/lib:$DYLD_FALLBACK_LIBRARY_PATH"
export WINEDLLPATH="$WINE_PATH/wine/lib/wine"

# Wine 執行文件
WINE_EXE="$WINE_PATH/wine/bin/wine"

# 檢查 Wine 是否存在
if [ ! -f "$WINE_EXE" ]; then
    osascript -e 'display alert "Wine 組件缺失" message "應用程序包中的 Wine 組件不完整。請重新安裝應用程式。" as critical' 2>/dev/null || echo "Wine 組件缺失"
    exit 1
fi

# 初始化 Wine 前綴（如果不存在）
if [ ! -d "$WINEPREFIX/drive_c" ]; then
    osascript -e 'display notification "正在初始化 Wine 環境..." with title "Wine Steam DXVK"' 2>/dev/null || echo "正在初始化 Wine 環境..."
    "$WINE_EXE" wineboot --init
fi

# 檢查 Steam 是否已安裝
STEAM_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Steam/Steam.exe"
if [ ! -f "$STEAM_EXE" ]; then
    STEAM_EXE="$WINEPREFIX/drive_c/Program Files/Steam/Steam.exe"
fi

if [ ! -f "$STEAM_EXE" ]; then
    # Steam 未安裝，提示用戶
    RESPONSE=$(osascript -e 'display dialog "Steam 尚未安裝。是否要下載並安裝 Steam？" buttons {"取消", "安裝 Steam"} default button 2' 2>/dev/null || echo "button returned:取消")
    
    if [[ "$RESPONSE" == *"安裝 Steam"* ]]; then
        # 下載 Steam 安裝程序
        STEAM_INSTALLER="$HOME/Downloads/SteamSetup.exe"
        if [ ! -f "$STEAM_INSTALLER" ]; then
            osascript -e 'display notification "正在下載 Steam 安裝程序..." with title "Wine Steam DXVK"' 2>/dev/null || echo "正在下載 Steam..."
            curl -L -o "$STEAM_INSTALLER" "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"
        fi
        
        # 運行安裝程序
        if [ -f "$STEAM_INSTALLER" ]; then
            cd "$(dirname "$STEAM_INSTALLER")"
            "$WINE_EXE" "$STEAM_INSTALLER"
        fi
    else
        exit 0
    fi
else
    # 運行 Steam
    if [ -f "$STEAM_EXE" ]; then
        cd "$(dirname "$STEAM_EXE")"
        "$WINE_EXE" "$STEAM_EXE" "$@"
    fi
fi
EOF

chmod +x "${MACOS_DIR}/launcher"

# 創建 Wine 配置腳本
cat > "${MACOS_DIR}/wine-config" << 'EOF'
#!/bin/bash
APP_PATH="$(cd "$(dirname "$0")/../.." && pwd)"
CONTENTS_PATH="$APP_PATH/Contents"
export WINEPREFIX="$CONTENTS_PATH/Wine/prefix"
export PATH="$CONTENTS_PATH/Wine/wine/bin:$PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$CONTENTS_PATH/Wine/wine/lib:$DYLD_FALLBACK_LIBRARY_PATH"
export WINEDLLPATH="$CONTENTS_PATH/Wine/wine/lib/wine"

if [ -f "$CONTENTS_PATH/Wine/wine/bin/winecfg" ]; then
    "$CONTENTS_PATH/Wine/wine/bin/winecfg"
else
    echo "錯誤：找不到 winecfg"
    exit 1
fi
EOF

chmod +x "${MACOS_DIR}/wine-config"

# 複製現有的 Wine 前綴（如果存在）
if [ -d "$HOME/Wine/Steam" ]; then
    print_info "複製現有的 Wine 前綴..."
    cp -R "$HOME/Wine/Steam/"* "${WINEPREFIX_DIR}/" 2>/dev/null || true
fi

# 如果有 DXVK 文件，複製它們
if [ -d "$HOME/Downloads/dxvk-macOS-async-v1.10.3-20230507-repack" ]; then
    print_info "安裝 DXVK 文件..."
    DXVK_DIR="$HOME/Downloads/dxvk-macOS-async-v1.10.3-20230507-repack"
    
    # 創建 Windows 目錄（如果需要）
    mkdir -p "${WINEPREFIX_DIR}/drive_c/windows/system32"
    mkdir -p "${WINEPREFIX_DIR}/drive_c/windows/syswow64"
    
    # 複製 DLL 文件
    cp "$DXVK_DIR/x64/"*.dll "${WINEPREFIX_DIR}/drive_c/windows/system32/" 2>/dev/null || true
    cp "$DXVK_DIR/x32/"*.dll "${WINEPREFIX_DIR}/drive_c/windows/syswow64/" 2>/dev/null || true
    cp "$DXVK_DIR/dxvk.conf" "${WINEPREFIX_DIR}/" 2>/dev/null || true
fi

# 複製圖標
if [ -f "/Applications/Wine Staging.app/Contents/Resources/wine.icns" ]; then
    cp "/Applications/Wine Staging.app/Contents/Resources/wine.icns" "${RESOURCES_DIR}/wine-steam.icns"
fi

# 創建管理工具
print_info "創建管理工具..."
cat > "${APP_DIR}/管理工具.command" << 'EOF'
#!/bin/bash

cd "$(dirname "$0")"
APP_DIR="$(pwd)"
CONTENTS_PATH="$APP_DIR/Contents"
export WINEPREFIX="$CONTENTS_PATH/Wine/prefix"
export PATH="$CONTENTS_PATH/Wine/wine/bin:$PATH"
export DYLD_FALLBACK_LIBRARY_PATH="$CONTENTS_PATH/Wine/wine/lib:$DYLD_FALLBACK_LIBRARY_PATH"

WINE_EXE="$CONTENTS_PATH/Wine/wine/bin/wine"

echo "Wine Steam DXVK 獨立版管理工具"
echo "============================="
echo ""
echo "1. 運行 winecfg（Wine 配置）"
echo "2. 運行 winetricks"
echo "3. 安裝 Steam"
echo "4. 打開 Wine 前綴目錄"
echo "5. 配置 DXVK"
echo "6. 測試 Wine"
echo "7. 退出"
echo ""
read -p "請選擇操作 (1-7): " choice

case $choice in
    1)
        "$WINE_EXE" winecfg
        ;;
    2)
        if command -v winetricks >/dev/null 2>&1; then
            winetricks
        else
            echo "winetricks 未安裝，請使用 Homebrew 安裝：brew install winetricks"
        fi
        ;;
    3)
        STEAM_INSTALLER="$HOME/Downloads/SteamSetup.exe"
        if [ ! -f "$STEAM_INSTALLER" ]; then
            echo "下載 Steam 安裝程序..."
            curl -L -o "$STEAM_INSTALLER" "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"
        fi
        cd "$(dirname "$STEAM_INSTALLER")"
        "$WINE_EXE" "$STEAM_INSTALLER"
        ;;
    4)
        open "$WINEPREFIX"
        ;;
    5)
        if [ -f "$WINEPREFIX/dxvk.conf" ]; then
            open -e "$WINEPREFIX/dxvk.conf"
        else
            echo "創建 DXVK 配置文件..."
            echo "dxvk.hud = devinfo,fps" > "$WINEPREFIX/dxvk.conf"
            open -e "$WINEPREFIX/dxvk.conf"
        fi
        ;;
    6)
        "$WINE_EXE" notepad
        ;;
    7)
        exit 0
        ;;
    *)
        echo "無效的選擇"
        ;;
esac

echo ""
echo "按任意鍵退出..."
read -n 1
EOF

chmod +x "${APP_DIR}/管理工具.command"

# 創建 README
cat > "${APP_DIR}/README.txt" << EOF
Wine Steam DXVK 獨立版
======================

這是一個完全獨立的 Wine 應用程序包，包含了：
- Wine Staging 運行環境
- 預配置的 DXVK 支持
- Steam 支持

特點：
- 無需預先安裝 Wine
- 獨立的 Wine 前綴
- 包含所有必要的依賴

使用方法：
1. 雙擊應用程序圖標啟動
2. 首次運行會初始化 Wine 環境
3. 選擇安裝 Steam（如果需要）

應用程序大小: 約 500MB+

注意事項：
- 應用程序包含完整的 Wine 環境，因此體積較大
- 首次啟動可能需要較長時間
- 所有數據都保存在應用程序包內

Wine 前綴位置：
${APP_DIR}/Contents/Wine/prefix
EOF

# 設置正確的權限
print_info "設置應用程式權限..."
chmod -R 755 "${APP_DIR}"
chmod +x "${MACOS_DIR}/launcher"
chmod +x "${MACOS_DIR}/wine-config"
chmod +x "${APP_DIR}/管理工具.command" 2>/dev/null || true

# 清除擴展屬性和隔離標記
print_info "清除擴展屬性..."
xattr -cr "${APP_DIR}" 2>/dev/null || true
xattr -d com.apple.quarantine "${APP_DIR}" 2>/dev/null || true

# 重建 Launch Services 資料庫
print_info "註冊應用程式..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "${APP_DIR}" 2>/dev/null || true

# 計算應用程序大小
APP_SIZE=$(du -sh "${APP_DIR}" | cut -f1)
print_info "應用程序創建完成！"
echo ""
print_info "應用程序信息："
echo "  位置: ${APP_DIR}"
echo "  大小: ${APP_SIZE}"
echo ""
print_info "這是一個完全獨立的應用程序，無需預裝 Wine！"
print_info "可以將其複製到任何 Mac 上使用。"
print_warning "首次運行提示："
echo "  - 右鍵點擊應用程式，選擇「打開」"
echo "  - 或在系統偏好設置 > 安全性與隱私 中允許執行"

# 提供壓縮選項
echo ""
read -p "是否要壓縮應用程序以便分享？(y/N): " compress
if [[ $compress == "y" || $compress == "Y" ]]; then
    print_info "正在壓縮應用程序..."
    cd "$HOME/Downloads"
    zip -r "${APP_NAME}.zip" "${APP_NAME}.app" -x "*.DS_Store"
    ZIP_SIZE=$(du -sh "${APP_NAME}.zip" | cut -f1)
    print_info "壓縮完成！"
    echo "  壓縮包: $HOME/Downloads/${APP_NAME}.zip"
    echo "  大小: ${ZIP_SIZE}"
fi