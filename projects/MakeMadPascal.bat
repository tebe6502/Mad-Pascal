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

MakeMadPascal.exe -allThreads -allFiles -mpFolderPath .\.. -compileReference -compile -compare -openResults ^
-referenceMPExePath %MP_REFERECE_FOLDER%\bin\windows_x86_64\mp.exe ^
-mpExePath          %MP_FOLDER%\bin\windows_x86_64\mp.exe ^
-inputFilePattern rijndael-test.pas

