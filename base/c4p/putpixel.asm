
.proc	@putpixel

	lda (:bp2),y
msk	and #$00
	sta (:bp2),y

	rts

c_and	dta 7
c_idx	dta 0

c0	dta $80^$ff,$40^$ff,$20^$ff,$10^$ff,$08^$ff,$04^$ff,$02^$ff,$01^$ff
c1	dta $80,$40,$20,$10,$08,$04,$02,$01

.endp
