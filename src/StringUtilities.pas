unit StringUtilities;


interface

type
  TStringArray = array of String;

const
  TAB = ^I;    // Char for a TAB
  CR = ^M;    // Char for a CR
  LF = ^J;    // Char for a LF

  AllowDirectorySeparators: set of Char = ['/', '\'];

  AllowWhiteSpaces: set of Char = [' ', TAB, CR, LF];
  AllowQuotes: set of Char = ['''', '"'];
  AllowLabelFirstChars: set of Char = ['A'..'Z', '_'];
  AllowLabelChars: set of Char = ['A'..'Z', '0'..'9', '_', '.'];
  AllowDigitFirstChars: set of Char = ['0'..'9', '%', '$'];
  AllowDigitChars: set of Char = ['0'..'9', 'A'..'F'];


// ----------------------------------------------------------------------------

function SplitStr(a: String; const Sep: Char): TStringArray;

// ----------------------------------------------------------------------------

implementation

// ----------------------------------------------------------------------------


(*----------------------------------------------------------------------------*)
(*  wczytaj dowolne znaki rozdzielone 'Sep'                          *)
(*  jesli wystepuja znaki otwierajace ciag, czytaj taki ciag                  *)
(*----------------------------------------------------------------------------*)
function SplitStr(a: String; const Sep: Char): TStringArray;

var
  znak: Char;
  i, len: Integer;
  txt, s: String;


  procedure omin_spacje(var i: Integer; var a: String);
  (*----------------------------------------------------------------------------*)
  (*  omijamy tzw. "biale spacje" czyli spacje, tabulatory          *)
  (*----------------------------------------------------------------------------*)
  begin

    if a <> '' then
      while (i <= length(a)) and (a[i] in AllowWhiteSpaces) do Inc(i);

  end;


  function get_string(var i: Integer; var a: String): String;
    (*----------------------------------------------------------------------------*)
    (*  pobiera ciag znakow, ograniczony znakami '' lub ""                        *)
    (*  podwojny '' oznacza literalne '                                           *)
    (*  podwojny "" oznacza literalne "                                           *)
    (*----------------------------------------------------------------------------*)
  var
    len: Integer;
    znak, gchr: Char;
  begin
    Result := '';

    omin_spacje(i, a);
    if not (a[i] in AllowQuotes) then exit;

    gchr := a[i];
    len := length(a);

    while i <= len do
    begin
      Inc(i);         // omijamy pierwszy znak ' lub "

      znak := a[i];

      if znak = gchr then
      begin
        Inc(i);
        if a[i] = gchr then znak := gchr
        else
          exit;
      end;

      Result := Result + znak;
    end;

  end;


  function ciag_ograniczony(var i: Integer; var a: String): String;
    (*----------------------------------------------------------------------------*)
    (*  pobiera ciag ograniczony dwoma znakami 'LEWA' i 'PRAWA'                   *)
    (*  znaki 'LEWA' i 'PRAWA' moga byc zagniezdzone                              *)
    (*----------------------------------------------------------------------------*)
  var
    nawias, len: Integer;
    znak, lewa, prawa: Char;
    petla: Boolean;
    txt: String;
  begin
    Result := '';

    if not (a[i] in ['(']) then exit;

    lewa := a[i];
    if lewa = '(' then prawa := ')'
    else
      prawa := chr(Ord(lewa) + 2);

    nawias := 0;
    petla := True;
    len := length(a);

    while petla and (i <= len) do
    begin

      znak := a[i];

      if znak = lewa then Inc(nawias)
      else
      if znak = prawa then Dec(nawias);

      //  if not(zag) then
      //   if nawias>1 then test_nawias(a,lewa,0);

      //  if nawias=0 then petla:=false;
      petla := not (nawias = 0);

      if znak in AllowQuotes then
      begin

        txt := get_string(i, a);

        Result := Result + znak + txt + znak;

        if txt = znak then Result := Result + znak;

      end
      else
      begin
        Result := Result + znak;
        Inc(i);
      end;

    end;

  end;


  procedure AddString;
  var
    i: Integer;
  begin

    i := High(Result);
    Result[i] := s;

    SetLength(Result, i + 2);

    s := '';
  end;

begin
  SetLength(Result, 1);

  i := 1;

  len := length(a);

  s := '';

  while i <= len do

    if a[i] = Sep then
    begin

      AddString;

      Inc(i);

    end
    else

      case UpCase(a[i]) of
        '(': s := s + ciag_ograniczony(i, a);

        '''', '"':
        begin
          znak := a[i];

          txt := get_string(i, a);

          s := s + znak + txt + znak;

          if znak = txt then s := s + znak;

        end;

        else
        begin
          s := s + a[i];
          Inc(i);
        end;
      end;

  if s <> '' then AddString;

end;


end.
