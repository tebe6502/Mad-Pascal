program slideshow;
uses neo6502,crt;
const 
  BUF = $7000;
  chunksize = $1000;

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
  x,o,len:word;
  y:byte;
  done:boolean;
begin
    y:=0;
    x:=0;
    fname := concat(fname,'.img');
    NeoOpenFile(0,@fname[0],OPEN_MODE_RO);
    repeat 
      o:=0;
      len := NeoReadFile(0,BUF,chunksize);
      done := len = 0;
      while (len>0) do begin
        NeoSetColor(buffer[o]);
        NeoDrawPixel(x,y);
        inc(x);
        inc(o);
        dec(len);
        if x=320 then begin
          x:=0;
          inc(y);
          if y=240 then done:=true;
        end;
      end;
    until done;
    NeoCloseFile(0);
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
  NeoSetDefaults(0,0,1,1,0);
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