
// file .a65 assemble with switch -hm (Mads Assembler)
// the -hm switch will generate a .HEA file

library subs : $6000;

uses crt ;


var tmp: integer;

var tb: array [0..255] of byte;


function dodaj(a,b: integer): integer; //stdcall;
begin

 Result := a+b;

end;


function SubStr(CString: PChar;FromPos,ToPos: Longint): PChar; //cdecl;
var
  len: Integer;

begin
  //len := StrLen(CString);
  len:=1;


  SubStr := CString + len;
  if (FromPos > 0) and (ToPos >= FromPos) then
  begin
    if len >= FromPos then
      SubStr := CString + FromPos;
    if len > ToPos then
    CString[ToPos+1] := #0;
  end;
end;


exports  SubStr, dodaj, tmp, tb;



begin

 writeln('Library TEST_LIB');

end.
