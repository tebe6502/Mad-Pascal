// ADAPTED FROM KYANPASCAL

PROGRAM KALEIDOSCOPE;

uses x16, graph;

var
  I,J,K,W: word;
  color: byte;

BEGIN
 InitGraph(X16_MODE_320x240);
 
 REPEAT
 FOR W:=3 TO 500 DO
  BEGIN
    FOR I:=1 TO 100 DO
    BEGIN
     FOR J:=0 TO 100 DO
      BEGIN
       K:=I+J;
       color:=J*3 div (I+3)+I*W div 12;
       PutPixel(I+80,K,color);
       PutPixel(K+80,I,color);
       PutPixel(320-I,240-K,color);
       PutPixel(320-K,240-I,color);
       PutPixel(K+80,240-I,color);
       PutPixel(320-I,K,color);
       PutPixel(I+80,240-K,color);
       PutPixel(320-K,I,color);
      END;
      // pause(10);
    END;
    // pause(10);
  END;
 UNTIL false; // UNENDING LOOP
 
END.

