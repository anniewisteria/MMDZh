@echo off
cd /d "%~dp0"
call "D:\MMD\VS\msvc_builder_v14.37.32822_Portable_by_pkups@wy\vs_builder\vc.bat"
if not exist release_log mkdir release_log
cl /nologo /EHsc /LD /W4 /O2 /MT /Zi /utf-8 /DMMDZH_LOG ^
   /DUNICODE /D_UNICODE /DMAKE_MMD_PLUGIN /DNDEBUG ^
   /I.\lib ^
   MMDZh.cpp ^
   /Fo"release_log\\" /Fd"release_log\MMDZh.pdb" ^
   /Fe"release_log\MMDZh.dll" ^
   /link /DEBUG /LIBPATH:.\lib MMDPlugin.lib shlwapi.lib psapi.lib gdi32.lib user32.lib kernel32.lib
if errorlevel 1 exit /b 1
set "DST=..\MikuMikuDanceE_v932x64\Plugin\MMDZh"
copy /Y "release_log\MMDZh.dll" "%DST%\" >nul
echo BUILD_LOG_OK
exit /b 0
