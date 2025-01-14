{ ===================== Test Program ================================ }

PROGRAM LZWTest;

{ Author: Gary Conway and Blake Ragsdell          }
{ This program compresses and uncompresses a file }
{ using LZW compression.                          }

USES Crt,Dos,LZWUnit;

VAR
  LZW       : LZWObj;
  InputFile : PathStr;
BEGIN

  ClrScr;
{
  InputFile := ParamStr(1);
  IF LENGTH(InputFile) = 0 THEN BEGIN
    WriteLn('Please include a filename on the command line.');
    Halt
    END;
}
//  WriteLn('Compressing ',InputFile,' into OUTPUT.DAT');

  LZW.Init;
  LZW.CompressFile('D:WINS.MIC','D:OUTPUT.DAT');
  LZW.CompressDone;

  ClrScr;
  WriteLn('UnCompressing OUTPUT.DAT into RESTORED.DAT');
  LZW.Init;
  LZW.UnCompressFile('D:OUTPUT.DAT','D:RESTORED.DAT');
  LZW.CompressDone;
END.
