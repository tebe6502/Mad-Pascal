
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
;
; Size cannot be known before assembly (macros, .align, .rept etc. may
; change the emitted byte count). We use a forward reference `len` in
; the XEX header; MADS resolves it on the second pass. This measures
; the actual emitted bytes, not the file size — which is what we need.
; -----------------------------------------------------------------------
.macro	RCASM (nam, lab)

	ift main.%%lab >= CODEORIGIN && main.%%lab < PROGRAMSTACK
	 ert 'RCASM: Overlap memory with program code'
	eif

	; Forward reference `len` — resolved by MADS on 2nd pass
	org [a(main.%%lab), a(main.%%lab + len - 1)], main.%%lab

	icl %%1

	len = * - main.%%lab

	.print '$R RCASM   ', main.%%lab, '..', main.%%lab + len - 1, " %%1"

.endm


; -----------------------------------------------------------------------
; RCDATA — raw binary file, starting at offset %%ofs
;
; Size is known upfront (filesize - offset), so `end` in the XEX header
; can be computed directly.
; -----------------------------------------------------------------------
.macro	RCDATA (nam, lab, ofs)

	; Guard: resource must not overlap the program's code/data segment
	ift main.%%lab >= CODEORIGIN && main.%%lab < PROGRAMSTACK
	 ert 'RCDATA: Overlap memory'
	eif

len = .filesize(%%1) - %%ofs

	; Emit XEX header + assemble data at target address
	org [a(main.%%lab), a(main.%%lab + len - 1)], main.%%lab

	ins %%1, %%ofs

	.print '$R RCDATA  ', main.%%lab, '..', main.%%lab + len - 1, " %%1"

.endm

	opt l+


