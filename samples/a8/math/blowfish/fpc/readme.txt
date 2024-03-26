myencryptedstring:=EncryptString('Hello');      // returns unreadable text
mydecryptedstring:=Decrypt(myencryptedstring);  // returns 'Hello'
function TForm1.EncryptString(aString:string):string;
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
...

function TForm1.DecryptString(aString:string):string;
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
