//
// Example datamatrix library usage in graphics mode
// by bocianu '2017
//

program dataGfxMode;
uses graph, datamatrix, crt;

const
    DM_DATA = $8400;
    DM_SIZE = 48;
    xOffset = (80 - DM_SIZE) div 2;
    yOffset = (48 - DM_SIZE) div 2;

procedure ShowMatrix;
var x,y,b:byte;
    data:word;
begin
    InitGraph(4 + 16);
    SetBkColor(15);

    Palette[4]:=0;	// colpf0s (708)
    Palette[5]:=0;	// colpf1s (709)
    Palette[6]:=0;	// colpf2s (710)

    data:=DM_DATA + $100;

    for y:=yOffset to yOffset + DM_SIZE - 1 do
        for x:=xOffset to xOffset + DM_SIZE - 1 do begin
            b:= Peek(data);
            PutPixel(x, y, b);
            Inc(data);
        end;

end;

begin
    SetMessage('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam in quam ligula.', DM_DATA);
    CalculateMatrix;
    ShowMatrix;

    Readkey;
end.
