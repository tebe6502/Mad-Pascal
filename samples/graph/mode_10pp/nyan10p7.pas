program nyan10p7;

uses atari, crt, gr10pp, graph; 

const
  DISPLAY_LIST_ADDRESS = $6000; 
  VIDEO_RAM_ADDRESS = $7000;
  BITMAP_ADDRESS = $8000;
  
  FRAME_SIZE = 26 * 19;

{$r resources.rc}
{$I procs.inc}

procedure PutTile(x, y, w, h : byte; tile : word);
var
  vOffset : word;
  b : byte;
begin
  vOffset := VIDEO_RAM_ADDRESS + y*40 + x;
  for b := 0 to h - 1 do begin
    Move(pointer(tile), pointer(vOffset), w);
    Inc(tile, w);
    Inc(vOffset, 40);
  end;
end;

var frame : byte;

begin
  InitGraph(10);
  Gr10Init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 51, 2, 2);
  Poke(77, 0);  // Prevent attract mode
      
  pcolr0 := $00; // background
  pcolr3 := $24; // rainbow
  pcolr1 := $18;
  color2 := $1c;
  pcolr2 := $ba;
  color1 := $74;
  color0 := $54;
  color4 := $3c; // cat
  color3 := $0a;

  // Graphics and color
  SetColor(1); PutPixel(0,0);
  SetColor(2); PutPixel(1,1);
  SetColor(3); PutPixel(2,2);
  SetColor(4); PutPixel(3,3);
  SetColor(5); PutPixel(4,4);
  SetColor(6); PutPixel(5,5);
  SetColor(7); PutPixel(6,6);
  SetColor(8); PutPixel(7,7);
  
  // Graphics text
  SetColor(1); PutChar('A', 0, 35);
  SetColor(2); PutChar('B', 4, 37);
  SetColor(8); PutChar('C', 8, 39);
  
  SetColor(3);
  SetText('ABCDEFGHIJKLMNOPRSTU', 0, 50);    
  SetColor(4);
  SetText('VZWXY 1234567890+-*/', 0, 56);
  SetColor(6);
  SetText('.,:;!?''"()=<>%#', 0, 62);
  
  // Graphics library calls 
  SetColor(7); Line(0, 85, 79, 101);
  SetColor(3); Rectangle(0, 92, 15, 101);
  SetColor(2); Ellipse(30, 90, 6, 10);
  SetColor(5); Bar3D(48, 91, 70, 100, 8, true);

  // Nyan animation
  repeat 
    for frame := 0 to 4 do begin
      Pause(5);
      PutTile(7, 12, 26, 19, BITMAP_ADDRESS + frame * FRAME_SIZE);    
    end;
  until KeyPressed;
end.