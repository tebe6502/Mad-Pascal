
procedure LoadMOD(fnam: TString);
var f: file;
    name: TString;
    i, j, a, x, y, num: byte;
    offset, tmp, temp: cardinal;
    len: word;
    smp: TPSample;
    p0, p1, p2: ^byte;
    header: string[4];


    procedure NormalizeBuf;
    begin

	for j:=0 to sizeof(BUF)-1 do
		buf[j] := buf[j] + $80;

    end;


begin

 name:='D:';
 name[0]:=chr(length(fnam)+2);

 for i:=1 to length(fnam) do			// 'D:' + filename
  name[i+2]:=fnam[i];

 assign(f, name); reset(f, 1);

 blockread(f, ModName, 20);			// Load Module Name

 NUMBER_OF_SAMPLES := 0;

 for i:=0 to 30 do begin			// Load Sample Information

  smp:=Sample[i];

  blockread(f, smp.name, sizeof(TSample));

  smp.len := swap(smp.len) shl 1;
  smp.loop_start := swap(smp.loop_start) shl 1;
  smp.loop_len := swap(smp.loop_len) shl 1;

  if smp.fine_tune > 7 then dec(smp.fine_tune, 16);

  if smp.len<>0 then begin
   inc(NUMBER_OF_SAMPLES);
   NUMBER_OF_BANKS := i + 1;
  end;

  if smp.len > sample_len then begin
   writeln('Only ',sample_len,' bytes length sample');
   halt;
  end;

 end;


 blockread(f, SONG_LENGTH, 1);
 blockread(f, SONG_RESTART, 1);


 NUMBER_OF_PATTERNS := 0;			// Load Order Information

 for i:=0 to 127 do begin
  blockread(f, a, 1);

  ORDER[i]:=hi(word(PATTERN_START)) + a shl 1+a;	// + a*3

  if a > NUMBER_OF_PATTERNS then NUMBER_OF_PATTERNS:=a;
 end;

 inc(NUMBER_OF_PATTERNS);			// pattern #0 -> +1


 blockread(f, header[1], 4);
 header[0]:=chr(4);

 if header <> 'M.K.' then begin
  writeln('Unsuported MOD file');

  halt;
 end;


 writeln('Name: ',ModName);			// Information About Module

 for i:=0 to 30 do begin

  smp:=Sample[i];

  if smp.len<>0 then begin
   write(hexStr(i+1, 2),' ',smp.name);
   GotoXY(26, WhereY);
   write(' ',hexStr(smp.len,4),' ', smp.fine_tune);
   GotoXY(35, WhereY);
   writeln(hexStr(smp.volume,2),' ', hexStr(smp.loop_start,4),' ', hexStr(smp.loop_len,4) );
  end;

 end;


 if NUMBER_OF_PATTERNS > PATTERN_LIMIT then begin
  writeln(eol, 'Samples: ',NUMBER_OF_PATTERNS);
  writeln('Only ',PATTERN_LIMIT,' samples allowed');
  halt;
 end;


 xms.Create;

 if xms.Size < NUMBER_OF_BANKS*$010000 then begin
  writeln(eol, 'Need minimum ',NUMBER_OF_BANKS,' banks expanded memory');
  halt;
 end;


 temp:=pattern_temp;

 xms.Position := pattern_start;

 write(eol, 'Load Pattern: ');
 x:=WhereX;
 y:=WhereY;

 for i:=1 to NUMBER_OF_PATTERNS do begin	// Load Pattern Data

  p0:=pointer(temp);
  p1:=pointer(temp+$100);
  p2:=pointer(temp+$200);

  GotoXY(x,y);
  write(i,'/',NUMBER_OF_PATTERNS);

  for j:=0 to 255 do begin
   blockread(f, buf, 4);

   tmp:=CnvPattern;

   p0^:=tmp;		inc(p0);
   p1^:=tmp shr 8;	inc(p1);
   p2^:=tmp shr 16;	inc(p2);
  end;

   dec(p0, $100);

   xms.WriteBuffer(p0^, $300);

 end;


 writeln;
 write('Load Sample: ');
 x:=WhereX;
 y:=WhereY;

 offset:=sample_start;
 num:=1;

 for i:=0 to 30 do begin			// Load Sample Data

  TSTRL[i] := lo(VOLUME);
  TSTRH[i] := hi(VOLUME);
  TREPL[i] := lo(VOLUME);
  TREPH[i] := hi(VOLUME);

  TIVOL[i] := hi(VOLUME);

  smp:=Sample[i];

  len := smp.len;

  if len <> 0 then begin

  GotoXY(x,y);
  write(num,'/',NUMBER_OF_SAMPLES);

  temp:=sample_len - len + offset;

  xms.position := temp;				// sampl konczy sie na $FFFF

  TSTRL[i] := lo(word(temp));
  TSTRH[i] := hi(word(temp));

  if {(smp.loop_start = 0 ) and }(smp.loop_len < 8) then	// If the length is less than four, then there is no loop.
   temp := $ffff					// skoncz i graj cisze
  else							// sample na poczatku maja 4 zera (dla wyciszenia)
   inc(temp, smp.loop_start);

  TREPL[i] := lo(word(temp));
  TREPH[i] := hi(word(temp));

  TIVOL[i] := smp.volume shr 1 + hi(VOLUME);

  while len > 0 do begin

   if len >= sizeof(BUF) then
    temp:=sizeof(BUF)
   else
    temp:=len;

   BlockRead (f, buf, temp);
   NormalizeBuf;
   xms.WriteBuffer(buf, temp);

   dec(len, temp);

  end;

  inc(num);

  end;	// if len <> 0

  inc(offset, sample_len);

 end;

 writeln;

 close(f);

end;
