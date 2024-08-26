
{

0D523E88
053B7FA8
0E887644
0E886C96
04C07985
0D334D44

}

uses crt;
 
var
    q: cardinal;

 
function ElfHash(const Value: string): cardinal;
var
  x: cardinal;
  ch: char;
begin
  Result := 0;
  for ch in Value do
  begin
    Result := (Result shl 4) + Ord(ch);
    x := Result and $F0000000;
    if (x <> 0) then
      Result := Result xor (x shr 24);
    Result := Result and (not x);
  end;
end;



begin

q:=ElfHash('@movZTMP_aBX'); writeln(hexStr(q,8));

q:=ElfHash('@movaBX_EAX'); writeln(hexStr(q,8));

q:=ElfHash('@BYTE.MOD'); writeln(hexStr(q,8));

q:=ElfHash('@BYTE.DIV'); writeln(hexStr(q,8));

q:=ElfHash('imulBYTE'); writeln(hexStr(q,8));

q:=ElfHash('mulSHORTINT'); writeln(hexStr(q,8));


repeat until keypressed;

end.
