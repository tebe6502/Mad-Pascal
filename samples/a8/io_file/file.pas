
var	f: file;
	buf: array [0..2047] of byte;

	NumRead: word;

begin

 assign(f, 'D:CONSTANT.OBX' ); 

 reset(f, 40);
 
 blockread(f, buf, 2, NumRead);
 
 writeln(ioresult, ',', numread);
 
 close(f);

end.

