
procedure Dye(x,y: smallint; color: byte);
var xStack, yStack: array [0..4095] of smallint;
    stackEntry: word;
    sx: smallint;
    spanAbove, spanBelow: Boolean;
    oldColor, belowColor, aboveColor: byte;
begin
	oldColor := GetPixel(x,y);

	if (oldColor = color) then exit;

	SetColor(color);

	stackEntry := 1;

	repeat

		while (x > 0) and (GetPixel(x-1,y) = oldColor) do dec(x);

		spanAbove := false;
		spanBelow := false;

		sx := x;

		while (x < ScreenWidth) and (GetPixel(x,y) = oldColor) do begin

			if (y < smallint(ScreenHeight-1)) then begin

				belowColor := GetPixel(x, y+1);

				if (spanBelow=false) and (belowColor = oldColor) then begin

					xStack[stackEntry]  := x;
					yStack[stackEntry]  := y+1;
					inc(stackEntry);

					if stackEntry > sizeof(xStack) then exit;

					spanBelow := true;
				end
				else if (spanBelow=true) and (belowColor <> oldColor) then
					spanBelow := false;
			end;

			if (y > 0) then begin

				aboveColor := GetPixel(x, y-1);

				if (spanAbove=false) and (aboveColor = oldColor) then begin

					xStack[stackEntry]  := x;
					yStack[stackEntry]  := y-1;
					inc(stackEntry);

					if stackEntry > sizeof(xStack) then exit;

					spanAbove := true;
				end
				else if (spanAbove=true) and (aboveColor <> oldColor) then
					spanAbove := false;
			end;

			inc(x);
		end;

		dec(x);

		Line(sx,y,x,y);

		dec(stackEntry);
		x := xStack[stackEntry];
		y := yStack[stackEntry];

	until stackentry=0;

end;
