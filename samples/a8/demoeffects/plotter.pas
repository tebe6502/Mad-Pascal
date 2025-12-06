uses crt, graph;

const
  dots=256;

//  slen1=511; samp1=46; sofs1=49;
//  slen2=511; samp2=46; sofs2=49;

//  dx1=3; dy1=5; xspd1=4; yspd1=2;
//  dx2=4; dy2=3; xspd2=2; yspd2=3;

  slen1=512; samp1=46; sofs1=49;
  slen2=512; samp2=46; sofs2=49;

  dx1=3; dy1=5; xspd1=1; yspd1=2;
  dx2=4; dy2=3; xspd2=1; yspd2=1;

var

  beat1, beat2: byte; // used to sync to music
  increasing: boolean;

  stab1:array[0..255] of byte absolute $4000;
  stab2:array[0..255] of byte absolute $4100;

  lline: array [0..255] of byte absolute $4200;
  hline: array [0..255] of byte absolute $4300;

  color_1: array [0..255] of byte absolute $4400;
  color_0: array [0..255] of byte absolute $4500;

  div8_plus56: array [0..255] of byte absolute $4600;

procedure init;
var
  i: byte;
  w: word;
const
  c_pi: single = pi;
  cl: array [0..7] of byte = ($80,$40,$20,$10,$08,$04,$02,$01);
begin
  for i := 0 to 255 do
  begin
    stab1[i] := round(sin(i*(4*c_pi)/slen1)*samp1)+sofs1;
    //stab2[i] := round(sin(i*(4*c_pi)/slen2)*samp2)+sofs2;
  end;
  Move(stab1, stab2, $100);

  //for i := 0 to 255 do stab2[i] := round(sin(i*(4*c_pi)/slen2)*samp2)+sofs2;

  // 88: The lowest address of the screen memory, corresponding to the
  // upper left corner of the screen | SAVMSC = $58, $59

  w := dpeek(88);

  for i := 0 to 255 do
  begin
    lline[i] := lo(w);
    hline[i] := hi(w);
    color_1[i] := cl[i and 7];
    color_0[i] := cl[i and 7] xor $ff;
    div8_plus56[i] := byte(i) shr 3 + 7;		// 7 -> 7*8 = 56
    inc(w, 40);
  end;

end;


procedure plotter;
var i, count: byte;

    offset_x, onset_x: byte;
    offset_y, onset_y: byte;

    yst1: byte register;
    i_dy1: byte register;
    i_dy1_: byte register;

    yst2: byte register;
    i_dy2: byte register;
    i_dy2_: byte register;

    xst1: byte register;
    i_dx1: byte register;
    i_dx1_: byte register;

    xst2: byte register;
    i_dx2: byte register;
    i_dx2_: byte register;

    hlp: PByte register;

begin

  //xst1:=100; xst2:=800; yst1:=300; yst2:=700;

  count := 255;

  repeat

    i_dy1 := yst1;
    i_dy2 := yst2;

    i_dx1 := xst1;
    i_dx2 := xst2;

    xst1:=xst1+xspd1+beat1;
    yst1:=yst1+yspd1+beat2;

    xst2:=xst2+xspd2;
    yst2:=yst2+yspd2;

    i_dy1_ := yst1;
    i_dy2_ := yst2;

    i_dx1_ := xst1;
    i_dx2_ := xst2;

    if (count < 1) then
    begin
      beat1 := beat1 - 1;
      if (beat1 > $c0) then  // f1 -- 1f
        beat1 := $0f;
    end
    else
      begin
        count := count - 1
      end;

    for i:=count to dots-1 do begin

      offset_y := stab1[i_dy1] + stab2[i_dy2];
      offset_x := stab1[i_dx1] + stab2[i_dx2];// + 60;

      onset_y := stab1[i_dy1_] + stab2[i_dy2_];
      onset_x := stab1[i_dx1_] + stab2[i_dx2_];// + 60;

    asm
      ldy offset_y

      lda adr.lline,y
      sta hlp
      lda adr.hline,y
      sta hlp+1

      ldx offset_x

      ldy adr.div8_plus56,x

      lda (hlp),y
      and adr.color_0,x
      sta (hlp),y

      ldy onset_y

      lda adr.lline,y
      sta hlp
      lda adr.hline,y
      sta hlp+1

      ldx onset_x

      ldy adr.div8_plus56,x

      lda (hlp),y
      ora adr.color_1,x
      sta (hlp),y

    end;

    i_dy1 := i_dy1 + dy1 ;
    i_dx1 := i_dx1 + dx1 ;
    i_dy2 := i_dy2 + dy2 ;
    i_dx2 := i_dx2 + dx2 ;

    i_dy1_ := i_dy1_ + dy1 ;
    i_dx1_ := i_dx1_ + dx1 ;
    i_dy2_ := i_dy2_ + dy2 ;
    i_dx2_ := i_dx2_ + dx2 ;

    end;

  until keypressed;
end;


begin

  //Writeln('One moment...');

  InitGraph(8+16);

  init;

asm
  lda #$82
  sta 712
  sta 710
  lda #15
  sta 709
end;

  beat1 := 0;
  beat2 := 0;

  plotter;

end.
