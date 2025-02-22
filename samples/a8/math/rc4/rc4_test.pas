uses crt, rc4;

var seed: RC4_SEED;
    txt: string;

begin

 txt:='Atari Power with Price';

 rc4_init(seed, 'a-t-a-r-i');	// create a seed based on a password

 rc4_crypt(seed, txt[1], length(txt));

 writeln(txt);			// crypted text
 writeln;


 rc4_crypt(seed, txt[1], length(txt));

 writeln(txt);			// encrypted text


 repeat until keypressed;

end.