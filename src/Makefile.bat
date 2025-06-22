@echo off
rem
rem Windows Makefile for PAS2JS and verification of regresssion tests during refactorings.
rem
rem Set %WUDSN_TOOLS_FOLDER% to the folder with the latest https://github.com/wudsn/wudsn-ide-tools
rem The script will use the FPC, MP and MADS version from there as reference.
rem
rem The script compiles "Test-0.pas" with FPC vs. the new MP.
rem The script compiles a set of reference examples with the released and the new MP an validates that there are no differences in the binary output.
rem The optional first argument to the script is "FAST" to only compile the first test.

setlocal
set TEST_MODE=%1

set PATH=%WUDSN_TOOLS_FOLDER%\PAS\FPC.jac;%WUDSN_TOOLS_FOLDER%\ASM\MADS\bin\windows_x86_64;%PATH%
call :normalize_path %~dp0..
set MP_FOLDER=%RETVAL%
set MP_SRC_FOLDER=%MP_FOLDER%\src
set MP_PAS=%MP_SRC_FOLDER%\mp.pas
set MP_EXE=%MP_FOLDER%\bin\windows\mp.exe

set REFERENCE_MP_EXE=%MP_FOLDER%-origin\bin\windows\mp.exe

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
  mv "mp.exe" "%MP_EXE%"

rem Regression test with standard MP.
goto :run_new_tests

  if "%TEST_MODE%"=="" (
    echo.
    echo INFO: Compiling with reference version.
    echo ===================================
    echo.
    call :run_tests %REFERENCE_MP_EXE%
  )
 
    
   echo.
   echo.
   echo INFO: Comiling with new version.
   echo ================================
   echo.
   if exist "%MP_EXE%" (
     call :run_tests %MP_EXE%
   ) else (
     echo INFO: "%MP_EXE%" does not exist.
   )
 )

goto :eof


:normalize_path
  set retval=%~f1
  exit /b
 
 rem IN: %1=Path to mp.exe´, %2=Folder of test source %3=File name without file extension of the ".pas" file
:run_mp
  set MP=%1
  set TEST_FOLDER=%2
  set TEST_MP=%3
  
  set MP_INPUT_PAS=%TEST_MP%.pas

  set MP_OUTPUT_ASM_REF=%TEST_MP%-Reference.a65
  set MADS_OUTPUT_XEX_REF=%TEST_MP%-Reference.xex

  if %MP%==%REFERENCE_MP_EXE% (
    set MP_OUTPUT_ASM=%MP_OUTPUT_ASM_REF%
    set MADS_OUTPUT_XEX=%MADS_OUTPUT_XEX_REF%
  ) else (
    set MP_OUTPUT_ASM=%TEST_MP%.a65
    set MADS_OUTPUT_XEX=%TEST_MP%.xex
  )
  pushd %TEST_FOLDER%
  echo INFO: Compiling "%MP_INPUT_PAS%" in "%TEST_FOLDER%" with "%MP%" to "%MP_OUTPUT_ASM%" and "%MADS_OUTPUT_XEX%".
  if exist %MP_OUTPUT_ASM% del %MP_OUTPUT_ASM%
  %MP% -ipath:%MP_FOLDER%\lib %MP_INPUT_PAS% -o:%MP_OUTPUT_ASM%
  if errorlevel 1 goto :mp_error
  if exist %MP_OUTPUT_ASM% (
     if exist %MADS_OUTPUT_XEX% del %MADS_OUTPUT_XEX%
     mads %MP_OUTPUT_ASM% -x -i:%MP_FOLDER%\base -o:%MADS_OUTPUT_XEX%
     if exist %MADS_OUTPUT_XEX% (
       if "%TEST_MODE%"=="FULL" (
         echo Starting test program "%MADS_OUTPUT_XEX%".
         %MADS_OUTPUT_XEX%
       )	
     ) else (
       echo ERROR: MADS output file %MADS_OUTPUT_XEX% not created.
       pause
     ) 
  ) else (
    echo ERROR: MP output file %MP_OUTPUT_ASM% not created.
    dir *.a65
    pause
  )
  
  REM Compare file if both files reference exists
  call :compare_files %MP_OUTPUT_ASM%   %MP_OUTPUT_ASM_REF%   TEXT
  call :compare_files %MADS_OUTPUT_XEX% %MADS_OUTPUT_XEX_REF% BINARY
  popd
goto :eof

rem Compare file if both files and reference file exist
rem call :compare_files actual_file reference_file mode (TEXT or BINARY)
:compare_files
  set COMPARE_CURRENT_FILE=%1
  set COMPARE_REFERENCE_FILE=%2
  set COMPARE_MODE=%3
  if not "%COMPARE_CURRENT_FILE%" == "%COMPARE_REFERENCE_FILE%" (
    if exist %COMPARE_CURRENT_FILE% (

      if exist %COMPARE_CURRENT_FILE% (
        rem echo INFO: Comparing "%COMPARE_CURRENT_FILE%" with "%COMPARE_REFERENCE_FILE%" in mode %COMPARE_MODE%.
        if "%COMPARE_MODE%"=="TEXT" (
          rem Strip the compiler version difference.
          more +2 "%COMPARE_CURRENT_FILE%"   > "%COMPARE_CURRENT_FILE%.tmp"
          more +2 "%COMPARE_REFERENCE_FILE%" > "%COMPARE_REFERENCE_FILE%.tmp"
          fc /L %COMPARE_CURRENT_FILE%.tmp %COMPARE_REFERENCE_FILE%.tmp
          if errorlevel 1 (
            echo ERROR: "%COMPARE_CURRENT_FILE%" and "%COMPARE_REFERENCE_FILE%" are different.
            pause
          )
          del %COMPARE_CURRENT_FILE%.tmp %COMPARE_REFERENCE_FILE%.tmp
        ) else (
          fc /B %COMPARE_CURRENT_FILE% %COMPARE_REFERENCE_FILE%
          if errorlevel 1 ( 
            echo ERROR: "%COMPARE_CURRENT_FILE%" and "%COMPARE_REFERENCE_FILE%" are binary different.
            pause
          )
        )
      ) else (
        echo WARNING: Reference file "%COMPARE_REFERENCE_FILE%" does not exist, no comparsion possible.
      )
    )
  )
  goto :eof


:mp_error
  popd
  echo ERROR: Mad-Pascal error.
  pause
  goto :eof
 

rem Run all tests with a given mp.exe.
rem IN: Path to mp.exe
rem
:run_tests
  call :run_mp %1 %MP_TESTS_FOLDER% TestMP
  
  if "%TEST_MODE%"=="FAST" goto :eof
  call :run_mp %1 %MP_FOLDER%\samples\a8\games\PacMad pacmad
  call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform fedorahat
  call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform cannabis
  call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform snowflake
  call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform spline
  call :run_mp %1 %MP_FOLDER%\samples\a8\graph_crossplatform fern
  goto :eof
 

rem New version of the comparison test
:run_new_tests
rem %MP_FOLDER%\projects\MakeMadPascal -allThreads -openResults
%MP_FOLDER%\projects\MakeMadPascal -allThreads *allFiles -compileReference -compile -compare -openResults
goto :eof
