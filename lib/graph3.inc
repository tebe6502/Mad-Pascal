
procedure SetDisplayBuffer(var a: TDisplayBuffer);
(*
@description:
Set video buffer which is displayed
*)
begin
	sdlstl := a.dl;
	dlistl := sdlstl;
end;


procedure ClrBuffer;
var x, y: pointer;
    l: word;
begin

 x:=Scanline(WIN_TOP);

 y:=Scanline(WIN_BOTTOM + 1);
 l:=word(y);

 dec(l, word(x));

 fillbyte(x, l, 0);

end;


function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
(*
@description:
Initialize new graphical buffer
*)
begin

 ramtop := bound;

 InitGraph(mode);

 a.dl := sdlstl;
 a.bp := savmsc;

 a.clr := @ClrBuffer;

end;


procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);
(*
@description:
Switch graphical buffer between A <> B
*)
var tmp: TDisplayBuffer;
begin

 tmp:=b;

 b:=a;
 a:=tmp;

 SetDisplayBuffer(a);
 SetActiveBuffer(b);

 b.clr;

end;

