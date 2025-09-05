Program FOURIER;

uses crt;

{ Real FFT with single sine look-up per pass }

Type
  TFloat = single;

Const
  Asize = 4096;           { Size of array goes here }
  PI2: TFloat   = 1.570796327;    { PI/2 }
  F     = 16;             { Format constants }
  D     = 6;              {   "      " }

Type
  Xform = (Fwd,Inverse);  { Transform types }
  Xary  = Array[0..Asize] of TFloat;

Var
  I,j,N,modulo   : Integer;
  F1    : Text;  { File of Real;}
  X     : Xary;           { Array to transform }
  Inv   : Xform;          { Transform type - Forward or Inverse }
  w     : TFloat;         { Frequency of wave }

{*****************************************************************************}

Procedure Debug;          { Used to print intermediate results }

Var I3 : Integer;

Begin
  For I3 := 1 to N Do
    Writeln((I3-1):3,'   ',X[I3]:F:D);
End;    { Debug }

{*****************************************************************************}

Function Ibitr(j,nu : Integer) : Integer;
  { Function to bit invert the number j by nu bits }

Var
  i,j2,ib    : Integer;

Begin
  ib := 0;   { Default return integer }
  For i := 1 to nu do
  Begin
    j2 := j Div 2;          { Divide by 2 and compare lowest bits }
    { ib is doubled and bit 0 set to 1 if j is odd }
    ib := ib*2 + (j - 2*j2);
    j := j2;                { For next pass }
  End;  {For}
  ibitr := ib;              { Return bit inverted value }
End;    { Ibitr }

{*****************************************************************************}

Procedure Expand;

Var
  i,nn2,nx2    : Integer;

Begin
  nn2 := n div 2;
  nx2 := n + n;
  For i := 1 to nn2 do x[i+n] := x[i+nn2]; { Copy IM to 1st half IM position }
  For i := 2 to nn2 do
  Begin
    x[nx2-i+2] := -x[i+n];    { Replicate 2nd half Imag as negative }
    x[n-i+2] := x[i];         { Replicate 2nd half Real as mirror image }
  End;
  n := nx2;       { We have doubled number of points }
End;

{*****************************************************************************}

Procedure Post(inv : Xform);
  { Post processing for forward real transforms and pre-processing for inverse
    real transforms, depending on state of the variable inv. }

Var
  nn2,nn4,l,i,m,ipn2,mpn2   : Integer;
  arg,rmsin,rmcos,ipcos,ipsin,ic,is1,rp,rm,ip,im   : TFloat;

Begin
  nn2 := n div 2;   { n is global }
  nn4 := n div 4;
  { imax represents PI/2 }
  For l := 1 to nn4 Do
  { Start at ends of array and work towards middle }
  Begin
    i := l+1;       { Point near beginning }
    m := nn2-i+2;   { Point near end }
    ipn2 := i+nn2;  { Avoids recalculation each time }
    mpn2 := m+nn2;  { Calcs ptrs to imaginary part }
    rp := x[i]+x[m];
    rm := x[i]-x[m];
    ip := x[ipn2]+x[mpn2];
    im := x[ipn2]-x[mpn2];
    { Take cosine of PI/2 }
    arg := (Pi2/nn4)*(i-1);
    ic := Cos(arg);
    { Cosine term is minus if inverse }
    If inv = Inverse Then ic := -ic;
    Is1 := Sin(arg);
    ipcos := ip*ic;  { Avoid remultiplication below }
    ipsin := ip*is1;
    rmsin := rm*is1;
    rmcos := rm*ic;
    x[i] := (rp + ipcos - rmsin)/2.0;    {* Combine for real-1st pt }
    x[ipn2] := (im - ipsin - rmcos)/2.0; {* Imag-1st point }
    x[m] := (rp - ipcos + rmsin)/2.0;    {* Real - last pt }
    x[mpn2] := -(im +ipsin +rmcos)/2.0;  {* Imag, last pt }
  End;  { For }
  x[1] := x[1]+x[nn2+1];    {** For first complex pair}
  x[nn2+1] := 0.0;          {**}
End;    { Post }

{*****************************************************************************}

Procedure Shuffl(inv : Xform);
  { This procedure shuffels points from alternate real-imaginary to
    1st-half real, 2nd-half imaginary order if inv=Fwd, and reverses the
    process if inv=Inverse.  Algorithm is much like Cooley-Tukey:
      Starts with large cells and works to smaller ones for Fwd
      Starts with small cells and increases if inverse }

Var
  i,j,k,ipcm1,celdis,celnum,parnum  : Integer;
  xtemp                             : TFloat;

Begin
  { Choose whether to start with large cells and go down or start with small
    cells and increase }

  Case inv Of

  Fwd: Begin
    celdis := n div 2;     { Distance between cells }
    celnum := 1;           { One cell in first pass }
    parnum := n div 4;     { n/4 pairs per cell in 1st pass }
    End;   { Fwd case }

  Inverse: Begin
    celdis := 2;           { Cells are adjacent }
    celnum := n div 4;     { n/4 cells in first pass }
    parnum := 1;
    End;  { Inverse case }

  End;  { Case }

  Repeat      { Until cells large if Fwd or small if Inverse }
    i := 2;
    For j:= 1 to celnum do
    Begin
      For k := 1 to parnum do  { Do all pairs in each cell }
      Begin
        Xtemp := x[i];
        ipcm1 := i+celdis-1;   { Index of other pts }
        x[i] := x[ipcm1];
        x[ipcm1] := xtemp;
        i := i+2;
      End;  { For k }

      { End of cell, advance to next one }
      i := i+celdis;
    End;    { For j }

    { Change values for next pass }

    Case inv Of
    Fwd:    Begin
      celdis := celdis div 2;         { Decrease cell distance }
      celnum := celnum * 2;           { More cells }
      parnum := parnum div 2;         { Less pairs per cell }
      End;   { Case Fwd }

    Inverse: Begin
      celdis := celdis * 2;           { More distance between cells }
      celnum := celnum div 2;         { Less cells }
      parnum := parnum * 2;           { More pairs per cell }
      End;   { Case Inverse }
    End;  { Case }

  Until  (((inv = Fwd) And (Celdis < 2)) Or ((inv=Inverse) And (celnum = 0)));

End;  { Shuffl }

{*****************************************************************************}

Procedure FFT(inv : Xform);
  { Fast Fourier transform procedure operating on data in 1st half real,
    2nd half imaginary order and produces a complex result }

Var
  n1,n2,nu,celnum,celdis,parnum,ipn2,kpn2,jpn2,
  i,j,k,l,i2,imax,index      : Integer;
  arg,cosy,siny,r2cosy,r2siny,i2cosy,i2siny,picons,
  y,deltay,k1,k2,tr,ti,xtemp  : TFloat;

Begin
  { Calculate nu = log2(n) }
  nu := 0;
  n1 := n div 2;
  n2 := n1;
  While n1 >= 2 Do
  Begin
    nu := nu + 1;            { Increment power-of-2 counter }
    n1 := n1 div 2;          { divide by 2 until zero }
  End;
  { Shuffel the data into bit-inverted order }
  For i := 1 to n2 Do
  Begin
    k := ibitr(i-1,nu)+1;  { Calc bit-inverted position in array }
    If i>k Then            { Prevent swapping twice }
    Begin
      ipn2 := i+n2;
      kpn2 := k+n2;
      tr := x[k];         { Temp storage of real }
      ti := x[kpn2];      { Temp imag }
      x[k] := x[i];
      x[kpn2] := x[ipn2];
      x[i] := tr;
      x[ipn2] := ti;
    End;  { If }
  End;  { For }

  { Do first pass specially, since it has no multiplications }
  i := 1;
  While i <= n2 Do
  Begin
    k := i+1;
    kpn2 := k+n2;
    ipn2 := i+n2;
    k1 := x[i]+x[k];        { Save this sum }
    x[k] := x[i]-x[k];      { Diff to k's }
    x[i] := k1;             { Sum to I's }
    k1 := x[ipn2]+x[kpn2];  { Sum of imag }
    x[kpn2] := x[ipn2]-x[kpn2];
    x[ipn2] := k1;
    i := i+2;
  End;  { While }

  { Set up deltay for 2nd pass, deltay=PI/2 }
    deltay := PI2;   { PI/2 }
    celnum := n2 div 4;
    parnum := 2;     { Number of pairs between cell }
    celdis := 2;     { Distance between cells }


  { Each pass after 1st starts here }
  Repeat             { Until number of cells becomes zero }

{ Writeln(Lst,'After Nth Pass:');  ### }
{ Debug; }

    { Each new cell starts here }
    index := 1;
    y := 0;      { Exponent of w }
    { Do the number of pairs in each cell }
    For i2 := 1 To parnum Do
    Begin
      If y <> 0 Then
      Begin                { Use sines and cosines if y is not zero }
        cosy := cos(y);    { Calc sine and cosine }
        siny := sin(y);
        { Negate sine terms if transform is inverse }
        If inv = Inverse then siny := -siny;
      End;   { If }
      { These are the fundamental equations of the FFT }
      For l := 0 to celnum-1 Do
      Begin
        i := (celdis*2)*l + index;
        j := i+celdis;
        ipn2 := i + n2;
        jpn2 := j + n2;
        If y = 0 Then   { Special case for y=0 -- No sine or cosine terms }
        Begin
          k1 := x[i]+x[j];
          k2 := x[ipn2]+x[jpn2];
          x[j] := x[i]-x[j];
          x[jpn2] := x[ipn2]-x[jpn2];
        End   { If-Then }
        Else
        Begin
          r2cosy := x[j]*cosy;   { Calc intermediate constants }
          r2siny := x[j]*siny;
          i2cosy := x[jpn2]*cosy;
          i2siny := x[jpn2]*siny;
          { Butterfly }
          k1 := x[i] + r2cosy + i2siny;
          k2 := x[ipn2] - r2siny + i2cosy;
          x[j] := x[i] - r2cosy - i2siny;
          x[jpn2] := x[ipn2] + r2siny - i2cosy;
        End;   { Else }
        { Replace the i terms }
        x[i] := k1;
        x[ipn2] := k2;

      { Advance angle for next pair }
      End;  { For l }

      Y := y + deltay;
      index := index + 1;
    End;  { For i2 }

    { Pass done - change cell distance and number of cells }
    celnum := celnum div 2;
    parnum := parnum * 2;
    celdis := celdis * 2;
    deltay := deltay/2;

  Until celnum = 0;

End;  { FFT }

{*****************************************************************************}

Begin    { * Main program * }
  For i := 0 To Asize-1 Do
  Begin
    x[i] := 0.0;
  End;

{  Write('Enter number of points: ');
  Readln(n);}
  n := 32;
  
  If (n > Asize) Then
  Begin
    Writeln('Too large, will use maximum');
    n := Round(asize/2.0);
  End;

  For i := 2 to n Do begin	{ Create Real array }
   w:=(1-i)*0.25;
   
   x[i] := Exp(w); 
  End; 
   
  x[1] := 0.5;

  Writeln('Input Array:');
  Debug;
  Shuffl(Fwd);
  FFT(Fwd);
  Post(Fwd);
  For i:= 1 to n Do x[i] := x[i]*8/n;
  Writeln('Forward FFT with real array first:');
  Debug;
  
  repeat until keypressed;
End.
