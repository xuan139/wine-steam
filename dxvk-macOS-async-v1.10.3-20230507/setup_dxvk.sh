#!/bin/bash

set -e

# WINEPREFIX="$HOME/steam"
export WINEPREFIX="/Volumes/Windows/System/Steam"

DXVK_DIR="$PWD"

echo "复制64位DLL到系统目录..."
cp "$DXVK_DIR/x64/d3d11.dll" "$WINEPREFIX/drive_c/windows/system32/"
cp "$DXVK_DIR/x64/dxgi.dll" "$WINEPREFIX/drive_c/windows/system32/"
cp "$DXVK_DIR/x64/d3dcompiler_47.dll" "$WINEPREFIX/drive_c/windows/system32/"

echo "复制32位DLL到syswow64目录..."
cp "$DXVK_DIR/x32/d3d11.dll" "$WINEPREFIX/drive_c/windows/syswow64/"
cp "$DXVK_DIR/x32/dxgi.dll" "$WINEPREFIX/drive_c/windows/syswow64/"
cp "$DXVK_DIR/x32/d3dcompiler_47.dll" "$WINEPREFIX/drive_c/windows/syswow64/"

echo "完成！请使用 winecfg 配置这三个 DLL 为 native, then builtin"


winecfg
# 在“Libraries”添加：
# d3d11，设置为 native,builtin
# d3d10core，设置为 native,builtin

export DXVK_HUD=1

# wine "C:\\Program Files (x86)\\Steam\\steamapps\\common\\3on3 FreeStyle Rebound\\DoubleClutch.exe"

安装 steam 用 wine-stage

wine /Volumes/Windows/System/Steam/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe