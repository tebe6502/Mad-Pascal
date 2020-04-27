
type

	TName = array [0..21] of char;

	TSample = packed record
			name		: TName;
			len		: word;
			fine_tune,
			volume		: byte;
			loop_start,
			loop_len	: word;
		end;

	TPSample = ^TSample;


const
	COVOX	= $d600;

	PATTERN_LIMIT = 37;
	SAMPLE_LIMIT = 31;

	ZPAGE	= $db00;		// kopia strony zerowej
	EFFECT	= $dc00;		// dekodowaniu kodu dla efektu sampla
	TADCL	= $dd00;		// mlodsze bajty przyrostu offsetu dla sampla (nuta)
	TADCH	= TADCL + $30;		// starsze bajty przyrostu offsetu dla sampla (nuta)

	VOLUME	= $de00;		// 33 tablice glosnosci (pierwsza tablica zawiera same zera)

	pattern_start = $4000;		// $4000 + $300 * PATTERN_LIMIT
	sample_start = $4000;
	sample_len = $4000;


	KOD : array [0..47] of word = (
	$6b0,$650,$5f4,$5a0,
	$54c,$500,$4b8,$474,
	$434,$3f8,$3c0,$380,
	$358,$328,$2fa,$2d0,
	$2a6,$280,$25c,$23a,
	$21a,$1fc,$1e0,$1c5,
	$1ac,$194,$17d,$168,
	$153,$140,$12e,$11d,
	$10d,$fe,$f0,$e2,
	$d6,$ca,$be,$b4,
	$aa,$a0,$97,$8f,
	$87,$7f,$78,$71
	);

var
	BUF: array [0..255] of byte absolute $0500;

	TIVOL: array [0..31] of byte absolute $0150;	// starszy adres glosnosci tablicy VOLUME = glosnosc SAMPLA

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
