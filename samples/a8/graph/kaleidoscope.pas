// ADAPTED FROM KYANPASCAL

PROGRAM KALEIDOSCOPE;

uses fastgraph;

VAR I,J,K,W: shortint;

BEGIN
 InitGraph(3 + 16);
 
 REPEAT
 FOR W:=3 TO 50 DO
  BEGIN
    FOR I:=1 TO 10 DO
    BEGIN
     FOR J:=0 TO 10 DO
      BEGIN
       K:=I+J;
       SetCOLOR(J*3 div (I+3)+I*W div 12);
       PutPixel(I+8,K);
       PutPixel(K+8,I);
       PutPixel(32-I,24-K);
       PutPixel(32-K,24-I);
       PutPixel(K+8,24-I);
       PutPixel(32-I,K);
       PutPixel(I+8,24-K);
       PutPixel(32-K,I)
      END
    END
  END
 UNTIL false // UNENDING LOOP
 
END.

