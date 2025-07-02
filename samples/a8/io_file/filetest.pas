program filehandle;
uses atari, crt, sysutils;

const
    DB_FILE = 'D:DATA.DBF';
    
type 
TRecord = record
    name: TString;
    b: byte;
    w: word;
end;    
    
var
    i: byte;
    f: file;
    r: TRecord;
    fpos: array [0..100] of cardinal;


procedure DBCreate(count:byte);
begin
    Assign (f, DB_FILE);
    Rewrite (f, sizeOf(r));
    for i:=0 to count do begin
        r.name := Concat('Record No. ', IntToStr(i));
        r.b := Random(0);
        r.w := 256 * i;
        fpos[i] := FilePos(f);
        BlockWrite(f, r, 1);
        Write('.');
    end;
    Close(f);
    Writeln;
    Writeln(count,' records saved');
end;

procedure DBStore(pos:byte;sr:TRecord);
var sf:file;
begin
    Assign (sf, DB_FILE);
    Reset (sf, sizeOf(TRecord));
    Seek(sf,fpos[pos]);
    BlockWrite(sf, sr, 1);
    Close(sf);
    Writeln('record saved');
end;

function DBLoad(pos:byte):TRecord;
var sf:file;
    sr:TRecord;
begin
    Assign (sf, DB_FILE);
    Reset (sf, sizeOf(TRecord));
    Seek(sf,fpos[pos]);
    BlockRead(sf, sr, 1);
    Close(sf);
    result := sr;
end;

begin
    DBCreate(32);
    write('press any key');
    Readkey;
    writeln(' -> read test');
    r := DBLoad(10);
    writeln(r.name);
    Writeln(r.b);
    writeln(r.w);
    write('press any key');
    Readkey;
    writeln(' -> write test');
    r.name:='updated';
    DBStore(10,r); 
    r := DBLoad(10);
    writeln(r.name);
    Writeln(r.b);
    writeln(r.w);
end.


