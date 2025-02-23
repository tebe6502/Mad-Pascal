unit image;
(*
@type: unit
@name: A unit to load a variety of image formats for ANTIC/GTIA
@author: Steven Henk Don <https://www.shdon.com/>, Tomasz Biela (Tebe)

@description:
Load BMP, GIF, PCX, MIC, PIC.
*)

(****************************************************************************
** IMAGE unit, ANTIC/GTIA						   **
**  by Steven Henk Don, Tomasz Biela					   **
*****************************************************************************
** A unit to load a variety of image formats.				   **
**                                                                         **
** Supported image formats are: Windows BMP                                **
**				Compuserve GIF (87a)			   **
**				Z-Soft PCX				   **
**				MIC Micropainter			   **
**				PIC Koala Microillustrator		   **
**                                                                         **
** Images must be in 4 colours and may be up to 320x192 in size.           **
*****************************************************************************
** Three functions are available to the calling program:                   **
**                                                                         **
**   LoadMIC (FileName, Location);					   **
**   LoadPIC (FileName, Location);					   **
**   LoadBMP (FileName);						   **
**   LoadGIF (FileName);						   **
**   LoadPCX (FileName);						   **
**                                                                         **
** Name is the filename, including extension (e.g. TEST.GIF)               **
** All functions are boolean. If they return false, check IMGERROR to find **
** out what happened.                                                      **
**                                                                         **
****************************************************************************)


{

LoadMIC
LoadPIC
LoadBMP
LoadGIF
LoadPCX

}

interface

uses atari, sysutils, graph;

{$i imageh.inc}

var
	IMGError: byte;		(* @var =0 if operation successfull *)

{Error codes}
const
  FileNotFound      = $01;
  UnsupportedFormat = $02;
  TooLarge          = $03;


	function LoadMIC(const FileName: TString; Location: pointer): Boolean;
	function LoadPIC(const FileName: TString; Location: pointer): Boolean;
	function LoadBMP(const FileName: TString): Boolean;
	function LoadPCX(const FileName: TString): Boolean;
	function LoadGIF(const FileName: TString): Boolean;

implementation

var
	Buffer		: array [0..0] of byte absolute $0400;
	nextPointer	: Word;
	f: file;


function NextByte : Byte;
(*
@description:
This function reads the next byte from the PIC/PCX file

*)
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


function LoadPIC(const FileName: TString; Location: pointer): Boolean;
(*
@description:
This loads a PIC File to the specified location

*)
var Header		: TPicHeader;
    i, ile		: word;
    tmp, px, py, v	: byte;
    scrwidth, scrheight	: byte;

    buf: array [0..255] of byte;

    tab: array [0..0] of byte;


procedure PutPic(a: byte);
var i: byte;
begin

case Header.typcprs of
 1: begin
     buf[tmp]:=a; inc(tmp);
     if tmp=scrheight then begin
      tmp:=0;
      for i:=0 to (scrheight shr 1)-1 do begin
       tab[px+i*80]:=buf[i];
       tab[px+i*80+40]:=buf[scrheight shr 1+i];
      end;
      inc(px);
     end;
    end;

 2: begin
     buf[tmp]:=a; inc(tmp);
     if tmp=scrwidth then begin
      tmp:=0;
      for i:=0 to scrwidth-1 do tab[px+i+py*40]:=buf[i];
      inc(py);
     end;
    end;
end;

end;


begin

 {Check to see whether the file exists and can be opened}
 if not(FileExists(Filename)) then begin
   IMGError := FileNotFound;
   Result := false;
   Exit;
 end;

 tab:=pointer(Location);

 assign(f, FileName); reset(f, 1);

 blockread(f, Header, sizeof(Header));

 if Header.id <> $c7c980ff then begin
  Close(f);
  IMGError := UnsupportedFormat;
  Result:=false;
  Exit;
 end;

 scrwidth := Header.scrwidth shr 8;
 scrheight := Header.scrheight shr 8;

 if (scrwidth<>40) and (scrwidth<>48) then begin
  Close(f);
  IMGError := UnsupportedFormat;
  Result:=false;
  Exit;
 end;

 colbaks:=Header.colors[4];
 color0:=Header.colors[0];
 color1:=Header.colors[1];
 color2:=Header.colors[2];
 color3:=Header.colors[3];

 ile:=Header.headln;

 if (ile=0) or (ile>1024) then ile:=26;
 blockread(f, Buffer,ile-21);		// naglowek ma 21 bajtow

 nextPointer:=0;

 tmp:=0; px:=0; py:=0;

 while (px<>scrwidth) and (py<>scrheight) do begin

      v:=NextByte;

      case (v and $80) of
       $00: begin			// z kompresja
             ile:=v;
             if ile=0 then begin	// wiekszy blok
              ile:=NextByte shl 8 + NextByte;
             end;
             v:=NextByte;
             for i:=0 to ile-1 do putPic(v);
            end;

       $80: begin			// bez kompresji
             ile:=v and $7f;
             if ile=0 then begin	// wiekszy blok danych
              ile:=NextByte shl 8 + NextByte;
             end;
             for i:=0 to ile-1 do putPic(NextByte);
            end;
      end;

 end;

 {Close the file}
 Close (f);

 {Successful}
 Result := true;

end;


function LoadMIC(const FileName: TString; Location: pointer): Boolean;
(*
@description:
This loads a MIC File to the specified location

*)
begin

  {Check to see whether the file exists and can be opened}
  if not(FileExists(Filename)) then begin
    IMGError := FileNotFound;
    Result := false;
    Exit;
  end;

  assign(f, FileName);
  reset(f, 1);

  blockread(f, Location^, 192*40);

  Location:=pointer(712);
  blockread(f, Location^, 1);

  Location:=pointer(708);
  blockread(f, Location^, 3);

  {Close the file}
  Close (f);

  {Successful}
  Result := true;

end;


function LoadBMP(const FileName: TString): Boolean;
(*
@description:
This loads a BMP File (4bit, 8bit)

*)
var
  BMPFile			: File;
  Header			: TBMPHeader;
  OffSet, Counter		: Word;
  Lines				: smallint;

begin
  {No errors yet}
  IMGError := 0;

  {Check to see whether the file exists and can be opened}
  if not(FileExists(Filename)) then begin
    IMGError := FileNotFound;
    Result := false;
    Exit;
  end;

  {Read in header information}
  assign(BMPFile, Filename); reset(BMPFile, 1);
  BlockRead (BMPFile, Header, SizeOf (Header));

  {Check to see whether we can display it}
  if (Header.bfType <> 19778)
  or (Header.bfReserved <> 0)
  or (Header.biPlanes <> 1)
  or (Header.biCompression <> 0)
  or (Header.biBitCount <> 8) then begin
    Close (BMPFile);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  if (Header.biWidth > 320) or (Header.biHeight > 192) then begin
    Close (BMPFile);
    IMGError := TooLarge;
    Result := false;
    Exit;
  end;


  {Load in the palette}
//  BlockRead (BMPFile, Palette, 1024);

  BlockRead (BMPFile, Buffer, 512);
  BlockRead (BMPFile, Buffer, 512);

  {Set the palette}
  {
  for Counter := 0 to 255 do begin
    SetDAC (Counter,
            Palette [Counter, 2] shr 2,
            Palette [Counter, 1] shr 2,
            Palette [Counter, 0] shr 2);
  end;
}


  {Figure out where to load graphics data}
  Lines := Header.biHeight - 1;

  {Stored upside down, so moving up}
  while (Lines >= 0) do begin
    {Read next line}
    BlockRead (BMPFile, Buffer, Header.biWidth);

    for Counter := 0 to Header.biWidth-1 do
      PutPixel(Counter, Lines, buffer[Counter]);

    {increase amount of lines read}
    dec (Lines);
  end;

  {Close the file}
  Close (BMPFile);

  {Successful}
  Result := true;
end;


function LoadPCX(const FileName: TString): Boolean;
(*
@description:
This loads a PCX File (8bit)

*)
var
  Header                         : PCXHeader;
  PCXLen                         : LongInt;
  DOffSet, OffSet, Width, Height : Word;
  HowMany, DataByte, Counter     : Byte;
  X, Y                           : smallint;

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

  if (Header.xMax > 319) or (Header.xMin < 0)
  or (Header.yMax > 199) or (Header.yMin < 0) then begin
    Close (f);
    IMGError := TooLarge;
    Result := false;
    Exit;
  end;

  {Load in the palette}
 (*
  Seek (f, FileSize (f) - 769);
  {Read in identifier}
  BlockRead (f, DataByte, 1);
  if DataByte <> 12 then begin
    Close (f);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  BlockRead (f, Palette[0, 0], 768);

  {Set the palette}

  for Counter := 0 to 255 do begin
    SetDAC(Counter,
           Palette [Counter, 0] shr 2,
           Palette [Counter, 1] shr 2,
           Palette [Counter, 2] shr 2);
  end;
*)

  {Go back to start of graphic data}
//  Seek (f, 128);

  x := Header.xMin;
  y := Header.yMin;
  inc (Header.xMax);
  inc (Header.yMax);

  {Figure out where to load graphics data}
//  Buffer := Location;

  {Initialize loader}
  nextPointer := 0;

  {Decode and display graphics}
  While (Y < Header.yMax) do begin
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
      PutPixel (X, Y, DataByte);
      {Next pixel}
      inc (X);

      {If End of Line reached, next line}
      if X = Header.xMax then begin
        inc (Y);
        X := Header.xMin;
      end;

    end;
  end;

  {Close the file}
  Close (f);

  {Successful}
  Result := true;
end;


function LoadGIF(const FileName: TString): Boolean;
(*
@description:
This loads a GIF File (GIF87a)

*)
var
  {For loading from the GIF file}
  GIFFile      : File;
  Header       : GIFHeader;
  Descriptor   : GIFDescriptor;
  Temp         : Byte;
  BPointer     : Word;

  {Colour information}
  BitsPerPixel,
  NumOfColours,
  DAC          : Byte;

  {Coordinates}
  X, Y,
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


  {Local function to read from the buffer}
  function LoadByte : Byte;
  begin
    {Read next block}
    if (BPointer = BlockSize) then begin
      {$I-}
      BlockRead (GIFFile, Buffer, BlockSize + 1);
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
      if ((Temp and 1) > 0) then inc (Code, 1 shl Counter);
      Temp := Temp shr 1;
    end;
  end;


  {Local procedure to draw a pixel}
  procedure NextPixel (c : byte);
  begin
    {Actually draw the pixel on screen}
    PutPixel (X, Y, c);

    {Move on to next pixel}
    inc (X);

    {Or next row, if necessary}
    if (X = brX) then begin
      X := tlX;
      inc (Y);
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

  assign(GIFFile, Filename); reset(GIFFile, 1);

  {Read header}
  Header.Signature [0] := Chr (6);
  Blockread (GIFFile, Header.Signature [1], sizeof (Header) - 1);

  {Check signature and terminator}
  if ((Header.Signature <> 'GIF87a') {and (Header.Signature <> 'GIF89a')})
  or (Header.Zero <> 0) then begin
    Close (GIFFile);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  {Get amount of colours in image}
  BitsPerPixel := 1 + (Header.Depth and 7);
  NumOfColours := (1 shl BitsPerPixel) - 1;

  {Load global colour map}
//  BlockRead (GIFFile, Palette, 3 * (NumOfColours + 1));

  BlockRead (GIFFile, Buffer, (NumOfColours + 1));
  BlockRead (GIFFile, Buffer, (NumOfColours + 1));
  BlockRead (GIFFile, Buffer, (NumOfColours + 1));

{  for DAC := 0 to NumOfColours do begin
    SetDAC(DAC, Palette [DAC, 0] shr 2,
                Palette [DAC, 1] shr 2,
                Palette [DAC, 2] shr 2);
  end;
}
  {Load the image descriptor}
  BlockRead (GIFFile, Descriptor, sizeof (Descriptor));

  if (Descriptor.Separator <> ',')
  or (Descriptor.Depth and 192 > 0) then begin
    Close (GIFFile);
    IMGError := UnsupportedFormat;
    Result := false;
    Exit;
  end;

  {Get image corner coordinates}
  tlX := Descriptor.ImageLeft;
  tlY := Descriptor.ImageTop;
  brX := tlX + Descriptor.ImageWidth;
  brY := tlY + Descriptor.ImageHeight;

  {Get initial code size}
  BlockRead (GIFFile, CodeSize, 1);

  {GIF data is stored in blocks, so it's necessary to know the size}
  BlockRead (GIFFile, BlockSize, 1);

  {Start loader}
  BPointer := BlockSize;

  {Special codes used in the GIF spec}
  ClearCode        := 1 shl CodeSize;    {Code to reset}
  EOICode          := ClearCode + 1;     {End of file}

  {Initialize the string table}
  FirstFree        := ClearCode + 2;     {Strings start here}
  FreeCode         := FirstFree;         {Strings can be added here}

  {Initial size of the code and its maximum value}
  inc (CodeSize);
  InitCodeSize     := CodeSize;
  MaxCode          := 1 shl CodeSize;

  BitsIn := 8;

  {Start at top left of image}
  X := Descriptor.ImageLeft;
  Y := Descriptor.ImageTop;

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
      MaxCode  := 1 shl CodeSize;

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
  Close (GIFFile);
end;

end.
