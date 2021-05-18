// vertical scrolling, smart program (copy only 40 bytes from extended memory)
// modify Display List by Array
// FOR is slowest then MOVE

uses crt, graph,  objects, atari;

{$r vscrol.rc}

const

	bitmap = 0;		// extended memory address

	scr = $8000;		// memory address for antic

	height = 194;		// screen_height = height - 2

	stp = $40;		// antic memory block step

	dls = scr + height*stp;	// display list #1 address
	dls2 = dls + $400;      // display list #2 address

	len = 778-height;	// bitmap lines to display


type
	TLineDisplay = record
			cmd: byte;
			adr: word;
		       end;

var
	m: TMemoryStream;

	dlist: ^TLineDisplay;
	p: ^byte;

	i: byte;
	lines: word;

	add: smallint;

	l_block, h_block: array [0..height-1] of byte;

begin

 dlist:=pointer(dls);

 color0:=4;
 color1:=6;
 color2:=8;
 color4:=0;

 m.Create;
 m.position := bitmap;

 for i:=0 to length(l_block)-1 do begin
  p:=pointer(scr+i*stp);

  l_block[i] := lo(word(p));
  h_block[i] := hi(word(p));

  m.ReadBuffer(p^, 40);
 end;

 dlist^.cmd := $70 ;
 dlist^.adr := $7070;
 inc(dlist);

 for i:=1 to length(l_block)-2 do begin
  dlist^.cmd := $4e;
  dlist^.adr := l_block[i] + h_block[i] shl 8;
  inc(dlist);
 end;

 dlist^.cmd := $41;
 dlist^.adr := dls;

 sdlstl := dls;

 add := 1;

 repeat
  pause;

  p:=pointer(l_block[length(l_block)-1] + h_block[length(l_block)-1] shl 8);

  if add > 0 then begin

   for i:=0 to length(l_block)-2 do begin
    l_block[i] := l_block[i+1];
    h_block[i] := h_block[i+1];
   end;

   l_block[length(l_block)-1] := l_block[0];
   h_block[length(l_block)-1] := h_block[0];

  end else begin

   for i:=length(l_block)-2 downto 0 do begin
    l_block[i+1] := l_block[i];
    h_block[i+1] := h_block[i];
   end;

   l_block[0] := l_block[length(l_block)-1];
   h_block[0] := h_block[length(l_block)-1];

   dec(m.position, 80);

  end;

  m.ReadBuffer(p^, 40);

  dlist := pointer(dls + 3);

  for i:=1 to length(l_block)-2 do begin
   dlist^.adr := l_block[i] + h_block[i] shl 8;
   inc(dlist);
  end;

  inc(lines, add);

  if (lines = len) or (lines = 0) then begin
   add := -add;

   if add > 0 then
    inc(m.position, (height-2)*40)
   else
    dec(m.position, (height-2)*40);

  end;

 until keypressed;

end.
