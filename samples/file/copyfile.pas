
{ Program to demonstrate the BlockRead and BlockWrite functions. }

var Fin, Fout : File;
    NumRead,NumWritten : Word;
    Buf : Array[0..2047] of byte;
    Total : word;
    
    p1,p2: string[16];

begin
  p1:='D:CONSTANT.OBX';
  p2:='D:COPY.DAT';

  Assign (Fin, p1);
  Assign (Fout, p2);
  
  Reset (Fin, 1);
  Rewrite (Fout, 1);
  
  Total:=0;
  Repeat
    BlockRead (Fin,buf,Sizeof(buf),NumRead);
    BlockWrite (Fout,Buf,NumRead,NumWritten);
 
    inc(Total,NumWritten);
  Until (NumRead=0) or (NumWritten<>NumRead);
  
  Write ('Copied ',Total,' bytes from file ', p1);
  Writeln (' to file ', p2);

  close(Fin);
  close(Fout);
end.

