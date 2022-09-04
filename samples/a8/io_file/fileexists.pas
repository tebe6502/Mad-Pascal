// false, false, true, true, true, true


uses crt, sysutils;
{

procedure SaveData(var s:string; buf: pointer; size: word);
var file_out: file;
begin
    s:=Concat('D:', s);

    if FileExists(s) then begin 
      CRT_Write('File already exists!'~*);
      Readkey;
      Exit;
    end;

    Assign(file_out, s); 
    Rewrite(file_out, 1);
    BlockWrite(file_out, buf, size);
    CRT_Write('IO Result: '~);
    CRT_Write(ioresult);
    Close(file_out);
    Readkey;
end;
}

begin
 writeln(FileExists('D:FILE2.OBX'));
 writeln(FileExists('D:FILE2.OBX'));

 writeln(FileExists('D:DIR.OBX'));
// writeln(FileExists('D:DIR2.OBX'));
 writeln(FileExists('D:FILE.OBX'));

 writeln(FileExists('D:CONSTANT.OBX'));
 writeln(FileExists('D:DIR.OBX'));

end.