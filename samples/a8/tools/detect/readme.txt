            org $c000  

             dta $9B
tNameQMEG   dta c "QMEG-OS?RC01"
               dta $9B


            org $C000
;
            dta $9B
            dta c "QMEG-OS 4.04"
            dta $9B



ale test stereo to masz przegięcie na maksa, przecież drugi pokey to nie tylko dźwięk  :D

minimum

          ldx #'s' 
          lda KBCODE             ; AD 09 D2
          cmp $D219              ; CD 19 D2
          bne TstStereo
          ldx #"m"
TstStereo


albo


; c=1 -> stereo present
sys.checkStereo equ *
                lda $d209
                beq sys.checkStereo_1
                lda $d219
                beq sys.checkStereo_OK
sys.checkStereo_BAD equ *
                clc
                rts
sys.checkStereo_1 equ *
                ldy #$07
                lda $d210,y
                bne sys.checkStereo_BAD
                dey
                bpl *-6
sys.checkStereo_OK equ *
                sec
                rts

