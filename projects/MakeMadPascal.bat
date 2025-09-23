rem Replace .pas ^ .pas ^
rem Replace -inputFilePattern IdentifierAt(IdentIndex)   -inputFilePattern
MakeMadPascal.exe -allThreads -allFiles -mpFolderPath .\.. -compileReference -compile -compare -openResults ^
-inputFilePattern samples\a8\graph\stereogram.pas ^
-inputFilePattern samples\common\math\fft\fourier.pas ^
-inputFilePattern samples\tests\tests-medium\array-with-char-index.pas ^
-inputFilePattern samples\a8\crt_console\life.pas ^
-inputFilePattern samples\a8\demoeffects\bobs.pas ^
-inputFilePattern samples\a8\demoeffects\bobs_f.pas ^
-inputFilePattern samples\a8\games\jump.pas ^
-inputFilePattern samples\a8\games\mine.pas ^
-inputFilePattern samples\a8\games\skyscrapers.pas ^
-inputFilePattern samples\a8\games\skyscrapers2.pas ^
-inputFilePattern samples\a8\games\hitbox\hitbox2.pas ^
-inputFilePattern samples\a8\library\test_lib.pas ^
-inputFilePattern samples\a8\math\aes\aes_test.pas ^
-inputFilePattern samples\a8\math\sha256\sha256_test.pas ^
-inputFilePattern samples\a8\math\sorting\quicksort.pas ^
-inputFilePattern samples\a8\tools\heatmap\heatmap.pas ^
-inputFilePattern samples\common\crt_console\life.pas ^
-inputFilePattern samples\common\graphics\mandel.pas ^
-inputFilePattern samples\common\object\hello.pas ^
-inputFilePattern samples\tests\tests-basic\negative-index-range.pas ^
-inputFilePattern samples\tests\tests-medium\array-with-char-index.pas ^
-inputFilePattern samples\vic-20\snake\vic20.pas ^

pause


