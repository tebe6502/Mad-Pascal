{ 
 FindFirst
 FindNext
 FindClose

 TSearchRec
}

uses crt, sysutils;

var Info : TSearchRec;

begin

  if FindFirst('D:*.*', faAnyFile, Info) = 0 then
  begin
    repeat
      writeln(Info.Name,' | ',hexStr(Info.Attr,2));
    until FindNext(Info) <> 0;
    
    FindClose(Info);
  end;
  
  
  repeat until keypressed;

end.
