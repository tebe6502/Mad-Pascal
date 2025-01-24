program dl_modify1;
{$librarypath '../'}
uses b_dl, crt;

const
    blankLineHeights: array [0..11] of byte = (
        DL_BLANK1, DL_BLANK2, DL_BLANK3, DL_BLANK4, DL_BLANK5, DL_BLANK6,
        DL_BLANK6, DL_BLANK5, DL_BLANK4, DL_BLANK3, DL_BLANK2, DL_BLANK1
    );

var o,l:byte;

procedure IncOffset;
begin
    o:=o+1;
    if o=12 then o:=0;
end;

begin
    ClrScr;
    Writeln('press any key,');
    Writeln('to modify current display list...');
    Readkey;

    DL_Attach;

    Writeln;
    Writeln('display list has been wobbled.');

    o:=0;
    repeat
        l:=6;
        Pause(2);
        repeat
            DL_Poke(l, blankLineHeights[o]);
            Inc(l,2);
            IncOffset;
        until l=30;
        IncOffset;
    until keypressed;
    Readkey;
end.
