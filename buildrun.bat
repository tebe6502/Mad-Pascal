@setlocal
@SET PATH=%PATH%;D:\atari\MadPascal;D:\atari\mads

mp.exe %1.pas

mads %1.a65 -x -i:D:\atari\MadPascal\base -o:%1.xex

D:\atari\Altirra\altirra64.exe %1.xex
