function AnsiLowerCase(const s: String): String;
begin
     result:=LowerCase(s);
end;

function AnsiUpperCase(const s: String): String;
begin
     result:=UpperCase(s);
end;

function CompareWord(const buf1; const buf2; len: SizeInt): SizeInt;
begin
     Assert(false, 'Not implemented yet');
end;

function GetTickCount64: QWord;
begin
// TODO
end;
