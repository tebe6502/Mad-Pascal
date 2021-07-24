var
    i: cardinal;

    a: byte;
    b: word;
    c: cardinal;

    d: shortint;
    e: smallint;
    f: integer;


begin
    a:=10;
    b:=100;
    c:=1000;

    d:=10;
    e:=100;
    f:=1000;

    if a < 0 then inc(i);
    if b < 0 then inc(i,2);
    if c < 0 then inc(i,4);

    if d < 0 then inc(i,8);
    if e < 0 then inc(i,16);
    if f < 0 then inc(i,32);

    if a < 7 then inc(i,64);

    if b <$12 then inc(i,128);
    if b < $1234 then inc(i,256);

    if c < $11 then inc(i,512);
    if c < $1122 then inc(i,1024);
    if c < $112233 then inc(i,2048);
    if c < $11223344 then inc(i,4096);

    if d < 117 then inc(i,8192);
    if e < 1117 then inc(i,16384);
    if f < 11117 then inc(i,32768);

    if d < low(shortint) then inc(i,65536);
    if e < low(smallint) then inc(i,131072);
    if f < low(integer) then inc(i,262144);

end.