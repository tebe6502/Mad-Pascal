@echo off
rem Temporary experimental makefile for testing.
setlocal
set PATH=C:\jac\system\Java\Programming\Repositories\wudsn-ide-tools\PAS\FPC.jac;%PATH%
set MP_FOLDER=C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\
set MP_SRC_FOLDER=%MP_FOLDER%\src
set MP_EXE=%MP_SRC_FOLDER%\mp.exe
set TEST_EXE=%MP_SRC_FOLDER%\Test-0.exe

cd /d %MP_SRC_FOLDER%

goto :main
call fpc.bat %MP_SRC_FOLDER%\Test-0.pas
if errorlevel 1 goto :eof
if exist %TEST_EXE% (
  echo Starting test program %TEST_EXE%.
   %TEST_EXE%
)

rem goto :eof

:main
if exist %MP_EXE% del %MP_EXE%
call fpc.bat %MP_SRC_FOLDER%\mp.pas
if errorlevel 1 goto :eof

if exist %MP_EXE%  %MP_EXE% -ipath:%MP_FOLDER%\lib Test-MP.pas
