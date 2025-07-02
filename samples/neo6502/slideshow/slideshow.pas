program slideshow;
uses neo6502,crt;
const 
  BUF = $7000;
  chunksize = $4000;

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
  len:word;
  y:byte;
  vram:cardinal;
begin
    vram := MEM_VRAM;
    fname := concat(fname,'.img');
    NeoOpenFile(0,@fname[0],OPEN_MODE_RO);
    repeat 
      len := NeoReadFile(0,BUF,chunksize);
      if (len>0) then begin
        repeat until not NeoBlitterBusy;
        NeoBlitterCopy(BUF,vram,len);
        vram := vram + len;
      end;
    until len=0;
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
