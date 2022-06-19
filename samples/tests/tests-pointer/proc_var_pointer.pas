{
 VAR
 VAR POINTER
}

uses crt;

var pn: pointer;

    tb: array [0..0] of byte;



procedure put_char(var a); overload;
begin


 writeln('VAR',',',cardinal(@a));

end;


procedure put_char(var a: pointer); overload;
begin


 writeln('VAR POINTER',',',cardinal(a));


end;




begin

 pn:=@tb;

 writeln('tb');
 put_char(tb);

 writeln('pn');
 put_char(pn);

 repeat until keypressed;

end.