unit gr10pp;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Graphics 10 mode ++ (GTIA) library
* @version: 0.5.4
* @description:
* Set of procedures to initialize, run, and use special graphics mode 10++.
*
* Resolution 80x48, 9 colors, square pixel (for lineHeight = 4)
*
* This library is nota a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses atari;

procedure Gr10Init(DListAddress: word; VRamAddress: word; lines: byte; pixelHeight:byte; blanks: byte);
(*
* @description:
* Turns on 10++ mode.
*
* @param: DListAddress - memory address of Display list
*
* @param: VRamAddress - video memory address
*
* @param: lines - number of horizontal lines (vertical resolution)
*
* @param: pixelHeight - height of a pixel in scanlines (between 2 and 16)
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
    DL_BLANK1 = 0; // 1 blank line
    DL_BLANK8 = %01110000; // 8 blank lines
    DL_DLI = %10000000; // Order to run DLI
    DL_LMS = %01000000; // Order to set new memory address
    DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
    DL_MODE_320x192G2 = $F;
    DL_JVB = %01000001; // Jump to begining

implementation

uses graph;


var dList : array [0..0] of byte;
    dlPtr: word;


procedure G10Dli;interrupt; assembler;
asm
dli
    pha
    sta WSYNC  ;($d40a)
    lda #13
.def :VS_Upper = *-1
    sta VSCROL ;($d405)
    lda #3
.def :VS_Lower = *-1
    sta VSCROL ;($d405)
    pla
end;


procedure SetVS(upper, lower:byte); assembler;
asm
    lda upper
    sta VS_Upper
    lda lower
    sta VS_Lower
end;


procedure SetPixelHeight(lines: byte);
begin
    if (lines > 1) and (lines < 17) then begin
        Pause();
        setVS(17 - lines, lines - 1);
    end;
end;

procedure DLPoke(b: byte);
begin
    dList[dlPtr] := b;
    Inc(dlPtr);
end;

procedure DLPokeW(w: word);
begin
    dList[dlPtr] := Lo(w);
    Inc(dlPtr);
    dList[dlPtr] := Hi(w);
    Inc(dlPtr);
end;

procedure BuildDisplayList(DListAddress: word; VRamAddress: word; lines: byte; blanks: byte);
var limit4k : word;
    setLMS : boolean;
begin
    lines := lines and %11111110; // trim to be even
    dList := pointer(DListAddress);
    dlPtr := 0;
    while blanks > 0 do begin
        DLPoke(DL_BLANK8);
        dec(blanks);
    end;
    DLPoke(DL_BLANK1 + DL_DLI); // dli forced before first line
    setLMS := true;
    while (lines > 0) do begin
        if setLMS then begin
            DLPoke(DL_MODE_320x192G2 + DL_LMS + DL_VSCROLL);
            DLPokeW(VRamAddress);
            limit4k := (VRamAddress and $F000) + $1000;
            setLMS := false;
        end else
            DLPoke(DL_MODE_320x192G2 + DL_VSCROLL);
        DLPoke(DL_MODE_320x192G2 + DL_DLI);
        dec(lines,2);
        VRamAddress := VRamAddress + 80;
        if VRamAddress >= limit4k then setLMS := true;
    end;
    DLPoke(DL_JVB);
    DLPokeW(DListAddress);
end;

procedure Gr10Init(DListAddress: word; VRamAddress: word; lines: byte; pixelHeight:byte; blanks: byte);
begin
    InitGraph(10+16);

    BuildDisplayList(DListAddress, VRamAddress, lines, blanks);
    SetPixelHeight(pixelHeight);
    SDLSTL := DListAddress;
    savmsc := VRamAddress;
    SetIntVec(iDLI, @G10Dli);
    nmien := $c0;
    gprior := $81;
end;

end.
