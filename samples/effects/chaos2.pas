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

    s,p,p2: ^byte;

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

 for i := 0 to 3 do begin

   a:=Random(0);

   p^  := col[a and $03];
   p2^ := col[a and $06];
   s^  := col[a and $0c];

   inc(p);
   inc(p2);
   inc(s);

 end;

 shift:=0;
 inc(ps);

 shift:=(shift shl 1) or (ps and 1);    	// bSize (8 -> x=2) (16 -> x=3)
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
//   ad:=xdst+ydst*sw;

   ad2:=xsrc + lsw[ysrc] + hsw[ysrc] shl 8;
//   ad2:=xsrc+ysrc*sw;

//   for j := 0 to bSize - 1 do
    for i := 0 to bSize - 1 do begin

    p:=@temp[ad];
    p2:=@temp2[ad2];

    p^:=p2^; inc(p, sw); inc(p2, sw);
    p^:=p2^; inc(p, sw); inc(p2, sw);
    p^:=p2^; inc(p, sw); inc(p2, sw);
    p^:=p2^; inc(p, sw); inc(p2, sw);
    p^:=p2^; inc(p, sw); inc(p2, sw);
    p^:=p2^; inc(p, sw); inc(p2, sw);
    p^:=p2^; inc(p, sw); inc(p2, sw);
    p^:=p2^;

    inc(ad);
    inc(ad2);

{
    ad_  := ad;
    ad2_ := ad2;

    temp[ad] := temp2[ad2];	inc(ad, sw); inc(ad2, sw);
    temp[ad] := temp2[ad2];	inc(ad, sw); inc(ad2, sw);
    temp[ad] := temp2[ad2];	inc(ad, sw); inc(ad2, sw);
    temp[ad] := temp2[ad2];	inc(ad, sw); inc(ad2, sw);
    temp[ad] := temp2[ad2];	inc(ad, sw); inc(ad2, sw);
    temp[ad] := temp2[ad2];	inc(ad, sw); inc(ad2, sw);
    temp[ad] := temp2[ad2];	inc(ad, sw); inc(ad2, sw);
    temp[ad] := temp2[ad2];

    ad  := ad_+1;
    ad2 := ad2_+1;
}

    end;

   inc(tx, bSize);

  end;

  inc(ty, bSize);
 end;


//  ad:=0;

  p:=@temp;
  p2:=@temp2;

  scr:=pointer(dpeek(88));

  for y:=0 to sh-1 do begin

   if y>=16 then
    ad2:=byte(y-16)*40
   else
    ad2:=0;

   s:=@scr[ad2];

   for x:=0 to sw shr 2-1 do begin

    a:=p^; p2^:=a; inc(p); inc(p2);
    b:=p^; p2^:=b; inc(p); inc(p2);
    c:=p^; p2^:=c; inc(p); inc(p2);
    d:=p^; p2^:=d; inc(p); inc(p2);
{
    a:=temp[ad] and 3;
    temp2[ad]:=a; inc(ad);

    b:=temp[ad] and 3;
    temp2[ad]:=b; inc(ad);

    c:=temp[ad] and 3;
    temp2[ad]:=c; inc(ad);

    d:=temp[ad] and 3;
    temp2[ad]:=d; inc(ad);
}
    s^:=byte(a and $c0) or byte(b and $30) or byte(c and $0c) or (d and $03);
    inc(s);

//    scr[ad2]:=byte(a shl 6) or byte(b shl 4) or byte(c shl 2) or d;
//    inc(ad2);

   end;
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


