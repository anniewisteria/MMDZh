@echo off
chcp 936 >nul
cd /d "%~dp0"

echo ========================================
echo  编译 MMDZh 汉化插件（发布版 /MT，优化）
echo ========================================

:: MMD 开着时 DLL 被占用，无法覆盖，先拦下来
powershell -NoProfile -Command "if (Get-Process -Name MikuMikuDance -ErrorAction SilentlyContinue | Where-Object { $_.Path }) { exit 1 } else { exit 0 }"
if errorlevel 1 (
    echo [错误] 请先关闭 MMD（MikuMikuDance.exe）再编译。
    pause
    exit /b 1
)

:: 加载便携 MSVC 环境（x64）
call "D:\MMD\VS\msvc_builder_v14.37.32822_Portable_by_pkups@wy\vs_builder\vc.bat"

if not exist release mkdir release

:: /MT 静态链接运行库，产物只依赖系统 DLL，免装 VC 运行库
:: /O2 速度优化；/Zi + /DEBUG 生成 PDB 留档（不随 DLL 发布）
:: /utf-8 源文件为 UTF-8 编码（MMDZh.cpp）
cl /nologo /EHsc /LD /W4 /O2 /MT /Zi /utf-8 ^
   /DUNICODE /D_UNICODE /DMAKE_MMD_PLUGIN /DNDEBUG ^
   /I.\lib ^
   MMDZh.cpp ^
   /Fo"release\\" /Fd"release\MMDZh.pdb" ^
   /Fe"release\MMDZh.dll" ^
   /link /DEBUG /LIBPATH:.\lib MMDPlugin.lib shlwapi.lib user32.lib kernel32.lib comdlg32.lib

if errorlevel 1 (
    echo.
    echo *** 编译失败 ***
    pause
    exit /b 1
)

:: 只把 DLL 放到测试 MMD；PDB 留在本地，不外发
set "DST=..\MikuMikuDanceE_v932x64\Plugin\MMDZh"
if not exist "%DST%" mkdir "%DST%"
copy /Y "release\MMDZh.dll" "%DST%\" >nul

echo.
echo *** 发布版编译成功 ***
echo 测试目录：%DST%\MMDZh.dll（已更新）
echo 外发只发 release\MMDZh.dll 这一个文件
echo release\MMDZh.pdb 自己留档，别发
echo.
pause