uses crt, blowfish;

var
	myencryptedstring, mydecryptedstring: string;


begin

blowfish.Create('your_secret_encryption_key');

myencryptedstring := blowfish.EncryptString('ATARI Power With Price');

writeln(myencryptedstring);


mydecryptedstring := blowfish.DecryptString(myencryptedstring);

writeln(mydecryptedstring);


repeat until keypressed;

end.
