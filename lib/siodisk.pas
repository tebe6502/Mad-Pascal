unit siodisk;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: SIO Floppy Disk interface
 @version: 1.0

 @description:

*)


{

ReradBoot
ReadConfig
ReadSector
WriteBoot
WriteSector

}

interface

	procedure ReadBoot(devnum: byte; var buf); assembler;
	function ReadConfig (devnum: byte): cardinal; assembler;
	procedure ReadSector (devnum: byte; sector: word; var buf); assembler;
	procedure WriteBoot(devnum: byte; var buf); assembler;
	procedure WriteSector(devnum: byte; sector: word; var buf); assembler;

implementation


function ReadConfig(devnum: byte): cardinal; assembler;
(*
@description:
Read disk drive configuration

@param: devnum - device number

@result: cardinal
*)

{
DVSTAT
Byte 0 ($02ea):
Bit 0:Indicates the last command frame had an error.
Bit 1:Checksum, indicates that there was a checksum error in the last command or data frame
Bit 2:Indicates that the last operation by the drive was in error.
Bit 3:Indicates a write protected diskette. 1=Write protect
Bit 4:Indicates the drive motor is on. 1=motor on
Bit 5:A one indicates MFM format (double density)
Bit 6:Not used
Bit 7:Indicates Density and a Half if 1

Byte 1 ($02eb):
Bit 0:FDC Busy should always be a 1
Bit 1:FDC Data Request should always be 1
Bit 2:FDC Lost data should always be 1
Bit 3:FDC CRC error, a 0 indicates the last sector read had a CRC error
Bit 4:FDC Record not found, a 0 indicates last sector not found
Bit 5:FDC record type, a 0 indicates deleted data mark
Bit 6:FDC write protect, indicates write protected disk
Bit 7:FDC door is open, 0 indicates door is open

Byte 2 ($2ec):
Timeout value for doing a format.

Byte 3 ($2ed):
not used, should be zero
}
asm
{	txa:pha

	lda devnum
	m@call	@sio.devnrm
	tya
	bmi _err

	lda #'S'	; odczyt statusu stacji
	sta dcmnd

	m@call	jdskint	; $e453
	tya
	bmi _err

	ldx <256	; 256 bajtow
	ldy >256	; w sektorze

	lda dvstat
	and #%00100000
	bne _skp

	ldx <128	;128 bajtow
	ldy >128	;w sektorze

_skp	m@call	@sio.devsec

	mva dvstat result
	mva dvstat+1 result+1
	mva dvstat+2 result+2
	mva dvstat+3 result+3

	ldy #1

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure ReadSector(devnum: byte; sector: word; var buf); assembler;
(*
@description:
Read disk sector to buffer

@param: devnum - device number
@param: sector - sector number
@param: buf - pointer to buffer
*)
asm
{	txa:pha

	lda devnum
	m@call	@sio.devnrm
	tya
	bmi _err

	lda sector
	sta daux1
	lda sector+1
	sta daux2

	ldx buf
	ldy buf+1
	lda #'R'	; $52 - Get Sector

	m@call	@sio

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure WriteSector(devnum: byte; sector: word; var buf); assembler;
(*
@description:
Write disk sector from buffer

@param: devnum - device number
@param: sector - sector number 1..
@param: buf - pointer to buffer
*)
asm
{	txa:pha

	lda devnum
	m@call	@sio.devnrm
	tya
	bmi _err

	lda sector
	sta daux1
	lda sector+1
	sta daux2

	ldx buf
	ldy buf+1
	lda #'P'	; $50 - Put Sector, without verify

	m@call	@sio

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure ReadBoot(devnum: byte; var buf); assembler;
(*
@description:
Write disk sector 1-3 from buffer

@param: devnum - device number
@param: buf - pointer to buffer
*)
asm
{	txa:pha

	lda devnum
	m@call	@sio.devnrm
	tya
	bmi _err

	lda <1
	sta daux1
	lda >1
	sta daux2

lp	ldx buf
	ldy buf+1
	lda #'R'	; $52 - Get Sector

	m@call	@sio.boot
	tya
	bmi _err

	adw buf #128

	inc daux1
	lda daux1
	cmp #4
	bne lp

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure WriteBoot(devnum: byte; var buf); assembler;
(*
@description:
Write disk sector 1-3 from buffer

@param: devnum - device number
@param: buf - pointer to buffer
*)
asm
{	txa:pha

	lda devnum
	m@call	@sio.devnrm
	tya
	bmi _err

	lda <1
	sta daux1
	lda >1
	sta daux2

lp	ldx buf
	ldy buf+1
	lda #'P'	; $50 - Put Sector, without verify

	m@call	@sio.boot
	tya
	bmi _err

	adw buf #128

	inc daux1
	lda daux1
	cmp #4
	bne lp

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


end.
