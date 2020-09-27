// Rascal '12_sqrt_and_atan.ras'

program tutorial_12_sqrt_and_atan;

uses crt, fastmath;

(*
	In this tutorial, we slowly pre-render a screen that is slowly flled with a spiral.
	In order to calculate the value of the spiral, we need to use both radial and tangentinal values,
	which we obtain by using sqrt() and atan2. The screen is rendered using 16 characters (64-80,
	view the character set used in "charsets/charset.flf).

	After the screen is rendered, the program simply sets up a small raster irq routine that does
	a simple and neat trick: it "shifts" the data character set by copying the data of the 16
	characters used for displaying the image 1 character "to the left" in the character set. By doing
	this, we obtain the effect that the image is spiraling - even though the only thing that is going
	on is a small data shift in the character set.


*)

const
	screen_height = 24;
	screen_width = 40;

var
	x,y,tangent,i,dx,dy : byte;
	radial : word;


procedure RenderScreen();
var screenmemory: PByte absolute $e0;
begin

	screenmemory:=pointer(dpeek(88));

	// 24 rows
	for y:=0 to screen_height-1 do begin
		//40 columns
		for x:=0 to screen_width do begin

			// calculate delta x and delta y from the center of the screen (20,13)
			dx:=abs(shortint(20-x));
			dy:=abs(shortint(13-y));

			// Calculate the "tangential" value of dx,dy. Try to plot this value indepenedntly!
			tangent:=(atan2(20,x,12,y));
			radial:=(dx*dx+dy*dy);

			// Calculate the "radial" value of dx,dy. Try to plot this value indepenedntly!
			radial:=sqrt16(radial);

			// Combine the values to create a spiral. Ideally the (tangent
			i:=radial shr 2+tangent;

			// Ideal, (radial,tangent) should be used to lookup a seamless texture
			// Divide by 4 (so values are 0-64) and then constrain to 0-15
			i:=(i shr 2) and 15;

			// Fill screen memory with the character value
			screenmemory[x]:=i;

		end;
		inc(screenmemory, screen_width);
	end;

end;


// Main initialization routine
begin
	RenderScreen();

	repeat until keypressed;
end.
