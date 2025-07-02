
uses crt, graphics, types;

{$r txtout.rc}

var   canvas: TCanvas;

      s: TString;

      p: pointer;

      i,j: byte;

      b: TBrushBitmap;

begin

canvas.create;

s:='ATARI';

canvas.brush.color:=1;


b[0]:=$81;
b[1]:=$42;
b[2]:=$24;
b[3]:=$18;
b[4]:=$18;
b[5]:=$24;
b[6]:=$42;
b[7]:=$81;

canvas.brush.bitmap:=b;

canvas.fillrect(Rect(10,12,319,30));

canvas.brush.mode:=bmXor;

canvas.fillrect(Rect(12,14,88,28));

canvas.pen.color:=1;


canvas.textout((320-canvas.textwidth(s)) shr 1, 80, s);

GetResourceHandle(p, 'weirdo');

canvas.Font(p);

s:='POWER with PRICE';

canvas.textout((320-canvas.textwidth(s)) shr 1, 89, s);


canvas.pen.color:=10;

canvas.moveto(20,31);

canvas.lineto(220,131);



repeat until keypressed;

end.

// 4905