PROGRAM MAIN(INPUT,OUTPUT);

uses crt;

VAR I,ISQ,ICUBE: REAL;
BEGIN
  WRITELN('Number Square Cube');
  WHILE (I<10.0) DO
  BEGIN
    ISQ:=I*I;
    ICUBE:=ISQ*I;
    WRITELN(I:4:4,'       ',ISQ:4:4,'       ',ICUBE:4:4);
    I:=I+1.0;
  END;

  repeat until keypressed;
END.
