
procedure SetDisplayBuffer(var a: TDisplayBuffer);
(*
@description:
Set video buffer which is displayed
*)
begin
	sdlstl := a.dl;
	dlistl := sdlstl;
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

end;


procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);
(*
@description:
Switch graphical buffer between A <> B
*)
var tmp: TDisplayBuffer;
    x, y: pointer;
    l: word;
begin

 tmp:=b;

 b:=a;
 a:=tmp;

 SetDisplayBuffer(a);
 SetActiveBuffer(b);

 x:=Scanline(WIN_TOP);

 y:=Scanline(WIN_BOTTOM);
 l:=word(y);
 y:=Scanline(WIN_TOP);

 dec(l, word(y));

 fillchar(x, l, 0);

end;

