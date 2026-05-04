uses crt, graph, snappy, sysutils;

{$r snappy.rc}

const

 buf = $4000;


var src: array [0..8191] of byte absolute buf;

    p: pointer;
    
    tick:cardinal;

begin

 InitGraph(15);
 
 p:=pointer(dpeek(88));

 tick:=GetTickCount;
 
 SnappyDecode(@src[18], p);	// skip 18 bytes -> src[18]
 
 writeln('tick: ',GetTickCount-tick);

 repeat until keypressed;

end.
