var lineX,lineY:word;

procedure InitGraph(mode: byte); overload;
(*
@description:
Init graphics mode
*)
begin
    ScreenWidth:=320;	(* @var current screen width *)
	ScreenHeight:=240;	(* @var current screen height *)
    asm
	    @ClrScr
	end;
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
    lda color
    add #$90
    @putchar
end;


procedure SetColor(color: byte); assembler;
(*
@description:
Sets the foreground color to Color
*)
asm
    stz	DParameters
    stz DParameters+2
    stz DParameters+3
    stz DParameters+4
    lda color
    sta DParameters+1
    @SendMessage
	.byte 	5,1
end;

procedure PutPixel(x,y: smallint); assembler; overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
asm
    lda x
    //sta CurrentX
    sta DParameters
    lda x+1
    //sta CurrentX+1
    sta DParameters+1
    lda y
    //sta CurrentY
    sta DParameters+2
    lda y+1
    //sta CurrentY+1
    sta DParameters+3
    @SendMessage
	.byte 	5,5
end;


procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin
    SetColor(color);
    PutPixel(x,y);
end;


function GetPixel(x,y: smallint): byte; assembler;
(*
@description:
Return color of pixel
*)
asm
    mwa x DParameters
    mwa y DParameters+2
    @SendMessage
	.byte 	5,33
    lda DParameters
    sta result
end;


procedure DrawLine(x0,y0,x1,y1:word);assembler;
asm

end;


procedure LineTo(x, y: smallint);
(*
@description:
Draw a line starting from current position to a given point
*)
begin
    asm
        mwa CurrentX DParameters
        mwa CurrentY DParameters+2
        mwa x DParameters+4
        mwa y DParameters+6
        @SendMessage
        .byte 	5,2
    end;
    CurrentX:=x;
    CurrentY:=y;
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


procedure OutTextXY(x,y: smallint; s: string);
begin


end;
