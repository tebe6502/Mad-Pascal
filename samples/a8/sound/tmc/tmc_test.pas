uses crt, tmc;

{$r tmc_test.rc}

const
tmc_player = $a000;
tmc_modul = $8000;

fps = 2;

var
	msx: TTMC;

	ch: char;
	
begin

	msx.player:=pointer(tmc_player);
	msx.modul:=pointer(tmc_modul);

	msx.init;

	writeln('Pascal TMC player example');

	repeat

	  pause;

	  msx.play;


	  case fps of	// liczba wywolan playera 2, 3, 4

	   2: msx.sound(48);
	
	   3:
	   begin
	     msx.sound(20);
	     msx.sound(76);
	   end;
	
	   4: 
	   begin
	     msx.sound(8);
	     msx.sound(48);
	     msx.sound(88);
	   end;
	   
	  end;


	until keypressed;
	ch:=readkey();

	msx.stop;

 repeat until keypressed;

end.
