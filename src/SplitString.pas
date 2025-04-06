unit SplitString;


interface

uses Common;

// ----------------------------------------------------------------------------

	function SplitStr(a: string; const Sep: Char): TArrayString;

// ----------------------------------------------------------------------------

implementation

// ----------------------------------------------------------------------------


function SplitStr(a: string; const Sep: Char): TArrayString;
(*----------------------------------------------------------------------------*)
(*  wczytaj dowolne znaki rozdzielone 'Sep'		                      *)
(*  jesli wystepuja znaki otwierajace ciag, czytaj taki ciag                  *)
(*----------------------------------------------------------------------------*)

var znak: char;
    i, len: integer;
    txt, s: string;


procedure omin_spacje (var i:integer; var a:string);
(*----------------------------------------------------------------------------*)
(*  omijamy tzw. "biale spacje" czyli spacje, tabulatory		      *)
(*----------------------------------------------------------------------------*)
begin

 if a <> '' then
  while (i<=length(a)) and (a[i] in AllowWhiteSpaces) do inc(i);

end;


function get_string(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobiera ciag znakow, ograniczony znakami '' lub ""                        *)
(*  podwojny '' oznacza literalne '                                           *)
(*  podwojny "" oznacza literalne "                                           *)
(*----------------------------------------------------------------------------*)
var len: integer;
    znak, gchr: char;
begin
 Result:='';

 omin_spacje(i,a);
 if not(a[i] in AllowQuotes) then exit;

 gchr:=a[i]; len:=length(a);

 while i<=len do begin
  inc(i);         // omijamy pierwszy znak ' lub "

  znak:=a[i];

  if znak=gchr then begin
   inc(i);
   if a[i]=gchr then znak:=gchr else exit;
  end;

  Result := Result + znak;
 end;

end;


function ciag_ograniczony(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobiera ciag ograniczony dwoma znakami 'LEWA' i 'PRAWA'                   *)
(*  znaki 'LEWA' i 'PRAWA' moga byc zagniezdzone                              *)
(*----------------------------------------------------------------------------*)
var nawias, len: integer;
    znak, lewa, prawa: char;
    petla: Boolean;
    txt: string;
begin
 Result:='';

 if not(a[i] in ['(']) then exit;

 lewa:=a[i];
 if lewa='(' then prawa:=')' else prawa:=chr(ord(lewa)+2);

 nawias:=0; petla:=true; len:=length(a);

 while petla and (i<=len) do begin

  znak := a[i];

  if znak=lewa then inc(nawias) else
   if znak=prawa then dec(nawias);

//  if not(zag) then
//   if nawias>1 then test_nawias(a,lewa,0);

//  if nawias=0 then petla:=false;
  petla := not(nawias=0);

   if znak in AllowQuotes then begin

   txt:= get_string(i,a);

   Result := Result + znak + txt + znak;

   if txt = znak then Result:=Result + znak;

   end else begin
    Result := Result + znak;
    inc(i)
   end;

 end;

end;


procedure AddString;
var i: integer;
begin

 i:=High(Result);
 Result[i] := s;

 SetLength(Result, i + 2);

 s:='';
end;


begin
 SetLength(Result, 1);

 i:=1;

 len:=length(a);

 s:='';

 while i <= len do

  if a[i]=Sep then begin

   AddString;

   inc(i);

  end else

  case UpCase(a[i]) of
   '(': s:=s + ciag_ograniczony(i,a);

   '''','"':
     begin
      znak:=a[i];

      txt:=get_string(i,a);

      s:=s + znak + txt + znak;

      if znak = txt then s:=s + znak;

     end;

  else
   begin
    s := s + a[i];
    inc(i);
   end;
  end;

 if s <> '' then AddString;

end;


end.
