
{$r amiga.rc}

uses crt, vbxe;

const
	pic = VBXE_OVRADR;

var	xdl: txdl absolute VBXE_XDLADR+VBXE_WINDOW;

	i: smallint;
	j: smallint;
	dx,dy: shortint;

	c: cardinal;

begin

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 SetHorizontalRes(VBXE.VGAMed);

 VBXEMemoryBank($80);

 xdl.ov_step:=640;

 poke(559,0);

 dx:=2;
 dy:=4;
 i:=0;
 j:=120;

 repeat

  c:=pic+i+j*640;

  xdl.ov_adr.byte2:=c shr 16;
  xdl.ov_adr.byte1:=c shr 8;
  xdl.ov_adr.byte0:=c;

  pause;

  inc(i, dx);
  if (i>320) or (i<0) then dx:=-dx;

  inc(j, dy);
  if (j>320) or (j<0) then dy:=-dy;

 until keypressed;

 VBXEOff;

end.

