unit stringUtils;
(*
* @type: unit
* @author: dely <daniel.kozminski@gmail.com>
* @name: String manipulation library.
* @version: 0.1

* @description:
* String manipulation procedures and functions for use with MadPascal. 
*
* <https://gitlab.com/delysio/mad-pascal>
*)
interface 

function strCat(s1: string; s2: string): string; overload;
(*
* @description:
* Returns concatenated strings.
*
* @param: (string) s1 - The input string.
* @param: (string) s2 - The string to concatenate.
*
* @returns: (string) - Concatenated string.
*) 

function strCat(s: string; c: char): string; overload;
(*
* @description:
* Returns concatenated strings.
*
* @param: (string) s - The input string.
* @param: (char) c - The char to concatenate.
*
* @returns: (string) - Concatenated string.
*) 

procedure strAdd(var s: string; c: char); overload;
(*
* @description:
* Adds char to string.
*
* @param: (string) s - The input string.
* @param: (char) c - Char to add.
*)

procedure strAdd(var s1: string; s2: string); overload;
(*
* @description:
* Adds string to string.
*
* @param: (string) s1 - The input string.
* @param: (string) s2 - The string to add.
*)

function strLeft(s: string; count: byte): string;
(*
* @description:
* Returns left portion of string specified by the count parameter.
*
* @param: (string) s - The input string.
* @param: (byte) count - How many characters will be returned.
*
* @returns: (string) - the returned string will end at the count position in string, counting from one.
*) 

function strRight(s: string; count: byte): string;
(*
* @description:
* Returns right portion of string specified by the count parameter.
*
* @param: (string) s - The input string.
* @param: (byte) count - How many characters will be returned.
*
* @returns: (string) - the returned string will start at the count position in string, counting from one.
*) 

function strMid(s: string; startChar: byte; countChars: byte): string;
(*
* @description:
* Returns the portion of string specified by the startChar and countChars parameters.
*
* @param: (string) s - The input string.
* @param: (byte) startChar - start character index counting from one.
* @param: (byte) countChars - How many characters will be returned.
*
* @returns: (string) - the returned string will start at the startChar position in string, counting from one and will consist of countChars chars.
*) 

function strPos(s1: string; s2: string): byte;
(*
* @description:
* Returns the first index of substring in string
*
* @param: (string) s1 - Substring / needle.
* @param: (string) s2 - String / haystack.
*
* @returns: (byte) - returns first index or 0 if substring was not found
*) 

function strLastPos(s1: string; s2: string): byte;
(*
* @description:
* Returns the last index of substring in string
*
* @param: (string) s1 - Substring / needle.
* @param: (string) s2 - String / haystack.
*
* @returns: (byte) - returns last index or 0 if substring was not found
*) 

function strIsPrefix(s: string; p: string): boolean;
(*
* @description:
* Returns information whether the first chars of the strings are the same
*
* @param: (string) s1 - String.
* @param: (string) s2 - Prefix.
*
* @returns: (byte) - returns true or false
*) 

implementation

function strCat(s1: string; s2: string): string; overload;
var 
    l1, l2, i : byte;
    r         : string;
begin
    SetLength(r,0);
    l1 := Length(s1);
    l2 := Length(s2);

    r := s1;
    for i := 1 to l2 do r[i+l1] := s2[i];
    r[0] := char(l1 + l2);
    result := r;
end;

function strCat(s: string; c: char): string; overload;
var 
    l : byte;
    r : string;
begin
    SetLength(r,0);
    l := Length(s);

    r := s;
    r[l+1] := c;
    r[0] := char(l + 1);
    result := r;
end;

procedure strAdd(var s: string; c: char); overload;
var 
    l : byte;
begin
    l := Length(s);
    s[0] := char(l + 1);
    s[l+1] := c;
end;

procedure strAdd(var s1: string; s2: string); overload;
var 
    l1, l2 : byte;
begin
    l1 := Length(s1);
    l2 := Length(s2);
    s1[0] := char(l1 + l2);
 
    while l2>0 do begin
        s1[l1+l2] := s2[l2];
        dec(l2);
    end;
end;

function strLeft(s: string; count: byte): string;
var
    r : string;
    i : byte;
begin
    SetLength(r,count);
    for i := 1 to count do r[i] := s[i];
    result := r;
end;

function strRight(s: string; count: byte): string;
var
    r : string;
    i : byte;
begin
    SetLength(r,count);
    for i := (Length(s)-count)+1 to Length(s) do r[i-(Length(s)-count)] := s[i]; 
    result := r;
end;

function strMid(s: string; startChar: byte; countChars: byte): string;
var
    r: string;
    i: byte;
begin
    SetLength(r,countChars);
    for i := startChar to startChar+countChars-1 do r[i-startChar+1] := s[i];
    result := r;
end;

function strPos(s1: string; s2: string): byte;
var
    s1len: byte;
    s2len: byte;
    i    : byte;
    j    : byte;
begin
    s1len := Length(s1);
    s2len := Length(s2);
    result := 0;

    for i := 1 to s2len - s1len do
    begin
        j := 0;

        for j := 1 to s1len do
        begin
            if s2[i+j] <> s1[j] then 
            begin
                break;
            end;
        end;

        if j -1 = s1len then 
        begin
            result := i+1;
            break;
        end;

    end
end;

function strLastPos(s1: string; s2: string): byte;
var
    s1len: byte;
    s2len: byte;
    i    : byte;
    j    : byte;
begin
    s1len := Length(s1);
    s2len := Length(s2);
    result := 0;

    for i := 1 to s2len - s1len do
    begin
        j := 0;

        for j := 1 to s1len do
        begin
            if s2[i+j] <> s1[j] then 
            begin
                break;
            end;
        end;

        if j -1 = s1len then result := i+1;       
    end
end;

function strIsPrefix(s: string; p: string): boolean;
var
    i: byte;
begin
    result := true;
    for i := 1 to Length(p) do
    begin
        if s[i] <> p[i] then
        begin
            result := false;
            break;
        end;
    end;
end;

end.