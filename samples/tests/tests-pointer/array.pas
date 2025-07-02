uses crt;

var s,t,b,x,y: byte;
    w: word;

    tb: array [0..9, 0..9] of byte;

begin
{
tb[s,t]:=5;

if tb[s,t] =5 then b:=1;

tb[x,y+1]:=tb[x,y];

if (tb[x,y+1]=tb[x,y]) then b:=1;
}
poke(w, peek(w+1) shr 4);

poke(w + x, peek(w + x) xor 128);

end.