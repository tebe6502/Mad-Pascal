uses crt, cio, graph;

var

 s: string;

begin

 InitGraph(2);
 
 
 s:='AaBbCcDd';
 
 GotoXY(5,5);
 
 BPut(6, @s[1], 8);
 
 Put(6, ord('A'*));

 
 repeat until keypressed;

end.