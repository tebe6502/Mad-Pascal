// 112

uses crt;

type

  rc = packed record

        a: cardinal;
	b: word;
	c: byte;

       end;

var
	p: ^rc;

	v: rc;


procedure test(var f: word);
begin

 inc(f);
end;


begin

 v.b:=111;

 p:=@v;


 test(p^.b);

 writeln(v.b);

 repeat until keypressed;

end.