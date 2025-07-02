program RijndaelTool;
  { Copyright (c) 2001, Tom Verhoeff (TUE) }
  { Version 1.0 (July 2001) }
  { Interactive example program using FreePascal library RijndaelECB }

uses RijndaelECB;

procedure Pad0 ( var s: HexString );
var i: byte;
  begin
    s := UpCase ( s );

    i := length(s) + 1;

    SetLength(s, HexStringLen);

    while i <= HexStringLen do begin
      s [i] := '0';
      inc(i);
    end { while }

  end; { Pad0 }

procedure Interact;
  { interactively encrypt/decrypt messages }
  const
    Unmodified = '';             { to mark unmodified block }
    Modified   = ' <-- updated'; { to mark modified block }
  var
    command: Char; { input command }
    p, k, c, tmp: HexString;
    pt, ck, ct: Block;
    pStatus, kStatus, cStatus: String[16];
  begin
    p := ''
  ; k := ''
  ; c := ''
  ; pStatus := Unmodified
  ; kStatus := Unmodified
  ; cStatus := Unmodified

  ; repeat
      writeln
    ; writeln
    ; Pad0 ( p )
    ; Pad0 ( k )
    ; Pad0 ( c )
    ; writeln ( 'Plaintext    ', pStatus); writeln ( p ); writeln;
    ; writeln ( 'Key          ', kStatus ); writeln ( k ); writeln;
    ; writeln ( 'Ciphertext   ', cStatus ); writeln ( c ); writeln;
    ; writeln ( 'HexString index'); writeln( '12345678901234567890123456789012' ); writeln;
    ; writeln ( 'Block index'); writeln( ' 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5' ); writeln;
    ; pStatus := Unmodified
    ; kStatus := Unmodified
    ; cStatus := Unmodified
    ; writeln ( 'P(laintext, K(ey, C(iphertext,' ); writeln( 'E(ncrypt, D(ecrypt, S(wap, Q(uit? ' )
    ; readln ( command )
    ; command := UpCase ( command )
    ; case command of
      'P': begin
          write ( 'Plaintext?   ' )
        ; readln ( p )
        ; pStatus := Modified
        end;
      'K': begin
          write ( 'Key?         ' )
        ; readln ( k )
        ; kStatus := Modified
        end;
      'C': begin
          write ( 'Ciphertext?  ' )
        ; readln ( c )
        ; cStatus := Modified
        end;
      'E': begin
          HexStringToBlock ( p, pt )
        ; HexStringToBlock ( k, ck )
        ; Encrypt ( pt, ck, ct )
        ; BlockToHexString ( ct, c )
        ; writeln ( 'Encrypted plaintext with key to ciphertext' )
        ; cStatus := Modified
        end;
      'D': begin
          HexStringToBlock ( c, ct )
        ; HexStringToBlock ( k, ck )
        ; Decrypt ( ct, ck, pt )
        ; BlockToHexString ( pt, p )
        ; writeln ( 'Decrypted ciphertext with key to plaintext' )
        ; pStatus := Modified
        end;
      'S': begin
          tmp := p
        ; p := c
        ; c := tmp
        ; writeln ( 'Swapped plaintext and ciphertext' )
        ; pStatus := Modified
        ; cStatus := Modified
        end;
      'Q': writeln ( 'End of Interaction with RijndaelECB' );
      else writeln ( 'Unknown command ''', command, '''' )
      end { case }
    until command = 'Q'

  end; { Interact }

begin
  writeln ( 'Interactive Tool for Using FreePascal Library RijndaelECB' )
; Interact
end.

// 28436