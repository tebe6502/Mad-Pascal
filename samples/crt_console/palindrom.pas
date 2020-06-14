program palindrom;
uses crt;

const
  vdec = 2;                // sta³a liczbowa w kodzie dziesiêtnym
  vhex = $ff;              // sta³a liczbowa w kodzie szesnastkowym
  vbin = %10110001;        // sta³a liczbowa w kodzie binarnym
  e = 2.7182818;           // sta³a zmiennoprzecinkowa

  d = (2 * pi * 12.4);      // sta³e z u¿yciem operatorów
  ls = SizeOf(cardinal);   // sta³a zawieraj¹ca rozmiar zmiennej typu cardinal
  x: word = 5;             // wymuszenie typu sta³ej
  a = ord('A');            // sta³a zawieraj¹ca kod ATASCII znaku A
  b = '4';                 // sta³a znakowa
  c = chr(65);             // sta³a zawieraj¹ca znak o kodzie 65

  ts = 'atari';             // ³añcuch znaków
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
