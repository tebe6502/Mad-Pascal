	lda $d018
	ora #$0e       ; set chars location to $3800 for displaying the custom font
	sta $d018      ; Bits 1-3 ($400+512bytes * low nibble value) of $d018 sets char location
                       ; $400 + $200*$0E = $3800

	lda $d016      ; turn off multicolor for characters
	and #$ef       ; by cleaing Bit#4 of $D016
	sta $d016
