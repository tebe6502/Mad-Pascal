program blowfish_test;

uses
  crt,
  blowfish;

var
  myencryptedstring, mydecryptedstring: String;


begin

  blowfish.Create('your_secret_encryption_key');

  myencryptedstring := blowfish.EncryptString('ATARI Power With Price');

  WriteLn(myencryptedstring);


  mydecryptedstring := blowfish.DecryptString(myencryptedstring);

  WriteLn(mydecryptedstring);


  repeat
  until keypressed;

end.
