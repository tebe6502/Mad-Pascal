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
  
  {$IFDEF ATARI}
  LZW.CompressFile('D:WINS.MIC','D:OUTPUT.DAT');
  {$ELSE}
  LZW.CompressFile('WINS.MIC','OUTPUT.DAT');  
  {$ENDIF} 
  LZW.CompressDone;

  ClrScr;
  WriteLn('UnCompressing OUTPUT.DAT into RESTORED.DAT');
  LZW.Init;
  {$IFDEF ATARI}  
  LZW.UnCompressFile('D:OUTPUT.DAT','D:RESTORED.DAT');
  {$ELSE}
  LZW.UnCompressFile('OUTPUT.DAT','RESTORED.DAT');  
  {$ENDIF}  
  LZW.CompressDone;
END.
