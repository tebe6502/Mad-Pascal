
// DLI Scroll by Greblus

uses crt;

const
	dl: array [0..32] of byte =
	(
	112, 112, 112, 66, 0, 64, 2, 2, 2, 2, 2, 2, 2, 2, 2,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 130, 86, 36, 67, 65,
	lo(word(@dl)), hi(word(@dl))
	);

var
	col0: byte absolute 708;
	col1: byte absolute 709;
	savmsc: word absolute 88;
	nmien: byte absolute $d40e;
	pc: ^byte;
	tmp: word;
	hscrol: byte absolute 54276;
	vcount: byte absolute $d40b;
	colt: byte absolute $d017;
	wsync: byte absolute $d40a;
	dlist: word absolute 560;
	i,j,k,l,indx: byte;
	old_dli, old_vbl: pointer;

procedure dli; interrupt;
begin
 asm { phr };
 inc(indx);
 for i:=0 to 7 do
  begin
   wsync:=1;
   if indx>30 then indx:=0;
   colt:=vcount+indx;
  end;
 asm { plr };
end;			// mad pascal add RTI

procedure scroll; interrupt;
begin
 hscrol:=j;
 inc(j);
 if j=17 then
  begin
   j:=0; dec(pc^,2); inc(k);
   if k=14 then
    begin
     k:=0; pc^:=tmp;
    end
  end;
 asm { jmp $E462 };
end;

begin
 i:=0; j:=0; k:=0; indx:=0;
 dlist:=word(@dl);

 GetIntVec(iVBL, old_vbl);
 GetIntVec(iDLI, old_dli);

 SetIntVec(iVBL, @scroll);
 SetIntVec(iDLI, @dli);

 nmien:=$c0;

 pc := @dl;
 inc(pc, 28);

 tmp := pc^+6;
 col0 := 14; col1 := 14;
 savmsc := $4000;

 for l:=1 to 22 do
  writeln(' mp rulez! ');

 repeat until keypressed;

 SetIntVec(iVBL, old_vbl);
 SetIntVec(iDLI, old_dli);

end.

