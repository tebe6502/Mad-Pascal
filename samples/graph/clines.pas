uses crt, fastgraph;

const xsize	   = 80;
const ysize	   = 48;	
const maxLines     = 5;
const xspeed	   = 1;

const lineSpanX	   = xsize div (maxLines-1);
const lineSpanY	   = ysize div 3;
const lineY1	   = 0;
const LineY2 	   = lineSpanY;
const LineY3 	   = lineSpanY shl 1;
const LineY4       = ysize-1;
const XOffset     = xsize shr 2;
      
var lineX1, lineX2, i, c, sc: Byte;

	
procedure putLine(x: Byte);	
begin
		lineX2 := (x shr 1) + XOffset;
		MoveTo (x, lineY1);
		LineTo (lineX2, lineY2);	
		LineTo (lineX2, lineY3);
		LineTo (x, lineY4);	
end;
	
procedure setAtX(x: Byte);
begin
	for i := 0 to maxLines-1 do begin 

		SetColor(c);
		putLine(x);
		Inc(c);
		if c>3 then c:=1;
		Inc(x, lineSpanX);
    end; 
end;
 
begin

	InitGraph(5 + 16);
	LineX1 := 0; 
	sc := 1;
	repeat 
		pause;

		fillchar(pointer(dpeek(88)), 20*48, 0);

		c := sc;
		setAtX(LineX1);
		Inc(LineX1,xspeed);
		if LineX1 >= lineSpanX then begin
			Dec(sc);
			if sc<1 then sc:=3;
			LineX1 := 0;
		end;
	until KeyPressed;

end.