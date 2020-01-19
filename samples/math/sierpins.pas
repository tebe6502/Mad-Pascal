uses fastgraph, crt;

const tiefe =5;
      maxX  =320;
      maxY  =192;
      breite=128;

var   altx ,
      alty ,
      x0   ,
      y0   ,
      i    ,
      h    :smallint;


procedure nline(richtung: byte; laenge:smallint);

  procedure lineR(x,y:smallint);

    begin
      altx:=altx+x;
      alty:=alty+y;
      SetColor(1);
      lineto(altx,alty);
    end;

  begin
    case richtung of
      0:lineR(+laenge, 0     );
      1:lineR(+laenge,+laenge);
      2:lineR( 0     ,+laenge);
      3:lineR(-laenge,+laenge);
      4:lineR(-laenge, 0     );
      5:lineR(-laenge,-laenge);
      6:lineR( 0     ,-laenge);
      7:lineR(+laenge,-laenge)
    end
  end;

procedure A(k:smallint);
  forward;

procedure B(k:smallint);
  forward;

procedure C(k:smallint);
  forward;

procedure D(k:smallint);
  forward;

procedure A;

  begin
    if k>0 then
      begin
        A(k-1); nline(7,h);
        B(k-1); nline(0,2*h);
        D(k-1); nline(1,h);
        A(k-1)
      end
  end;

procedure B;

  begin
    if k>0 then
      begin
        B(k-1); nline(5,h);
        C(k-1); nline(6,2*h);
        A(k-1); nline(7,h);
        B(k-1)
      end
  end;

procedure C;

  begin


    if k>0 then
      begin
        C(k-1); nline(3,h);
        D(k-1); nline(4,2*h);
        B(k-1); nline(5,h);
        C(k-1)
      end
  end;

procedure D;

  begin
    if k>0 then
      begin
        D(k-1); nline(1,h);
        A(k-1); nline(2,2*h);
        C(k-1); nline(3,h);
        D(k-1)
      end
  end;

begin

  InitGraph(8+16);

  SetColor(1);

  h :=breite div 4;
  i :=0;
  x0:=(maxX-1) div 2;
  y0:=(maxY-1) div 2 +h;

  repeat
    inc(i);
    x0  :=x0-h;
    h   :=h div 2;
    y0  :=y0+h;
    altX:=x0;
    altY:=y0;

    MoveTo(altX,altY);

    A(i); nline(7,h);
    B(i); nline(5,h);
    C(i); nline(3,h);
    D(i); nline(1,h);
  until(i=tiefe);

  repeat until keypressed;
end.

