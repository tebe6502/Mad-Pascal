@echo off
rem
rem Windows Makefile for PAS2JS and verification of regresssion tests during refactorings.
rem
rem Set %WUDSN_TOOLS_FOLDER% to the folder with the latest https://github.com/wudsn/wudsn-ide-tools
rem The script will use the FPC, MP and MADS version from there as reference.
rem
rem The script compiles "Test-0.pas" with FPC vs. the new MP.
rem The script compiles a set of reference examples with the released and the new MP an validates that there are no differences in the binary output.

setlocal
set PATH=%WUDSN_TOOLS_FOLDER%\PAS\FPC.jac;%WUDSN_TOOLS_FOLDER%\ASM\MADS\bin\windows_x86_64;%PATH%
set MP_FOLDER=%~dp0..
set MP_SRC_FOLDER=%MP_FOLDER%\src

rem set TEST_EXE=%MP_SRC_FOLDER%\Test-0.exe
set MP_EXE=%MP_SRC_FOLDER%\mp.exe

set WUDSN_MP_EXE=%WUDSN_TOOLS_FOLDER%\PAS%\MP\bin\windows\mp.exe

cd /d %MP_SRC_FOLDER%

if not "%TEST_EXE%"=="" (
  if exist "%TEST_EXE%" del "%TEST_EXE%"
  call fpc.bat %MP_SRC_FOLDER%\Test-0.pas
  if errorlevel 1 goto :eof
  if exist "%TEST_EXE%" (
     echo Starting test program "%TEST_EXE%".
     %TEST_EXE%
  )
)

if not "%MP_EXE%"=="" (

rem Regression test with standard MP.
   if 1==1 (
     echo.
     echo INFO: Compiling with WUDSN version.
     echo ===================================
     echo.
     call :run_tests %WUDSN_MP_EXE%
   )
 
    
   echo.
   echo.
   echo INFO: Comiling with new version.
   echo ================================
   echo.
   if exist "%MP_EXE%" del "%MP_EXE%"
   call fpc.bat %MP_SRC_FOLDER%\mp.pas
   if errorlevel 1 goto :eof
   if exist "%MP_EXE%" (
     call :run_tests %MP_EXE%
   )
 )

goto :eof

 rem IN: %1=Path to mp.exe´, %2=Folder of test source %3=File name without file extension of the ".pas" file
:run_mp
  set MP=%1
  set TEST_FOLDER=%2
  set TEST_MP=%3
  
  set MP_INPUT_PAS=%TEST_MP%.pas
  set MP_OUTPUT_ASM=%TEST_MP%.a65
  set MADS_OUTPUT_XEX_REF=%TEST_MP%-Reference.xex
  echo %MADS_OUTPUT_XEX_REF%
  if %MP%==%WUDSN_MP_EXE% (
    set MADS_OUTPUT_XEX=%MADS_OUTPUT_XEX_REF%
  ) else (
    set MADS_OUTPUT_XEX=%TEST_MP%.xex
  )
  pushd %TEST_FOLDER%
  echo INFO: Compiling "%MP_INPUT_PAS%" in "%TEST_FOLDER%" with "%MP%".
  if exist %MP_OUTPUT_ASM% del %MP_OUTPUT_ASM%
  %MP% -ipath:%MP_FOLDER%\lib %MP_INPUT_PAS%
  if errorlevel 1 goto :mp_error
  if exist %MP_OUTPUT_ASM% (
     if exist %MADS_OUTPUT_XEX% del %MADS_OUTPUT_XEX%
     mads %MP_OUTPUT_ASM% -x -i:%MP_FOLDER%\base -o:%MADS_OUTPUT_XEX%
     if exist %MADS_OUTPUT_XEX% (
       echo Starting test program "%MADS_OUTPUT_XEX%".
       rem %MADS_OUTPUT_XEX%
     ) else (
       echo ERROR: MADS output file %MADS_OUTPUT_XEX% not created.
       pause
     ) 
  ) else (
    echo ERROR: MP output file %MP_OUTPUT_ASM% not created.
    pause
  )
  
  REM TODO Compare file if both files reference exists
  if not "%MADS_OUTPUT_XEX%" == "%MADS_OUTPUT_XEX_REF%" (
    if exist %MADS_OUTPUT_XEX% (

      if exist %MADS_OUTPUT_XEX_REF% (
        fc /b %MADS_OUTPUT_XEX%  %MADS_OUTPUT_XEX_REF%
        if errorlevel 1 goto :fc_error
      ) else (
        echo WARNING: Reference file "%MADS_OUTPUT_XEX_REF%" does not exist, no comparsion possible.
      )
    )
  )
  popd
goto :eof

:mp_error
  popd
  echo ERROR: Mad-Pascal error.
  pause
  goto :eof
 

:fc_error
  popd
  echo ERROR: %MADS_OUTPUT_XEX%  and %MADS_OUTPUT_XEX_REF% are binary different.
  pause
  goto :eof

 rem Run all tests with a given mp.exe.
 rem IN: Path to mp.exe
 rem
:run_tests
rem    call :run_mp % %MP_SRC_FOLDER% Test-MPP
rem    call :run_mp %1=%MP_FOLDER%\samples\a8\games\PacMad pacmadd
    call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform fedorahat
    call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform cannabis
    call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform snowflake
    call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform spline
    call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform fern
    goto :eof
 