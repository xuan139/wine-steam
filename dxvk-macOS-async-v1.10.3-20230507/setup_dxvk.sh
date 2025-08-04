#!/bin/bash
set -e

export WINEPREFIX=/Volumes/Windows/System/Steam

cp /x64/*.dll $WINEPREFIX/drive_c/windows/system32/
cp /x32/*.dll $WINEPREFIX/drive_c/windows/syswow64/

# 验证复制结果：列出 system32 目录中的 DLL 文件
echo "ls $WINEPREFIX/drive_c/windows/system32/ 中的 DLL 文件："
ls -l "$WINEPREFIX/drive_c/windows/system32/" | grep "\.dll$"

# 验证复制结果：列出 syswow64 目录中的 DLL 文件
echo "列出 $WINEPREFIX/drive_c/windows/syswow64/ 中的 DLL 文件："
ls -l "$WINEPREFIX/drive_c/windows/syswow64/" | grep "\.dll$"

winecfg

# 在“Libraries”添加：
# d3d11，设置为 native,builtin
# dxgi，设置为 native,builtin
# d3d10core，设置为 native,builtin

export DXVK_HUD=1

# ls /Volumes/Windows/Steam/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe
# /Volumes/Windows/Steam/drive_c/Program Files (x86)/Steam/Steam.exe

export WINEPREFIX=/Volumes/Windows/System/Steam
wine /Volumes/Windows/System/Steam/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe




