program intro;
uses atari, graph, crt, aplib;
const   
    LOGO = $3000;
{$r assets/intro.rc}
var
    i:byte;

procedure PlayChord(a,b:byte);
var vol:byte;
begin
    for vol:=15 downto 0 do begin
        Sound(0,a,10,vol);
        Sound(1,b,10,vol);
        Pause;
    end;    
end;

begin
    Initgraph(8+16);
    color1:=0;
    color2:=0;

    Pause;
    UnApl(pointer(LOGO), pointer(savmsc));

    for color1:=0 to 14 do Pause;

    PlayChord(108,81);
    PlayChord(135,108);
    PlayChord(121,96);

    i:=0;
    repeat 
        Pause; 
        Inc(i); 
    until keypressed or (i=150);

    for color1:=15 downto 1 do Pause;
    if keypressed then readkey;
end.