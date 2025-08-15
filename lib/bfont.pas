unit bfont;
(*
 @type: unit
 @author: Andrew Danson, Tomasz Biela (Tebe)
 @name: BGI Stroked Font (Borland CHR)
 @version: 1.2

 @description:
 Unit designed to read and interpret Borland CHR stroked file and write to the screen using unit graph

 The CHR files are scalable fonts used by the Borland graphics interface (BGI) to display fonts in graphics mode.

 OFFSET              Count TYPE   Description
 0000h                   4 char   ID='PK',08,08
 0004h                   4 char   ID='BGI '
 0008h                   ? char   Font description, terminated with #26
 0008h                   1 word   Headersize
 +????                            ="SIZ"
                         4 char   Internal font name
                         1 word   Font file size in bytes
                         1 byte   Font driver major version
                         1 byte   Font driver minor version
                         1 word   0100h
                     "SIZ" word   Zeroes to pad out the header
 0080h                   1 char   Signature byte, '+' means stroke font
 0081h                   1 word   Number of chars in font file
                                 ="NUM"
 0083h                   1 byte   undefined
 0084h                   1 byte   ASCII value of first char in file
 0085h                   1 word   Offset to stroke definitions
 0087h                   1 byte   Scan flag ??
 0088h                   1 byte   Distance from origin to top of capital
 0089h                   1 byte   Distance from origin to baseline
 008Ah                   1 byte   Distance from origin to bottom descender
 008Bh                   4 char   Four character name of font
 0090h               "NUM" word   Offsets to character definitions
 0090h+              "NUM" byte   Width table for the characters
 "NUM"*2
 0090h+                           Start of character definitions
 "NUM"*3

 The individual character definitions consist of a variable number of words
 describing the operations required to render a character. Each word
 consists of an (x,y) coordinate pair and a two-bit opcode, encoded as shown
 here:

 Byte 1          7   6   5   4   3   2   1   0     bit #
                op1  <seven bit signed X coord>

 Byte 2          7   6   5   4   3   2   1   0     bit #
                op2  <seven bit signed Y coord>

          Opcodes

        op1=0  op2=0  End of character definition.
        op1=0  op2=1  Do scan
        op1=1  op2=0  Move the pointer to (x,y)
        op1=1  op2=1  Draw from current pointer to (x,y)

*)

{
loadFont
textXY
}

interface

type
  TFName = string[31];
  TSize = real;

{very simple interface!!}
procedure loadFont(fontFile : TFName);
procedure textXY(curX, curY: smallint; size: TSize; colour: byte; s: string);

implementation

uses graph;

type
   FontHeader =  packed record
		    signature  : char;
		    charcount  : word;
		    reserved   : byte;
		    firstchar  : byte;
		    charofset  : word;
		    scanflag   : byte;
		    capheight  : byte;		{capital height}
		    chrheight  : byte;		{standard height}
		    descheight : shortint;	{descender height}
		    fontCode   : array[0..3] of char;
		    unused     : byte;
		 end;


var
   header     : FontHeader;
   charbuffer : array [0..18*1024-1] of byte;	{buffer of drawing instructions for each character}
   charofs    : array[0..255] of word;		{list of ofsets for each character in the char buffer}
   charwidth  : array[0..255] of byte;		{list of character widths}
   msize      : array[0..63] of byte;		{mulitply round(float_size * 0..63)}


procedure loadFont(fontFile : TFName);
var
   input  : file;
   read   : word;
begin
   {initialise space}
   fillchar(charofs, sizeof(charofs), 0);
   fillchar(charwidth, sizeof(charwidth), 0);

   {assign file}
   assign(input, fontFile);
   reset(input, 1);

   {read the header section}
//   seek(input, $80);
   blockread(input, charofs, $80, read);

   blockread(input, header, sizeof(header), read);

   {read the offsets and widths}
//   seek(input, $90);
   blockread(input, charofs[header.firstchar], header.charcount*2, read);
   blockread(input, charwidth[header.firstchar], header.charcount, read);

   {read the stroke data - should be the rest of the file }
//   len := filesize(input) - filepos(input);
   blockread(input,charbuffer, sizeof(charbuffer), read);

   {ok font should be loaded close the file!}
   close(input);
end;


procedure writeChar(x,y: smallint; c:char);
var
   cx,cy      : smallint;
   nx,ny      : smallint;
   yofs	      : smallint;
   bofs       : word;
   op1,op2,op : byte;
   done	      : boolean;

begin
   done:= false;
   cx := x;
   cy := y;
   bofs := charofs[ord(c)];
   yofs := msize[header.capheight - header.descheight];

   y := y + yofs;

   while (not done) do begin

     op1 := charbuffer[bofs];
     op2 := charbuffer[bofs+1];
     
     //op := ((op1 and $80) shr 6) or ((op2 and $80) shr 7);
     op := ( ((op2 and $80) shr 1) or (op1 and $80) ) shr 6;

     inc(bofs, 2);
      
     case op of

      0: done := true;

      2:
      begin

	 if ((op1 and $40) > 0) then
	    cx := x - msize[op1 and $3f]
         else
	    cx := x + msize[op1 and $3f];

	 if ((op2 and $40) > 0) then
	    cy := y + msize[64 - (op2 and $3f)]
         else
	    cy := y - msize[op2 and $3f];

      end;

      3:
      begin

	 if ((op1 and $40) > 0) then
	    nx := x - msize[op1 and $3f]
         else
	    nx := x + msize[op1 and $3f];

	 if ((op2 and $40) > 0) then
	    ny := y + msize[64 - (op2 and $3f)]
         else
	    ny := y - msize[op2 and $3f];

	 line(cx,cy,nx,ny);

	 cx := nx;
	 cy := ny;
      end;
      
     end; 

   end;

end;


procedure textxy(curX, curY: smallint; size: TSize; colour: byte; s: string);
var
   i : byte;
   x : TSize;
begin

   if size <= 0 then exit;

   if size > 3.5 then size := 3.5;

   x:=0;
   for i:=0 to High(msize) do begin
     mSize[i] := round(x);
     x := x + size;
   end;  

   SetColor(colour);

   for i:= 1 to length(s) do begin

      writeChar(curX, curY, s[i]);

      curX := curX + ( msize[ charwidth[ord(s[i])] ] );

   end;

end;


end.
