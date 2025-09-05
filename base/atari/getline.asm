
/*
  GETLINE

  Program czeka, az uzytkownik wpisze ciag znakow z klawiatury i nacisnie klawisz RETURN.
  Znaki podczas wpisywania sa wyswietlane na ekranie, dzialaja tez normalne znaki kontrolne
  (odczyt jest robiony z edytora ekranowego).

  Wywolanie funkcji polega na zaladowaniu adresu, pod jaki maja byc wpisane znaki,
  do rejestrow A/Y (mlodszy/starszy) i wykonaniu rozkazu JSR GETLINE.

*/

.proc	@GetLine

	stx @sp

	ldx #0

	stx MAIN.SYSTEM.EoLn

	mwa	#@buf+1	icbufa,x

	mwa	#$ff	icbufl,x	; maks. wielkosc tekstu

	mva	#$05	iccmd,x

	m@call	ciov

	dew icbufl
	mva icbufl @buf			; length

	ldx @buf+1
	cpx #EOL
	bne skp

	ldx #TRUE
	stx MAIN.SYSTEM.EoLn
skp
	ldx @sp: #0

	rts
.endp
