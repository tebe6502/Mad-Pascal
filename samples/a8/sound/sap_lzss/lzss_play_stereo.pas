// https://forums.atariage.com/topic/315537-rmt2lzss-convert-rmt-tunes-to-lzss-for-fast-playback/

uses crt, saplzss;

{$define romoff}

const

//mod_r = $9000;
//mod_l = $7000;

play_r = $c000;		// ..$02FF player, $0300..$0BFF buffers
play_l = $f000;

var
	msx_r, msx_l: TLZSSPlay;

	len: word;

	p: pointer;

	ch: char;

{$r 'lzss_play_stereo.rc'}


begin
	fillchar(pointer(play_r+$300), $900, 0);		// clear sapr-lzss buffer
	fillchar(pointer(play_l+$300), $900, 0);		// clear sapr-lzss buffer

        SizeofResource(len, 'mod_r');
	GetResourceHandle(p, 'mod_r');
	writeln('modul_r length: ', len, ', address: $', hexStr(word(p),4));

	msx_r.modul := p;
//	msr_r.modul := pointer(mod_r);
	msx_r.player := pointer(play_r);

        SizeofResource(len, 'mod_l');
	GetResourceHandle(p, 'mod_l');
	writeln('modul_l length: ', len,', address: $', hexStr(word(p), 4));

	msx_l.modul:=p;
//	msr_l.modul := pointer(mod_l);
	msx_l.player:=pointer(play_l);


	fillchar(pointer(play_r+$300), $900, 0);	// clear buffers
	fillchar(pointer(play_l+$300), $900, 0);	// clear buffers


	msx_r.init($00);	// $d200
	msx_l.init($10);	// $d210

	writeln;
	writeln('Pascal SAP-R LZSS 8chn player example');

	repeat
		pause;

		msx_r.decode;
		msx_l.decode;

		msx_r.play;
		msx_l.play;

	until keypressed;

	ch:=readkey();

	msx_r.stop($00);
	msx_l.stop($10);

end.
