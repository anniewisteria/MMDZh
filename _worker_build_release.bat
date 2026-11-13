@echo off
cd /d "%~dp0"
call "D:\MMD\VS\msvc_builder_v14.37.32822_Portable_by_pkups@wy\vs_builder\vc.bat"
if not exist release mkdir release
cl /nologo /EHsc /LD /W4 /O2 /MT /utf-8 ^
   /DUNICODE /D_UNICODE /DMAKE_MMD_PLUGIN /DNDEBUG ^
   /I.\lib ^
   MMDZh.cpp ^
   /Fo"release\\" ^
   /Fe"release\MMDZh.dll" ^
   /link /LIBPATH:.\lib MMDPlugin.lib shlwapi.lib psapi.lib gdi32.lib user32.lib kernel32.lib
if errorlevel 1 exit /b 1
echo BUILD_RELEASE_OK
exit /b 0
