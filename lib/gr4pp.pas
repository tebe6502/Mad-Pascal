unit gr4pp;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>, tebe <tebe6502@gmail.com>
* @name: Graphics 4++ library
* @version: 1.0
* @description:
* Set of procedures to initialize, run, and use special graphics mode 4++.
*
* Resolution 160x240 / 80x60, 5 colors
*
*)
interface
uses atari;

procedure Gr4Init(DListAddress: word; VRamAddress: word; lines: byte; pixelHeight:byte; blanks: byte);
(*
* @description:
* Turns on 4++ mode.
*
* @param: DListAddress - memory address of Display list
*
* @param: VRamAddress - video memory address
*
* @param: lines - number of horizontal lines (vertical resolution)
*
* @param: pixelHeight - height of a pixel in scanlines (between 2 and 6)
*
* @param: blanks - number of blanklines (8 x scanline) at top of the screen
*
*)
procedure SetPixelHeight(lines: byte);
(*
* @description:
* Sets height of a pixel in a scan lines.
*
* @param: lines -  height of a pixel in scanlines (between 2 and 16)
*
*)


const
    DL_BLANK8 = %01110000; // 8 blank lines
    DL_DLI = %10000000; // Order to run DLI
    DL_LMS = %01000000; // Order to set new memory address
    DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
    DL_MODE_320x192G2 = $F;
    DL_JVB = %01000001; // Jump to begining

implementation

var dList : PByteArray;

procedure G4Dli;interrupt;assembler;
asm {
dli
    pha
    sta WSYNC
    lda #4
.def :VS_Upper = *-1
    sta VSCROL
    lda #3
.def :VS_Lower = *-1
    sta VSCROL
    pla
};
end;

procedure SetVS(upper, lower:byte);assembler;
asm {
    lda upper
    sta VS_Upper
    lda lower
    sta VS_Lower
};
end;

procedure SetPixelHeight(lines: byte);
begin
    if (lines > 1) and (lines < 7) then begin
        Pause();
        setVS(8 - lines, lines - 1);
    end;
end;

procedure DLPoke(b: byte);
begin
    dList[0] := b;
    Inc(dList);
end;

procedure DLPokeW(w: word);
begin
    dList[0] := Lo(w);
    dList[1] := Hi(w);
    Inc(dList, 2);
end;

procedure BuildDisplayList(DListAddress: word; VRamAddress: word; lines: byte; blanks: byte);
begin
    dList := pointer(DListAddress);
    while blanks > 0 do begin
	DLPoke(DL_BLANK8);
        dec(blanks);
    end;
    DLPoke($e4);
    DLPokeW(VRamAddress);

    lines:=lines shr 1 - 1;
    while (lines > 0) do begin
        DLPokeW($2484);
        dec(lines);
    end;
    DLPoke($04);
    DLPoke(DL_JVB);
    DLPokeW(DListAddress);
end;

procedure Gr4Init(DListAddress: word; VRamAddress: word; lines: byte; pixelHeight:byte; blanks: byte);
begin
    BuildDisplayList(DListAddress, VRamAddress, lines, blanks);
    SetPixelHeight(pixelHeight);
    SDLSTL := DListAddress;
    savmsc := VRamAddress;
    SetIntVec(iDLI, @G4Dli);
    nmien := $c0;
end;

end.
