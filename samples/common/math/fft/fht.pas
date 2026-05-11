program FHT_test;

uses crt;

const
	pi: single = 3.1415926535897932384626433832795;

type points = array [0..1023] of single;

var fx: points;
    i : smallint;

procedure fht(len: smallint; var fx: points);
(**************************************************************************
   Fast Hartley Transform, an alternative to the Fast Fourier Transform
   -- DDJ, December 1984 p.12
   Results can be switched to the Fourier transform by the equations

           single[Xf(k)] = [Xh(k) + Xh(-k)]/2
           IMAG[Xf(k)] = [Xh(k) - Xh(-k)]/2

   This method can be used provided the original data has no imaginary part.
   Since complex arithmetic is not involved, less storage and fewer
   calculations are required than for the FFT.
   See DDJ for credits, references and justification.
   ***********************************************************************)

var ii, jj, kk, ll, istep: smallint;
    a, b, c, d: smallint;
    temp1, temp2, arg, tt,
    fcos, fsin, dcos, dsin: single;

begin
(* Test to see that len is a power of two and not zero *)
    kk := len;
    while not odd(kk) do kk := kk shr 1;
    if kk <> 1 then begin
       writeln('len must be an smallint power of 2');
       halt;
       end;
(* Reorder the data *)
    tt:=1/len;
    arg := sqrt(tt);
    
//    writeln(arg:8:8); while true do;

    jj := 0;  ii := 0;  kk := 0;
    while ii < len do begin
        if ii <= kk then begin
            temp1 := fx[kk] * arg;
            fx[kk] := fx[ii] * arg;
            fx[ii] := temp1;
            end;
        jj := len shr 1;
        while (kk >= jj) and (jj >= 1) do begin
            kk := kk - jj;
            jj := jj shr 1;
            end;
        kk := kk + jj;
        ii := ii + 1;
        end;          {while ii}
    arg := pi;
    jj := 1;

    while jj < len do begin
        istep := jj shl 1;
        dcos := cos(arg);  dsin := sin(arg);
        arg := arg / 2;
        ii := 0;
        while ii < len do begin
            a := ii;  c := ii + jj;
            temp1 := fx[c];
            fx[c] := fx[a] - temp1;
            fx[a] := fx[a] + temp1;
            ii := ii + istep;
            end;
        fcos := dcos;  fsin := dsin;
        ll := 1;      kk := jj - 2;
        while ll < (jj shr 1) do begin
            ii := ll;
            while ii < len do begin
                a := ii;      b := a + kk;
                c := a + jj;  d := c + kk;
                temp1 := fcos * fx[c] + fsin * fx[d];
                temp2 := fsin * fx[c] - fcos * fx[d];
                fx[c] := fx[a] - temp1;
                fx[d] := fx[b] - temp2;
                fx[a] := fx[a] + temp1;
                fx[b] := fx[b] + temp2;
                ii := ii + istep;
                end;
            temp1 := fcos * dcos - fsin * dsin;
            fsin := fsin * dcos + fcos * dsin;
            fcos := temp1;
            ll := ll + 1;  kk := kk - 2;
            end;
        if (jj > 1) then begin
            ii := jj shr 1;
            while ii < len do begin
                a := ii; c := ii + jj;
                temp1 := fx[c];
                fx[c] := fx[a] - temp1;
                fx[a] := fx[a] + temp1;
                ii := ii + istep;
                end;
            end;
        jj := istep;
        end;
end;        (* end of FHT *)

begin
    for i := 0 to 63 do     
       fx[i] := sin(pi*(i/100));
	

    fht(64, fx);      {transform}
    fht(64, fx);      {again, for the inverse}

    for i := 0 to 63 do
       writeln((fx[i] - sin(pi*i/100)):8:8); {should all be zero}
	
    repeat until keypressed;	
end.
