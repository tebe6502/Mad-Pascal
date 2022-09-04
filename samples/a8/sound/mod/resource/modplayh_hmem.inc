type

	TName = array [0..21] of char;

	TSample = packed record
			name		: TName;
			len		: word;
			fine_tune	: shortint;
			volume		: byte;
			loop_start,
			loop_len	: word;
		end;

	TPSample = ^TSample;

const
	COVOX	= $d700;

	pattern_temp = $5000;

	PATTERN_LIMIT = 85;

	ZPAGE	= $d900;		// kopia strony $00 i $03 ($d900..$daff)

	EFFECT	= $dc00;		// dekodowaniu kodu dla efektu sampla
	TADCL	= $dd00;		// mlodsze bajty przyrostu offsetu dla sampla (nuta)
	TADCH	= TADCL + $30;		// starsze bajty przyrostu offsetu dla sampla (nuta)

	VOLUME	= $de00;		// 33 tablice glosnosci (pierwsza tablica zawiera same zera)

	sample_len = $10000;


	KOD : array [0..47] of word = (
	$6b0,$650,$5f4,$5a0,$54c,$500,$4b8,$474,
	$434,$3f8,$3c0,$380,$358,$328,$2fa,$2d0,
	$2a6,$280,$25c,$23a,$21a,$1fc,$1e0,$1c5,
	$1ac,$194,$17d,$168,$153,$140,$12e,$11d,
	$10d,$fe,$f0,$e2,$d6,$ca,$be,$b4,
	$aa,$a0,$97,$8f,$87,$7f,$78,$71
	);
{
per_table : array[1..60] of word = (
   1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960,906,
   856,808,762,720,678,640,604,570,538,508,480,453,
   428,404,381,360,339,320,302,285,269,254,240,226,
   214,202,190,180,170,160,151,143,135,127,120,113,
   107,101,95,90,85,80,75,71,67,63,60,56);

note_table : array[1..60] of byte =
   (32+0,32+1,32+2,32+3,32+4,32+5,32+6,32+7,32+8,32+9,32+10,32+11,
   48+0,48+1,48+2,48+3,48+4,48+5,48+6,48+7,48+8,48+9,48+10,48+11,
   64+0,64+1,64+2,64+3,64+4,64+5,64+6,64+7,64+8,64+9,64+10,64+11,
   80+0,80+1,80+2,80+3,80+4,80+5,80+6,80+7,80+8,80+9,80+10,80+11,
   96+0,96+1,96+2,96+3,96+4,96+5,96+6,96+7,96+8,96+9,96+10,96+11);
}

var
	BUF: array [0..$e0-1] of byte absolute $0500;

	TIVOL: array [0..31] of byte absolute $05e0;	// starszy adres glosnosci tablicy VOLUME = glosnosc SAMPLA
	ORDER: array [0..127] of byte absolute $0600;	// tablica SONG ORDER
	TSTRL: array [0..31] of byte absolute $0680;	// mlodszy bajt adresu poczatkowego sampla
	TSTRH: array [0..31] of byte absolute $06A0;	// starszy bajt adresu poczatkowego sampla
	TREPL: array [0..31] of byte absolute $06C0;	// mlodszy bajt adresu powtorzenia sampla
	TREPH: array [0..31] of byte absolute $06E0;	// starszy bajt adresu powtorzenia sampla

	ModName: array [0..19+1] of char;

	sampl_0, sampl_1, sampl_2, sampl_3, sampl_4,
	sampl_5, sampl_6, sampl_7, sampl_8, sampl_9,
	sampl_10, sampl_11, sampl_12, sampl_13,
	sampl_14, sampl_15, sampl_16, sampl_17,
	sampl_18, sampl_19, sampl_20, sampl_21,
	sampl_22, sampl_23, sampl_24, sampl_25,
	sampl_26, sampl_27, sampl_28, sampl_29, sampl_30: TSample;

	Sample: array [0..30] of pointer = (
	@sampl_0, @sampl_1, @sampl_2, @sampl_3, @sampl_4,
	@sampl_5, @sampl_6, @sampl_7, @sampl_8, @sampl_9,
	@sampl_10, @sampl_11, @sampl_12, @sampl_13,
	@sampl_14, @sampl_15, @sampl_16, @sampl_17,
	@sampl_18, @sampl_19, @sampl_20, @sampl_21,
	@sampl_22, @sampl_23, @sampl_24, @sampl_25,
	@sampl_26, @sampl_27, @sampl_28, @sampl_29, @sampl_30);

	gchar: char;

	SONG_LENGTH,
	SONG_RESTART,
	NUMBER_OF_PATTERNS,
	NUMBER_OF_BANKS,
	NUMBER_OF_SAMPLES	: byte;

	xms: THighMemoryStream;
