PROGRAM ROMAN;

uses crt;

//   ROMAN NUMERAL SAMPLE PROGRAM
//   ADAPTED FROM PASCAL USER MANUAL AND REPORT BY JENSEN AND WIRTH

VAR X,Y: WORD;

   BEGIN Y:=1;
   REPEAT X:=Y; WRITE (X,' ');
    WHILE X>=1000 DO
     BEGIN
      WRITE ('M'); X:=X-1000
     END;
    IF X>=500 THEN
     BEGIN
      WRITE ('D'); X:=X-500
     END;
    WHILE X>=100 DO
     BEGIN
      WRITE ('C'); X:=X-100
     END;
    IF X>=50 THEN
     BEGIN
      WRITE ('L'); X:=X-50
     END;
    WHILE X>=10 DO
     BEGIN
      WRITE ('X'); X:=X-10
     END;
    IF X>=5 THEN
     BEGIN
      WRITE ('V'); X:=X-5
     END;
    WHILE X>=1 DO
     BEGIN
      WRITE ('I'); X:=X-1
     END;
  WRITELN;
  Y:=Y SHL 1
 UNTIL Y>5000;

 repeat until keypressed;
 END.

