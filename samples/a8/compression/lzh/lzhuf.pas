
{This is an LZH compression routine used in BRANCH version 0.97. }
{Most of the code here is adapted from LZHSRC10.???              }
{
  The file LZHUF.C is originally written in C. I have re-written it
  in  PASCAL.
}


program lzh;
uses crt;


const
  N = 1024;             { Size of string buffer     }	// 4096
  F = 60;               { Size of look-ahead buffer }
  THRESHOLD = 2;
  NILL = N;	        { End of tree's node  }
  TREENODE = N+1;
  EXIT_OK = 0;
  EXIT_FAILED = -1;


  buffersize=10*1024;

  {**** Huffman coding parameters ****}

  N_CHAR = (256 - THRESHOLD + F);  {character code (= 0..N_CHAR-1)}
  T      = (N_CHAR * 2 - 1);       { Size of table }
  R      = (T - 1);		   { root position }

  MAX_FREQ	= $8000;
                    {*** update when cumulative frequency ***}
                    {*** reaches to this value ***}


{**
***    Tables for encoding/decoding upper 6 bits of
***    sliding dictionary pointer
***}

{*** encoder table ***}

p_len:array[0..63] of byte= (
  $03, $04, $04, $04, $05, $05, $05, $05,
  $05, $05, $05, $05, $06, $06, $06, $06,
  $06, $06, $06, $06, $06, $06, $06, $06,
  $07, $07, $07, $07, $07, $07, $07, $07,
  $07, $07, $07, $07, $07, $07, $07, $07,
  $07, $07, $07, $07, $07, $07, $07, $07,
  $08, $08, $08, $08, $08, $08, $08, $08,
  $08, $08, $08, $08, $08, $08, $08, $08
);


p_code:array [0..63] of byte = (
    $00, $20, $30, $40, $50, $58, $60, $68,
    $70, $78, $80, $88, $90, $94, $98, $9C,
    $A0, $A4, $A8, $AC, $B0, $B4, $B8, $BC,
    $C0, $C2, $C4, $C6, $C8, $CA, $CC, $CE,
    $D0, $D2, $D4, $D6, $D8, $DA, $DC, $DE,
    $E0, $E2, $E4, $E6, $E8, $EA, $EC, $EE,
    $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7,
    $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF
);


{*** decoder table ***}

d_code:array[0..255] of byte = (
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $01, $01, $01, $01, $01, $01, $01, $01,
    $01, $01, $01, $01, $01, $01, $01, $01,
    $02, $02, $02, $02, $02, $02, $02, $02,
    $02, $02, $02, $02, $02, $02, $02, $02,
    $03, $03, $03, $03, $03, $03, $03, $03,
    $03, $03, $03, $03, $03, $03, $03, $03,
    $04, $04, $04, $04, $04, $04, $04, $04,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $06, $06, $06, $06, $06, $06, $06, $06,
    $07, $07, $07, $07, $07, $07, $07, $07,
    $08, $08, $08, $08, $08, $08, $08, $08,
    $09, $09, $09, $09, $09, $09, $09, $09,
    $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A,
    $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B,
    $0C, $0C, $0C, $0C, $0D, $0D, $0D, $0D,
    $0E, $0E, $0E, $0E, $0F, $0F, $0F, $0F,
    $10, $10, $10, $10, $11, $11, $11, $11,
    $12, $12, $12, $12, $13, $13, $13, $13,
    $14, $14, $14, $14, $15, $15, $15, $15,
    $16, $16, $16, $16, $17, $17, $17, $17,
    $18, $18, $19, $19, $1A, $1A, $1B, $1B,
    $1C, $1C, $1D, $1D, $1E, $1E, $1F, $1F,
    $20, $20, $21, $21, $22, $22, $23, $23,
    $24, $24, $25, $25, $26, $26, $27, $27,
    $28, $28, $29, $29, $2A, $2A, $2B, $2B,
    $2C, $2C, $2D, $2D, $2E, $2E, $2F, $2F,
    $30, $31, $32, $33, $34, $35, $36, $37,
    $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
);

d_len:array[0..255] of byte = (
    $03, $03, $03, $03, $03, $03, $03, $03,
    $03, $03, $03, $03, $03, $03, $03, $03,
    $03, $03, $03, $03, $03, $03, $03, $03,
    $03, $03, $03, $03, $03, $03, $03, $03,
    $04, $04, $04, $04, $04, $04, $04, $04,
    $04, $04, $04, $04, $04, $04, $04, $04,
    $04, $04, $04, $04, $04, $04, $04, $04,
    $04, $04, $04, $04, $04, $04, $04, $04,
    $04, $04, $04, $04, $04, $04, $04, $04,
    $04, $04, $04, $04, $04, $04, $04, $04,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $05, $05, $05, $05, $05, $05, $05, $05,
    $06, $06, $06, $06, $06, $06, $06, $06,
    $06, $06, $06, $06, $06, $06, $06, $06,
    $06, $06, $06, $06, $06, $06, $06, $06,
    $06, $06, $06, $06, $06, $06, $06, $06,
    $06, $06, $06, $06, $06, $06, $06, $06,
    $06, $06, $06, $06, $06, $06, $06, $06,
    $07, $07, $07, $07, $07, $07, $07, $07,
    $07, $07, $07, $07, $07, $07, $07, $07,
    $07, $07, $07, $07, $07, $07, $07, $07,
    $07, $07, $07, $07, $07, $07, $07, $07,
    $07, $07, $07, $07, $07, $07, $07, $07,
    $07, $07, $07, $07, $07, $07, $07, $07,
    $08, $08, $08, $08, $08, $08, $08, $08,
    $08, $08, $08, $08, $08, $08, $08, $08
);

var
  buf : array [0..buffersize-1] of byte;
  text_buf : array[0..N+F-1] of byte;

  lson  : array [0..N+1] of word;
  rson  : array [0..N+1] of word;
  eqson : array [0..N+1] of word;
  dad   : array [0..N+1] of word;

  [striped] sub_tree: array[0..255] of word;

  infile,outfile: file;

  useleftnode: boolean;

  codesize,
  printcount,
  buf_idx,
  match_position,
  match_length     : word;

  textsize: integer;

  freq  : array[0..T+1] of word;  {**** cumulative freq table ****}

{*
 * pointing parent nodes.
 * area [T..(T + N_CHAR - 1)] are pointers for leaves
 *}

  prnt:array[0..T+N_CHAR] of word;

{**** pointing children nodes (son[], son[] + 1) ***}

  son:array[0..T] of word;
  getbuf : word;
  getlen : byte;

  putbuf : word;
  putlen : byte;

  eof_infile : word;


  outfilename,infilename: string[32];


function freadbyte: byte;
begin
  freadbyte:=buf[buf_idx];

  inc(buf_idx);

  dec(eof_infile);
end;

procedure fwritebyte(b:byte);
begin
  blockwrite(outfile,b, 1);
end;


procedure freadlong(var ll:integer);
var
  lla:array[0..3] of byte absolute ll;
  i:byte;
begin
  for i:=0 to 3 do
    lla[i]:=freadbyte;
end;

procedure fwritelong(ll:integer);
var
  lla:array[0..3] of byte absolute ll;
  i:byte;
begin
  for i:=0 to 3 do
    fwritebyte(lla[i]);
end;


procedure InitTree;              	{ *** Initializing tree *** }
var
  i:word;
begin

  for i := 0 to 255 do
    sub_tree[i] := NILL;		{**** root ****}

  for i := 0 to N-1 do
    dad[i] := NILL;			{**** node ****}

end;

  function  searchtree(r:word):boolean;
  var
    x,match_value:word;
    p:word;
  begin
    searchtree:=false;
    match_value:=text_buf[r+1]+text_buf[r+2]*256;
    p:=sub_tree[text_buf[r]];
    match_position:=NILL;

    while p<>NILL do
      begin
        match_position:=p;
        x:=text_buf[p+1]+text_buf[p+2]*256;
        if match_value=x then
          begin
            searchtree:=true;
            exit;
          end;
        if x>match_value then
          begin
            useleftnode:=false;
            p:=rson[p];
          end
        else
          begin
            useleftnode:=true;
            p:=lson[p];
          end;
      end;
  end;



  procedure insertnode(r:word);
  var
    parent :word;
    p:word;
    i,curr_position:word;

  begin

    if searchtree(r) then
      begin
        eqson[r]:=match_position;
        dad[r]  :=dad[match_position];
        dad[match_position]:=r;

        rson[r]:=rson[match_position];
        if rson[r]<>NILL then dad[rson[r]]:=r;

        lson[r]:=lson[match_position];
        if lson[r]<>NILL then dad[lson[r]]:=r;

        p:=dad[r];
        if p=TREENODE then
          sub_tree[text_buf[r]]:=r
        else
          begin
            if rson[p]=match_position then rson[p]:=r
            else lson[p]:=r;
          end;

        curr_position:=match_position;
        match_length:=0;

        repeat
          i:=3;
          while i<F do
            begin
              if text_buf[curr_position+i]=text_buf[r+i] then
                inc(i)
              else
                begin
                  if i>match_length then
                    begin
                      match_length:=i;
                      match_position:=curr_position;
                    end;
                  i:=N;
                end;
              if i=F then
                begin

                  match_length:=i;
                  match_position:=curr_position;
                  exit;

                end;
            end;
          curr_position:=eqson[curr_position];
        until curr_position=NILL;

        exit;
      end;

    parent:=match_position;
    if parent=NILL then
      begin
        sub_tree[text_buf[r]]:=r;
        parent:=TREENODE;
      end
    else
      begin
        if useleftnode then lson[parent]:=r
        else rson[parent]:=r;

      end;

    lson[r]:=NILL;
    rson[r]:=NILL;
    eqson[r]:=NILL;
    dad[r]:=parent;
    match_position:=NILL;
    match_length  :=0;
  end;



  procedure deletenode(p:word);
  var
    q:word;
  begin

    if (dad[p]=NILL) then exit;

    if (dad[p]<>TREENODE)and(eqson[dad[p]]=p) then
      begin
        q:=eqson[p];
        eqson[dad[p]]:=q;
        if q<>NILL then dad[q]:=dad[p];
        exit;
      end;


    if rson[p]=NILL then q:=lson[p]
    else if lson[p]=NILL then q:=rson[p]
    else
      begin
        q:=lson[p];
        if rson[q]<>NILL then
          begin
            repeat
              q:=rson[q];
            until  rson[q]=NILL;
            rson[dad[q]]:=lson[q];
            dad[lson[q]]:=dad[q];
            lson[q]:=lson[p];
            dad[lson[p]]:=q;
          end;
        rson[q]:=rson[p];
        dad[rson[p]]:=q;
      end;

    dad[q]:=dad[p];
    if dad[p]<>TREENODE then
      begin
        if rson[dad[p]]=p then rson[dad[p]]:=q
        else lson[dad[p]]:=q;
      end
    else
      begin
        sub_tree[text_buf[p]]:=q;
      end;
    dad[p]:=NILL
  end;



function GetBit: byte;	    {**** get one bit ****}
var
  i:smallint;
begin

  if (getlen <= 8) then
    begin
      i:=freadbyte;

      getbuf := getbuf or (word(i) shl (8 - getlen));
      getlen := getlen + 8;
    end;

  i := getbuf;
  getbuf := getbuf shl 1;
  dec(getlen);

  Getbit:= ord(i < 0);
end;



function GetByte:byte;		{**** get a byte ****}
{^^ 1 times}
var
  i:word;
begin

    if (getlen <= 8) then
      begin
        i:=freadbyte;

        getbuf := getbuf or (i shl (8 - getlen));
        getlen := getlen + 8;
      end;

    i := getbuf;
    getbuf := getbuf shl 8;
    getlen := getlen - 8;

    Getbyte :=i shr 8;
end;


procedure Putcode(l:byte ;  c:word);		{**** output c bits ****}
begin
    putbuf := putbuf or (c shr putlen);
    putlen := putlen + l;
    if (putlen  >= 8) then
      begin
        fwritebyte(putbuf shr 8);
        putlen := putlen - 8;
        if (putlen >= 8) then
          begin
            fwritebyte(putbuf);
            codesize := codesize + 2;
            putlen := putlen - 8;
            putbuf := c shl (l - putlen);
          end
        else
          begin
            putbuf := putbuf shl 8;
            codesize:=codesize+1;
          end;
      end;
end;


{**** initialize freq tree ****}

procedure StartHuff;
var
  i,j:word;
begin

    for i := 0 to N_CHAR-1 do
      begin
        freq[i] := 1;
        son[i]  := i + T;
        prnt[i + T] := i;
      end;
    i := 0;
    j := N_CHAR;

    while (j <= R) do
      begin
        freq[j] := freq[i] + freq[i + 1];
        son[j]  := i;
        prnt[i] := j;
        prnt[i + 1] := j;
        i := i + 2;
        j:=j+1;
      end;

    freq[T] := $ffff;
    prnt[R] := 0;

end;


{**** reconstruct freq tree ****}

procedure reconst;
var
  i,j,k:word;
  f,l:word;
begin

    {**** halven cumulative freq for leaf nodes ****}
    j := 0;
    for i := 0 to T-1 do
      begin
        if (son[i] >= T) then
          begin
            freq[j] := word(freq[i] + 1) shr 1;
            son[j] := son[i];
            j:=j+1;
          end;
      end;

    {**** make a tree : first, connect children nodes ****}

    i:=0;
    for j:=N_CHAR to T-1 do
      begin
        k := i + 1;
        f := freq[i] + freq[k];
        freq[j] := freq[i] + freq[k];
        k:=j-1;
        while (f<freq[k]) do
          begin
            k:=k-1;
          end;

        k:=k+1;
        l := (j - k) * 2;


        move(freq[k],freq[k + 1], l);
        freq[k] := f;
        move(son[k], son[k + 1], l);
        son[k] := i;
        i:=i+2;
      end;
    {*** connect parent nodes ***}
    for i := 0 to T-1 do
      begin
        k := son[i];
        if (k  >= T) then
          begin
            prnt[k] := i;
          end
        else
          begin
            prnt[k] := i;
            prnt[k + 1] := i;
          end;
      end;
end;


{**** update freq tree ****}

procedure update(c:word);
var
  i,j,k,l:word;
begin
  if (freq[R] = MAX_FREQ) then
        reconst;
    c := prnt[c + T];

    repeat
	inc(freq[c]);
        k := freq[c];

        {**** swap nodes to keep the tree freq-ordered ****}
        l := c+1;
        if (k > freq[l]) then
          begin
            l:=l+1;
            while (k > freq[l]) do l:=l+1;

            l := l-1;
            freq[c] := freq[l];
            freq[l] := k;

            i := son[c];
            prnt[i] := l;
            if (i < T) then prnt[i + 1] := l;

            j := son[l];
            son[l] := i;

            prnt[j] := c;
            if (j < T) then prnt[j + 1] := c;
            son[c] := j;

            c := l;
          end;
        c := prnt[c];

    until (c = 0);	{**** do it until reaching the root ****}
end;


procedure EncodeChar(c:word);
var
  j: byte;
  i,k:word;
begin
    i := 0;
    j := 0;
    k := prnt[c + T];

    {**** search connections from leaf node to the root ****}
    repeat
        i := i shr 1;

        {/*
        if node's address is odd, output 1
        else output 0
        */}

        if (k and 1)<>0 then
          i := i + $8000;

        j:=j+1;
        k:=prnt[k];
    until (k = R);

    Putcode(j, i);

    update(c);
end;

procedure EncodePosition(c:word);
var
  i:word;
begin
    {**** output upper 6 bits with encoding ****}
    i := c shr 6;
    Putcode(p_len[i], word(p_code[i]) shl 8);

    {**** output lower 6 bits directly ****}
    Putcode(6, (c and $3f) shl 10);
end;


procedure EncodeEnd;
begin
    if (putlen)<>0 then
      begin
        fwritebyte(putbuf shr 8);
        codesize := codesize + 1;
      end;
end;

function DecodeChar:word;
var
  c:word;
begin
    c := son[R];

    {/*
     * start searching tree from the root to leaves.
     * choose node #(son[]) if input bit == 0
     * else choose #(son[]+1) (input bit == 1)
     */}
    while (c < T) do
      begin
        c := c + GetBit;
        c := son[c];
      end;
    c := c - T;
    update(c);
    Decodechar:= c;
end;


function DecodePosition: word;
var
  i,j,c:word;
begin

    {**** decode upper 6 bits from given table ****}
    i := GetByte;
    c := word(d_code[i]) shl 6;
    j := d_len[i];

    {**** input lower 6 bits directly ****}
    j := j - 2;
    while (j<>0) do
      begin
        j:=j-1;
        i := (i shl 1);
	i := i + GetBit;
      end;
    j:=j-1;
    DecodePosition := c or i and $3f;
end;


{**** Compression ****}

procedure Encode;  {**** Encoding/Compressing ****}
var
  c,r,s,last_match_length:word;
  i, len: word;
begin

    blockread(infile, buf, sizeof(buf), textsize);

    eof_infile:=textsize;
    buf_idx:=0;

    fwritelong(textsize);
    if (word(textsize) = 0) then exit;

    textsize := 0;			{**** rewind and rescan ****}
    StartHuff;
    InitTree;
    s := 0;
    r := N - F;

    for i := 0 to r-1 do
      begin
        text_buf[i] := 32;
      end;

    len:=0;
    while (len < F) and ( eof_infile<>0 ) do
      begin
        c:=freadbyte;
        text_buf[r+len]:=c;
        len := len+1;
      end;

    textsize := len;
    for i := F downto 1 do
        InsertNode(r - i);
    InsertNode(r);

    repeat
        if (match_length > len) then  match_length := len;
        if (match_length <= THRESHOLD) then
          begin
            match_length := 1;
            EncodeChar(text_buf[r]);
          end
        else
          begin
            EncodeChar(255 - THRESHOLD + match_length);
            EncodePosition((r-match_position-1) and (N-1));
          end;
        last_match_length := match_length;

        i:=0;
        if i<last_match_length then
          begin
            while (i<last_match_length) and (eof_infile<>0) do
              begin
                c:=freadbyte;
                DeleteNode(s);
                text_buf[s] := c;
                if (s < F - 1) then
                    text_buf[s + N] := c;
                s := (s + 1) and (N - 1);
                r := (r + 1) and (N - 1);
                InsertNode(r);
                i:=i+1;
              end;
          end;

        textsize:=textsize+i;
        if (word(textsize) > printcount) then
          begin
            write(textsize,' ');
            printcount := printcount + 1024;
          end;

        while (i < last_match_length) do
          begin
            i:=i+1;                             {*****chk here****}
            DeleteNode(s);
            s := (s + 1) and (N - 1);
            r := (r + 1) and (N - 1);
            len:=len-1;
            if (len<>0) then InsertNode(r);
          end;
    until (len <= 0);

    EncodeEnd;

    writeln;
    writeln('Pack size=',codesize, ' bytes');
end;


procedure Decode; {**** Decoding/Uncompressing ****}
var
  r,c: word;
  i,j, k, count: word;
begin

    blockread(infile, buf, sizeof(buf), textsize);

    eof_infile:=textsize;
    buf_idx:=0;

    freadlong(textsize);
    if (textsize = 0) then exit;

    StartHuff;

    for i := 0 to N-F-1 do
        text_buf[i] := 32;

    r := N - F;
    count:=0;
    while count<word(textsize) do
      begin
        c := DecodeChar;
        if (c < 256) then
          begin
            fwritebyte(c);
            text_buf[r] := c;
            r := r+1;
            r := r and (N - 1);
            count:=count+1;
          end
        else
          begin
	    k := DecodePosition;
            i := (r - k - 1) and (N - 1);
            j := c - 255 + THRESHOLD;
            for k := 0 to j-1 do
              begin
                c := text_buf[(i + k) and (N - 1)];
                fwritebyte(c);
                text_buf[r] := c;
                r :=r+1;
                r := r and (N - 1);
                count:=count+1;
               end;
          end;

        if (count > printcount) then
          begin
            write(count,' ');
            printcount := printcount + 1024;
          end;
      end;

    writeln(count);
end;


procedure Syntax;
begin
        writeln('Usage: LZHUF.EXE E(compression)|D(uncompression) infile outfile');
        halt;
end;


procedure main;
var
  s: string[32];
begin

    textsize   := 0;
    codesize   := 0;
    printcount := 0;
    getbuf := 0;
    getlen := 0;
    putbuf := 0;
    putlen := 0;
    if (paramcount <> 3) then Syntax;

    s:=paramstr(1);

    case s[1] of
     'D','E','d','e': ;
    else
     Syntax
    end;

    assign(infile,paramstr(2));
    reset(infile, 1);

    assign(outfile,paramstr(3));
    rewrite(outfile, 1);

    s[1]:=upcase(s[1]);

    if s[1]='E' then
        Encode
    else
        Decode;

    close(infile);
    close(outfile);
end;

begin

  main;

end.
