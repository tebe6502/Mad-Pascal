unit StringUtilities;

interface

uses CommonTypes, SysUtils;

type
  TStringIndex = Integer;
  TStringArray = array of String;

const
  TAB = ^I;   // Char for a TAB
  CR = ^M;    // Char for a CR
  LF = ^J;    // Char for a LF

  AllowDirectorySeparators: set of Char = ['/', '\'];

  AllowWhiteSpaces: set of Char = [' ', TAB, CR, LF];
  AllowQuotes: set of Char = ['''', '"'];
  // TODO: Include '.'?
  AllowLabelFirstChars: set of Char = ['A'..'Z', 'a'..'z', '_'];
  AllowLabelChars: set of Char = ['A'..'Z', 'a'..'z', '0'..'9', '_', '.'];
  AllowDigitFirstChars: set of Char = ['0'..'9', '%', '$'];
  AllowDigitChars: set of Char = ['0'..'9', 'A'..'F', 'a'..'f'];

  // ----------------------------------------------------------------------------

function IntToStr(const Value: Int64): String;
function StrToInt(const a: String): TInteger;

// ----------------------------------------------------------------------------

procedure SkipWhitespaces(const a: String; var i: TStringIndex);

function GetNumber(const a: String; var i: TStringIndex): String;

function GetConstantUpperCase(const a: String; var i: TStringIndex): String;

function GetLabel(const a: String; var i: TStringIndex): String;
function GetLabelUpperCase(const a: String; var i: TStringIndex): String;

function GetString(const a: String; const upperCase: Boolean; var i: TStringIndex): String;
function GetStringUpperCase(const a: String; var i: TStringIndex): String;
function GetFilePath(const a: String; var i: TStringIndex): String;

function SplitStr(const a: String; const separatorCharacter: Char): TStringArray;

// ----------------------------------------------------------------------------

implementation

const
  MAX_DECIMAL_VALUE = 1023;

var
  DecimalStringArray: array[0..MAX_DECIMAL_VALUE] of String;



function IntToStr(const Value: Int64): String;
begin
  if (Value >= Low(DecimalStringArray)) and (Value <= High(DecimalStringArray)) then
  begin
    Result := DecimalStringArray[Value];
  end
  else
  begin
    str(Value, Result);
  end;
end;

function StrToInt(const a: String): TInteger;
{$IFNDEF PAS2JS}
var
  i: Integer; // ##NEEDED
begin
  val(a, Result, i);
end;

{$ELSE}
// This code below should work the same in FPC, but this needs to be tested first.
var value: integer;
var i: integer;
begin
 val(a,value, i);
 Result := value;
end;
{$ENDIF}

(*----------------------------------------------------------------------------*)
(* Skip whitespace characters until the next non-whitespace character.        *)
(*----------------------------------------------------------------------------*)
procedure SkipWhitespaces(const a: String; var i: TStringIndex);
begin

  if a <> '' then
    while (i <= length(a)) and (a[i] in AllowWhiteSpaces) do Inc(i);

end;

(*----------------------------------------------------------------------------*)
(*  Get numeric string starting with characters '0'..'9','%','$'.             *)
(*----------------------------------------------------------------------------*)
function GetNumber(const a: String; var i: TStringIndex): String;
begin
  Result := '';

  if a <> '' then
  begin

    SkipWhitespaces(a, i);

    if (i <= Length(a)) then
    begin
      if a[i] in AllowDigitFirstChars then
      begin

        Result := UpCase(a[i]);
        Inc(i);

        while (i <= Length(a)) and (a[i] in AllowDigitChars) do
        begin
          Result := Result + UpCase(a[i]);
          Inc(i);
        end;

      end;

    end;

  end;

end;

(*----------------------------------------------------------------------------*)
(*  Get label starting with characters 'A'..'Z','_', '.'                      *)
(*----------------------------------------------------------------------------*)
function GetConstantUpperCase(const a: String; var i: TStringIndex): String;
begin

  Result := '';

  if a <> '' then
  begin

    SkipWhitespaces(a, i);

    if a[i] in AllowLabelFirstChars + ['.'] then
      while a[i] in AllowLabelChars do
      begin

        Result := Result + UpCase(a[i]);

        Inc(i);
      end;

  end;

end;


(*----------------------------------------------------------------------------*)
(* Get label starting with characters 'A'..'Z','_', '.', '/', '\'.            *)
(*----------------------------------------------------------------------------*)
function GetLabel(const a: String; var i: TStringIndex): String;
begin

  Result := '';

  if a <> '' then
  begin

    SkipWhitespaces(a, i);


    if (i <= length(a)) and (a[i] in AllowLabelFirstChars + ['.']) then
      while (i <= length(a)) and (a[i] in (AllowLabelChars + AllowDirectorySeparators)) do
      begin
        Result := Result + a[i];

        Inc(i);
      end;
  end;

end;


(*----------------------------------------------------------------------------*)
(* Get upper-case label starting with characters 'A'..'Z','_', '.', '/', '\'. *)
(*----------------------------------------------------------------------------*)
function GetLabelUpperCase(const a: String; var i: TStringIndex): String;
begin
  Result := '';

  if a <> '' then
  begin

    SkipWhitespaces(a, i);

    if (i <= length(a)) and (a[i] in AllowLabelFirstChars + ['.']) then
      while (i <= length(a)) and (a[i] in (AllowLabelChars + AllowDirectorySeparators)) do
      begin
        Result := Result + UpCase(a[i]);

        Inc(i);
      end;
  end;

end;


(*----------------------------------------------------------------------------*)
(*  Geta string, delimited by the characters '' or ""                         *)
(*  Double '' means literal '                                                 *)
(*  Double "" means literal "                                                 *)
(*----------------------------------------------------------------------------*)
function GetString(const a: String; const upperCase: Boolean; var i: TStringIndex): String;
var
  znak, gchr: Char;
begin
  Result := '';

  SkipWhitespaces(a, i);

  if (i <= length(a)) then
  begin

    if a[i] = '%' then
    begin

      while (i <= length(a)) and (a[i] in ['A'..'Z', 'a'..'z', '%']) do
      begin
        Result := Result + Upcase(a[i]);
        Inc(i);
      end;

    end
    else
      if not (a[i] in AllowQuotes) then
      begin

        if upperCase then Result := GetLabelUpperCase(a, i)
        else
          Result := GetLabel(a, i);

      end
      else
      begin

        gchr := a[i];

        while (i <= length(a)) do
        begin
          Inc(i);   // we skip the first character ' or "

          znak := a[i];

          if znak = gchr then
          begin
            Inc(i);
            Break;
          end;

          Result := Result + znak;
        end;

      end;
  end;

end;

function GetStringUpperCase(const a: String; var i: TStringIndex): String;
begin
  Result := GetString(a, True, i);
end;

function GetFilePath(const a: String; var i: TStringIndex): String;
begin
  Result := GetString(a, False, i);
end;


(*----------------------------------------------------------------------------*)
(* Read sequence of characters separated by 'separatorCharacter'.             *)
(* If there are characters opening the string, read such a string             *)
(*----------------------------------------------------------------------------*)
function SplitStr(const a: String; const separatorCharacter: Char): TStringArray;
var
  znak: Char;
  i, len: Integer;
  txt, s: String;

  function GetParenthesizedString(const a: String; var i: TStringIndex): String;
    (*------------------------------------------------------------------------*)
    (* Takes a sequence bounded by two characters '(' and ')'                 *)
    (* The characters '(' and ')' can be nested                               *)
    (*------------------------------------------------------------------------*)
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

        txt := GetStringUpperCase(a, i);

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

    if a[i] = separatorCharacter then
    begin

      AddString;

      Inc(i);

    end
    else

      case UpCase(a[i]) of
        '(': s := s + GetParenthesizedString(a, i);

        '''', '"':
        begin
          znak := a[i];

          txt := GetStringUpperCase(a, i);

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

procedure InitializeStrings;
var
  i: Integer;
begin
  for i := Low(DecimalStringArray) to High(DecimalStringArray) do
  begin
    DecimalStringArray[i] := SysUtils.IntToStr(i);
  end;
end;


initialization

  InitializeStrings;

end.
end.
