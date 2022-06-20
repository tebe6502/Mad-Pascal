program hcf;

{ Highest common factor.
  Expeced result: 4 }

var
  r:integer;

function mod_(x,y:integer):integer;
  begin
    mod_ := x-(x div y)*y;
  end;

function hcf(p,q:integer):integer;
  begin
    r:=mod_(p,q);
    while r<>0 do
      begin
      p:=q;
      q:=r;
      r:=mod_(p,q);
      end;
    hcf:=q;
  end;
begin
  writeln(hcf(2*2*3,2*2*5));

  while true do;
end.
