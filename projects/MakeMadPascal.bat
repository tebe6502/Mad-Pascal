@echo on
cd %~dp0
rem Replace .WinMerge .pas ^
rem Replace C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\ -inputFilePattern
MakeMadPascal.exe -allThreads -allFiles -mpFolderPath .\.. -compileReference -compile -compare -openResults ^
-referenceMPExePath C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\bin\windows_x86_64\origin\mp.exe ^
-mpExePath C:\jac\system\Atari800\Programming\Repositories\Mad-Pascal\projects\TestMadPascal.exe ^
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


