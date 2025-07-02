uses crt;
   
var optval:byte;
    strTemp:string;

begin
    optval := 1;
    strTemp := 'test  ';
    strTemp[Length(strTemp)] := char(optval + $30);
    Writeln(strTemp);
    optval := optval + $30;
    strTemp[Length(strTemp)] := char(optval);
    Writeln(strTemp);
    Readkey;
end.
