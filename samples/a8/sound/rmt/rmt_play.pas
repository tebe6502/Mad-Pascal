// RMT - RASTER Music Tracker Player
// To use this player, you need and ".RMT" file and the corresponding features file.
// The features file is module-specific assembly file that indicates which features
// of the player the module actually uses. Using this file at compile-time, a player
// that is optimized to the requirements of the specific song is created.
// While this help to save memory for a single song, it also creates overhead when
// using multiple songs at once. Because then you need the player also indidivually
// for every song.
// To create a stripped ".RMT" file (with song name and instrument names removed to
// save space) and the features files, use the menu "File / Export As... / ".
// Copy the displayed features definition to the clipboard and paste it into a ".FEAT" file.
// The songs and their features a linked as resources using the related ".RC" file.

uses crt, rmt;

const
        rmt_module_4 = $4000;
        rmt_module_8 = $5000;

	rmt_player_4 = $8000;  // Beware, the player uses also $400 byte before this address
        rmt_player_8 = $9000;  // Beware, the player uses also $400 byte before this address

var
        song: byte;
        song_name: string;
        song_author: string;
	msx: TRMT;

	ch: char;

{$r 'rmt_play.rc'}

begin
        song:=0;

	while true do begin

        write(chr$(125));
        writeln('Pascal RMT player example');
        writeln;

        if song=0 then
        begin
               song_name:='Delta (Mono)';
               song_author:='Radek Sterba aka RASTER';
	       msx.player:=pointer(rmt_player_4);
	       msx.modul:=pointer(rmt_module_4);
	end else
	begin
	       song_name:='Smell Like Teean Spirit (Stereo)';
	       song_author:='Adam Hay aka sack/c0s';
               msx.player:=pointer(rmt_player_8);
               msx.modul:=pointer(rmt_module_8);
	end;

	msx.init(0);
	writeln('Currently playing ...');
        writeln;
	writeln(song_name);
	writeln('by ', song_author);
        writeln;
        writeln('Press any key to toggle song.');
	repeat
		pause;

		msx.play;

	until keypressed;
	
	ch:=readkey();

	msx.stop;
        
        inc(song);
        if song=2 then song:=0;;

	end;

end.

