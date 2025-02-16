unit vimage;
(*
@type: unit
@name: A unit to load a variety of image formats for VBXE
@author: Steven Henk Don (https://www.shdon.com/), Tomasz Biela (Tebe)

@description:
*****************************************************************************
** VIMAGE unit (14.01.2018) VBXE					   **
**   by Steven Henk Don, Tomasz Biela					   **
*****************************************************************************
** A unit to load a variety of image formats to a buffer.		   **
**                                                                         **
** Supported image formats are: Windows BMP		DOS II/D, SDX	   **
**                              Compuserve GIF (87a)	DOS II/D, SDX	   **
**                              Z-Soft PCX		SDX (Seek) !!!	   **
**                                                                         **
** Images must be in 256 colours and may be up to 336x240 in size.         **
*****************************************************************************
** Three functions are available to the calling program:		   **
**                                                                         **
**   LoadVBMP (FileName, Location);					   **
**   LoadVGIF (FileName, Location);					   **
**   LoadVPCX (FileName, Location);					   **
**                                                                         **
** Name is the filename, including extension (e.g. TEST.GIF)               **
** Location is a pointer to an Array [0..64000] of Byte; where the image   **
** data will be stored.                                                    **
** All functions are boolean. If they return false, check IMGERROR to find **
** out what happened.                                                      **
**                                                                         **
*****************************************************************************
*)

{

LoadVBMP
LoadVGIF
LoadVPCX

}

interface

uses crt, graph, vbxe, sysutils;

{$i imageh.inc}

var
	IMGError: byte;


{Error codes}
const
  FileNotFound      = $01;
  UnsupportedFormat = $02;
  TooLarge          = $03;


	function LoadVBMP(Filename: PString; Location: cardinal): Boolean;
	function LoadVPCX(Filename: PString; Location: cardinal): Boolean;
	function LoadVGIF(FileName: PString; Location: cardinal): Boolean;


implementation

var
	Buffer	: array [0..255] of byte absolute $0400;

	vram: TVBXEMemoryStream;

	f: file;


procedure UpdateXDL(Location: cardinal; Top: word; Height: word);
(*
@description:

*)
var xdl: TXDL;
begin

  GetXDL(xdl);

  xdl.ov_step := 336;
  xdl.ov_width := %00010010;	// playfield pal = 0 ; overlay pal = 1 ; width = 3

  xdl.ov_adr.byte2 := Location shr 16;
  xdl.ov_adr.byte1 := Location shr 8;
  xdl.ov_adr.byte0 := Location;

  if Height>240 then begin
  xdl.rptl_ := 0;
  xdl.rptl := 240;
  end else begin
   xdl.rptl_ := Top;
   xdl.rptl  := Height;
  end;

  SetXDL(xdl);

end;


procedure LoadPalette(cnt: byte; x, ln, a,b,c: byte);
(*
@description:

*)
var i: word;
begin

 SetRGBPalette(1, x);

 for i:=0 to cnt do begin
  blockread(f, Buffer, ln);
  SetRGBPalette(Buffer[a], Buffer[b], Buffer[c]);
 end;

end;


function LoadVPCX(Filename: PString; Location: cardinal): Boolean;
(*
@description:
This loads a PCX File (8bit)
*)
var
  Header			: PCXHeader;
  DOffSet, OffSet, Width, Height: Word;
  HowMany, DataByte, Counter	: Byte;
  nextPointer			: Word;
  X, Y, nY			: Word;

  {This function reads the next byte from the PCX file}
  function NextByte : Byte;
  begin

    {Check to see whether next block should be read}
    if nextPointer < 1 then begin
      {If so, read it and reset the pointer}
      {$I-}
      BlockRead (f, Buffer [1], 512);
      if IOResult <> 0 then;
      {$I+}
      nextPointer := 1;
    end;

    {Return byte in buffer}
    Result := Buffer [nextPointer];

    {Adjust pointer}
    inc (nextPointer);
    if nextPointer > 512 then NextPointer := 0;
  end;

begin
  {No errors yet}
  IMGError := 0;

  {Check to see whether the file exists and can be opened}
  if not(FileExists(FileName)) then begin
    IMGError := FileNotFound;
    Result := false;
    Exit;
  end;

  assign(f, Filename); reset(f, 1);

  {Read in header information}
  BlockRead (f, Header, SizeOf (Header));


  {Check to see whether we can display it}
  if Header.Version <> 5 then begin
    Close (f);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  if (word(Header.xMax) > 336-1) or (Header.xMin < 0)
  or (word(Header.yMax) > 256-1) or (Header.yMin < 0) then begin
    Close (f);
    IMGError := TooLarge;
    Result := false;
    Exit;
  end;

  x := Header.xMin;
  y := Header.yMin;
  inc (Header.xMax);
  inc (Header.yMax);

  {Figure out where to load graphics data}

  UpdateXDL(Location, Header.yMin, Header.yMax);

  vram.position:=Location+X;


  {Load in the palette}
  Seek (f, FileSize (f) - 769);

  {Read in identifier}
  BlockRead (f, DataByte, 1);
  if DataByte <> 12 then begin
    Close (f);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  LoadPalette(255,0, 3, 0,1,2);

  {Go back to start of graphic data}
  Seek (f, 128);


  {Initialize loader}
  nextPointer := 0;

  nY:=0;

  {Decode and display graphics}
  While (Y < word(Header.yMax)) do begin
    {Read next byte}
    DataByte := NextByte;

    {Reset counter}
    HowMany := 1;

    {If it is encoded, extract the count information and read in the colour byte}
    if (DataByte and $C0) = $C0 THEN begin
      HowMany := DataByte and $3F;
      DataByte := NextByte;
    end;

    {Display it}
    for Counter := 1 to HowMany do begin
      {Store pixel in the buffer}

      vram.WriteByte(DataByte);
      {Next pixel}
      inc (X);

      {If End of Line reached, next line}
      if X = word(Header.xMax) then begin
        X := Header.xMin;
	inc(Y);
	inc(nY);
	vram.position:=Location+X+nY*336;
      end;

    end;
  end;

  {Close the file}
  Close (f);

  {Successful}
  Result := true;

  VBXEMemoryBank(0);

end;


function LoadVBMP(Filename: PString; Location: cardinal): Boolean;
(*
@description:
This loads a BMP File (4bit, 8bit)
*)
var Header: TBmpHeader;
    x, w, h: word;
    b, v, i: byte;
    a: cardinal;
begin

 if not FileExists(Filename) then begin
   IMGError:=FileNotFound;
   Result:=false;
   exit;
 end;

 assign(f, Filename); reset(f, 1);

 blockread(f, Header, sizeof(Header));

 w:=Header.biwidth;
 h:=Header.biheight;
 b:=Header.bibitcount;

 {Check to see whether we can display it}
 if (Header.bfType <> 19778)
 or (Header.bfReserved <> 0)
 or (Header.biPlanes <> 1)
 or (Header.biCompression <> 0)
 or ((b <> 4) and (b <> 8)) then begin
   Close (f);
   IMGError := UnsupportedFormat;
   Result := false;
   Exit;
 end;

 if (w>336) or (h>256) then begin
  IMGError := TooLarge;
  Result := false;
  Exit;
 end;

 if w and 3<>0 then w:=w and $fffc + 4;

 dec(h);

 UpdateXDL(Location, (240-h) shr 1, h);

 vram.position:=Location+h*336;

 {Set the palette}

 case b of
  4: begin v:=16-1; x:=64 end;
  8: begin v:=256-1; x:=1024 end;
 end;

 blockread(f, Buffer, Header.bfOffBits-x-sizeof(TBMPHeader));	// offset do tablicy pikseli obrazka

 LoadPalette(v, Header.biClrImportant, 4, 2,1,0);

 x:=0;

 while not eof(f) do begin

	case b of
	  4:  begin
		blockread(f, Buffer[128], 64);

		for i:=0 to 63 do begin
		  v:=Buffer[128+i];
		  Buffer[i shl 1]:=v shr 4;
		  Buffer[i shl 1+1]:=v and $0f;
		end;

	      end;

	  8: blockread(f, Buffer, 128);

	end;


	if word(x+128) < w then begin

	 vram.WriteBuffer(Buffer, 128);
	 inc(x, 128);

	end else

	for i:=0 to 127 do begin

	 vram.WriteByte(Buffer[i]);

	 inc(x);

	 if x = w then begin
		x:=0;
		dec(vram.position, w + 336);
	 end;

	end;

 end;

 {Close the file}
 Close (f);

 {Successful}
 Result := true;

 VBXEMemoryBank(0);

end;


function LoadVGIF(FileName: PString; Location: cardinal): Boolean;
(*
@description:
This loads a GIF File (GIF87a)
*)
var
  {For loading from the GIF file}
  Header       : GIFHeader;
  Descriptor   : GIFDescriptor;
  Temp         : Byte;
  BPointer     : Word;

  {Colour information}
  BitsPerPixel,
  NumOfColours,
  DAC          : Byte;

  {Coordinates}
  X, Y, nY,
  tlX, tlY,
  brX, brY     : Word;

  {GIF data is stored in blocks of a certain size}
  BlockSize    : Byte;

  {The string table}
  Prefix,
  Suffix       : Array [0..4096] Of Word;
  OutCode      : Array [0..1024] Of Byte;
  FirstFree,
  FreeCode     : Word;

  {All the code information}
  InitCodeSize,
  CodeSize     : Byte;
  Code,
  OldCode,
  MaxCode      : Word;

  {Special codes}
  ClearCode,
  EOICode      : Word;

  {Used while reading the codes}
  BitsIn       : Byte;


const

 BitShift: array [0..15] of word = (1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000);


  {Local function to read from the buffer}
  function LoadByte : Byte;
  begin
    {Read next block}
    if (BPointer = BlockSize) then begin
      {$I-}
      BlockRead (f, Buffer, BlockSize + 1);
      if IOResult <> 0 then;
      {$I+}
      BPointer := 0;
    end;
    {Return byte}
    Result := Buffer [BPointer];
    inc (BPointer);
  end;

  {Local procedure to read the next code from the file}
  procedure ReadCode;
  var
    Counter : Byte;

  begin
    Code := 0;
    {Read the code, bit by bit}
    for Counter := 0 To CodeSize - 1 do begin
      {Next bit}
      inc (BitsIn);

      {Maybe, a new byte needs to be loaded with a further 8 bits}
      if (BitsIn = 9) then begin
        Temp := LoadByte;
        BitsIn := 1;
      end;

      {Add the current bit to the code}
      if ((Temp and 1) > 0) then inc (Code, BitShift[Counter]);
      Temp := Temp shr 1;
    end;
  end;

  {Local procedure to draw a pixel}
  procedure NextPixel (c : byte);
  begin
    {Actually draw the pixel on screen}
    vram.WriteByte(c);

    {Move on to next pixel}
    inc (X);

    {Or next row, if necessary}
    if (X = brX) then begin
      X := tlX;
      inc (Y);
      inc(nY);
      vram.Position:=Location+X+nY*336;
    end;
  end;

  {Local function to output a string. Returns the first character.}
  function OutString (CurCode : Word) : Byte;
  var
    OutCount : Word;

  begin
    {If it's a single character, output that}
    if CurCode < 256 then begin
      NextPixel (CurCode);
    end else begin
      OutCount := 0;

      {Store the string, which ends up in reverse order}
      repeat
        OutCode [OutCount] := Suffix [CurCode];
        inc (OutCount);
        CurCode := Prefix [CurCode];
      until (CurCode < 256);

      {Add the last character}
      OutCode [OutCount] := CurCode;
      inc (OutCount);

      {Output all the string, in the correct order}
      repeat
        dec (OutCount);
        NextPixel (OutCode [OutCount]);
      until OutCount = 0;
    end;
    {Return 1st character}
    Result := CurCode;
  end;

begin
  {No errors yet}
  IMGError := 0;

  {Check to see whether the file exists and can be opened}
  if not(FileExists(FileName)) then begin
    IMGError := FileNotFound;
    Result := false;
    Exit;
  end;

  assign(f, Filename); reset(f, 1);

  {Read header}
  Header.Signature [0] := Chr (6);
  Blockread (f, Header.Signature [1], sizeof (Header) - 1);

  {Check signature and terminator}
  if ((Header.Signature <> 'GIF87a') {and (Header.Signature <> 'GIF89a')})
  or (Header.Zero <> 0) then begin
    Close (f);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  {Get amount of colours in image}
  BitsPerPixel := 1 + (Header.Depth and 7);
  NumOfColours := (BitShift[BitsPerPixel]) - 1;

  {Load global colour map}
  LoadPalette(NumOfColours, 0, 3, 0,1,2);

  {Load the image descriptor}
  BlockRead (f, Descriptor, sizeof (Descriptor));

  if (Descriptor.Separator <> ',')
  or (Descriptor.Depth and 192 > 0) then begin
    Close (f);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  {Get image corner coordinates}
  tlX := Descriptor.ImageLeft;
  tlY := Descriptor.ImageTop;
  brX := tlX + Descriptor.ImageWidth;
  brY := tlY + Descriptor.ImageHeight;

  if (brX > 336) or (brY > 256) then begin
    Close (f);
    IMGError := TooLarge;
    Result := false;
    Exit;
  end;


  UpdateXDL(Location, tly, Descriptor.ImageHeight);

  vram.position:=Location+tlX;


  {Get initial code size}
  BlockRead (f, CodeSize, 1);

  {GIF data is stored in blocks, so it's necessary to know the size}
  BlockRead (f, BlockSize, 1);

  {Start loader}
  BPointer := BlockSize;

  {Special codes used in the GIF spec}
  ClearCode        := BitShift[CodeSize];    {Code to reset}
  EOICode          := ClearCode + 1;     {End of file}

  {Initialize the string table}
  FirstFree        := ClearCode + 2;     {Strings start here}
  FreeCode         := FirstFree;         {Strings can be added here}

  {Initial size of the code and its maximum value}
  inc (CodeSize);
  InitCodeSize     := CodeSize;
  MaxCode          := BitShift[CodeSize];

  BitsIn := 8;

  {Start at top left of image}
  X := Descriptor.ImageLeft;
  Y := Descriptor.ImageTop;

  nY := 0;

  repeat
    {Read next code}
    ReadCode;

    {If it's an End-Of-Information code, stop processing}
    if Code = EOICode then break
    {If it's a clear code...}
    else if Code = ClearCode then begin
      {Clear the string table}
      FreeCode := FirstFree;

      {Set the code size to initial values}
      CodeSize := InitCodeSize;
      MaxCode  := BitShift[CodeSize];

      {The next code may be read}
      ReadCode;
      OldCode := Code;

      {Set pixel}
      NextPixel (Code);
    {Other codes}
    end else begin
      {If the code is already in the string table, it's string is displayed,
      and the old string followed by the new string's first character is
      added to the string table.}
      if (Code < FreeCode) then
        Suffix [FreeCode] := OutString (Code)
      else begin
      {If it is not already in the string table, the old string followed by
      the old string's first character is added to the string table and
      displayed.}
        Suffix [FreeCode] := OutString (OldCode);
        NextPixel (Suffix [FreeCode]);
      end;

      {Finish adding to string table}
      Prefix [FreeCode] := OldCode;
      inc (FreeCode);

      {If the code size needs to be adjusted, do so}
      if (FreeCode >= MaxCode) and (CodeSize < 12) then begin
        inc (Codesize);
        MaxCode := MaxCode shl 1;
      end;

      {The current code is now old}
      OldCode := Code;
    end;

  until Code = EOICode;

  {Close the GIF file}
  Close (f);

  {Successful}
  Result := true;

  VBXEMemoryBank(0);
end;

end.
