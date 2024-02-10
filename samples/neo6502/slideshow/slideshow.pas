program slideshow;
uses neo6502,crt;
const BUF = $7000;
var buffer : array[0..0] of byte absolute BUF;
    fnum: byte;
    imgname: TString;
    autorun: boolean;

function LoadPalette(fname:Tstring):boolean;
var 
  w:word;
  b:byte;
begin
    fname := concat(fname,'.pal');
    NeoLoad(fname,BUF);
    result := NeoMessage.error = 0;
    if result then begin
      w:=0;
      for b:=0 to 255 do begin
        NeoSetPalette(b,buffer[w],buffer[w+1],buffer[w+2]);
        inc(w,3);
      end;
    end;
end;

procedure LoadImage(fname:TString);
var 
  x,o:word;
  y,c:byte;
  chunkname:TString;
begin
    c:=0;
    y:=0;
    x:=0;
    repeat 
      Str(c,chunkname);
      chunkname := concat('.c',chunkname);
      chunkname := concat(fname,chunkname);
      NeoLoad(chunkname,BUF);
      o:=0;
      repeat 
        NeoSetColor(0,buffer[o],0,0,0);
        NeoDrawPixel(x,y);
        inc(x);
        inc(o);
        if x=320 then begin
          x:=0;
          inc(y);
        end;
      until (y=240) or (o=$8000);
      inc(c);
    until (y=240)
end;

procedure Wait5secOrKey;
var s,t:cardinal;
    k:char;
begin
  k := #0;
  s := NeoGetTimer;
  repeat
    t := NeoGetTimer - s;
  until keypressed or (autorun and (t>1000));
  if keypressed then k := ReadKey;
  if k = 'a' then autorun := not autorun;
end;

begin
  fnum := 0;
  repeat 
    Str(fnum,imgname);
    imgname := concat('slide',imgname);
    ClrScr;
    if LoadPalette(imgname) then begin
      LoadImage(imgname);
      Inc(fnum);
      Wait5secOrKey;
    end else fnum:=0;
  until false;

end.