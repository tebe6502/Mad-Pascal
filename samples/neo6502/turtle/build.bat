@setlocal
@SET PATH=%PATH%;D:\atari\MadPascal;D:\atari\mads;
@SET NEOPATH=D:\neo6502\latest
@SET ORG=8000

@SET NAME=%1

mp.exe %NAME%.pas -target:neo -code:%ORG%
@if %ERRORLEVEL% == 0 mads %NAME%.a65 -x -i:D:\atari\MadPascal\base -o:%NAME%.bin
@if %ERRORLEVEL% == 0 python %NEOPATH%\exec.zip %NAME%.bin@%ORG% run@%ORG% -o%NAME%.neo
@if %ERRORLEVEL% == 0 %NEOPATH%\neo.exe %NAME%.bin@%ORG% run@%ORG%

