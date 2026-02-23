uses crt, lzjb;

var f: file;

    bf, bf_out: array [0..16384] of byte;
    
    err: smallint;
    
    ln: word;

begin

 assign(f, 'wins.lzjb'); reset(f, 1);
 blockread(f, bf, sizeof(bf), err);
 close(f);


 ln := lzjb_decompress_mem(@bf, 4381, @bf_out);
 
 writeln(ln);
 
 assign(f, 'wins.dat'); rewrite(f, 1);
 blockwrite(f, bf_out, ln);
 close(f);

 
 repeat until keypressed;


end.