uses crt, lzrw1kh;

var
	src, dst, tst: array [0..16383] of byte;
	
	f:file;
	ln, pack, unpack: integer;


begin

 assign(f, 'koronis.mic'); reset(f,1);
 blockread(f, src, sizeof(src), ln);
 close(f);
 
 pack := Compression(@src, @dst, ln);

 unpack := Decompression(@dst, @tst, pack);
 
 
 assign(f, 'koronis.lzw'); rewrite(f,1);
 blockwrite(f, dst, pack);
 close(f);
 
 assign(f, 'koronis.dat'); rewrite(f,1);
 blockwrite(f, tst, unpack);
 close(f);

 
 writeln(pack);
 writeln(unpack);

 repeat until keypressed;

end.

