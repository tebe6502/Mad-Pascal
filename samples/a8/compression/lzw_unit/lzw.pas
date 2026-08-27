
{ Author: Gary Conway and Blake Ragsdell          }
{ This program compresses and uncompresses a file }
{ using LZW compression.                          }

USES Crt,Dos,LZWUnit;

VAR
  LZW       : LZWObj;
  InputFile : PathStr;

  s: string[32];


procedure Syntax;
begin
        writeln('Usage: LZW.EXE E(ncode)|D(ecode) infile outfile');
        halt;
end;


BEGIN

  if (paramcount <> 3) then Syntax;

  s:=paramstr(1);

  case s[1] of
     'D','E','d','e': ;
  else
     Syntax
    end;


  LZW.Init;

  if UpCase(s[1]) = 'E' then begin			// encode (compression)
    LZW.CompressFile(paramstr(2), paramstr(3));
    LZW.CompressDone;
  end else begin					// decode (decompression)
    LZW.UnCompressFile(paramstr(2), paramstr(3));
    LZW.CompressDone;
  end;

END.
