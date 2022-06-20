unit test_unit;


interface

	procedure pok(a:word; b:byte); inline;

	procedure pok2(a:word; b:byte);

implementation


procedure pok2(a:word; b:byte);

 procedure nested_test; inline;
 begin
  poke(a,b);
 end;

begin

 nested_test;

end;



procedure pok(a:word; b:byte); inline;
begin

 poke(a,b);

end;


end.

