var 
    fscr: file;

function Antic2Atascii(c: byte):byte;assembler;
asm {
    lda c
    asl
    php
    cmp #2*$60
    bcs @+
    sbc #2*$40-1
    bcs @+
    adc #2*$60
@   plp
    ror
    sta result;
    };
end;

procedure InitIO;
begin
    Assign(fscr, 'S:'); 
    Rewrite(fscr, 1);
end;

procedure Print(s: String40);overload;
begin
    blockwrite(fscr, s[1], length(s));
end;

procedure Print(c: char);overload;
begin
    blockwrite(fscr, c, 1);
end;

procedure Print(c1, c2: char);overload;
begin
    blockwrite(fscr, c1, 1);
    blockwrite(fscr, c2, 1);
end;

procedure Position(x, y: byte);
begin
    gotoxy(x + 1, y + 1);
end;

function Locate(x, y: byte):byte;
begin
    result := Antic2Atascii(peek(savmsc + (y * 40) + x));
end;

function GetKey:byte;overload;
begin
    result := byte(ReadKey) and %01011111;
end;

function GetKey(a, b:byte):byte;overload;
begin
    repeat 
        result := byte(ReadKey) and %01011111;
    until (result = a) or (result = b);
end;

function GetKey(a, b, c, d: byte):byte;overload;
begin
    repeat 
        result := byte(ReadKey) and %01011111;
    until (result = a) or (result = b) or (result = c) or (result = d);
end;

procedure ClearLine;
begin
    fillbyte(pointer(savmsc+22*40),80,0);
end;

procedure StatusLine(s: String40);
begin
    ClearLine;
    Position(2, 22);
    Write(s);
end;

procedure StatusLineln(s: String40);
begin
    StatusLine(s);
    Writeln;
end;

procedure StatusLine2(s: String40);
begin
    Position(2, 23);
    Write(s);
end;
