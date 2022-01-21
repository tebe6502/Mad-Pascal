uses crt, graph, c64;

var i: byte;

    GraphDriver, GraphMode : smallint;

begin

 GraphDriver := VGA;
 GraphMode := VGAMed;
 InitGraph(GraphDriver,GraphMode,'');

// %00 for background color 0 ($d021)
 SetBkColor(0);

// %01 for the upper nibble of the screen matrix
// %10 for lower nibble of the screen matrix
 fillchar(ScreenRAM, 25*40, RED*16 + BLUE);

// %11 for the lower nibble of Screen RAM.
 fillchar(ColorRAM, 25*40, YELLOW);


 SetColor(1);

 MoveTo(10,10);
 LineTo(155,140);

 SetColor(2);

 MoveTo(119,34);
 LineTo(55,194);

 SetColor(3);

 MoveTo(19,74);
 LineTo(126,114);

repeat until keypressed;

TextMode(0);

end.
