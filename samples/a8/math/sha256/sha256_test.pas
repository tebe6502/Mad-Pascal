{

07F2BDEF34ED16E3A1BA0DBB7E47B8FD981CE0CCB3E1BFE564D82C423CBA7E47

}

uses crt, sha256;

var
 r: SHA256Result;
 i: byte;
 

begin

r:=SHA256Hash('Hello World !');

for i:=0 to 31 do
 write(hexStr(r[i], 2));
 
writeln;

repeat until keypressed;

end.

// 3994
