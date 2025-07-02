{$librarypath blibs}

program nyan10plus;
uses atari, crt, rmt, gr10pp, graph; 

const
{$i const.inc}
{$r resources.rc}

procedure PutTile(x, y, w, h: byte; tile: word);
var vOffset: word;
    b: byte;
begin
  
    vOffset := VIDEO_RAM_ADDRESS + y*40 + x;
    for b:=0 to h - 1 do begin
        Move(pointer(tile), pointer(vOffset), w);
        Inc(tile, w);
        Inc(vOffset, 40);
    end;
end;

var frame: byte;

begin
    Gr10Init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 48, 4, 2);
    
    pcolr0 := $00; // background
    pcolr3 := $24; // rainbow
    pcolr1 := $18;
    color2 := $1c;
    pcolr2 := $ba;
    color1 := $74;
    color0 := $54;
    color4 := $3c; // cat
    color3 := $0a;
    
    repeat 
        for frame := 0 to 4 do begin
            Pause(5);
            PutTile(7, 12, 26, 19, BITMAP_ADDRESS + frame * FRAME_SIZE);    
        end;
    until KeyPressed;
end.
