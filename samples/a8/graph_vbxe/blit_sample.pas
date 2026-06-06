program Blit;

uses
crt, vbxe;

const
ScreenWidth = 320;
ScreenHeight = 192;

var
BCB : TBCB absolute VBXE_BCBADR+VBXE_WINDOW; 
src, dst: cardinal;

procedure DrawTestPattern;
var x, y: integer;
begin
vbxe.setcolor(Red);
for y := 0 to 63 do
for x := 0 to 63 do
vbxe.PutPixel(x, y);
end;


procedure BlitBlock;
begin

 asm
  fxs FX_MEMS #$80
 end;

src := VBXE_OVRADR;

BCB.src_adr.byte0 := src;
BCB.src_adr.byte1 := src shr 8;
BCB.src_adr.byte2 := src shr 16;

dst := VBXE_OVRADR + (120 * ScreenWidth) + 120;

BCB.dst_adr.byte0 := dst;
BCB.dst_adr.byte1 := dst shr 8;
BCB.dst_adr.byte2 := dst shr 16;

BCB.src_step_x := 1;
BCB.dst_step_x := 1;

BCB.src_step_y := ScreenWidth;
BCB.dst_step_y := ScreenWidth;

BCB.blt_width := 63;
BCB.blt_height := 63;


BCB.blt_and_mask := $FF;
BCB.blt_xor_mask := 0;
BCB.blt_collision_mask := 0;
BCB.blt_zoom := 0;
BCB.pattern_feature := 0;

BCB.blt_control := 0;

 asm
  fxs FX_MEMS #$00
 end;
 
RunBCB(BCB);
while BlitterBusy do;

end;


procedure InitBlit;
begin

 asm
  fxs FX_MEMS #$80
 end;

FillByte(BCB, SizeOf(BCB), 0);

 asm
  fxs FX_MEMS #$00
 end;

end;


begin

VBXEMode(VBXE.VGAmed, 0);


InitBlit;


DrawTestPattern;

BlitBlock;

ReadKey;
end.
