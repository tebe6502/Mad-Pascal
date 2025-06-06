{ Bob's fury font unit 
   Unit designed to read and interpret Borland CHR stroked file and write to the screen
   using bobgraph (could be adapted to any graphics unit)
   This will replace the stroked font functionality in the BGI for the game, and should
   be faster as it won't use real or single for scaling the font.
   
   A Danson 2022 }

unit bfont;

interface

{very simple interface!!}
procedure loadFont(fontFile : string);
procedure textxy(x,y,size, colour : integer; s:string);

implementation

uses bobgraph;

type
   FontHeader =  record
		    signature  : char;
		    charcount  : word;
		    reserved   : byte;
		    firstchar  : byte;
		    charofset  : word;
		    scanflag   : byte;
		    capheight  : byte; {capital height}
		    chrheight  : byte; {standard height}
		    descheight : shortint; {descender height}
		    fontCode   : array[1..4] of char;
		    unused     : byte;
		 end;


var
   header     : FontHeader;
   charbuffer : pointer; {pointer to buffer of drawing instructions for each character}
   charofs    : array[0..255] of word; {list of ofsets for each character in the char buffer}
   charwidth  : array[0..255] of byte; {list of character widths }

procedure loadFont(fontFile : string);
var
   input  : file;
   read	  : word;
   length : longint;
begin
   {initialise space}
   fillchar(charofs,sizeof(charofs),0);
   fillchar(charwidth,sizeof(charwidth),0);
   {assign file}
   assign(input,fontFile);
   reset(input,1);
   {read the header section}
   seek(input, $80);
   blockread(input,header,sizeof(header),read);
   {read the offsets and widths}
   seek(input, $90);
   blockread(input,addr(charofs[header.firstchar])^,header.charcount*2, read);
   blockread(input,addr(charwidth[header.firstchar])^,header.charcount, read);

   {read the stroke data - should be the rest of the file }
   length := filesize(input) - filepos(input);
   getmem(charbuffer,length+1);
   blockread(input,charbuffer^, length, read);

   {ok font should be loaded close the file!}
   close(input);
end;

procedure writeChar(x,y,colour : integer; c:char);
var
   cx,cy      : integer;
   nx,ny      : integer;
   bseg,bofs  : integer;
   op1,op2,op : byte;
   n1,n2      : boolean;
   done	      : boolean;
   yofs	      : integer;
begin
   done:= false;
   cx := x;
   cy := y;
   bseg := seg(charbuffer^);
   bofs := ofs(charbuffer^) + charofs[ord(c)];
   yofs := (header.capheight - header.descheight);
   y := y + yofs;
   while (not done) do
   begin
      op1 := mem[bseg:bofs];
      op2 := mem[bseg:bofs+1];
      op := ((op1 and $80) shr 6) or  ((op2 and $80) shr 7);
      bofs := bofs + 2;
      if (op=0) then done := true;
      if (op=3) then
      begin
	 n1 := (op1 and $40) > 0;
	 n2 := (op2 and $40) > 0;
	 op1 := op1 and $3f;
	 op2 := op2 and $3f;
	 if (n1) then
	 begin
	    nx := x - op1; 
	 end
         else
	 begin
	    nx := x + op1;
	 end;
	 if (n2) then
	 begin
	    ny := y + (64 - op2);
	 end
         else
	 begin
	    ny := y - op2;
	 end;
	 line(cx,cy,nx,ny,colour);
	 cx := nx;
	 cy := ny;
      end;
      if (op=2) then
      begin
	 n1 := (op1 and $40) > 0;
	 n2 := (op2 and $40) > 0;
	 op1 := op1 and $3f;
	 op2 := op2 and $3f;
	 if (n1) then
	 begin
	    cx := x - op1;
	 end
         else
	 begin
	    cx := x + op1;
	 end;
	 if (n2) then
	 begin
	    cy := y + (64 - op2 );
	 end
         else
	 begin
	    cy := y - op2;
	 end;
      end;
   end;
end;

procedure writeCharScaled(x,y,colour,size : integer; c:char);
var
   cx,cy      : integer;
   nx,ny      : integer;
   bseg,bofs  : integer;
   op1,op2,op : byte;
   done	      : boolean;
   yofs	      : integer;
begin
   done:= false;
   cx := x;
   cy := y;
   bseg := seg(charbuffer^);
   bofs := ofs(charbuffer^) + charofs[ord(c)];
   yofs := (header.capheight - header.descheight) * size;
   y := y + yofs;
   while (not done) do
   begin
      op1 := mem[bseg:bofs];
      op2 := mem[bseg:bofs+1];
      op := ((op1 and $80) shr 6) or  ((op2 and $80) shr 7);
      bofs := bofs + 2;
      if ( op = 0) then done := true;
      
      if ( op = 3 ) then
      begin
	 if ((op1 and $40) >0) then
	 begin
	    nx := x - (( op1 and $3f) * size);
	 end
         else
	 begin
	    nx := x + ((op1 and $3f)* size);
	 end;
	 if ((op2 and $40) >0) then
	 begin
	    ny := y + ((64 - (op2 and $3f))*size);
	 end
         else
	 begin
	    ny := y - ((op2 and $3f) * size);
	 end;
	 line(cx,cy,nx,ny,colour);
	 cx := nx;
	 cy := ny;
      end;
      if (op = 2) then
      begin
	 if ((op1 and $40) >0) then
	 begin
	    cx := x - (( op1 and $3f) * size);
	 end
         else
	 begin
	    cx := x + ((op1 and $3f) * size);
	 end;
	 if ((op2 and $40) >0) then
	 begin
	    cy := y + ((64 - (op2 and $3f)) * size);
	 end
         else
	 begin
	    cy := y - ((op2 and $3f) * size);
	 end;
      end;
   end;
end;

procedure textxy(x,y,size, colour : integer; s:string);
var
   curX,curY : integer;
   strpos    : byte;
   cc	     : char;
   i	     : word;
begin
   curX := x;
   curY := y;
   size := size shr 2; {divide size by 4}
   for i:= 1 to length(s) do
   begin
      if size=1 then
	 writeChar(curX,curY,colour,s[i])
      else
	 writeCharScaled(curX,curY,colour,size,s[i]);
      curX := curX + (charwidth[ord(s[i])] * size);
   end;
end;


end.
