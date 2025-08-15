program sort;

uses
  crt,
  dos;

const
  max = 2000;

type
  TArray = array[0..max] of Integer; // Index 0 is not used

var
  test, feld: TArray;
  h, h1, m, m1, s, s1, hund, hund1: Word;
  j, i: Integer;

  {----------------------------------------------------------------------}
  procedure ausgabe(h, h1, m, m1, s, s1, hund, hund1: Word);
  var
    h2, m2, s2, hund2: Longint;
  begin
    if hund1 < hund then
    begin
      hund2 := 100 - (hund - hund1);
      Dec(s1);
    end
    else
      hund2 := hund1 - hund;
    if s1 < s then
    begin
      s2 := 60 - (s - s1);
      Dec(m1);
    end
    else
      s2 := s1 - s;
    if m1 < m then m2 := 60 - (m - m1)
    else
      m2 := m1 - m;
    h2 := h1 - h;
    writeln('                         ', h2, ' h ', m2, ' m ', s2, ' s ', hund2, '/100s');
    writeln;
  end;

  {----------------------------------------------------------------------}
  procedure testmenge(var menge: TArray);

  var
    i: Integer;

  begin
    randomize;
    for i := 1 to max do
      menge[i] := random(65535);
  end;

  {----------------------------------------------------------------------}
  procedure bubble(feld: TArray);

  var
    t: Boolean;
    x, i: Integer;
    tausch: Integer;

  begin
    textcolor(yellow);
    writeln('Bubblesort:');
    textcolor(white);
    gettime(h, m, s, hund);
    t := True;
    x := max;
    while t = True do
    begin
      Dec(x);
      for i := 1 to x do
        if feld[i] > feld[i + 1] then
        begin
          tausch := feld[i];
          feld[i] := feld[i + 1];
          feld[i + 1] := tausch;
          t := True;
        end
        else if x = 2 then t := False;
    end;
    gettime(h1, m1, s1, hund1);
  end;

  {----------------------------------------------------------------------}
  procedure ripple(feld: TArray);
  var
    i, j: Integer;
    pos: Integer;
    test, hold: Integer;

  begin
    textcolor(yellow);
    writeln('Ripplesort (made by R.Patschke):');
    textcolor(white);
    gettime(h, m, s, hund);
    for i := 1 to max - 1 do
    begin
      test := feld[i];
      hold := test;
      pos := i;
      for j := i + 1 to max do
        if feld[j] < test then
        begin
          test := feld[j];
          pos := j;
        end;
      feld[i] := test;
      feld[pos] := hold;
    end;
    gettime(h1, m1, s1, hund1);
  end;

  {----------------------------------------------------------------------}
  procedure einfueg(von, bis: Longint; var feld: TArray);
  var
    i, j, test, pos: Integer;
  begin
    for i := von to bis - 1 do
    begin
      ;
      test := feld[i];
      pos := i;
      for j := i + 1 to bis do
        if feld[j] < test then
        begin
          test := feld[j];
          pos := j;
        end;
      for j := pos - 1 downto i do feld[j + 1] := feld[j];
      feld[i] := test;
    end;
    gettime(h1, m1, s1, hund1);
  end;

  {----------------------------------------------------------------------}
  procedure gabler(feld: TArray);
  var
    i, n, k, tausch: Integer;
  begin
    textcolor(yellow);
    writeln('Ripplesort (made by J.Gabler):');
    textcolor(white);
    gettime(h, m, s, hund);
    for i := 1 to max - 1 do
    begin
      n := i;
      for k := i + 1 to max do
        if feld[n] > feld[k] then n := k;
      if n > i then
      begin
        tausch := feld[i];
        feld[i] := feld[n];
        feld[n] := tausch;
      end;
    end;
    gettime(h1, m1, s1, hund1);
  end;

  {----------------------------------------------------------------------}
  procedure mischsort(test: TArray);

  var
    feld: TArray;
    dummy: Boolean;
    v, i, links, rechts, lgr, rgr: Longint;

  begin
    textcolor(yellow);
    writeln('Sort and Mix:');
    textcolor(white);
    gettime(h, m, s, hund);
    lgr := max div 2;
    rgr := lgr + 1;
    einfueg(1, lgr, test);
    einfueg(rgr, max, test);
    i := 1;
    links := i;
    rechts := rgr;
    dummy := False;
    repeat
      if test[links] < test[rechts] then
      begin
        feld[i] := test[links];
        Inc(i);
        Inc(links);
        if links = rgr then
        begin
          for v := rechts to max do
          begin
            feld[i] := test[v];
            Inc(i);
          end;
          dummy := True;
        end;
      end
      else
      begin
        feld[i] := test[rechts];
        Inc(i);
        Inc(rechts);
        if rechts > max then
        begin
          for v := links to rgr do
          begin
            feld[i] := test[v];
            Inc(i);
          end;
          dummy := True;
        end;
      end;
    until dummy = True;
    gettime(h1, m1, s1, hund1);
  end;

  {----------------------------------------------------------------------}
begin
  clrscr;
  textcolor(lightred);
  Write('Number of array elements: ');
  textcolor(lightblue);
  writeln(max);
  writeln;
  testmenge(test);
  for i := 1 to 5 do
  begin
    case i of
      1: bubble(test);
      2: ripple(test);
      3: gabler(test);
      4: begin
        for j := 1 to max do feld[j] := test[j];
        textcolor(yellow);
        writeln('Insertion Sort:');
        textcolor(white);
        gettime(h, m, s, hund);
        einfueg(1, max, feld);
        gettime(h1, m1, s1, hund1);
      end;
      5: mischsort(test);
    end;
    ausgabe(h, h1, m, m1, s, s1, hund, hund1);
  end;
  textcolor(lightgreen);
  writeln('Press a key.');
  repeat
  until keypressed;
end.
