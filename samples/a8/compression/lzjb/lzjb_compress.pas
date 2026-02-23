uses crt, lzjb;

var f: file;

    bf, bf_out: array [0..16384] of byte;
    
    err: smallint;
    
    ln: word;

begin

 assign(f, 'wins.mic'); reset(f, 1);
 blockread(f, bf, sizeof(bf), err);
 close(f);


 ln := lzjb_compress_mem(@bf, 7680, @bf_out, 7680);
 
 writeln(ln);
 
 assign(f, 'wins.lzjb'); rewrite(f, 1);
 blockwrite(f, bf_out, ln);
 close(f);

 
 repeat until keypressed;


end.