@setlocal
@SET PATH=%PATH%;D:\atari\MadPascal;D:\atari\mads;D:\neo6502
@SET ORG=8000

@SET NAME=%1

mp.exe %NAME%.pas -target:neo -code:%ORG%
@if %ERRORLEVEL% == 0 mads %NAME%.a65 -x -i:D:\atari\MadPascal\base -o:%NAME%.neo
@if %ERRORLEVEL% == 0 neo.exe %NAME%.neo@%ORG% exec

