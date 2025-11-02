@echo off
rem
rem This script compiles all available/all known problematic samples with the current and the reference version of MadPascal.
rem The current version must have been built using src\Makefile.bat
rem To convert the output of "samples\MakeMadPascal-COMPARE.log":
rem - Replace ".WinMerge" with ".pas ^"
rem - Replace "C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\" with "-inputFilePattern "

cd %~dp0
setlocal
set MP_FOLDER=C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal
set MP_REFERECE_FOLDER=C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal-Reference

set MP_EXE_PATH=%MP_FOLDER%\bin\windows_x86_64\mp.exe
rem For 1.7.4
set MP_REFERENCE_EXE_PATH= %MP_REFERECE_FOLDER%\bin\windows_x86_64\mp.exe
rem For 1.7.5-master
set MP_REFERENCE_EXE_PATH= %MP_FOLDER%\bin\windows_x86_64\master\mp.exe

MakeMadPascal.exe -allThreads -allFiles -mpFolderPath .\.. -compileReference -compile -compare -openResults ^
-mpExePath          %MP_EXE_PATH% ^
-referenceMPExePath %MP_REFERENCE_EXE_PATH% ^


rem -inputFilePattern rijndael-test.pas

