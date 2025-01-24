program rle_test;
{$librarypath '../'}
uses atari, crt, graph, b_utils;
{$R rle.res}
const
    RLE_DATA = $4000;
    COLOR_OFFSET = 135;
begin
    InitGraph(8+16);
    ExpandRLE(RLE_DATA, savmsc);
    repeat 
        wsync := 0;
        colpf2 := (vcount + COLOR_OFFSET) or 12;
        colpf1 := (vcount + COLOR_OFFSET) and 3;
    until keypressed;
end.
