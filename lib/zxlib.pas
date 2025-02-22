unit zxlib;
(*
 @type: unit
 @author: Bostjan Gorisek (Gury)
 @name: ZX Spectrum library
 @version: 1.4

 @description:
 Initial release date: 26.3.2016

 Supporting routines are copies of Mad Pascal library routines

 Version 1.1:
	- Function SGN added
	- Removed supporting routines previously needed (Position, Locate)
	- New versions of Flash routine added (overloaded for more parameter variations)
	- Screen functions updated (GetPixel function used instead of removed Locate function)

 Version 1.2:
	- ZXTitle procedure:
	- detecting console keys Start, Select and Option
	- Text "Press any key to start a game" moved upper in text mode 1
	- Flashing of this text
	- Added additional text parameter

  Version 1.3:
	- [Added] Beep procedure, simulating ZX Spectrum beeper in middle C
	- PrintAt procedure: check x boundaries for text mode 1 and 2
	- ZXTitle procedure: minor updates
	- [Bug fix] FlashAt procedure: removed annoying messed up alternating text

  Version 1.4:
	- Text -> Txt
	- Beep (duration : real; pitch : integer); -> Beep (duration : real; pitch : shortint);
*)

interface

procedure PrintAt(y, x : byte; c : char); overload;
procedure PrintAt(y, x : byte; txt : string); overload;
procedure PrintAt(var f : file; y, x : byte; c : char); overload;
procedure PrintAt(var f : file; y, x : byte; txt : string); overload;
procedure Flash(y, x : byte; char01, char02 : char); overload;
procedure Flash(y, x : byte; str : string); overload;
procedure Flash(var f : file; y, x : byte; str : string); overload;
procedure Flash(var f : file; y, x, rep : byte; str : string); overload;
function Screen(y, x : byte) : char; overload;
function Screen(var f : file; y, x : byte) : char; overload;
function SetRAM(pages : byte) : word;
procedure ZXTitle(title : string; y, x : byte; author, dev, txt, misc : string);
function Sgn(number : integer) : integer;
procedure Beep (duration : real; pitch : shortint);

implementation

uses Graph, Crt;

const
  // Middle C notes
  baseNotes : array[0..19] of byte =
    (114, 109, 104, 97, 90, 84, 80, 76, 71, 67, 63, 60, 49, 42, 36, 30, 23, 16, 9, 2);
  baseNotesBelow : array[0..19] of byte =
    (128, 133, 138, 145, 152, 158, 162, 166, 171, 175, 179, 186, 193, 200, 206, 236, 243, 250, 253, 255);

procedure PrintAt (y, x : byte; c : char); overload;
(*
* @description:
* Print character on location y, x in text mode 0
*
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: c - character to be displayed
*)
begin
  GotoXY(x+1, y+1);
  Write(c);
end;


procedure PrintAt (y, x : byte; txt : string); overload;
(*
* @description:
* Print string on location y, x in text mode 0
*
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: txt - string to be displayed
*)
begin
  GotoXY(x+1, y+1);
  Write(txt);
end;


procedure PrintAt (var f : file; y, x : byte; c : char); overload;
(*
* @description:
* Print character on location y, x to screen device S:
*
* @param: f - variable holder for screen device S: (text mode 1, 2)
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: c - character to be displayed
*)
begin
  if (x >= 0) and (x <= 19) then begin
    //and (y >= 0) and (y <= 23) then begin
    GotoXY(x+1, y+1);
    blockwrite(f, c, 1);
  end;
end;


procedure PrintAt (var f : file; y, x : byte; txt : string); overload;
(*
* @description:
* Print string on location y, x to screen device S:
*
* @param: f - variable holder for screen device S: (text mode 1, 2)
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: txt - string to be displayed
*)
begin
  if (x >= 0) and (x <= 19) then begin
    //and (y >= 0) and (y <= 23) then begin
    GotoXY(x+1, y+1);
    blockwrite(f, txt[1], length(txt));
  end;
end;


procedure Flash (y, x : byte; char01, char02 : char); overload;
(*
* @description:
* Alternate flashing of two characters on location y, x
*
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: char01 - first character to flash
* @param: char02 - second character to flash
*)
begin
  if char01 = char02 then
    PrintAt(y, x, chr(ord(char01) + $80))
  else
    PrintAt(y, x, char01);

  Delay(340);
  PrintAt(y, x, char02);
  Delay(340);
end;


procedure Flash (y, x : byte; str : string); overload;
(*
* @description:
* Alternate flashing text on location y, x
*
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: str - flashing string
*)
var
  i : byte;
  origStr : string;
begin
  origStr := str;

  for i := 1 to Length(str) do
    str[i] := Chr(Ord(str[i]) + $80);

  PrintAt(y, x, str);

  Delay(340);
  PrintAt(y, x, origStr);
  Delay(340);
end;


procedure Flash (var f : file; y, x : byte; str : string); overload;
(*
* @description:
* Alternate flashing text on location y, x on screen device S:
*
* @param: f - variable holder for screen device S: (text mode 1, 2)
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: str - flashing string
*)
var
  i : byte;
  origStr : string;
begin
  origStr := str;

  for i := 1 to Length(str) do begin
    str[i] := Chr(Ord(str[i]) + $80);
  end;

  PrintAt(f, y, x, str);

  Delay(340);
  PrintAt(f, y, x, origStr);
  Delay(340);
end;


procedure Flash (var f : file; y, x, rep : byte; str : string); overload;
(*
* @description:
* Alternate flashing text on location y, x on screen device S:
*
* @param: f - variable holder for screen device S: (text mode 1, 2)
* @param: y - coordinate Y
* @param: x - coordinate X
* @param: str - flashing string
*)
var
  i, j : byte;
  text02 : string;
begin
  j := 0;
  text02 := str;

  for i := 1 to Length(str) do begin
    text02[i] := Chr(Ord(text02[i]) + $80);
  end;

  for i := 1 to rep do begin
    if j = 0 then begin
      j := 1;
      GotoXY(x+1, y+1);
      blockwrite(f, str[1], length(str));
    end else begin
      j := 0;
      GotoXY(x+1, y+1);
      blockwrite(f, text02[1], length(str));
    end;
    Pause(30);
  end;
end;


function Screen (y, x : byte) : char; overload;
(*
* @description:
* Locate character on location y, x in text mode 0
*
* @param: y - coordinate Y
* @param: x - coordinate X
*)
begin
  result := chr(GetPixel(x, y));
  PrintAt(y, x, result);
end;


function Screen (var f : file; y, x : byte) : char; overload;
(*
* @description:
* Locate character on location y, x on screen device S:
*
* @param: f - variable holder for screen device S: (text mode 1, 2)
* @param: y - coordinate Y
* @param: x - coordinate X
*)
begin
  result := chr(GetPixel(x, y));
  PrintAt(f, y, x, result);
end;


procedure ZXTitle (title : string; y, x : byte; author, dev, txt, misc : string);
(*
* @description:
* ZX Spectrum title screen
*
* @param: title  - title name
* @param: y      - coordinate Y
* @param: x      - coordinate X
* @param: author - author
* @param: dev    - port by...
* @param: txt    - miscellaneous text
* @param: misc   - additional text
*)
var
  f : file;
begin
  // Set text in mode 1 (20 x 24)
  assign(f, 'S:'); rewrite(f, 1);
  InitGraph(1);
  Poke(752, 1);

  // Display text
  PrintAt(f, y, x, title);
  PrintAt(f, 3, 0, txt);

  if dev <> '' then
    Write('Original author: ', author,
          eol, 'Ported to Atari: ', dev,
          eol, eol, misc)
  else begin
    Write('Original author: ', author,
          eol, eol, misc);
  end;

  PrintAt(f, 16, 1, 'press any key');
  repeat
    Flash(f, 17, 1, 'to start the game');
  until (consol = CN_START) or (consol = CN_SELECT) or (consol = CN_OPTION) or KeyPressed;
  if KeyPressed then ReadKey;
end;


function SetRAM (pages : byte) : word;
(*
* @description:
* Set new top free RAM and character set address
*
* @param: pages - number of pages reserved at the top of free memory
*)
var
  topMem : word;
  CHBAS  : byte absolute $2F4;	// Character base address
  RAMTOP : byte absolute $6A;	// RAM top memory address
begin
  // New top RAM address
  topMem := RAMTOP - pages;
  topMem := topMem shl pages;

  // Set new character set
  CHBAS := hi(topMem);
  Move(pointer(57344), pointer(topMem), 1023);

  result := topMem;
end;


function Sgn (number : integer) : integer;
(*
* @description:
* Return signed or zero number depending on input number
*
* @param: number - Number to be checked
*
* @returns: number > 0: returned value 1
* @returns: number < 0: returned value -1
* @returns: number = 0: returned value 0
*)
begin
  if number > 0 then
    result := 1
  else if number < 0 then
    result := -1
  else
    result := 0;
end;


procedure Beep (duration : real; pitch : shortint);
(*
* @description:
* Emulate ZX Spectrum beeper
*
* @param: duration - duration of the sound
* @param: pitch    - pitch is given in semitones above middle C using negative
                     numbers for notes below middle C
*)
var
  base : byte = 121;
begin
  // Pitch above 0
  if pitch >= 1 then begin
    base := baseNotes[pitch - 1];
  end
  // Pitch below 0
  else if pitch <= -1 then begin
    base := baseNotesBelow[abs(pitch) - 1];
  end;

  // Middle C
  Sound(0, base, 10, 8);
  Delay(Round(duration * 1150));
  // Shut off sound when finished
  Sound(0, 0, 0, 0);
end;

end.