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
// The songs and their feature files are linked as resources using the related ".RC" file.
// See "base\atari\players" folder for implementation details.


{$define romoff} // TODO: Does not copy font https://forums.atariage.com/topic/240919-mad-pascal/page/38/#findComment-5623690

uses crt, rmt;

const
        rmt_player_4 = $8000;  // RMTPLAY resource, can be used in memory area $0000-$bfff
                               // Beware, the player uses also $400 byte before this address
        rmt_player_8 = $f000;  // RMTPLAY2 resource, can also be used in memory area $c000-ffff
                               // Beware, the player uses also $400 byte before this address

        rmt_module_4 = $6000;  
        rmt_module_8 = $c000;
        
        charset      = $e000;  // Workarund for https://github.com/tebe6502/Mad-Pascal/issues/162

var
        song: byte;
        song_name: string;
        song_author: string;
	msx: TRMT;

	ch: char;

{$r 'rmt_play.rc'}

begin

        song:=0;

(*      The following block can only be used if there is a single RMLT/RMT2 player
        asm
        lda #$00                ; $00 max volume ; $f0 silenc
        sta RMTGLOBALVOLUMEFADE
        end;
*)

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
	       song_name:='Smells Like Teen Spirit (Stereo)';
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

