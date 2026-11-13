@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================
echo  编译 MMDZh 汉化插件（调试版 /MTd，带 PDB）
echo ========================================

:: MMD 开着时 DLL 被占用，无法覆盖，先拦下来
:: 用 Path 过滤，避免退出中的僵尸进程条目误报
powershell -NoProfile -Command "if (Get-Process -Name MikuMikuDance -ErrorAction SilentlyContinue | Where-Object { $_.Path }) { exit 1 } else { exit 0 }"
if errorlevel 1 (
    echo [错误] 请先关闭 MMD（MikuMikuDance.exe）再编译。
    pause
    exit /b 1
)

:: 加载便携 MSVC 环境（x64）
call "D:\MMD\VS\msvc_builder_v14.37.32822_Portable_by_pkups@wy\vs_builder\vc.bat"

if not exist build_debug mkdir build_debug

:: /MTd = 静态链接调试运行库（用户机不用装 VC 运行库）
:: /Zi /Od = 带调试信息、不优化，崩了能停在源码行
:: /utf-8 = 源码里可以直接写中文和日文
cl /nologo /EHsc /LD /W3 /Zi /Od /MTd /utf-8 ^
   /DUNICODE /D_UNICODE /DMAKE_MMD_PLUGIN ^
   /I.\lib ^
   MMDZh.cpp ^
   /Fo"build_debug\\" /Fd"build_debug\MMDZh.pdb" ^
   /Fe"build_debug\MMDZh.dll" ^
   /link /LIBPATH:.\lib MMDPlugin.lib shlwapi.lib user32.lib kernel32.lib

if errorlevel 1 (
    echo.
    echo *** 编译失败 ***
    pause
    exit /b 1
)

:: 部署到测试用 MMD（PDB 一起放，方便附加调试）
set "DST=..\MikuMikuDanceE_v932x64\Plugin\MMDZh"
if not exist "%DST%" mkdir "%DST%"
copy /Y "build_debug\MMDZh.dll" "%DST%\" >nul
copy /Y "build_debug\MMDZh.pdb" "%DST%\" >nul

echo.
echo *** 调试版编译成功 ***
echo DLL/PDB 已复制到 %DST%
echo 调试方法：打开 MMD 后 VSCode 按 F5，附加到 MikuMikuDance.exe
echo.
pause
