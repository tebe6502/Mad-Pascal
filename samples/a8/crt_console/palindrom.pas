program palindrom;
uses crt;

const
  vdec = 2;                // stała liczbowa w kodzie dziesiętnym
  vhex = $ff;              // stała liczbowa w kodzie szesnastkowym
  vbin = %10110001;        // stała liczbowa w kodzie binarnym
  e = 2.7182818;           // stała zmiennoprzecinkowa

  d = (2 * pi * 12.4);      // stałe z użyciem operatorów
  ls = SizeOf(cardinal);   // stała zawierająca rozmiar zmiennej typu cardinal
  x: word = 5;             // wymuszenie typu stałej
  a = ord('A');            // stała zawierająca kod ATASCII znaku A
  b = '4';                 // stała znakowa
  c = chr(65);             // stała zawierająca znak o kodzie 65

  ts = 'atari';             // łańcuch znaków
  t: array [0..3] of byte = (16, 24, 48, 64);  // tablica

var
  s: string;
  i: byte;

begin

    Write('Podaj wyraz: ');
    Readln(s);
    Writeln;
    for i := byte(s[0]) - 1 downto 1 do begin
        Inc(s[0]);
        //SetLength(s, Length(s) + 1);
        s[byte(s[0])] := s[i];
    end;
    Writeln('Palindrom: ', s);
    Readkey;
end.
