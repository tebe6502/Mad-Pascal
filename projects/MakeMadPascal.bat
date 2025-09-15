rem Replace .pas  ^ .pas  ^ ^
rem Replace -inputFilePattern IdentifierAt(IdentIndex)   -inputFilePattern
MakeMadPascal.exe -allThreads -allFiles -mpFolderPath .\.. -compileReference -compile -compare -openResults ^
-inputFilePattern samples\a8\games\mine.pas  ^
-inputFilePattern samples\a8\games\hitbox\hitbox2.pas  ^
-inputFilePattern samples\a8\graph\stereogram.pas  ^
-inputFilePattern samples\a8\graph_vbxe\gif\gifview.pas  ^
-inputFilePattern samples\a8\math\aes\aes_test.pas  ^
-inputFilePattern samples\a8\math\sha256\sha256_test.pas  ^
-inputFilePattern samples\a8\tools\sortviz\source\SortViz.pas  ^
-inputFilePattern samples\common\dynrec.pas  ^
-inputFilePattern samples\common\realmath.pas  ^
-inputFilePattern samples\common\math\fft\fourier.pas  ^
-inputFilePattern samples\common\object\hello.pas  ^
-inputFilePattern samples\tests\tests-basic\negative-index-range.pas  ^
-inputFilePattern samples\tests\tests-enum\enum_proc_arg.pas  ^
-inputFilePattern samples\tests\tests-medium\array-with-char-index.pas  ^
-inputFilePattern samples\vic-20\snake\vic20.pas
pause
