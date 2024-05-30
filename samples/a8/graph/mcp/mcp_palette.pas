// MCP Palette Creator

uses crt, pmg, atari, joystick;

const

  bmp = $bc00;
  inf = bmp+16*40;
  txt = inf+80;

  dlist : array [0..75] of byte = 
  (
  $70,$70,$70,
  $4e,lo(bmp),hi(bmp),
  $4e,lo(bmp+40),hi(bmp+40),
  $4e,lo(bmp+40*2),hi(bmp+40*2),
  $4e,lo(bmp+40*3),hi(bmp+40*3),
  $4e,lo(bmp+40*4),hi(bmp+40*4),
  $4e,lo(bmp+40*5),hi(bmp+40*5),
  $4e,lo(bmp+40*6),hi(bmp+40*6),
  $4e,lo(bmp+40*7),hi(bmp+40*7),
  
  $4e,lo(bmp+40*8),hi(bmp+40*8),
  $4e,lo(bmp+40*9),hi(bmp+40*9),
  $4e,lo(bmp+40*10),hi(bmp+40*10),
  $4e,lo(bmp+40*11),hi(bmp+40*11),
  $4e,lo(bmp+40*12),hi(bmp+40*12),
  $4e,lo(bmp+40*13),hi(bmp+40*13),
  $4e,lo(bmp+40*14),hi(bmp+40*14),
  $4e,lo(bmp+40*15),hi(bmp+40*15),  
  $30,
  $42,lo(inf),hi(inf),
  2,
  
  $70,$70,$70,$70,$70,$70,
  $42,lo(txt),hi(txt),
  $70,$70,$70,$70,$70,$70,$70,
  2,
 
  $41,lo(word(@dlist)),hi(word(@dlist))
  );


  p0Data : array [0.._P_MAX] of byte = (255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0);
  
  info = '00102030011121310212222303132333        '~;

var
   pinf: array [0..39] of word absolute inf;
   
   psel: array [0..39] of word absolute txt;

   pcol : array[0..7] of byte = ($00, $86, $26, $fc, $00, $34, $60, $c4);
   
   sel, old_sel: byte;
   
   joy_old: byte;
   rep: byte = 12;


procedure SetupPM;
begin
  // Initialize P/M custom variables
  p_data[0] := @p0Data;
  p_data[1] := @p0Data;
  p_data[2] := @p0Data;
  p_data[3] := @p0Data;

  // Initialize P/M graphics
  SetPM(_PM_DOUBLE_RES);
  InitPM(_PM_DOUBLE_RES);

  // Turn on P/M graphics
  ShowPM(_PM_SHOW_ON);

  // Set player sizes
  SizeP(0, _PM_NORMAL_SIZE);
  SizeP(1, _PM_NORMAL_SIZE);
  SizeP(2, _PM_NORMAL_SIZE);
  SizeP(3, _PM_NORMAL_SIZE);

  // Position and show players
  MoveP(0, 64, 64);
  MoveP(1, 80, 64);
  MoveP(2, 96, 64);
  MoveP(3, 112, 64);
  
  // Position and show players
  MoveP(0, 64, 79);
  MoveP(1, 80, 79);
  MoveP(2, 96, 79);
  MoveP(3, 112, 79);  
end;


procedure KeyScan;
var ch: char;
    joy, l,h: byte;
    v, i: word;
    
const
 thex : array [0..15] of char = ('0'~,'1'~,'2'~,'3'~,'4'~,'5'~,'6'~,'7'~,'8'~,'9'~,'A'~,'B'~,'C'~,'D'~,'E'~,'F'~);
 
begin

 joy := joy_1;
 
 if consol = cn_select then joy := 1;

 if joy_old = joy then begin
  dec(rep);
  
  if rep>0 then Exit;  
 end; 
 
 
 if joy = 1 then begin inc(sel); sel:=sel and 7 end;
 
 
 l:=pcol[sel] and $0f;
 h:=pcol[sel] shr 4; 

 case joy of
	    joy_up: inc(h);
	  joy_down: dec(h);
	  joy_left: dec(l, 2);
	 joy_right: inc(l, 2);
 end;

 joy_old := joy;


 pcol[sel]:=h shl 4 + l and $0f;
 
 v:=byte(thex[h]) + byte(thex[l]) shl 8;


 rep:=12;
 
 if old_sel < 4 then 
  psel[old_sel shl 1+2] := psel[old_sel shl 1+2] and $7f7f
 else
  psel[old_sel shl 1+14] := psel[old_sel shl 1+14] and $7f7f;
  
  
 if sel < 4 then begin
  psel[sel shl 1+2] := v;
  psel[sel shl 1+2] := psel[sel shl 1+2] or $8080
 end else begin
  psel[sel shl 1+14] := v;
  psel[sel shl 1+14] := psel[sel shl 1+14] or $8080;
 end; 

 old_sel:=sel; 

end;


procedure onInit;
var i, j: byte;

const
     pixel: array [0..3] of word = ($0000,$5555,$aaaa,$ffff);
  
begin

 fillchar(pointer(bmp), 8*40, 0);

 for i:=0 to 7 do
  for j:=0 to 15 do dpoke(bmp+i*80+j*2, pixel[j and 3]); 
 
 for i:=0 to 7 do
  for j:=4 to 7 do dpoke(bmp+i*80+j*2+40, $5555); 

 for i:=0 to 7 do
  for j:=8 to 11 do dpoke(bmp+i*80+j*2+40, $aaaa); 

 for i:=0 to 7 do
  for j:=12 to 15 do dpoke(bmp+i*80+j*2+40, $ffff); 
  
 move(info[1], pointer(inf), 40);
 
 for i:=0 to 7 do begin
  pinf[i shl 1] := pinf[i shl 1] xor $8080;
 end;
 
 pinf[20]:=$8080;
 pinf[21]:=$8080;
 pinf[22]:=$8080;
 pinf[23]:=$8080;
 
 pinf[28]:=$8080;
 pinf[29]:=$8080;
 pinf[30]:=$8080;
 pinf[31]:=$8080;
 
end;


begin

  onInit;

  sdlstl := word(@dlist);

  SetupPM;
  
  // Main loop
  repeat
   // ConsoleKeys;
  //	KeyScan;

  KeyScan;
    
  colbk:=00;

  repeat   
  case vcount of
  
     15: begin
        
        asm
        {
        txa:pha
	
	sta wsync
	
        .rept 8
        lda adr.pcol+1
        ldx adr.pcol+2
        ldy adr.pcol+3
        sta wsync
        sta color0
        stx color1
        sty color2

        lda adr.pcol+5
        ldx adr.pcol+6
        ldy adr.pcol+7
        sta wsync
        sta color0
        stx color1
        sty color2
        .endr
	
	sta wsync
	
	mva #$00 color0
	sta color2
	sta color3
	mva #$0e color1
	
        pla:tax
        };
       end;
       
   60: begin
//        colbk:=$44;
        
        colpm0:=pcol[0];
        colpm1:=pcol[1];
        colpm2:=pcol[2];
        colpm3:=pcol[3];
       end;
  
   78: begin
//        colbk:=$98;
        
        colpm0:=pcol[4];
        colpm1:=pcol[5];
        colpm2:=pcol[6];
        colpm3:=pcol[7];
       end;  
  end;
  
  until vcount = $50;
  

  until false;
  
  // Reset P/M graphics
  ShowPM(_PM_SHOW_OFF);  

end.
