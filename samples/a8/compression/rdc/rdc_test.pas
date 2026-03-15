{

 133
 29

5172 KORONIS.MIC

}

program test: $400;

uses crt, sysutils, atari, graph, rdc;

{$r pack.rc}

const
       src = $9400;

var
	ln, pack, unpack: word;

	tick: cardinal;


begin

 move(pointer(src), rdc.inputbuffer, 7684);   //before 'InitGraph', which will destroy this memory area


 InitGraph(15);

 ln:=7684;
 
 write('Compress ', ln, 'b -> ');

 tick:=GetTickCount;
 pack := RDC_Compress(@rdc.inputbuffer, @rdc.outputbuffer, ln);

 writeln(pack, 'b (',GetTickCount-tick,' ticks)');


 write('Decompress ', pack, 'b -> ');

 tick:=GetTickCount;
 unpack := RDC_Decompress(@rdc.outputbuffer, pointer(dpeek(88)), pack);

 writeln(unpack,'b (', GetTickCount-tick,' ticks)');

 repeat until keypressed;

end.

// 11281