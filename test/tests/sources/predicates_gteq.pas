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

    if a >= 0 then inc(i);
    if b >= 0 then inc(i,2);
    if c >= 0 then inc(i,4);

    if d >= 0 then inc(i,8);
    if e >= 0 then inc(i,16);
    if f >= 0 then inc(i,32);

    if a >= 7 then inc(i,64);
    if b >= 7 then inc(i,128);
    if c >= 7 then inc(i,256);

    if d >= 7 then inc(i,512);
    if e >= 7 then inc(i,1024);
    if f >= 7 then inc(i,2048);

end.
