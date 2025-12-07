@echo off
rem
rem Windows Makefile for PAS2JS and verification of regression tests during refactorings.
rem
rem Set %WUDSN_TOOLS_FOLDER% to the folder with the latest https://github.com/wudsn/wudsn-ide-tools
rem The script will use the FPC, MP, and MADS versions from there as a reference.
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
set MP_PAS_FILE=mp
set MP_BIN_FOLDER=%MP_FOLDER%\bin\windows_x86_64
set MP_EXE_FILE=mp.exe
set MP_EXE=%MP_BIN_FOLDER%\%MP_EXE_FILE%

set REFERENCE_MP_FOLDER=C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal
set REFERENCE_MP_SRC_FOLDER=%REFERENCE_MP_FOLDER%\origin
set REFERENCE_MP_BIN_FOLDER=%MP_FOLDER%\bin\windows_x86_64\origin
set REFERENCE_MP_EXE=%REFERENCE_MP_BIN_FOLDER%\mp.exe

set TEST_PAS=%MP_SRC_FOLDER%\TestUnits.pas
rem set TEST_EXE=%MP_SRC_FOLDER%\TestUnits.exe
set MP_TESTS_FOLDER=%MP_SRC_FOLDER%\tests

cd /d %MP_SRC_FOLDER%

if not "%TEST_EXE%"=="" (
  if exist "%TEST_EXE%" del "%TEST_EXE%"
  call fpc.bat %TEST_PAS%
  if errorlevel 1 goto :eof
)


call :make_exe %MP_SRC_FOLDER% %MP_BIN_FOLDER%
if errorlevel 1 goto :eof

call :make_exe %REFERENCE_MP_SRC_FOLDER% %REFERENCE_MP_BIN_FOLDER%
if errorlevel 1 goto :eof

set PAS_FOLDER=samples\a8\math\AES-Rijndael
set PAS_FILE=rijndael-test

rem Default regression test sample.
set PAS_FOLDER=samples\tests\tests-debug
set PAS_FILE=debug

rem Delete previous output files
if exist %PAS_FILE%-Reference.a65 del if %PAS_FILE%-Reference.a65
if exist stderr-Reference.log del stderr-Reference.log
if exist %PAS_FILE%.a65 del if %PAS_FILE%.a65
if exist stderr.log del stderr.log

cd %MP_FOLDER%\%PAS_FOLDER%
%REFERENCE_MP_EXE% -ipath %REFERENCE_MP_FOLDER%\lib -ipath %REFERENCE_MP_FOLDER%\blibs %PAS_FILE%.pas 2>stderr-Reference.log
if errorlevel 1 goto :eof

if exist %PAS_FILE%-Reference.a65 del %PAS_FILE%-Reference.a65
ren %PAS_FILE%.a65 %PAS_FILE%-Reference.a65

%MP_EXE% -ipath %MP_FOLDER%\lib -ipath %MP_FOLDER%\blibs %PAS_FILE%.pas 2>stderr.log
if errorlevel 1 goto :eof

start .

goto :eof


:normalize_path
  set retval=%~f1
  exit /b

rem call :make_exe <SRC_FOLDER> <BIN_FOLDER>
rem Uses: %MP_PAS_FILE%, %MP_EXE_FILE%
:make_exe
setlocal
echo on
set SRC_FOLDER=%1
set BIN_FOLDER=%2
set PAS=%SRC_FOLDER%\%MP_PAS_FILE%.pas
set EXE_FILE=%MP_EXE_FILE%
set EXE=%BIN_FOLDER%\%MP_EXE_FILE%

cd /d %SRC_FOLDER%

if not "%EXE_FILE%"=="" (
  echo INFO: Compiling %PAS%.pas to %EXE%.
  if exist "%EXE%" del "%EXE%"
  call fpc.bat %PAS%
  if errorlevel 1 goto :eof
  if not exist %BIN_FOLDER% mkdir "%BIN_FOLDER%"
  copy "%EXE_FILE%" "%EXE%"
  if errorlevel 1 goto :eof

  rem DEL does not set the errorlevel!
  del "%EXE_FILE%"
  if exist "%EXE_FILE%" (
    echo WARNING: Cannot delete %CD%\%MP_EXE_FILE%
  )

  rem Output version
  %EXE%
  exit /b 0
)
endlocal
goto :eof


