
	opt l-

; -----------------------------------------------------------------------
; X65 resources
;
; Supported: RCDATA, RCASM
;
; Each resource becomes a separate XEX segment. This is required because
; X65 target uses `f-` (no gap fill) and `h-` (no auto headers) — every
; segment must be explicitly declared with:
;
;     org [a(start), a(end-1)], start
;
; -----------------------------------------------------------------------


; -----------------------------------------------------------------------
; RCASM — MADS assembly source file
; -----------------------------------------------------------------------
.macro	RCASM (nam, lab)

	ift main.%%lab >= CODEORIGIN && main.%%lab < PROGRAMSTACK
	 ert 'RCASM: Overlap memory with program code'
	eif

	; Forward reference — `len_%%lab`
	org [a(main.%%lab), a(main.%%lab + len_%%lab - 1)], main.%%lab

	icl %%nam

	len_%%lab = * - main.%%lab

	.print '$R RCASM   ', main.%%lab, '..', main.%%lab + len_%%lab - 1, " %%nam"

.endm


; -----------------------------------------------------------------------
; RCDATA — raw binary file, starting at offset %%ofs
; -----------------------------------------------------------------------
.macro	RCDATA (nam, lab, ofs)

	ift main.%%lab >= CODEORIGIN && main.%%lab < PROGRAMSTACK
	 ert 'RCDATA: Overlap memory'
	eif

	len_%%lab = .filesize(%%nam) - %%ofs

	org [a(main.%%lab), a(main.%%lab + len_%%lab - 1)], main.%%lab

	ins %%nam, %%ofs

	.print '$R RCDATA  ', main.%%lab, '..', main.%%lab + len_%%lab - 1, " %%nam"

.endm

	opt l+
