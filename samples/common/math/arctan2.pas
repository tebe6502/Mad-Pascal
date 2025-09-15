uses crt;


function Q0(x, y: byte): byte;
const
  atan_tab: array[0..255] of Byte = (
    $20,$20,$20,$21,$21,$22,$22,$23,$23,$23,$24,$24,$25,$25,$26,$26,
    $26,$27,$27,$28,$28,$28,$29,$29,$2A,$2A,$2A,$2B,$2B,$2C,$2C,$2C,
    $2D,$2D,$2D,$2E,$2E,$2E,$2F,$2F,$2F,$30,$30,$30,$31,$31,$31,$31,
    $32,$32,$32,$32,$33,$33,$33,$33,$34,$34,$34,$34,$35,$35,$35,$35,
    $36,$36,$36,$36,$36,$37,$37,$37,$37,$37,$37,$38,$38,$38,$38,$38,
    $38,$39,$39,$39,$39,$39,$39,$39,$39,$3A,$3A,$3A,$3A,$3A,$3A,$3A,
    $3A,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3C,$3C,$3C,$3C,
    $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C,$3D,$3D,$3D,$3D,$3D,$3D,$3D,
    $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3E,$3E,$3E,
    $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,
    $3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$3F,
    $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
    $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
    $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
    $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,
    $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F
  );

  log2_tab: array[0..255] of Byte = (
    $00,$00,$20,$32,$40,$4A,$52,$59,$60,$65,$6A,$6E,$72,$76,$79,$7D,
    $80,$82,$85,$87,$8A,$8C,$8E,$90,$92,$94,$96,$98,$99,$9B,$9D,$9E,
    $A0,$A1,$A2,$A4,$A5,$A6,$A7,$A9,$AA,$AB,$AC,$AD,$AE,$AF,$B0,$B1,
    $B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$B9,$BA,$BB,$BC,$BD,$BD,$BE,$BF,
    $C0,$C0,$C1,$C2,$C2,$C3,$C4,$C4,$C5,$C6,$C6,$C7,$C7,$C8,$C9,$C9,
    $CA,$CA,$CB,$CC,$CC,$CD,$CD,$CE,$CE,$CF,$CF,$D0,$D0,$D1,$D1,$D2,
    $D2,$D3,$D3,$D4,$D4,$D5,$D5,$D5,$D6,$D6,$D7,$D7,$D8,$D8,$D9,$D9,
    $D9,$DA,$DA,$DB,$DB,$DB,$DC,$DC,$DD,$DD,$DD,$DE,$DE,$DE,$DF,$DF,
    $DF,$E0,$E0,$E1,$E1,$E1,$E2,$E2,$E2,$E3,$E3,$E3,$E4,$E4,$E4,$E5,
    $E5,$E5,$E6,$E6,$E6,$E7,$E7,$E7,$E7,$E8,$E8,$E8,$E9,$E9,$E9,$EA,
    $EA,$EA,$EA,$EB,$EB,$EB,$EC,$EC,$EC,$EC,$ED,$ED,$ED,$ED,$EE,$EE,
    $EE,$EE,$EF,$EF,$EF,$EF,$F0,$F0,$F0,$F1,$F1,$F1,$F1,$F1,$F2,$F2,
    $F2,$F2,$F3,$F3,$F3,$F3,$F4,$F4,$F4,$F4,$F5,$F5,$F5,$F5,$F5,$F6,
    $F6,$F6,$F6,$F7,$F7,$F7,$F7,$F7,$F8,$F8,$F8,$F8,$F9,$F9,$F9,$F9,
    $F9,$FA,$FA,$FA,$FA,$FA,$FB,$FB,$FB,$FB,$FB,$FC,$FC,$FC,$FC,$FC,
    $FD,$FD,$FD,$FD,$FD,$FD,$FE,$FE,$FE,$FE,$FE,$FF,$FF,$FF,$FF,$FF
  );
  
var
  lx, ly: byte;
  
begin

  lx := log2_tab[x];   // 32*log2(x)
  ly := log2_tab[y];   // 32*log2(y)

  if lx >= ly then 
   Result := (-atan_tab[byte(lx - ly)]) and $3f
  else 
   Result := atan_tab[byte(ly - lx)];

end;



function Atan2(y, x: smallint): byte;
{
; https://www.msx.org/forum/msx-talk/development/8-bit-atan2?page=0
; 8-bit atan2

; Calculate the angle, in a 256-degree circle.
; The trick is to use logarithmic division to get the y/x ratio and
; integrate the power function into the atan table. 

;	input
; 	B = x, C = y	in -128,127
;
;	output
;	A = angle		in 0-255

;      |
;  q1  |  q0
;------+-------
;  q3  |  q2
;      |
}
var
  a, e: byte;
  
  sx: word register;
  sy: word register;
begin

  if x < 0 then
   sx := -x
  else
   sx := x;
  
  if y < 0 then 
   sy := -y
  else
   sy := y;  

  
  while (sx > 127) or (sy > 127) do
  begin
    sx := sx shr 1;
    sy := sy shr 1;
  end;
  
  if x < 0 then
   x := -sx
  else
   x := sx;


  if y < 0 then
   y := -sy
  else
   y := sy;


  e:=0;
  
  // test znaków
  if (y < 0) then e:=e or 2;
  if (x < 0) then e:=e or 1;
  

  if e = 1 then
  begin
    // Q1
    //x := -x;
    a := Q0(-x, y); // wywołanie podstawowego bloku
    a := -a;
    a := a and $7F;
    Exit(a);
  end;

  if e = 2 then
  begin
    // Q2
    //y := -y;
    a := Q0(x, -y);
    a := -a;
    Exit(a);
  end;

  if e = 3 then
  begin
    // Q3
    //x := -x;
    //y := -y;
    a := Q0(-x, -y);
    a := a + 128;
    Exit(a);
  end;

  // Q0 – główna część algorytmu
  Result := Q0(x, y);
end;



var w, x,y: smallint;


begin

 x:=937;
 y:=751;

 w := Atan2(-y,x) ;	// * 1.40625 -> 0..359

end.
