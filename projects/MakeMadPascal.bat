@echo off
rem
rem This script compiles all available/all known problematic samples with the current and the reference version of MadPascal.
rem The current version must have been built using src\Makefile.bat
rem To convert the output of "samples\MakeMadPascal-COMPARE.log":
rem - Replace ".WinMerge"with ".pas ^"
rem - Replace "C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\" with "-inputFilePattern "

cd %~dp0
setlocal
set MP_FOLDER=C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal
set MP_REFERECE_FOLDER=C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal-Reference
rem This script compiles

MakeMadPascal.exe -allThreads -allFiles -mpFolderPath .\.. -compileReference -compile -compare -openResults ^
-referenceMPExePath %MP_REFERECE_FOLDER%\bin\windows_x86_64\mp.exe ^
-mpExePath          %MP_FOLDER%\bin\windows_x86_64\mp.exe ^
-inputFilePattern samples\a8\compression\apl\unapl.pas ^
-inputFilePattern samples\a8\compression\deflate\undef.pas ^
-inputFilePattern samples\a8\compression\lz4\unlz4.pas ^
-inputFilePattern samples\a8\compression\packfire\pcf_test.pas ^
-inputFilePattern samples\a8\compression\pp\test.pas ^
-inputFilePattern samples\a8\compression\pp\test_handle.pas ^
-inputFilePattern samples\a8\compression\upkr\test_upk.pas ^
-inputFilePattern samples\a8\compression\zx0\unzx0.pas ^
-inputFilePattern samples\a8\compression\zx2\unzx2.pas ^
-inputFilePattern samples\a8\compression\zx5\unzx5.pas ^
-inputFilePattern samples\a8\demoeffects\crosses_r.pas ^
-inputFilePattern samples\a8\displaylist\dl_create.pas ^
-inputFilePattern samples\a8\extra_ram\vscrol.pas ^
-inputFilePattern samples\a8\games\hitbox\hitbox2.pas ^
-inputFilePattern samples\a8\graph_vbxe\view.pas ^
-inputFilePattern samples\a8\graph_vbxe\gif\gifview.pas ^
-inputFilePattern samples\a8\graph_vbxe_ansi\test_ansi.pas ^
-inputFilePattern samples\a8\math\sorting\sortalg.tp.pas ^
-inputFilePattern samples\common\extreal.pas ^
-inputFilePattern samples\tests\tests-basic\negative-index-range.pas ^
-inputFilePattern samples\tests\tests-medium\array-with-char-index.pas ^
-inputFilePattern samples\tests\tests-while\while_lteq.pas ^
-inputFilePattern samples\vic-20\snake\vic20.pas ^


goto :eof

-inputFilePattern samples\a8\games\mine.pas ^
-inputFilePattern samples\a8\games\hitbox\hitbox2.pas ^
-inputFilePattern samples\a8\graph_vbxe\gif\gifview.pas ^
-inputFilePattern samples\a8\graph_vbxe_ansi\test_ansi.pas ^
-inputFilePattern samples\a8\math\sorting\sortalg.tp.pas ^
-inputFilePattern samples\tests\tests-basic\negative-index-range.pas ^
-inputFilePattern samples\tests\tests-medium\array-with-char-index.pas ^
-inputFilePattern samples\vic-20\snake\vic20.pas ^

pause


