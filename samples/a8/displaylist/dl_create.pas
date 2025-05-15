uses crt, atari;


{$r mic.rc}

const

 mic = $a010;


procedure doDisplayList(dl_adr: word; bmp_adr: word);
var d: PByte register;
    i: byte;

 procedure dlByte(a: byte);
 begin
  d[0]:=a;
  inc(d);
 end;

 procedure dlWord(a: word);
 begin
  d[0]:=lo(a);
  d[1]:=hi(a);
  inc(d, 2);
 end;


begin

 d:=pointer(dl_adr);

 dlByte(DL_BLANK8);	// 3 * 8 blank lines
 dlByte(DL_BLANK8); 
 dlByte(DL_BLANK8);

 dlByte(DL_LMS + DL_MODE_E);            // 1 line mode E + LMS
 dlWord(bmp_adr);                       // address+$10 BMP_ADR

 for i:=0 to 100 do dlByte(DL_MODE_E);  // 101 lines mode E -> 102*40 = 4080 bytes -> $A010 + 4080 = $B000
 
 dlByte(DL_LMS + DL_MODE_E);            // 1 line mode E + LMS
 dlWord((bmp_adr + $1000) and $ff00);   // address HI(BMP_ADR + $1000),$00

 for i:=0 to 88 do dlByte(DL_MODE_E);   // 89 lines mode E -> 192 lines

 dlByte(DL_JVB);                        // wait and jump
 dlWord(dl_adr);

 sdlstl := dl_adr;

end;



begin

 doDisplayList($0600, mic);
 
 repeat until keypressed;

end.
