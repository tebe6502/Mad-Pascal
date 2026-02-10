unit rc4;
(*
 @type: unit
 @author: Viacheslav Komenda
 @name: RC4 cipher unit
 @version: 1.0

 @description:
 <https://pl.wikipedia.org/wiki/RC4>

 <https://en.wikipedia.org/wiki/RC4>
*)

{  MIT License

Copyright (c) 2022 Viacheslav Komenda

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. }


INTERFACE

TYPE
RC4_SEED = ARRAY[0..255] OF BYTE;

PROCEDURE rc4_init(VAR seed : RC4_SEED; password : STRING);
PROCEDURE rc4_crypt(VAR seed : RC4_SEED; VAR buf; size : BYTE);


IMPLEMENTATION

PROCEDURE rc4_init(VAR seed : RC4_SEED; password : STRING);
VAR     i, j : BYTE;
        len  : BYTE;
        x    : BYTE;
BEGIN
        FOR i := 0 TO 255 DO seed[i] := i;
        len := Length(password);
        j := 0;
        FOR i := 0 TO 255 DO BEGIN
                j := (j + seed[i] + ORD(password[(i MOD len) + 1])) AND $FF;
                x := seed[i];
                seed[i] := seed[j];
                seed[j] := x;
        END;
END;

PROCEDURE rc4_crypt(VAR seed : RC4_SEED; VAR buf; size : BYTE);
VAR     i, j : BYTE;
        x    : BYTE;
        src  : PCHAR register;
BEGIN
        i := 0;
        j := 0;
        src := @buf;
        WHILE size <> 0 DO BEGIN
                Inc(i);
                i := i AND $FF;
                Inc(j);
                j := j AND $FF;
                x := seed[i];
                seed[i] := seed[j];
                seed[j] := x;
                src^ := CHR(ORD(src^) XOR seed[(seed[i] + seed[j]) AND $FF]);
                Inc(src);
                Dec(size);
        END;
END;

END.
