program test;

function test:byte;
var
  a:byte;

  function inside:byte; inline;
  var
    aa,bb,cc:byte;

  begin
    aa:=random(20);
    bb:=random(20);
    cc:=random(20);
    result:=aa+bb+cc;
  end;

  function inside2:byte;
  begin
    result:=inside;
  end;

begin
  a:=inside2;
  result:=a;
end;

begin
  writeLn(test);
end.
