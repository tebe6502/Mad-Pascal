unit inifiles;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: INI Files
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
	function ReadBool(const Section, Ident: TString; Default: Boolean): Boolean;

//	function ReadFloat(const Section, Ident: TString; Default: Single): Single;

	end;


implementation

uses sysutils;


var tmp: string;


procedure TINIFile.Free;
(*
@description:
*)

begin


end;


function Search(var FileName, Section, Ident: TString): TString;
(*
@description:
*)
var t: text;
    yes: Boolean;
    s: string;
begin

 Result:='';

 assign(t, FileName); reset(t);

 yes:=true;

 while IOResult = 1 do begin

  readln(t, s);

  tmp:=s;

  Section:=AnsiUpperCase(Section);
  Ident:=AnsiUpperCase(Ident);
  s:=AnsiUpperCase(s);

  if (length(s) > 0) and (s[1] <> ';') then

  if yes then begin					// search for SECTION

   if (s[1] = '[') and (s[length(Section) + 2] = ']') then
    if CompareByte(@Section[1], @s[2], length(Section)) = 0 then yes := false;

  end else begin					// search for KEY = VALUE

   if s[length(Ident) + 1] = '=' then
    if CompareByte(@Ident[1], @s[1], length(Ident)) = 0 then begin

     Result := copy(tmp, length(Ident) + 2, 255);
     Break;

    end;

  end;

 end;

 close(t);

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
begin

 Result := Search(FileName, Section, Ident);

 if length(Result) = 0 then
  Result := Default
 else
  if (Result[1] = '"') and (Result[length(Result)] = '"') then		// remove " "
   Result := copy(Result, 2, length(Result) - 2);

end;


function TINIFile.ReadInteger(const Section, Ident: TString; Default: integer): integer;
(*
@description:
*)
var i: byte;
begin

 tmp := Search(FileName, Section, Ident);

 val(tmp, Result, i);

 if (length(tmp) = 0) or (i <> 0) then Result := Default;

end;


function TINIFile.ReadBool(const Section, Ident: TString; Default: Boolean): Boolean;
(*
@description:
*)
begin

 tmp := Search(FileName, Section, Ident);

 if length(tmp) <> 0 then begin

  if length(tmp) = 1 then
   Result := (tmp[1] = '1')
  else
   Result := false;

 end else
  Result := Default;

end;



initialization


end.
