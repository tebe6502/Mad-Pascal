@Echo off
@setlocal
@set PATH=%PATH%;D:\Dropbox\Atari\DEV\MAD-Pascal\;D:\Dropbox\Atari\DEV\MADS\
echo Compiling
mp.exe pokeyflash.pas -define:DEBUG
if exist pokeyflash.a65 mads.exe pokeyflash.a65 -x -i:D:\Dropbox\Atari\DEV\MAD-Pascal\base -o:pokeyfla.xex
if not %ERRORLEVEL%==0 pause
rem echo.