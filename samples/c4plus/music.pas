//-----------------------------------------------------------------------------
// Commodore Plus/4, C16 or 264 TED sound frequency tables PAL
// https://www.dtech.lv/techarticles_plus4_freq.html
//-----------------------------------------------------------------------------
const
  a0   =   7; a1   = 516; a2   = 770; a3   = 897; a4   = 960; a5   = 992;
  a0is =  64; a1is = 544; a2is = 784; a3is = 904; a4is = 964; a5is = 994;
  b0   = 118; b1   = 571; b2   = 798; b3   = 911; b4   = 967; b5   = 996;
  c1   = 169; c2   = 597; c3   = 810; c4   = 917; c5   = 971; c6   = 997;
  c1is = 217; c2is = 621; c3is = 822; c4is = 923; c5is = 974;
  d1   = 262; d2   = 643; d3   = 834; d4   = 929; d5   = 976;
  d1is = 305; d2is = 665; d3is = 844; d4is = 934; d5is = 979;
  e1   = 345; e2   = 685; e3   = 854; e4   = 939; e5   = 982;
  f1   = 383; f2   = 704; f3   = 864; f4   = 944; f5   = 984;
  f1is = 419; f2is = 722; f3is = 873; f4is = 948; f5is = 986;
  g1   = 453; g2   = 739; g3   = 881; g4   = 953; g5   = 988;
  g1is = 485; g2is = 755; g3is = 889; g4is = 957; g5is = 990;

//-----------------------------------------------------------------------------
// Zielon mosteczek
//-----------------------------------------------------------------------------
const
  music_notes: array [0..39] of word = (
    c3,c3,c3,c3,e3,g3,f3,e3,d3,c3,
    g3,g3,g3,e3,g3,c4,a3,g3,f3,e3,
    d3,d3,d3,d3,f3,a3,g3,f3,e3,d3,
    c3,c3,c3,c3,e3,g3,f3,e3,d3,c3

  );
  music_duration: array [0..39] of byte = (
    2,2,4,2,2,4,2,2,4,8,
    2,2,4,2,2,4,3,1,2,2,
    2,2,4,2,2,4,3,1,2,2,
    2,2,4,2,2,4,2,2,4,4
  );

//-----------------------------------------------------------------------------

const
  TEMPO = 3;

//-----------------------------------------------------------------------------

{*
$FF0E 0-7 Low byte of frequency for voice 1

$FF0F 0-7 Low byte of frequency for voice 2

$FF10 0-1 High 2 bits of frequency for voice 2

$FF11 0-3 Volume
        4 Select voice 1 (0 = off, 1 = on)
        5 Select voice 2 (0 = off, 1 = on)
        6 Select noise for voice 2 (0 = off, 1 = on)
        7 Sound switch (0 = on, 1 = off)
$FF12 0-1 High 2 bits of frequency for voice 1
      2-7 Nonsound uses
*}
var
  TED_FF0E : byte absolute $FF0E;
  TED_FF11 : byte absolute $FF11;
  TED_FF12 : byte absolute $FF12;

//-----------------------------------------------------------------------------

var
  note      : word;
  duration  : byte;
  i, ii     : byte;

//-----------------------------------------------------------------------------

begin
  //Select voice 1 with maximum volume
  TED_FF11 := $9f;

  for i := 0 to SizeOf(music_duration)-1 do begin
    duration := music_duration[i];
    note := music_notes[i];

    TED_FF0E := Lo(note);
    TED_FF12 := (TED_FF12 and $fc) or Hi(note);

    //Turn on sound
    TED_FF11 := TED_FF11 and $7f;

    for ii := (duration shl TEMPO) downto 1 do pause;

    //Turn off sound
    TED_FF11 := TED_FF11 or $80;

    pause;
  end;

end.
