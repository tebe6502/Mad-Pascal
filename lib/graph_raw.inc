
procedure InitGraph(mode: byte); overload;
(*
@description:
Init graphics mode
*)
begin


end;


procedure InitGraph(driver, mode: byte; dev: PString); overload;
(*
@description:
Init graphics mode
*)
begin

 InitGraph(mode);

end;


procedure SetBkColor(color: byte); assembler;
(*
@description:
Sets the background color to Color
*)
asm

end;


procedure SetColor(color: byte); assembler;
(*
@description:
Sets the foreground color to Color
*)
asm

end;


procedure PutPixel(x,y: smallint); assembler; overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
asm

end;


procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin


end;


function GetPixel(x,y: smallint): byte; assembler;
(*
@description:
Return color of pixel
*)
asm

end;


procedure LineTo(x, y: smallint);
(*
@description:
Draw a line starting from current position to a given point
*)
begin

end;


procedure LineRel(dx, dy: smallint);
(*
@description:
LineRel draws a line starting from the current pointer position to the point(DX,DY),
relative to the current position, in the current line style and color.
The Current Position is set to the endpoint of the line.
*)
begin

 LineTo(CurrentX + dx, CurrentY + dy)

end;


procedure CloseGraph; assembler;
(*
@description:

*)
asm

end;

