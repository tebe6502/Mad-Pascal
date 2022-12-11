uses crt, xSFX;

// if you want play SFX on SECOND POKEY
//uses sfx_config;

const
	sfx1: array [0..11] of byte =	// upadek Preliminary Monte
	(
	$C0,$01,$06,$8A,		// C0 = REPF
					// 01 = zapisuj rejestr AUDF co 1 ramke
					// 06 = mamy 6 wartosci do pobrania
					// 8A = wartosc inicjujaca zapisywana do AUDC
	$C0,$C0,$01,$C0,$C0,$01,	// 6 wartosci po kolei beda zapisywane co jedna ramke do AUDF
	$00,$FF				// 00 FF = RTS w tym przypadku koniec odtwarzania
	);

	sfx2: array [0..50] of byte =	// local perfect w Gyruss
	(
	$80,$01,$03,$00,		// 80 = REPC
	$07,$27,$47,
	$80,$01,$03,$00,
	$06,$26,$46,
	$80,$01,$03,$00,
	$05,$27,$45,
	$80,$01,$03,$00,
	$04,$24,$44,
	$80,$01,$03,$00,
	$03,$23,$43,
	$80,$01,$03,$00,
	$02,$22,$42,
	$80,$01,$03,$00,
	$01,$21,$41,
	$00,$FF
	);

	sfx3: array [0..91] of byte =	// Donkey Kong
	(
	$02,$44,$A7,			// zagraj 2 ramki wartosci AUDF i AUDC
	$01,$43,$A7,
	$01,$44,$A7,
	$01,$3C,$A7,
	$01,$3D,$A7,
	$01,$3C,$A7,
	$01,$35,$A7,
	$02,$34,$A7,
	$01,$35,$A7,
	$01,$34,$A7,
	$01,$28,$A7,
	$01,$27,$A7,
	$01,$29,$A7,
	$01,$28,$A6,
	$01,$27,$A6,
	$02,$28,$A5,
	$01,$27,$A5,
	$01,$28,$A5,
	$01,$29,$A4,
	$01,$28,$A3,
	$04,$28,$A0,
	$04,$32,$A7,
	$01,$33,$A7,
	$03,$32,$A7,
	$01,$33,$A7,
	$03,$32,$A7,
	$01,$33,$A7,
	$04,$32,$A7,
	$01,$32,$A7,
	$01,$32,$00,
	$00,$FF
	);


	sfx4: array [0..11] of byte =	// chodzenie Preliminary Monty
	(
	$C0,$01,$03,$84,
	$C0,$FE,$01,
	$05,$00,$00,			// 05 = piec ramek
					// 00 do AUDF
					// 00 do AUDC = 5 ramek ciszy
	$00,$00				// 00 00 = LOOP zagraj tego SFX jeszcze raz od pozycji 00
	);

	sfx5: array [0..43] of byte =	// Pacman BG2
	(
//	$A3,				// A0 = JSR; E0 = JMP  starsze 3 bity %1110 0000
					// 03 = SFX nr. 03     mlodszy 5 bitow %0001 1111
	$C0,$01,$0A,$A5,
	$80,$70,$60,$50,$40,$50,$60,$70,$80,$90,
	$C0,$01,$0A,$A4,		// loop
	$80,$70,$60,$50,$40,$50,$60,$70,$80,$90,
	$C0,$01,$0A,$A3,
	$80,$70,$60,$50,$40,$50,$60,$70,$80,$90,
	$00,$0F-1			// $00,$0F,$=,$LOOP,$do,$pozycji,$0F
	);


	sfx6: array [0..34] of byte =	// Arkanoid ball bounces
	(
	$01,$00,$00,			// 1 frame AUDF, AUDC
	$01,$3C,$AF,
	$01,$3B,$AD,
	$01,$3B,$A7,
	$01,$3C,$A5,
	$01,$3B,$A5,
	$01,$3C,$A4,
	$01,$3C,$A3,
	$01,$3C,$A1,
	$01,$3C,$A0,
	$01,$3C,$A1,
	$00,$FF				// $00,$FF end
	);


	sfx7: array [0..34] of byte =	// Arkanoid ball bounces at the brick
	(
	$01,$00,$00,			// 1 frame AUDF, AUDC
	$01,$32,$AF,
	$01,$31,$AD,
	$01,$31,$A7,
	$01,$32,$A5,
	$01,$31,$A5,
	$01,$32,$A4,
	$01,$32,$A3,
	$01,$32,$A1,
	$01,$32,$A0,
	$01,$32,$A1,
	$00,$FF
	);


	sfx8: array [0..34] of byte =	// Arkanoid ball bounces at the hard brick
	(
	$01,$00,$00,			// 1 frame AUDF, AUDC
	$01,$19,$AF,
	$01,$18,$AD,
	$01,$18,$A7,
	$01,$19,$A5,
	$01,$18,$A5,
	$01,$19,$A4,
	$01,$19,$A3,
	$01,$19,$A1,
	$01,$19,$A0,
	$01,$19,$A1,
	$00,$FF
	);

	sfx9: array [0..34] of byte =	// Arkanoid ball bounces at the hard brick
	(
	$01,$00,$00,
	$01,$13,$AF,
	$01,$12,$AD,
	$01,$12,$A7,
	$01,$13,$A5,
	$01,$12,$A5,
	$01,$12,$A4,
	$01,$12,$A3,
	$01,$12,$A1,
	$01,$12,$A0,
	$01,$12,$A1,
	$00,$FF
	);


	sfx10: array [0..160] of byte =	// Arkanoid DOH destroyed
	(
	$01,$00,$00,
	$03,$03,$22,
	$03,$05,$22,
	$03,$04,$22,
	$03,$03,$22,
	$03,$03,$24,
	$03,$05,$24,
	$03,$04,$24,
	$03,$03,$24,
	$03,$03,$26,
	$03,$05,$26,
	$03,$04,$26,
	$03,$03,$26,
	$03,$03,$28,
	$03,$05,$28,
	$03,$04,$28,
	$03,$03,$28,
	$03,$03,$2A,
	$03,$05,$2A,
	$03,$04,$2A,
	$03,$03,$2A,
	$03,$03,$2C,
	$03,$05,$2C,
	$03,$04,$2C,
	$03,$03,$2C,
	$03,$03,$2E,
	$03,$05,$2E,
	$03,$04,$2E,
	$03,$03,$2E,
	$03,$03,$2C,
	$03,$05,$2C,
	$03,$04,$2C,
	$03,$03,$2C,
	$03,$03,$2A,
	$03,$05,$2A,
	$03,$04,$2A,
	$03,$03,$2A,
	$03,$03,$28,
	$03,$05,$28,
	$03,$04,$28,
	$03,$03,$28,
	$03,$03,$26,
	$03,$05,$26,
	$03,$04,$26,
	$03,$03,$26,
	$03,$03,$24,
	$03,$05,$24,
	$03,$04,$24,
	$03,$03,$24,
	$03,$03,$22,
	$03,$05,$22,
	$03,$04,$22,
	$03,$03,$22,
	$00,$FF
	);

	sfx11: array [0..46] of byte =	// Arkanoid VAUS destroyed
	(
	$03,$14,$29,			// 3 frame AUDF, AUDC
	$04,$10,$2C,			// 4 frame AUDF, AUDC
	$02,$12,$2B,
	$03,$14,$27,
	$04,$10,$2A,
	$02,$12,$29,
	$03,$14,$25,
	$04,$10,$28,
	$02,$12,$27,
	$03,$14,$23,
	$04,$10,$26,
	$02,$12,$25,
	$03,$14,$22,
	$04,$10,$25,
	$02,$12,$24,
	$00,$FF
	);

	sfx12: array [0..25] of byte =	// Arkanoid VAUS walks through the door to next round
	(
	$01,$00,$00,			// 1 frame AUDF, AUDC
	$07,$1F,$2F,			// 7 frame AUDF, AUDC
	$07,$21,$2D,
	$07,$23,$2B,
	$07,$25,$29,
	$06,$27,$27,
	$06,$29,$25,
	$06,$2B,$23,
	$00,$FF
	);


var

	sfx: TSFX;

begin
	sfx.clear;
	sfx.add(@sfx6);


	while true do begin

	 pause;
	 sfx.play;

	 if keypressed then begin

	  readkey;

    	  sfx.init(1);

	 end;

	end;
end.