{

AES256 Cipher  : SUCCESS! tick: 62
AES256 Decipher: SUCCESS! tick: 122

AES192 Cipher  : SUCCESS! tick: 53
AES192 Decipher: SUCCESS! tick: 103

AES128 Cipher  : SUCCESS! tick: 43
AES128 Decipher: SUCCESS! tick: 84

}


uses crt, sysutils, aes;

var

 rout: AESBlock;

 bf: AESBlock = ($E2BEC16B, $969F402E, $117E3DE9, $2A179373);

 tick: cardinal;

// -----------------------------------------------------------------------------

procedure test_AES256;
var
 key: AES256Key = ($10EB3D60, $BE71CA15, $F0AE732B, $81777D85, $072C351F, $D708613B, $A310982D, $F4DF1409);
 res: AESBlock = ($BDD1EEF3, $3CA0D2B5, $7E5A4B06, $F881B13D);

begin

 write('AES256 Cipher  : ');
 tick:=GetTickCount;

 rout := AES256Cipher(bf, key);

 if comparemem(@res, @rout, 16) then
   writeln('SUCCESS! tick: ',GetTickCount - tick)
 else
   writeln('FAILURE!');

 write('AES256 Decipher: ');
 tick:=GetTickCount;

 rout := AES256Decipher(res, key);

 if comparemem(@bf, @rout, 16) then
   writeln('SUCCESS! tick: ',GetTickCount - tick)
 else
   writeln('FAILURE!');

 writeln;
end;

// -----------------------------------------------------------------------------

procedure test_AES192;
var
 key: AES192Key = ($F7B0738E, $52640EDA, $2BF310C8, $E5799080, $D2EAF862, $7B6B2C52);
 res: AESBlock = ($1D4F33BD, $5FF2456E, $14A212F7, $CCA51F57);

begin

 write('AES192 Cipher  : ');
 tick:=GetTickCount;

 rout := AES192Cipher(bf, key);

 if comparemem(@res, @rout, 16) then
   writeln('SUCCESS! tick: ',GetTickCount - tick)
 else
   writeln('FAILURE!');

 write('AES192 Decipher: ');
 tick:=GetTickCount;

 rout := AES192Decipher(res, key);

 if comparemem(@bf, @rout, 16) then
   writeln('SUCCESS! tick: ',GetTickCount - tick)
 else
   writeln('FAILURE!');

 writeln;
end;

// -----------------------------------------------------------------------------

procedure test_AES128;
var
 key: AES128Key = ($16157E2B, $A6D2AE28, $8815F7AB, $3C4FCF09);
 res: AESBlock= ($B47BD73A, $60367A0D, $F3CA9EA8, $97EF6624);

begin

 write('AES128 Cipher  : ');
 tick:=GetTickCount;

 rout := AES128Cipher(bf, key);

 if comparemem(@res, @rout, 16) then
   writeln('SUCCESS! tick: ',GetTickCount - tick)
 else
   writeln('FAILURE!');

 write('AES128 Decipher: ');
 tick:=GetTickCount;

 rout := AES128Decipher(res, key);

 if comparemem(@bf, @rout, 16) then
   writeln('SUCCESS! tick: ',GetTickCount - tick)
 else
   writeln('FAILURE!');

 writeln;
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

begin

 test_AES256;

 test_AES192;

 test_AES128;

 repeat until keypressed;

end.

// 10015
