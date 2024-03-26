uses crt, classes, blowfish;

var
	myencryptedstring, mydecryptedstring: string[32];

	i: byte;


function EncryptString(aString:string):string;
var Key:string;
    EncrytpStream:TBlowFishEncryptStream;
    StringStream:TStringStream;
    EncryptedString:string;
begin
  Key := 'your_secret_encryption_key';
  StringStream := TStringStream.Create('');
  EncrytpStream := TBlowFishEncryptStream.Create(Key,StringStream);
  EncrytpStream.WriteAnsiString(aString);
  EncrytpStream.Free;
  EncryptedString := StringStream.DataString;
  StringStream.Free;
  EncryptString := EncryptedString;
end;


function DecryptString(aString:string):string;
var Key:string;
    DecrytpStream:TBlowFishDeCryptStream;
    StringStream:TStringStream;
    DecryptedString:string;
begin
  Key := 'your_secret_encryption_key';
  StringStream := TStringStream.Create(aString);
  DecrytpStream := TBlowFishDeCryptStream.Create(Key,StringStream);
  DecryptedString := DecrytpStream.ReadAnsiString;
  DecrytpStream.Free;
  StringStream.Free;
  DecryptString := DecryptedString;
end;


// -------------------------------------------------------------



begin

myencryptedstring:=EncryptString('Atari Power With Price');      	// returns unreadable text
mydecryptedstring:=DecryptString(myencryptedstring);	// returns 'Hello'


writeln(length(myencryptedstring));

for i:=1 to length(myencryptedstring) do
 write(hexStr(byte(myencryptedstring[i]),2),',');

writeln;

//writeln(myencryptedstring);

writeln(mydecryptedstring);

repeat until keypressed;

end.


// 6A,B3,3A,0A,41,4A,16,9E,17,DD,B8,61,69,D4,B0,C4,
// Hello