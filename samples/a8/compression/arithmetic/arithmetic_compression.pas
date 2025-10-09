{
Hello Thomas,

On 26.06.94 you wrote in area PASCAL to subject "Arithmetic compression":
TW> But where can we get a discription of this compression method ??
  Michael  Barnsley, Lyman Hurd, "Fractal Image Compression", AK Peters,
  1993
  Mark Nelson, "The Data Compression Book", M&T Books, 1991
  Ian  Witten,  Radford  Neal,  John Cleary, "Arithmetic Coding for Data
  Compression", CACM, Vol. 30, No.6, 1987

  Below  is a small source from the 1st book, translated into Pascal and
  adopted  to  work  on  the uppercase alphabet to demonstrate the basic
  principles.
  For  a  simple  explanation, the program uses the letters of the input
  string  to "drive" the starting point through the real interval 0.0 ..
  1.0
  By  this process, every possible input string stops at a unique point,
  that  is:  a  point  (better: a small interval section) represents the
  whole  string.  To  _decode_  it, you have to reverse the process: you
  start  at  the  given  end point and apply the reverse transformation,
  noting  which intervals you are touching at your voyage throughout the
  computation.
  Due  to the restricted arithmetic resolution of any computer language,
  the  max.  length of a string will be restricted, too (try it out with
  TYPE   REAL=EXTENDED,  for  example);  this  happens  when  the  value
  "underflows" the computers precision. }


PROGRAM arithmeticCompression;

USES CRT;

TYPE TFloat = single;

CONST charSet:STRING='ABCDEFGHIJKLMNOPQRSTUVWXYZ ';
      size=27; {=Length(charSet)}
      p:ARRAY[0..size] OF TFloat=  (* found empirically *)
       (
        0.0,
        6.1858296469E-02,
        1.1055412402E-02,
        2.6991022453E-02,
        2.6030374520E-02,
        9.2418577127E-02,
        2.1864028512E-02,
        1.4977615842E-02,
        2.8410764564E-02,
        5.5247871050E-02,
        1.3985123226E-03,
        3.8001321554E-03,
        3.2593032914E-02,
        2.1919756707E-02,
        5.2434924064E-02,
        5.7837905257E-02,
        2.0364674693E-02,
        1.0031075103E-03,
        4.9730779744E-02,
        4.8056280170E-02,
        7.2072478498E-02,
        2.0948493879E-02,
        8.2477728625E-03,
        1.0299101184E-02,
        4.7873173243E-03,
        1.3613601926E-02,
        2.7067980437E-03,
        2.3933136781E-01
       );
VAR   psum:ARRAY[0..size] OF TFloat;

 FUNCTION Encode(CONST s:STRING):TFloat;
 VAR i,po:byte;
     offset,len:TFloat;
 BEGIN
  offset:=0.0;
  len:=1.0;
  FOR i:=1 TO Length(s) DO
   BEGIN
    po:=POS(s[i],charSet);
    IF po<>0
     THEN BEGIN
           offset:=offset+len*psum[po];
           len:=len*p[po]
          END
     ELSE BEGIN
           WRITELN('only input chars ',charSet,' allowed!');
           Halt(1)
          END;
   END;
  Encode:=offset+len/2;
 END;


 FUNCTION Decode(x:TFloat; n:BYTE):STRING;
 VAR i,j:byte;
     s:STRING;
 BEGIN
 
  SetLength(s, 255);
 
  IF (x<0.0) OR (x>1.0)
   THEN BEGIN
         WRITELN('must lie in the range [0..1]');
         Halt(1)
        END;
  FOR i:=1 TO n DO
   BEGIN
    j:=size;
    WHILE x<psum[j] DO DEC(j);
    s[i]:=charSet[j];
    x:=x-psum[j];
    x:=x/p[j];
   END;
  SetLength(s, n);
  Decode:=s
 END;


CONST
     inp='ARITHMETIC';
VAR
    r:TFloat;
    i,j:byte;

BEGIN

 FOR i:=1 TO size DO
  BEGIN
   psum[i]:=0.0;
   FOR j:=1 TO i-1 DO
    psum[i]:=psum[i]+p[j];
  END;

 WRITELN('encoding string    : ',inp);
 r:=Encode(inp);
 WRITELN('string is encoded by ',r);
 WRITELN('decoding of r gives: ',Decode(r,Length(inp)));

 repeat until keypressed;
END.