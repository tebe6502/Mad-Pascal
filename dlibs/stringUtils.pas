unit stringUtils;
(*
* @type: unit
* @author: dely <daniel.kozminski@gmail.com>
* @name: String manipulation library.
* @version: 0.5

* @description:
* String manipulation procedures and functions for use with MadPascal. 
*
* <https://gitlab.com/delysio/mad-pascal>
*)

interface 

function strTrimLeft(var s: string): string;
(*
* @description:
* Strips blank characters (spaces and control characters) at the beginning of input string and returns the resulting string. 
* All characters with ordinal values less than or equal to 32 (a space) are stripped.
*
* @param: (string) s - The input string.
*)

function strTrimRight(var s: string): string;
(*
* @description:
* Strips blank characters (spaces and control characters) at the end of input string and returns the resulting string. 
* All characters with ordinal values less than or equal to 32 (a space) are stripped.
*
* @param: (string) s - The input string.
*)

function strTrim(var s: string): string;
(*
* @description:
* Strips blank characters (spaces and control characters) at the beginning and end of input string and returns the resulting string. 
* All characters with ordinal values less than or equal to 32 (a space) and greater or equal to 123 are stripped.
*
* @param: (string) s - The input string.
*)

procedure strInsert(var s: string; var s2: string; index: byte);
(*
* @description:
* Insert one string in another.
*
* @param: (string) s - The input string.
* @param: (string) s2 - String to insert.
* @param: (byte) index - Position to insert.
*) 

procedure strDelete(var s: string; index: byte; count: byte);
(*
* @description:
* Removes Count characters from string S, starting at position Index.
*
* @param: (string) s - The input string.
* @param: (byte) index - Position.
* @param: (byte) count - Number of chars to remove.
*) 

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

function strPadLeft(str: string; len: byte; padChar: char): string;
(*
* @description:
* Add character to the left of a string till a certain length is reached.
*
* @param: (string) str - String to pad..
* @param: (string) len - Length of the resulting string.
* @param: (string) padChar - The character that will be used to complete the string.
*)

function strPadRight(str: string; len: byte; padChar: char): string;
(*
* @description:
* Add character to the right of a string till a certain length is reached.
*
* @param: (string) str - String to pad..
* @param: (string) len - Length of the resulting string.
* @param: (string) padChar - The character that will be used to complete the string.
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

function strPos(c: char; s: string): byte; overload;
(*
* @description:
* Returns the first index of char in string
*
* @param: (string) c - char / needle.
* @param: (string) s - String / haystack.
*
* @returns: (byte) - returns first index or 0 if substring was not found
*) 

function strPos(s1: string; s2: string): byte; overload;
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

function strReplace(s: string; c: char; rpl: char): string; overload;
(*
* @description:
* Replace first occurrence of the search char (c) with the replacement char (rpl)
* This function is case-sensitive. Use strIReplace for case-insensitive replace.
*
* @param: (string) s - String / haystack.
* @param: (char) c - Char to find / needle.
* @param: (char) rpl - Replacement.
*
* @returns: (string) - replaced string
*) 

function strReplace(s1: string; s2: string; c: char): string; overload;
(*
* @description:
* Replace first occurrence of the search string (s2) with the replacement char (c)
* This function is case-sensitive. Use strIReplace for case-insensitive replace.
*
* @param: (string) s1 - String / haystack.
* @param: (string) s2 - String to find / needle.
* @param: (char) c - Replacement.
*
* @returns: (string) - replaced string
*) 

function strReplace(s1: string; s2: string; s3: string): string; overload;
(*
* @description:
* Replace first occurrence of the search string (s2) with the replacement string (s3)
* This function is case-sensitive. Use strIReplace for case-insensitive replace.
*
* @param: (string) s1 - String / haystack.
* @param: (string) s2 - String to find / needle.
* @param: (string) s3 - Replacement.
*
* @returns: (string) - replaced string
*) 

function strIReplace(s: string; c: char; rpl: char): string;
(*
* @description:
* Replace first occurrence of the search char (c) with the replacement char (rpl)
* This function is Case-insensitive. Use strReplace for case-sensitive replace.
*
* @param: (string) s - String / haystack.
* @param: (char) c - char to find / needle.
* @param: (char) rpl - replacement.
*
* @returns: (string) - replaced string
*) 

function strReplaceAll(s: string; c: char; rpl: char): string; overload;
(*
* @description:
* Replace all occurrences of the search char (c) with the replacement char (rpl)
* This function is case-sensitive. Use strIReplace for case-insensitive replace.
*
* @param: (string) s - String / haystack.
* @param: (char) c - Char to find / needle.
* @param: (char) rpl - Replacement.
*
* @returns: (string) - replaced string
*) 

function strWrap(var s: string; lineWidth: byte): string;
(*
* @description:
* WrapText does a wordwrap at column lineWidth of the string in Line. It breaks the string at spaces and inserts then the EOL
*
* @param: (string) s - String
* @lineWidth: (byte) lineWidth - maximum with of line.
*
* @returns: (string) - wrapped string
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

function strPadRight(str: string; len: integer; padChar: char): string;
var
    i: byte;
begin
    if Length(str) >= len then
    begin
        Result := str;
        Exit;
    end;

    Result := str;
    SetLength(Result, len);

    for i := Length(str) + 1 to len do
    begin
        Result[i] := padChar;
    end;
end;

function strPadLeft(str: string; len: byte; padChar: char): string;
var
    i: byte;
    shift: byte;
begin
    if Length(str) >= len then
    begin
        Result := str;
        Exit;
    end;

    Result := str;
    shift := len - Length(str);

    SetLength(Result, len);
    for i := len downto shift + 1 do
    begin
        Result[i] := Result[i - shift];
    end;

    for i := 1 to shift do
    begin
        Result[i] := padChar;
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

function strPos(c: char; s: string): byte; overload;
var
    slen: byte;
    i    : byte;
begin
    slen := Length(s);
    result := 0;

    for i := 1 to slen - 1 do
    begin
        if s[i] = c then
        begin
            result := i;
            break;
        end;
    end
end;

function strPos(s1: string; s2: string): byte; overload;
var
    s1len: byte;
    s2len: byte;
    i    : byte;
    j    : byte;
begin
    s1len := Length(s1);
    s2len := Length(s2);

    result := 0;

    for i := 1 to s2len - s1len do // 1 to 14
    begin

        for j := 0 to s1len - 1 do // 0 to 17
        begin
            if s2[i+j] <> s1[j+1] then // 1 <> 1
            begin
                break;
            end;
        end;

        if j = s1len then 
        begin
            result := i;
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

procedure strInsert(var s: string; var s2: string; index: byte);
var
    r: string;
    i: byte;
    j: byte;
    k: byte;
begin
    SetLength(r, 0);
    if index > Length(s) then 
    begin
        strAdd(s, s2);
        exit;
    end;
    
    j := 1;
    if index > 1 then
    begin
        for i := 1 to index do
        begin
            r[i] := s[i];
            Inc(j);
        end;
    end;
    for i := 1 to Length(s2) do
    begin
        r[j] := s2[i];
        Inc(j);
    end;
    if index > 1 then k := index + 1 else k := index;
    for i := k to Length(s) do
    begin
        r[j] := s[i];
        Inc(j);
    end;
    SetLength(r, j-1);
    s := r;
end;

procedure strDelete(var s: string; index: byte; count: byte);
var
    i: byte;
begin
    for i := index + count to Length(s) do
        s[i - count] := s[i];
    SetLength(s, Length(s)-count);
end;

function strReplace(s: string; c: char; rpl: char): string; overload;
var
    r : string;
    i : byte;
begin
    SetLength(r, Length(s));
    r := s;
    i := strPos(c, s);

    if i > 0 then r[i] := rpl;
    result := r;
end;

function strReplace(s1: string; s2: string; c: char): string; overload;
var
    r: string;
    i: byte;
    j: byte;
begin
    SetLength(r, 0);
    i := strPos(s2, s1);
    j := Length(s1) - Length(s2);
    if i > 0 then
    begin
        Dec(i);
        if i > 1 then r := strLeft(s1, i);
        strAdd(r, c);
        if j - 1 > 0 then strAdd(r, strRight(s1, j - i));
        result := r;
    end;
end;

function strReplace(s1: string; s2: string; s3: string): string; overload;
var
    r: string;
    i: byte;
    j: byte;
begin
    SetLength(r, 0);
    i := strPos(s2, s1);
    if i > 0 then begin
        strDelete(s1, i, Length(s2));
        strInsert(s1, s3, i); 
    end;
    result := s1;
end;

function strIReplace(s: string; c: char; rpl: char): string;
var
    r : string;
    i : byte;
begin
    SetLength(r, Length(s));

    if not isLetter(c) then
    begin
        result := strReplace(s, c, rpl);
    end else
    begin
        for i := 1 to Length(s) do
        begin
            if (s[i] = LowerCase(c)) or (s[i] = UpCase(c)) then
            begin
                r[i] := rpl;
            end else
            begin
                r[i] := s[i];
            end;
        end;
        result := r;
    end;
end;

function strReplaceAll(s: string; c: char; rpl: char): string; overload;
var
    r : string;
    i : byte;
begin
    SetLength(r, Length(s));
    for i := 1 to Length(s) do
    begin
        if s[i] = c then
        begin
            r[i] := rpl;
        end else
        begin
            r[i] := s[i];
        end;
    end;
    result := r;
end;

function strTrimRight(var s: string): string;
var
    count: byte;
    i: byte;
    r: string;
begin
    SetLength(r,0);
    count := 0;
    for i := Length(s) downto 1 do begin // 12 to 1
        if (ord(s[i]) >= 33) and (ord(s[i]) <= 122) then begin
            count := Length(s) - i; // 12 - 1
            break;
        end;
    end;
    if count = 0 then r := '' else r := strLeft(s, Length(s)-count);
    result := r;
end;

function strTrimLeft(var s: string): string;
var
    count: byte;
    i: byte;
    r: string;
begin
    SetLength(r,0);
    count := 0;
    for i := 1 to Length(s) do begin
        if (ord(s[i]) >= 33) and (ord(s[i]) <= 122) then begin
            count := i;
            break;
        end;
    end;
    if count = 0 then r := '' else r := strRight(s, Length(s)-count+1);
    result := r;
end;

function strTrim(var s: string): string;
var
    startPos: byte;
    endPos: byte;
    i: byte;
    r: string;
begin
    SetLength(r,0);
    for i := 1 to Length(s) do begin
        if (ord(s[i]) >= 33) and (ord(s[i]) <= 122) then begin
            startPos := i;
            break;
        end;
    end;
    for i := Length(s) downto 1 do begin
        if (ord(s[i]) >= 33) and (ord(s[i]) <= 122) then begin
            endPos := i - startPos + 1;
            break;
        end;
    end;
    r := strMid(s, startPos, endPos);
    result := r;
end;

function strWrap(var s: string; lineWidth: byte): string;
var
    i: byte;
    j: byte;
    k: byte;
    l: byte;
    r: string;
begin
    SetLength(r,0);

    i := 1;
    j := 1;
    k := 1;

    While (i <= Length(s)) do begin

        if j > lineWidth then begin

            j := 1;

            for l := i downto 1 do if s[l] = ' ' then break;

            r[l] := #155;
            i := l + 1;
            k := l + 1;

        end else begin
            
            r[k] := s[i];  
            k := k + 1;
            j := j + 1;
            i := i + 1;

        end;
        
    end;

    SetLength(r,k-1);
    result := r;
end;

end.