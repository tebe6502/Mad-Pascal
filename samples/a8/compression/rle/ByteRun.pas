// 1339

// 1,2,3,3,3,1,1,12,12,12,12,3,2,222

uses crt;

var
	buf: array [0..255] of byte;
	sav: array [0..255] of byte;
	tst: array [0..255] of byte;

	x, i: word;


procedure RLEDecompress(src,dst: pointer); assembler; register;
asm
	txa:pha

	dew edx

	mwa ecx outputPointer

	lda edx+1
	sta inputPointer+1

	ldx edx

loop    jsr getByte
	beq stop
	lsr @

	tay

lp0	jsr getByte
lp1	sta $ffff
outputPointer	equ *-2

	inw outputPointer

	dey
_bpl    bmi loop

	bcs lp0
	bcc lp1

getByte	inx
	sne
	inc inputPointer+1

	lda $ff00,x		; lo(inputPointer) = 0 !!!
inputPointer	equ *-2

	rts

stop	pla:tax

end;


function ByteRunCompress(len: word): word;
var i, j, k, x: word;
begin

k := 0;
i := 0;

//dopoki wszystkie bajty nie sa skompresowane
while (i < len) do begin

//sekwencja powtarzajacych sie conajmniej 3 bajtow
if ((i < word(len-2)) and (buf[i] = buf[i+1]) and (buf[i] = buf[i+2])) then begin

//zmierz dlugosc sekwencji
j := 0;

while ((word(i+j) < word(len-2)) and (buf[i+j] = buf[i+j+1]) and (buf[i+j] = buf[i+j+2]) and (j < 126)) do inc(j);

//wypisz spakowana sekwencje
sav[k] := byte(j+1) shl 1;
inc(k);

sav[k] := buf[i+j];
inc(k);

//przesun wskaznik o dlugosc sekwencji
inc(i, j+2);

//sekwencja roznych bajtow
end else begin

//zmierz dlugosc sekwencji
j:=0;

while ((word(i+j) < word(len-2)) and ((buf[i+j] <> buf[j+i+1]) or (buf[i+j] <> buf[j+i+2])) and (j < 128)) do inc(j);

//dodaj jeszcze koncowke
if ((word(i+j) = word(len-2)) and (j < 128)) then inc(j);

if ((word(i+j) = word(len-1)) and (j < 128)) then inc(j);

//wypisz spakowana sekwencje
sav[k] := byte(j-1) shl 1 or 1;
inc(k);

for x:=0 to j-1 do begin
 sav[k] := buf[i+x];
 inc(k);
end;

//przesun wskaznik o dlugosc sekwencji
inc(i, j);
end;

end;

sav[k]:=0;

Result:=k;

end;


begin

 buf[0]:=1;
 buf[1]:=2;
 buf[2]:=3;
 buf[3]:=3;
 buf[4]:=3;
 buf[5]:=1;
 buf[6]:=1;
 buf[7]:=12;
 buf[8]:=12;
 buf[9]:=12;
 buf[10]:=12;
 buf[11]:=3;
 buf[12]:=2;
 buf[13]:=222;

 x:=ByteRunCompress(14);

 writeln('Compress:');
 for i:=0 to x-1 do write(sav[i],',');

 writeln;
 writeln;

 RLEDecompress(@sav,@tst);

 writeln('Decompress:');
 for i:=0 to 13 do write(tst[i],',');

 repeat until keypressed;

end.
