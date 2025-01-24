program lz4_test;
{$librarypath '../'}
uses atari, crt, graph, b_utils;
{$R lz4.res}
const
    LZ4_DATA = $4000;
    COLOR_OFFSET = 135;
begin
    InitGraph(8+16);
    ExpandLZ4(LZ4_DATA, savmsc);
    repeat 
        wsync := 0;
        colpf2 := (vcount + COLOR_OFFSET) or 12;
        colpf1 := (vcount + COLOR_OFFSET) and 3;
    until keypressed;
end.
