
uses crt, sysutils;

var
  tekst: TString;
  liczba: cardinal;
  i: byte;
  suma: word;
begin
    Write('Podaj liczbe: ');
    Readln(liczba);
    Str(liczba, tekst);
    Writeln('Ilosc cyfr: ', Length(tekst)); // albo byte(tekst[0]) !!!
    Writeln('Pierwsza cyfra: ', tekst[1]);
    suma := 0;

    for i := 1 to Length(tekst) do
      suma := suma + StrToInt(tekst[i]);

    Writeln('Suma cyfr: ', suma);
    Readkey;
end.
