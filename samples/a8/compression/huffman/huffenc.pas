{Huffman encoder: Compression unit for compressing a bunch of bytes
 most useful for text files or anything which only uses a subset of the whole
 255 characters
 A Danson 2015}

unit huffenc;

interface

procedure openOutput(f : string);
procedure writeChar(o  : char);
//procedure writeLine(o : string);
procedure closeOutput;

implementation

uses buffer;

const
   bits	: array[0..7] of byte = ( $80, $40, $20, $10, $08, $04, $02, $01 );

type
   treenode = record
		 leftchild,rightchild : smallint;
		 character	      : word;
		 {low byte indicates a character $FF00 indicates a node.}
		 frequency            : word;
	      end;
   charfreq = record
		 character : word; {same as in tree node}
		 frequency : word;
	      end;

var output   : writer;

   outbyte   : byte;
   bit	     : byte;
   input     : array[0 .. 8192] of char;
   itail     : smallint; {place where next character will be stored}
   hufftree  : array[0 .. 512] of ^treenode;
   hufftail  : smallint; {index into tree array}
   [striped] freqtable : array[0..255] of ^charfreq;
   fttail    : smallint; {place where the next entry in the frequency table will be stored}


procedure addToTable(ch,fr : word);
var i,c	  : smallint;
begin
   i:=0;
   while i<fttail do
   begin
      if (fr > freqTable[i].frequency) then
      begin
	 {make room in the table}
	 for c := fttail downto i+1 do
	 begin
	    freqTable[c] := freqTable[c-1];
	 end;
	 inc(fttail);
	 {add it in the now empty slot}

	 GetMem(freqtable[i], sizeof(charfreq));

	 freqtable[i].character:=ch;
	 freqtable[i].frequency:=fr;
	 exit;
      end;
      inc(i);
   end;
   {ok it's the worst one add it at the end}
   
   GetMem(freqtable[fttail], sizeof(charfreq));
  
   freqtable[fttail].character:=ch;
   freqtable[fttail].frequency:=fr;

   inc(fttail);
end;

procedure popFTEntry(var ch, fr	: word);
begin
   ch := freqtable[fttail-1].character;
   fr := freqtable[fttail-1].frequency;
   dec(fttail);
end;

procedure fillFreqTable;
var
   [striped] frequency : array[0..255] of word;
   i	     : smallint;
begin
   fttail := 0;

   for i:=0 to 255 do
      frequency[i]:=0;

   for i:= 0 to itail-1 do
      inc(frequency[ord(input[i])]);

   for i:= 0 to 255 do
      if frequency[i]>0 then
	 addToTable(i,frequency[i]);
end;

function huffNode(ch,fr	: word):smallint;
var
   i : smallint;
begin
   if ((ch and $F000) = $F000) then
   begin {it's a node that's already created.}

      for i:= 0  to hufftail-1 do
	    if ((ch = hufftree[i].character) and (fr = hufftree[i].frequency)) then
	       {found it!}
	       exit(i);
   end
   else
   begin
      GetMem(hufftree[hufftail], sizeof(treenode));
   
      {Create a node for this character}
      

{
      with hufftree[hufftail]^ do begin
      
      leftChild := -1;
      rightChild := -1;
      character := ch;
      frequency := fr;   
      
      end;
}
      
      hufftree[hufftail].leftChild := -1;
      hufftree[hufftail].rightChild := -1;
      hufftree[hufftail].character := ch;
      hufftree[hufftail].frequency := fr;

      Result := hufftail;

      inc(hufftail);
   end;
end;

procedure writeNode(node : smallint);
begin

      output.writeChar(chr(hi(hufftree[node].character)));
      output.writeChar(chr(lo(hufftree[node].character)));

      if ((hufftree[node].character and $F000) = $F000) then
      begin
	 writeNode(hufftree[node].leftChild);
	 writeNode(hufftree[node].rightChild);
      end;

end;

procedure writeBit(o : boolean);
begin
   if o then
      outbyte := outbyte or bits[bit];
   inc(bit);
   if bit=8 then
   begin
      output.writeChar(chr(outbyte));
      outbyte := 0;
      bit := 0;
   end;
end;

procedure encodeByte(i : char);
var
   {a stack for the depth first search}
   [striped] node  : array[0..64] of word;
   enc   : array[0..64] of byte; { 0 unchecked 1 left 2 right 3 not found}
   cn,c  : word;
   found : boolean;
begin
   cn := 0;
   node[0] := hufftail - 1; {root node};
   enc[0] := 0;
   found := false;

   while not(found) do
   begin
      {check it's not a node and the character matches}
      if (not((huffTree[node[cn]].character and $F000) = $F000)
	  and (chr(lo(hufftree[node[cn]].character)) = i)) then
      begin
	 found := true;
      end
      else
      begin
	 inc(enc[cn]);
	 if not((huffTree[node[cn]].character and $F000) = $F000) then
	    enc[cn] := 3;
	 if (enc[cn] = 1) then
	 begin {move to left child}
	    node[cn+1] := hufftree[node[cn]].leftchild;
	    enc[cn+1] := 0;
	    inc(cn);
	 end
         else if (enc[cn] = 2) then
	 begin {move to right child}
	    node[cn+1] := hufftree[node[cn]].rightchild;
	    enc[cn+1] := 0;
	    inc(cn);
	 end
         else
	 begin {didn't find it, move up the stack}
	    dec(cn);
	 end;
	 
	 if (cn>64) then BEGIN writeln('error'); halt(0); END;
      end;
   end;

   {ok now we should have found the encoding! write it!}
   for c:= 0 to cn do
   begin
      if enc[c] = 1 then writeBit(false);
      if enc[c] = 2 then writeBit(true);
   end;
end;


procedure encodeBlock;
var
   ch1,ch2,hn1 : word;
   fr1,fr2,hn2 : word;
   pch,pfr     : word;
   i	       : word;
begin
 
   {the first step in building a huffman tree is collecting frequency information}
   fillFreqTable;

   {for i:= 0 to fttail-1 do
      write(chr(freqtable[i].character),'-',freqtable[i].frequency, ' ');
   writeln;

   writeln('fttail ',fttail);}
   {empty the huff coding tree}
   hufftail:=0;

   {now using the frequency table we need to construct a tree}
   while (fttail>1) do
   begin
      popFTEntry(ch1,fr1);
      popFTEntry(ch2,fr2);
      hn1 := huffNode(ch1,fr1);
      hn2 := huffNode(ch2,fr2);
      {now we need to create the parent node in the huffman tree
       and add it to the frequency table as well}
      pfr := fr1 + fr2;
      pch := $F000 or hufftail;
      addToTable(pch,pfr); {add to the freq table}
      
      GetMem(hufftree[hufftail], sizeof(treenode));

      {add to the huff coding tree}
      hufftree[hufftail].leftChild := hn1;
      hufftree[hufftail].rightChild := hn2;
      hufftree[hufftail].character := pch;
      hufftree[hufftail].frequency := pfr;
      inc(hufftail);
   end;

   writeln('hufftail ',hufftail);
   writeln('fttail ',fttail);
   writeln('itail ',itail);

   {ok now after all that we can encode bytes, I know it took a while}
   { but first we need to encode the tree and save that to disk }

   writeNode(hufftail-1); {the root node is the last one created}

   {write out the length (number of bytes) encoded in this block}
//   output.writeChar(chr(hi(itail)));
//   output.writeChar(chr(lo(itail)));

   outbyte := 0;
   bit := 0;

   for i:= 0 to itail-1 do
   begin
      encodeByte(input[i]);
   end;
   if bit>0 then
      output.writeChar(chr(outbyte));

   itail := 0;
end;

procedure openOutput(f : string);
begin
   output.fopen(f);
   {write the HUFF signature}
   output.writeChar('H');
   output.writeChar('U');
   output.writeChar('F');
   output.writeChar('F');
   itail := 0;
end;


procedure writeChar(o  : char);
begin
   input[itail] := o;
   inc(itail);
   if (itail = high(input)) then encodeBlock;
end;

{
procedure writeLine(o : string);
var
   i :  smallint;
begin
   for i:=1 to length(o) do
      writeChar(o[i]);

   writeChar(chr(13));
   writeChar(chr(10));
end;
}

procedure closeOutput;
begin
   if (itail>0) then encodeBlock;
   output.flush;
   output.fclose;
end;

end.
