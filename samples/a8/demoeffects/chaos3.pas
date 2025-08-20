// chaos zoomer

uses crt, graph;


const

  bSize = 8;		// block size
  sw = 128;		// screen width
  sh = 120;		// screen height

  xs = sw div bSize;
  ys = sh div bSize;


var
	ps: byte;

	scr: array [0..0] of byte;

	temp, temp2: array [0..16383] of byte;

	lsw, hsw: array [0..255] of byte;


procedure init;
var w: word;
    i: byte;
begin

 w:=0;

 for i:=0 to length(lsw)-1 do begin
  lsw[i] := lo(w);
  hsw[i] := hi(w);

  inc(w, sw);
 end;

end;


procedure chaos_zoom;
var a, b, c, d,
    shift, x,y, i,j,
    xsrc, ysrc, xdst, ydst, tx, ty: byte;

    ad, ad2, ad_, ad2_: word;

    s: PByte absolute $e0;
    p: PByte absolute $e2;
    p2: PByte absolute $e4;

const
    col: array [0..15] of byte = (
    $00,$55,$aa,$ff,
    $aa,$55,$ff,$55,
    $aa,$ff,$aa,$55,
    $00,$55,$aa,$ff
    );


begin

// random pixels

// bSize = 8 (68,84) / 16
// bsize = 16 (108, 120) / 12

 xsrc:=71;
 ysrc:=87;

 ad:=xsrc+ysrc*sw;

 p :=@temp2[ad];
 p2:=@temp2[ad+sw];
 s :=@temp2[ad+sw*2];

 for i := 3 downto 0 do begin

   a:=Random(0);

   p[i]  := col[a and $03];
   p2[i] := col[a and $06];
   s[i]  := col[a and $0c];

 end;

 shift:=0;
 inc(ps);

 shift:=ps and 1;  			  	// bSize (8 -> x=2) (16 -> x=3)
 shift:=(shift shl 1) or ((ps shr 1) and 1);
 shift:=(shift shl 1) or ((ps shr 2) and 1);

// copy block (bSize)  buf0 -> buf1

 ty:=shift+16;

 for y := 0 to ys - 1 do begin

  tx:=shift+16;

  for x := 0 to xs - 1 do begin

   xsrc:=tx-y-x;
   ysrc:=ty+x-y;

   xdst:=tx-16;
   ydst:=ty;

   ad:=xdst + lsw[ydst] + hsw[ydst] shl 8;

   ad2:=xsrc + lsw[ysrc] + hsw[ysrc] shl 8;

// bSize = 8 !!!

    p:=@temp[ad];
    p2:=@temp2[ad2];

    p[0] := p2[0];
    p[1] := p2[1];
    p[2] := p2[2];
    p[3] := p2[3];
    p[4] := p2[4];
    p[5] := p2[5];
    p[6] := p2[6];
    p[7] := p2[7];

    p[sw] := p2[sw];
    p[sw+1] := p2[sw+1];
    p[sw+2] := p2[sw+2];
    p[sw+3] := p2[sw+3];
    p[sw+4] := p2[sw+4];
    p[sw+5] := p2[sw+5];
    p[sw+6] := p2[sw+6];
    p[sw+7] := p2[sw+7];
    inc(p, sw*2); inc(p2, sw*2);

    p[sw] := p2[sw];
    p[sw+1] := p2[sw+1];
    p[sw+2] := p2[sw+2];
    p[sw+3] := p2[sw+3];
    p[sw+4] := p2[sw+4];
    p[sw+5] := p2[sw+5];
    p[sw+6] := p2[sw+6];
    p[sw+7] := p2[sw+7];

    p[0] := p2[0];
    p[1] := p2[1];
    p[2] := p2[2];
    p[3] := p2[3];
    p[4] := p2[4];
    p[5] := p2[5];
    p[6] := p2[6];
    p[7] := p2[7];
    inc(p, sw*2); inc(p2, sw*2);

    p[0] := p2[0];
    p[1] := p2[1];
    p[2] := p2[2];
    p[3] := p2[3];
    p[4] := p2[4];
    p[5] := p2[5];
    p[6] := p2[6];
    p[7] := p2[7];

    p[sw] := p2[sw];
    p[sw+1] := p2[sw+1];
    p[sw+2] := p2[sw+2];
    p[sw+3] := p2[sw+3];
    p[sw+4] := p2[sw+4];
    p[sw+5] := p2[sw+5];
    p[sw+6] := p2[sw+6];
    p[sw+7] := p2[sw+7];
    inc(p, sw*2); inc(p2, sw*2);

    p[sw] := p2[sw];
    p[sw+1] := p2[sw+1];
    p[sw+2] := p2[sw+2];
    p[sw+3] := p2[sw+3];
    p[sw+4] := p2[sw+4];
    p[sw+5] := p2[sw+5];
    p[sw+6] := p2[sw+6];
    p[sw+7] := p2[sw+7];

    p[0] := p2[0];
    p[1] := p2[1];
    p[2] := p2[2];
    p[3] := p2[3];
    p[4] := p2[4];
    p[5] := p2[5];
    p[6] := p2[6];
    p[7] := p2[7];


   inc(tx, bSize);

  end;

  inc(ty, bSize);
 end;


  p:=@temp;
  p2:=@temp2;

  scr:=pointer(dpeek(88));

  for y:=sh-1 downto 0 do begin

   if y>=16 then
    ad2:=byte(y-16)*40
   else
    ad2:=0;

   s:=@scr[ad2];

   i:=0;

   for x:=sw shr 2-1 downto 0 do begin

    a:=p[i]; p2[i]:=a; inc(i);
    b:=p[i]; p2[i]:=b; inc(i);
    c:=p[i]; p2[i]:=c; inc(i);
    d:=p[i]; p2[i]:=d; inc(i);

    s[x]:=byte(a and $03) or byte(b and $0c) or byte(c and $30) or (d and $c0);

   end;

   inc(p, sw);
   inc(p2, sw);

  end;

end;


begin

 randomize;

 InitGraph(7+16);

 init;

 repeat

	chaos_zoom;

 until false;

end.

//1589
