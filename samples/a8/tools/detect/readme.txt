SOPHIA $D01E (R)
    Bit    - 7 -     - 6 -     - 5 -     - 4 -     - 3 -     - 2 -     - 1 -     - 0
SOPHIA7 SOPHIA6  SOPHIA5  SOPHIA4  SOPHIA3  SOPHIA2  SOPHIA1  SOPHIA0
Initial 0     1     0     1     0     0     1     1
Ten rejestr służy do wykrycia obecności SOPHII w systemie. Zawiera stałą wartość 53 hex (“S”).






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

