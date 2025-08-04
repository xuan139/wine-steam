# 在 macOS 上使用 Wine 和 DXVK-macOS 支持 DirectX 10/11 游戏

## 总体目标
在 macOS 上通过 Wine 和 DXVK-macOS 实现对 DirectX 10 和 DirectX 11 游戏的兼容支持。

## 步骤一：准备环境

1. **安装 Homebrew（如未安装）**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **安装 Wine（Staging 版）**
   ```bash
   brew install --cask --no-quarantine wine-staging
   ```
   安装后验证版本：
   ```bash
   wine --version
   # 输出应为 wine-10.x (Staging)
   ```

3. **安装 winetricks（可选但推荐）**
   ```bash
   brew install winetricks
   ```

## 步骤二：配置 Wine 前缀

1. **设置前缀路径**
   ```bash
   export WINEPREFIX=/Volumes/Windows/Steam
   ```

2. **初始化 Wine 前缀**
   ```bash
   wine wineboot
   ```
   这将创建初始的 Windows 环境目录结构。

## 步骤三：获取 DXVK-macOS

1. **下载 DXVK-macOS 版本**
   - 访问 [Gcenx 的 DXVK-macOS 发布页面](https://github.com/Gcenx/DXVK-macOS/releases)。
   - 示例文件：`dxvk-macOS-async-v1.10.3-20230507.tar.gz`。

2. **解压文件**
   ```bash
   cd ~/Downloads
   tar -xvzf dxvk-macOS-async-v1.10.3-20230507.tar.gz
   ```
   解压后文件结构：
   ```
   dxvk.conf
   x32/
   x64/
   ```

## 步骤四：复制 DXVK DLL 到 Wine 系统目录

以您的前缀为例，执行以下操作：
```bash
# 设置变量
export WINEPREFIX=/Volumes/Windows/Steam

# 复制 64 位 DLL 到 system32
cp ~/Downloads/dxvk-macOS-async-v1.10.3-20230507/x64/*.dll $WINEPREFIX/drive_c/windows/system32

# 复制 32 位 DLL 到 syswow64
cp ~/Downloads/dxvk-macOS-async-v1.10.3-20230507/x32/*.dll $WINEPREFIX/drive_c/windows/syswow64
```

验证复制成功：
```bash
ls -la $WINEPREFIX/drive_c/windows/system32 | grep d3d11
ls -la $WINEPREFIX/drive_c/windows/syswow64 | grep d3d11
```

## 步骤五：配置 DLL 优先顺序（winecfg）

运行：
```bash
winecfg
```

在弹出的窗口中：
- 切换到“Libraries”（库）标签页。
- 添加以下条目：
  - `d3d11` → 设置为 `native, builtin`
  - `dxgi` → 设置为 `native, builtin`
- 点击“Apply”或“OK”保存。

## 步骤六：安装 & 运行 Steam 游戏

1. **下载并安装 Steam（Windows 版）**
   ```bash
   wine SteamSetup.exe
   ```
   完成后，Steam 客户端将安装到您的 Wine 前缀中。

2. **安装支持 DirectX 10/11 的游戏**
   推荐测试的游戏：
   - **Warframe**（免费）
   - **Unturned**（轻量级，DirectX 11，免费）
   - **Team Fortress 2**（部分 DX9，部分 DX11）
   - **Path of Exile**（部分 DX11）
   - **Destiny 2**（不推荐测试，可能不稳定）

## 步骤七：验证 DXVK 是否生效

编辑 `dxvk.conf` 以启用 HUD 显示 DXVK 状态：
```bash
nano $WINEPREFIX/dxvk.conf
```

添加内容：
```ini
dxvk.hud = devinfo,fps
```

运行游戏时，左上角将显示 FPS 和渲染信息，若显示 DXVK 信息，说明启用成功。

**注意**：确保 `dxvk.conf` 位于游戏执行路径或 Wine 前缀中，否则 DXVK 不会加载。

## 可选操作：关闭 macOS 防火墙（避免连接问题）

```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
```

测试完成后重新开启：
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

## 最终效果

您将获得：
- 已配置好的 Wine 前缀。
- DXVK-macOS 替换 Wine 的默认 wined3d，支持 DirectX 10/11。
- 可通过 Steam 安装和运行部分 DirectX 游戏。

**注意**：如遇到 AppSign Error 或反作弊问题，这是 Wine/CrossOver 的限制，或游戏本身的问题。尝试其他游戏或使用 CrossOver Pro 的封装环境规避。

## 额外建议
- 如果需要推荐适合测试 DXVK 的免费 Steam 游戏清单，请告知！
- 如遇到特定游戏或反作弊问题，提供游戏名称和错误详情，我可进一步协助。