unit inifiles;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name:
 @version: 1.0

 @description:

 https://github.com/graemeg/freepascal/blob/master/packages/fcl-base/src/inifiles.pp

 *)


{

+ TINIFile : Object

}


interface


type	TINIFile = Object
	(*
	@description:

	*)

	FileName: TString;


	procedure Create(fn: TString);
	procedure Free;

	function ReadString(const Section, Ident, Default: TString): TString;
	function ReadInteger(const Section, Ident: TString; Default: integer): integer;

{
	function ReadBool(const Section, Ident: TString; Default: Boolean): Boolean;
	function ReadFloat(const Section, Ident: TString; Default: Single): Single;
}
	end;


implementation

uses sysutils;


procedure TINIFile.Free;
(*
@description:
*)

begin


end;


procedure TINIFile.Create(fn: TString);
(*
@description:
*)
var t: text;
begin

 if not(FileExists(fn)) then begin
  assign(t, fn);
  rewrite(t);
  close(t);
 end;

 FileName:=fn;

end;


function TINIFile.ReadString(const Section, Ident, Default: TString): TString;
(*
@description:
*)
var t: text;
    s: TString;
    yes: Boolean;
begin

 Result:=Default;

 assign(t, FileName); reset(t);

 yes:=true;

 while IOResult = 1 do begin

  readln(t, s);

  if (length(s) > 0) and (s[1] <> ';') then

  if yes then begin		// search for SECTION

   if (s[1] = '[') and (s[length(Section) + 2] = ']') then
    if CompareByte(@Section[1], @s[2], length(Section)) = 0 then yes := false;

  end else begin		// search for KEY = VALUE

   if s[length(Ident) + 1] = '=' then
    if CompareByte(@Ident[1], @s[1], length(Ident)) = 0 then begin

     Result := copy(s, length(Ident) + 2, 255);

     if (Result[1] = '"') and (Result[length(Result)] = '"') then	// remove " "
      Result := copy(Result, 2, length(Result) - 2);

     Break;

    end;

  end;

 end;

 close(t);

end;


function TINIFile.ReadInteger(const Section, Ident: TString; Default: integer): integer;
(*
@description:
*)
var t: text;
    s: TString;
    yes: Boolean;
    i: byte;
begin

 Result:=Default;

 assign(t, FileName); reset(t);

 yes:=true;

 while IOResult = 1 do begin

  readln(t, s);

  if (length(s) > 0) and (s[1] <> ';') then

  if yes then begin		// search for SECTION

   if (s[1] = '[') and (s[length(Section) + 2] = ']') then
    if CompareByte(@Section[1], @s[2], length(Section)) = 0 then yes := false;

  end else begin		// search for KEY = VALUE

   if s[length(Ident) + 1] = '=' then
    if CompareByte(@Ident[1], @s[1], length(Ident)) = 0 then begin

     s := copy(s, length(Ident) + 2, 255);

     val(s, Result, i);

     Break;

    end;

  end;

 end;

 close(t);

end;


initialization


end.
