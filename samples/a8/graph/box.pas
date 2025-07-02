PROGRAM BOX(INPUT,OUTPUT,DRAW);

uses graph;

VAR LEFT,TOP:    INTEGER;
    MODE:        byte;
    RIGHT,BOTTOM:INTEGER;
    COUNT,DELAY: INTEGER;
BEGIN
  WRITE('Enter GRAPHICS Mode: ');
  READLN(MODE);
  LEFT:=0;
  TOP:=0;
  CASE MODE OF
      3:BEGIN
        RIGHT:=39;
        BOTTOM:=19;
        END;
      5:BEGIN
        RIGHT:=79;
        BOTTOM:=39;
        END;
      7:BEGIN
        RIGHT:=159;
        BOTTOM:=79;
        END
      ELSE
    END;
  InitGraph(MODE);

  POKE(756,204);
  WRITELN('  GRAPHICS Mode: ',MODE);
  
  FOR COUNT:=1 TO 1000 DO
    BEGIN
      SetColor(2);
      MoveTo(LEFT,TOP);
      SetColor(1);
      LineTo(RIGHT,TOP);
      SetColor(2);
      LineTo(RIGHT,BOTTOM);
      SetColor(1);
      LineTo(LEFT,BOTTOM);
      SetColor(3);
      LineTo(LEFT,TOP);
      FOR DELAY:=1 TO 500 DO
        BEGIN
        END;
      LEFT:=LEFT+2;
      TOP:=TOP+2;
      RIGHT:=RIGHT-2;
      BOTTOM:=BOTTOM-2;
    END;
END.
