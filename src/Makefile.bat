@echo off
rem
rem Windows Makefile for PAS2JS and verification of regression tests during refactorings.
rem
rem Set %WUDSN_TOOLS_FOLDER% to the folder with the latest https://github.com/wudsn/wudsn-ide-tools
re, The script will use the FPC, MP, and MADS versions from there as a reference.
rem
rem The script compiles "Test-0.pas" with FPC vs. the new MP.
rem The script compiles a set of reference examples with the released and the new MP and validates that there are no differences in the binary output.
rem The optional first argument to the script is "FAST" to only compile the first test.

setlocal
set TEST_MODE=%1

set PATH=%WUDSN_TOOLS_FOLDER%\PAS\FPC.jac;%WUDSN_TOOLS_FOLDER%\ASM\MADS\bin\windows_x86_64;%PATH%
call :normalize_path %~dp0..
set MP_FOLDER=%RETVAL%
set MP_SRC_FOLDER=%MP_FOLDER%\src
set MP_PAS=%MP_SRC_FOLDER%\mp.pas
set MP_BIN_FOLDER=%MP_FOLDER%\bin\windows_x86_64
set MP_EXE=%MP_BIN_FOLDER%\mp.exe

set REFERENCE_MP_EXE=%MP_BIN_FOLDER%-origin\bin\windows\mp.exe

set TEST_PAS=%MP_SRC_FOLDER%\TestUnits.pas
rem set TEST_EXE=%MP_SRC_FOLDER%\TestUnits.exe

set MP_TESTS_FOLDER=%MP_SRC_FOLDER%\tests

cd /d %MP_SRC_FOLDER%


if not "%TEST_EXE%"=="" (
  if exist "%TEST_EXE%" del "%TEST_EXE%"
  call fpc.bat %TEST_PAS%
  if errorlevel 1 goto :eof
)



if not "%MP_EXE%"=="" (
  echo INFO: Compiling %MP_PAS% to %MP_EXE%.
  if exist "%MP_EXE%" del "%MP_EXE%"
  call fpc.bat %MP_PAS%
  if errorlevel 1 goto :eof
  if not exist %MP_BIN_FOLDER% mkdir "%MP_BIN_FOLDER%"
  copy "mp.exe" "%MP_EXE%"
  if errorlevel 1 goto :eof

  rem DEL does not set the errorlevel!
  del "mp.exe"
  if exist "mp.exe" (
    echo WARNING: Cannot delete %CD%\mp.exe
  )
)

rem Regression test with standard MP.
call %MP_FOLDER%\projects\MakeMadPascal.bat
goto :eof


:normalize_path
  set retval=%~f1
  exit /b
