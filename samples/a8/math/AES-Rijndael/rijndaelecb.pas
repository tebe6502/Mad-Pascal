unit RijndaelECB;
  { Copyright (c) 2001, Tom Verhoeff (TUE) }
  { Version 1.0 (July 2001) }
  { FreePascal library for use of Rijndael in Electronic Codebook Mode }

interface

const
  HexStringLen = 32;
  BlockLen  = 16;

type
  HexString = String [ HexStringLen ]; { hex digits only: ['0'..'9', 'A'..'F'] }
  Block  = array [ 0 .. BlockLen-1 ] of Byte;

procedure HexStringToBlock ( const hs: HexString; var b: Block );
procedure BlockToHexString ( const b: Block; var hs: HexString );

procedure Encrypt ( const p, k: Block; var c: Block );
procedure Decrypt ( const c, k: Block; var p: Block );

implementation

uses Rijndael;

const
  HexBits = 4; { # bits per hex }
  HexBase = 1 SHL HexBits;

type
  Hex = 0 .. HexBase-1;

function CharToHex ( c: Char ): Hex;
  { pre: IsHexChar(c) }
  { impl. note: raises range check error if not IsHexChar(c) }
  begin
    if ( '0' <= c ) and ( c <= '9' ) then { c in ['0'..'9'] }
      CharToHex := ord ( c ) - ord ( '0' )
    else if ( 'A' <= c ) and ( c <= 'F' ) then { c in ['A'..'F'] }
      CharToHex := ord ( c ) - ord ( 'A' ) + 10
    else if ( 'a' <= c ) and ( c <= 'f' ) then { c in ['a'..'f'] }
      CharToHex := ord ( c ) - ord ( 'a' ) + 10
    else begin
      writeln ( '''', c, ''' is not a hexadecimal digit' )
    ; Halt ( 201 ) { range check error }
    end { else }
  end; { CharToHex }

function HexToChar ( h: Hex ): Char;
  begin
    if h < 10 then
      HexToChar := chr ( ord ( '0' ) + h )
    else { 10 <= h < 16 }
      HexToChar := chr ( ord ( 'A' ) + h - 10 )
  end; { HexToChar }

procedure HexStringToBlock ( const hs: HexString; var b: Block );
  { impl. note: right-pad with zeroes }
  var
    i: cardinal; { to traverse b }
    j: cardinal; { to traverse hs }
    h: Byte;
  begin

    for i := 0 to BlockLen - 1 do begin
      b [ i ] := 0
    end { for i }

  ; for j := 1 to Length ( hs ) do begin
      h := CharToHex ( hs[j] )
    ; if odd ( j ) then begin { most significant nibble }
        h := h SHL HexBits
      end { if }
    ; b [ (j-1) div 2 ] := b [ (j-1) div 2 ] OR h
    end { for j }

  end; { HexStringToBlock }

procedure BlockToHexString ( const b: Block; var hs: HexString );
  var
    i: cardinal; { to traverse b }
  begin
    hs := '                                '

  ; for i := 0 to BlockLen - 1 do begin
      hs [ 2*i+1 ] := HexToChar ( b[i] SHR HexBits )
    ; hs [ 2*i+2 ] := HexToChar ( b[i] AND (HexBase-1) )
    end { for i }

  end; { BlockToHexString }

procedure Encrypt ( const p, k: Block; var c: Block );
  var
    ek: ExpandedKey;
    nr: cardinal; { number of rounds }
  begin
    nr := Rijndael.KeySetupEnc ( ek, k, 128 )
  ; Rijndael.Encrypt ( ek, nr, p, 0, c, 0 )
  end; { Encrypt }

procedure Decrypt ( const c, k: Block; var p: Block );
  var
    ek: ExpandedKey;
    nr: cardinal; { number of rounds }
  begin
    nr := Rijndael.KeySetupDec ( ek, k, 128 )
  ; Rijndael.Decrypt ( ek, nr, c, 0, p, 0 )
  end; { Decrypt }

end { unit RijndaelECB }.
