// vertical scrolling, smart program (copy only 40 bytes from extended memory)
// modify DisplyList by Pointer to Record
// FOR loop replaced by MOVE

uses crt, graph,  objects, atari;

{$r vscrol.rc}

const

	bitmap = 0;		// extended memory address
	bitmap2 = 1000;		// extended memory address

	scr = $8000;		// memory address for antic

	height = 194;		// screen_height = height - 2

	stp = $40;		// antic memory block step

	dls = scr + height*stp;	// display list #1 address

	len = 778-height;	// bitmap lines to display


type
	TLineDisplay = record
			cmd: byte;
			adr: word;
		       end;

var
	m: TMemoryStream;

	dlist, first, last: ^TLineDisplay;

	p: ^byte;

	i: byte;
	lines: word;

	add: smallint;

begin

 dlist:=pointer(dls);

 color0:=4;
 color1:=6;
 color2:=8;
 color4:=0;

 m.Create;
 m.position := bitmap;

 dlist^.cmd := $70 ;
 dlist^.adr := $7070;
 inc(dlist);

 for i:=0 to height-2 do begin
  p:=pointer(scr+i*stp);

  dlist^.cmd := $4e;
  dlist^.adr := word(p);
  inc(dlist);

  m.ReadBuffer(p^, 40);
 end;

 dlist^.cmd := $41;
 dlist^.adr := dls;

 sdlstl := dls;					// dpoke 560,dls

 add := 1;

 first := pointer(dls + 3);		   	// first display line
 last := pointer(dls + (height-2)*3 + 3);  	// last display line

 repeat
//  colbak:=0;
  while vcount<>114 do;
//  colbak:=$f;

  p := pointer(first^.adr);

  if add > 0 then begin

   move(pointer(dls+6), pointer(dls+3), (height-2)*3);

   last^.adr := first^.adr;

  end else begin

   move(pointer(dls+3), pointer(dls+6), (height-2)*3);

   first^.adr := last^.adr;

   dec(m.position, 80);

  end;

  m.ReadBuffer(p^, 40);

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
