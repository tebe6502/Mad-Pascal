@echo off
cd %~dp0
rem Replace .WinMerge ^ .pas ^
rem Replace C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\ -inputFilePattern
MakeMadPascal.exe -allThreads -allFiles -mpFolderPath .\.. -compileReference -compile -compare -openResults ^
-referenceMPExePath C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\bin\windows_x86_64\origin\mp.exe ^
-mpExePath C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\bin\windows_x86_64\mp.exe ^
-inputFilePattern samples\a8\games\mine.pas ^
-inputFilePattern samples\a8\games\hitbox\hitbox2.pas ^
-inputFilePattern samples\a8\graph_vbxe\gif\gifview.pas ^
-inputFilePattern samples\a8\graph_vbxe_ansi\test_ansi.pas ^
-inputFilePattern samples\a8\math\sorting\sortalg.tp.pas ^
-inputFilePattern samples\tests\tests-basic\negative-index-range.pas ^
-inputFilePattern samples\tests\tests-medium\array-with-char-index.pas ^
-inputFilePattern samples\vic-20\snake\vic20.pas ^

pause


