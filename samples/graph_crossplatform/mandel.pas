program mandel;

{ This program generates the Mandlebrot set fractal curves. It is taken from
Roger T. Stevens book: FRACTAL Programming in Turbo Pascal.
This is the best book to buy if you are interested in or studying fractal
curves and chaos.

The below program is coded to be displayed on an EGA monitor at
640 x 200 resolution. Simple modifications can be made to display the set
on a higher resolution. Using anything below an EGA display will NOT
produce the spectacular effects as do the EGA and higher modes.

EGADrive is a unit I wrote to link in the EGAVGA.BGI screen routines
at compile time. Notice how you don't need to specify the BGI path in
the call to InitGraph.

To make the program run faster on slower machines, but sacrificing detail,
change the max_iterations constant to something lower. Therefore, the
lesser the iterations, the less detailed the curves, and vice versa.
}

uses CRT, Graph;

const
max_colors = 16;
max_iterations = 16;
max_size = 4;

var
Q : array[0..255] of single;
XMax,YMax,XMin,YMin,
P,deltaP,deltaQ,X,Y,Xsquare,Ysquare : single;
GraphDriver,GraphMode : smallint;
color, maxcol, col, maxrow, row: byte;
ch : char;

begin
XMax := 1.2;
XMin := -2.0;
YMax := 1.2;
YMin :=-1.2;
GraphDriver := VGA;
GraphMode := VGAMed;
InitGraph(GraphDriver,GraphMode,'');

maxcol:=GetMaxX;
maxrow:=GetMaxY;

if maxcol > 160 then maxcol:=160;
if maxrow > 192 then maxrow:=192;

deltaP := (XMax - XMin) / maxcol;
deltaQ := (YMax - Ymin) / maxrow;
Q[0] := YMax;
for row := 1 to maxrow do
Q[row] := Q[row-1] - deltaQ;
P := XMin;
for col := 0 to maxcol do
begin

if Keypressed then exit;

for row := 0 to maxrow shr 1 do
begin
X := 0.0;
Y := 0.0;
Xsquare := 0.0;
Ysquare := 0.0;
color := 1;

repeat { this is the "meat" }
	Xsquare := X*X;

	Ysquare := Y*Y;
	Y := 2*X*Y + Q[row];
	X := Xsquare - Ysquare + P;
	inc(color);

until (color>=max_iterations) OR (Xsquare + Ysquare >= max_size);

color:=color MOD max_colors;

PutPixel(col, row, color);
PutPixel(col, maxrow-row, color);

end;

P := P + deltaP;
end;

ch := ReadKey;
end.
