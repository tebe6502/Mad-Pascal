
per_table : array[0..48] of word = (
   0,
//   1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960,906,
   856,808,762,720,678,640,604,570,538,508,480,453,
   428,404,381,360,339,320,302,285,269,254,240,226,
   214,202,190,180,170,160,151,143,135,127,120,113,
   107,101,95,90,85,80,75,71,67,63,60,56);



function CnvPattern: cardinal;
var r0,r1,r2,r3: byte;
    w1, w2, i, x, y, per: word;
    w, sample, fx, fxdata: byte;

begin

 r0:=0;
 r1:=0;
 r2:=0;
 r3:=0;

      w1 := BUF[0] + BUF[1] shl 8;
      w2 := BUF[2] + BUF[3] shl 8;

      per := swap(w1) and $fff;
      sample := ((w2 shr 4) and $f) or (w1 and $f0);
      fx := w2 and 15;
      fxdata := hi(w2);

      if (fx=0) and (fxdata=0) then fx := 255;

 if per > 0 then begin

        i := per;
        w := 0;
        repeat
          inc(w);
        until (i >= per_table[w]);

        r0 := 48;
        if w < 48 then begin
          if i > per_table[w] then begin
            x := per_table[w-1]-i;
            y := i-per_table[w];
            if x < y then inc(w);
          end;
          r0 := w				// note
        end;

	r0:=48-r0;
	r1:=sample;				// sample


 case fx of

  $0c: begin				// Effect Cxy (Set Volume)
	r1:=r1 or $40;
	r2:=fxdata shr 1+hi(VOLUME);
       end;

  $0d: r1:=r1 or $80;			// Effect Dxy (Pattern Break)

  $0f: begin				// Effect Fxy (Set )
	r1:=r1 or $c0;
	r2:=fxdata;
	if r2 > 31 then r2:=31;
       end;

 end;


 end;	// if per > 0


 asm
 {	mva r0 Result
	mva r1 Result+1
	mva r2 Result+2
	mva r3 Result+3
 };

end;
