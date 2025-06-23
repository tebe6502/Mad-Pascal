program space;

{$librarypath 'blibs'}

uses
  b_crt,
  atari,
  SysUtils;

const
  player1: array[0..29] of Byte = ($3C, $10, $C8, $3E, $F, $3E, $C8, $10, $3C, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00);
  // player1 : array [0..10] of byte = (60, 66, 129, 165, 129, 153, 129, 165, 153, 66, 60);

var
  i, a: Byte;
  tab, add: array [0..255] of Byte;
  offset: Dword;

begin
  randomize;

  // Poke(752, 1);  // Cursor off

  offset := Peek(106) - 4;
  pmbase := offset;

  offset := offset * 256;

  gractl := 3;   // Turn on P/M graphics

  sdmctl := Ord(TDmactl.normal) + Ord(TDmactl.players) + Ord(TDmactl.enable);

  // // Clear player 1 memory
  // fillchar(pointer(offset+512), 128, 0);

  Move(player1, pointer(offset + 512 + 90), sizeof(player1));


  for i := 0 to 255 do
  begin
    tab[i] := peek($d20a);
    add[i] := peek($d20a) and 3 + 1;
    // tab[i]:=random(255);
    // add[i]:=random(255) and 3 + 1;
  end;

  sizep0 := 1;  // Size of player 0 (double size)
  pcolr0 := $18;   // Player 0 color
  hposp0 := 50;   // Horizontal position of player 0

  sizem := 0;
  pcolr3 := $0e;

  gprior := 1;

  repeat

    // if  (vcount>60) and (vcount<120) then begin
    grafm := 128;

    i := vcount;

    Inc(tab[i], add[i]);

    a := tab[i];

    wsync := 0;

    hposm3 := a;

    // end;

  until CRT_Keypressed;

end.
