levels_list
    dta a(level_1_1)        ;1  ; ORIGINAL PAC MAN      - easy
    ;dta a(0)
    dta a(level_1_2)        ;2  ; ORIGINAL MS PAC MAN   - easy
    dta a(level_2)          ;3  ; CROSS RECTANGLES      - easy
    dta a(level_7)          ;4  ; diamonds              - easy
    dta a(level_19)         ;5  ; boxes                 - easy
    dta a(level_20)         ;6  ; big X                 - easy
    dta a(level_15)         ;7  ; zxmas tree            - easy tactics
    dta a(level_22)         ;8  ; boomerang             - easy
    dta a(level_26)         ;9  ; warp madness          - easy (keep left-up pressed)
    dta a(level_10)         ;10 ; HUGE LEVEL            - not so hard at all

    dta a(level_3)          ;11 ; cross hatch           - medium
    dta a(level_4)          ;12 ; mandala               - medium
    dta a(level_5)          ;13 ; circla 1              - medium
    dta a(level_13)         ;14 ; cowboy                - medium
    dta a(level_11)         ;15 ; 3 sections            - medium dificulty
    dta a(level_12)         ;16 ; crowned snake         - medium tactics
    dta a(level_24)         ;17 ; butterfly             - medium - tricky, no pill (do it quick)
    dta a(level_17)         ;18 ; atari                 - medium tactics
    dta a(level_25)         ;19 ; chaos maze            - medium tactics
    dta a(level_23)         ;20 ; snake                 - medium hard

    dta a(level_21)         ;21 ; azteca                - hard
    dta a(level_28)         ;22 ; square bubbles        - hard
    dta a(level_6)          ;23 ; SQUARES 2             - HARD  !!!
    dta a(level_29)         ;24 ; carpet clean          - hard
    dta a(level_9)          ;25 ;                       - hard
    dta a(level_14)         ;26 ; whatta mess           - hard
    dta a(level_27)         ;27 ; curved pipes          - hard! - keep running (pill is a trap)
    dta a(level_16)         ;28 ; heart                 - hard hard hard -
    dta a(level_18)         ;29 ; serpent runner        - hard tactics
    dta a(level_8)          ;30 ; boxes                 - HARD !!! tactics

    dta a(0)

TILE_VOID = 0;
TILE_DOT = 1;
TILE_EMPTY = 2;
TILE_PILL = 3;
TILE_SPAWNER = 4;
TILE_SPAWNER_OPEN1 = 5;
TILE_SPAWNER_OPEN2 = 6;
TILE_WARP_RIGHT = 7;
TILE_WARP_LEFT = 8;
TILE_EXIT = 9;
TILE_EXIT_OPEN = 10;

COLOR_PACMAD = $1c;

;;;;;;;;;;;;;;;;;;;;;;;;;; ORIGINAL PAC MAN
.local level_1_1
    dta 10,14 ; starting pos - x,y
    dta 10,4 ; exit pos - x,y
    dta 2,2,2,2    ; ghost AI level (1 dumbest .. 9 deadly)
    dta 5    ; ghost spawner delay in seconds
    dta 10    ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $8C,$84,$00,COLOR_PACMAD,$82 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,4,5,3
    dta 15,4,5,3
    dta 7,4,7,3
    dta 11,1,9,4
    dta 1,1,9,4
    dta 5,4,11,11
    dta 1,12,19,7
    dta 7,14,7,3
    dta 9,16,3,3
    dta 9,12,3,3
    dta 1,14,3,3
    dta 17,14,3,3
    dta 3,14,3,3
    dta 15,14,3,3
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 9,7,3,4
    dta 7,8,7,3
    dta 14,9,6,1
    dta 1,9,6,1
    dta 7,11,1,1
    dta 13,11,1,1
empty_end

; void
    dta TILE_VOID,[void_end-(* + 1)]/4
    dta 10,6,1,2
    dta 19,15,1,1
    dta 1,15,1,1
    dta 10,16,1,1
    dta 10,12,1,1
    dta 16,14,1,1
    dta 4,14,1,1
void_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 19,14
    dta 1,14
    dta 1,2
    dta 19,2
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,9
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 9
warps_end

    dta $ff
.endl ; level size: 145 bytes

;;

;;;;;;;;;;;;;;;;;;;;;;;;;; ORIGINAL MS PAC MAN

.local level_1_2
    dta 10,14 ; starting pos - x,y
    dta 10,3 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $8c,$84,$00,COLOR_PACMAD,$82 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,5,3
    dta 15,1,5,3
    dta 7,1,7,3
    dta 5,3,11,4
    dta 9,3,3,4
    dta 3,3,15,10
    dta 13,12,5,3
    dta 3,12,5,3
    dta 5,14,11,5
    dta 7,16,7,3
    dta 9,14,3,3
    dta 15,14,5,5
    dta 1,14,5,5
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 13,7,1,1
    dta 7,7,1,1
    dta 7,8,7,3
    dta 9,10,1,2
    dta 11,11,1,1
    dta 14,8,2,1
    dta 15,9,1,2
    dta 16,10,1,1
    dta 18,10,2,1
    dta 5,8,2,1
    dta 5,9,1,2
    dta 4,10,1,1
    dta 1,10,2,1
    dta 4,8,1,1
    dta 16,8,1,1
    dta 18,6,2,1
    dta 1,6,2,1
empty_end

; void
    dta TILE_VOID,[void_end-(* + 1)]/4
    dta 10,6,1,1
    dta 10,12,1,1
    dta 10,16,1,1
void_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 19,2
    dta 1,2
    dta 1,17
    dta 19,17
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,9
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 6
    dta 10
warps_end

    dta $ff
.endl ; level size: 170 bytes


;;;;;;;;;;;;;;;;;;;;; CROSS RECTANGLES   ;; easy
.local level_2
    dta 10,10 ; starting pos - x,y
    dta 10,5 ; exit pos - x,y
    dta 2,2,2,2 ; ghost AI level (1 dumbest .. 9 deadly)
    dta 5    ; ghost spawner delay in seconds
    dta 10    ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $bC,$b4,$00,COLOR_PACMAD,$b2 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,19,14
    dta 3,3,15,10
    dta 2,5,17,1
    dta 2,10,17,1
    dta 5,2,1,13
    dta 15,2,1,12
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 17,12
    dta 17,3
    dta 3,3
    dta 3,12
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,6
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 5
    dta 10
warps_end

    dta $ff
.endl ; level size: 58 bytes



;;;;;;;;;;;;;;;;;;;;; cross hatch    ;;; medium
.local level_3
    dta 10,20 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 3,3,3,3    ; ghost AI level (1 dumbest .. 9 deadly)
    dta 5    ; ghost spawner delay in seconds
    dta 10    ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $5C,$54,$00,COLOR_PACMAD,$52 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 9,2,3,17
    dta 7,4,7,13
    dta 5,6,11,9
    dta 3,8,15,5
    dta 1,10,19,1
    dta 10,19,1,2
    dta 10,0,1,2
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 5,6
    dta 15,14
    dta 15,6
    dta 5,14
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,10
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 10
warps_end

    dta $ff
.endl ; level size: 61 bytes



;;;;;;;;;;;;;;;;;;;;;;;  mandala  ;;;, medium

.local level_4
    dta 10,28 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 3,3,3,3    ; ghost AI level (1 dumbest .. 9 deadly)
    dta 5    ; ghost spawner delay in seconds
    dta 10    ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $2C,$24,$00,COLOR_PACMAD,$22 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 8,1,5,7
    dta 6,3,9,3
    dta 1,4,5,1
    dta 15,4,5,1
    dta 10,8,1,3
    dta 8,11,5,7
    dta 6,13,9,3
    dta 1,14,5,1
    dta 15,14,5,1
    dta 14,7,5,5
    dta 2,7,5,5
    dta 4,5,1,2
    dta 4,12,1,2
    dta 16,12,1,2
    dta 16,5,1,2
    dta 11,9,3,1
    dta 7,9,3,1
    dta 8,21,5,7
    dta 6,23,9,3
    dta 10,18,1,3
    dta 15,24,5,1
    dta 1,24,5,1
    dta 2,17,5,5
    dta 14,17,5,5
    dta 4,15,1,2
    dta 4,22,1,2
    dta 16,22,1,2
    dta 16,15,1,2
    dta 7,19,3,1
    dta 11,19,3,1
    dta 10,28,1,1
    dta 10,0,1,1
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 2,9
    dta 2,19
    dta 18,19
    dta 18,9
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,24
    dta 10,14
    dta 10,4
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 4
    dta 14
    dta 24
warps_end

    dta $ff
.endl ; level size: 167 bytes


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; circla 1    ;; medium
.local level_5
    dta 10,16 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 4,4,4,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $fc,$f4,$00,COLOR_PACMAD,$f2 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 6,1,9,1
    dta 4,2,3,1
    dta 14,2,3,1
    dta 3,3,2,1
    dta 16,3,2,1
    dta 3,4,1,2
    dta 17,4,1,2
    dta 2,5,1,7
    dta 18,5,1,7
    dta 17,11,1,3
    dta 3,11,1,3
    dta 4,13,1,2
    dta 16,13,1,2
    dta 5,14,2,1
    dta 14,14,2,1
    dta 6,15,9,1
    dta 1,8,19,1
    dta 6,3,9,11
    dta 8,5,5,7
    dta 10,0,1,1
    dta 10,16,1,1
    dta 10,4,1,9
    dta 4,5,2,1
    dta 4,11,2,1
    dta 15,5,2,1
    dta 15,11,2,1
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 4,3
    dta 16,13
    dta 10,8
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 16,7
    dta 4,7
    dta 4,9
    dta 16,9
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 8
warps_end

    dta $ff
.endl ; level size: 141 bytes




;;;;;;;;;;;;;;;;;;;;;;;; SQUARES 2 ----          HARD  !!!
.local level_6
    dta 10,17 ; starting pos - x,y
    dta 10,1 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $cc,$c4,$00,COLOR_PACMAD,$c2 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 2,1,17,17
    dta 2,3,17,13
    dta 4,1,13,17
    dta 6,3,9,13
    dta 4,5,13,9
    dta 19,3,1,1
    dta 1,3,1,1
    dta 1,15,1,1
    dta 19,15,1,1
    dta 17,9,1,1
    dta 3,9,1,1
    dta 10,2,1,1
    dta 10,16,1,1
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 8,7,5,5
    dta 7,9,7,1
    dta 10,6,1,7
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 6,5
    dta 14,13
    dta 4,15
    dta 16,3
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,9
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 15
    dta 3
warps_end

    dta $ff
.endl ; level size: 100 bytes



;;;;;;;;;;;;;;;;;;;;;;;; diamonds   ;;; easy
.local level_7
    dta 10,20 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $5c,$54,$00,COLOR_PACMAD,$52 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 10,0,1,2
    dta 9,1,1,2
    dta 11,1,1,2
    dta 8,2,1,2
    dta 12,2,1,2
    dta 7,3,1,2
    dta 13,3,1,2
    dta 6,4,1,2
    dta 14,4,1,2
    dta 5,5,1,2
    dta 15,5,1,2
    dta 4,6,1,2
    dta 16,6,1,2
    dta 3,7,1,2
    dta 17,7,1,2
    dta 2,8,1,2
    dta 18,8,1,2
    dta 1,9,1,3
    dta 19,9,1,3
    dta 2,11,1,2
    dta 18,11,1,2
    dta 3,12,1,2
    dta 17,12,1,2
    dta 4,13,1,2
    dta 16,13,1,2
    dta 5,14,1,2
    dta 15,14,1,2
    dta 6,15,1,2
    dta 14,15,1,2
    dta 13,16,1,2
    dta 7,16,1,2
    dta 8,17,1,2
    dta 12,17,1,2
    dta 9,18,1,2
    dta 11,18,1,2
    dta 10,19,1,2
    dta 5,5,11,11
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 6,10,9,1
    dta 10,6,1,9
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 15,15
    dta 5,5
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,10
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 10
warps_end

    dta $ff
.endl ; level size: 187 bytes


;;;;;;;;;;;;;;;;;;;;;;;;;;; boxes   ---  HARD !!! tactics
.local level_8
    dta 10,44 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 3,2,4,5 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $1c,$14,$00,COLOR_PACMAD,$12 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 10,0,1,1
    dta 9,1,3,3
    dta 9,5,3,3
    dta 10,4,1,1
    dta 5,5,3,3
    dta 13,5,3,3
    dta 5,9,3,3
    dta 9,9,3,3
    dta 13,9,3,3
    dta 17,9,3,3
    dta 1,9,3,3
    dta 8,6,1,1
    dta 12,6,1,1
    dta 6,8,1,1
    dta 14,8,1,1
    dta 4,10,1,1
    dta 16,10,1,1
    dta 9,13,3,3
    dta 5,13,3,3
    dta 13,13,3,3
    dta 10,12,1,1
    dta 10,8,1,1
    dta 8,14,1,1
    dta 12,14,1,1
    dta 6,12,1,1
    dta 14,12,1,1
    dta 9,17,3,3
    dta 10,16,1,1
    dta 10,20,1,1
    dta 8,21,5,5
    dta 10,26,1,1
    dta 7,27,7,7
    dta 6,35,9,9
    dta 10,34,1,1
    dta 14,22,3,3
    dta 4,22,3,3
    dta 7,23,1,1
    dta 13,23,1,1
    dta 3,29,3,3
    dta 15,29,3,3
    dta 6,30,1,1
    dta 14,30,1,1
    dta 9,29,3,3
    dta 2,17,3,3
    dta 16,17,3,3
    dta 4,20,1,2
    dta 16,20,1,2
    dta 18,12,1,5
    dta 2,12,1,5
    dta 1,30,2,1
    dta 18,30,2,1
    dta 16,32,1,8
    dta 15,39,1,1
    dta 5,39,1,1
    dta 4,32,1,8
    dta 8,37,5,5
    dta 8,36,1,1
    dta 12,36,1,1
    dta 7,41,1,1
    dta 13,41,1,1
    dta 10,44,1,1
    dta 10,32,1,1
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 2,19
    dta 18,19
    dta 3,29
    dta 17,29
    dta 10,4
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,30
    dta 10,10
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 10
    dta 30
warps_end

    dta $ff
.endl ; level size: 286 bytes



.local level_9                           ; HARD
    dta 10,32 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 5,3,4,5 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $8c,$84,$00,COLOR_PACMAD,$82 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 7,3,7,5
    dta 1,5,6,1
    dta 14,5,6,1
    dta 5,6,1,4
    dta 15,6,1,4
    dta 6,9,9,5
    dta 4,11,5,5
    dta 12,11,5,5
    dta 1,13,3,1
    dta 17,13,3,1
    dta 10,14,1,7
    dta 6,17,3,3
    dta 12,17,3,3
    dta 6,16,1,1
    dta 14,16,1,1
    dta 2,17,3,7
    dta 16,17,3,7
    dta 2,14,1,3
    dta 18,14,1,3
    dta 5,19,1,1
    dta 15,19,1,1
    dta 6,21,9,7
    dta 1,25,5,1
    dta 15,25,5,1
    dta 8,23,5,8
    dta 8,8,1,1
    dta 12,8,1,1
    dta 10,0,1,1
    dta 9,1,3,5
    dta 10,27,1,6
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 10,26,1,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 10,21
    dta 4,13
    dta 16,13
    dta 10,3
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,25
    dta 10,8
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 13
    dta 5
    dta 25
warps_end

    dta $ff
.endl ; level size: 163 bytes


;;;;;;;;;;;;;;;;;;;;;;;;   HUGE LEVEL           ;;; not so hard at all
.local level_10
    dta 10,91 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 6,5,4,3    ; ghost AI level (1 dumbest .. 9 deadly)
    dta 5    ; ghost spawner delay in seconds
    dta 10    ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $bC,$b8,$00,COLOR_PACMAD,$b4 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 9,1,3,3
    dta 6,3,9,5
    dta 3,5,15,7
    dta 1,9,19,1
    dta 8,7,5,11
    dta 6,13,9,3
    dta 2,15,5,5
    dta 14,15,5,5
    dta 6,19,9,9
    dta 1,17,1,1
    dta 19,17,1,1
    dta 16,21,3,11
    dta 2,21,3,11
    dta 6,29,9,3
    dta 10,28,1,1
    dta 5,30,1,1
    dta 15,30,1,1
    dta 15,25,1,1
    dta 5,25,1,1
    dta 3,20,1,1
    dta 17,20,1,1
    dta 3,33,15,5
    dta 3,32,1,1
    dta 17,32,1,1
    dta 10,32,1,1
    dta 1,35,2,1
    dta 18,35,2,1
    dta 5,35,11,7
    dta 2,39,17,11
    dta 4,43,13,5
    dta 7,42,1,1
    dta 13,42,1,1
    dta 6,45,9,9
    dta 3,45,1,1
    dta 17,45,1,1
    dta 2,1,5,5
    dta 14,1,5,5
    dta 16,51,4,5
    dta 1,51,4,5
    dta 5,55,11,5
    dta 5,52,1,1
    dta 15,52,1,1
    dta 10,54,1,1
    dta 3,57,15,5
    dta 7,60,1,1
    dta 13,60,1,1
    dta 5,61,11,7
    dta 7,63,7,3
    dta 16,64,4,1
    dta 1,64,4,1
    dta 6,65,1,1
    dta 14,63,1,1
    dta 13,66,1,1
    dta 7,62,1,1
    dta 1,66,3,9
    dta 17,66,3,9
    dta 5,69,11,3
    dta 5,73,5,5
    dta 11,73,5,5
    dta 7,72,1,1
    dta 13,72,1,1
    dta 16,70,1,1
    dta 4,70,1,1
    dta 2,65,1,1
    dta 18,65,1,1
    dta 10,68,1,1
    dta 4,74,1,1
    dta 16,74,1,1
    dta 7,75,7,5
    dta 2,77,4,9
    dta 15,77,4,9
    dta 7,81,7,9
    dta 3,87,15,5
    dta 17,86,1,1
    dta 3,86,1,1
    dta 6,81,1,1
    dta 14,81,1,1
    dta 1,79,1,1
    dta 19,79,1,1
    dta 18,89,2,1
    dta 1,89,2,1
    dta 9,83,3,3
    dta 8,84,1,1
    dta 12,84,1,1
    dta 8,90,1,1
    dta 12,90,1,1
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 10,0,1,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 2,15
    dta 18,15
    dta 2,1
    dta 18,1
    dta 15,25
    dta 5,25
    dta 5,35
    dta 15,35
    dta 4,47
    dta 16,47
    dta 15,67
    dta 5,67
    dta 5,59
    dta 15,59
    dta 5,73
    dta 15,73
    dta 2,85
    dta 18,85
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,6
    dta 10,18
    dta 10,26
    dta 10,42
    dta 10,76
    dta 10,60
    dta 10,52
    dta 10,84
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 9
    dta 17
    dta 35
    dta 64
    dta 51
    dta 55
    dta 79
    dta 89
warps_end

    dta $ff
.endl ; level size: 432 bytes


; 3 sections - medium dificulty

.local level_11
    dta 10,48 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 2,2,2,2 ; ghost AI levels (1 dumb - 9 ninja)
    dta 6    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $8c,$84,$00,COLOR_PACMAD,$82 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 2,1,17,7
    dta 4,3,13,3
    dta 6,1,9,9
    dta 15,9,5,1
    dta 1,9,4,1
    dta 4,9,1,3
    dta 4,11,13,5
    dta 2,13,17,5
    dta 6,13,9,9
    dta 8,19,5,7
    dta 16,19,3,5
    dta 2,19,3,5
    dta 5,23,11,5
    dta 16,25,4,1
    dta 1,25,3,1
    dta 3,25,1,5
    dta 3,29,15,3
    dta 17,18,1,1
    dta 3,18,1,1
    dta 2,33,3,3
    dta 16,33,3,3
    dta 12,33,3,3
    dta 6,33,3,3
    dta 3,32,1,1
    dta 17,32,1,1
    dta 5,34,1,1
    dta 15,34,1,1
    dta 9,34,3,1
    dta 3,37,15,3
    dta 10,35,1,2
    dta 6,37,9,7
    dta 16,41,4,5
    dta 1,41,4,5
    dta 10,39,1,10
    dta 5,43,1,1
    dta 15,43,1,1
    dta 6,45,3,3
    dta 12,45,3,3
    dta 4,43,3,3
    dta 14,43,3,3
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 10,0,1,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 18,19
    dta 2,19
    dta 3,39
    dta 17,39
    dta 2,33
    dta 18,33
    dta 2,9
    dta 2,25
    dta 18,4
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,4
    dta 10,14
    dta 10,26
    dta 10,32
    dta 10,38
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 9
    dta 25
warps_end

    dta $ff
.endl ; level size: 218 bytes


; crowned snake - medium tactics

.local level_12
    dta 10,48 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 4    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $4c,$64,$00,COLOR_PACMAD,$72 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 10,1,1,2
    dta 1,2,9,1
    dta 12,2,8,1
    dta 12,3,1,2
    dta 1,4,11,1
    dta 14,4,6,1
    dta 14,5,1,2
    dta 1,6,13,1
    dta 16,6,4,1
    dta 2,8,17,5
    dta 16,7,1,1
    dta 6,8,9,9
    dta 4,10,13,5
    dta 9,12,3,11
    dta 13,18,6,5
    dta 2,18,6,5
    dta 4,20,13,5
    dta 2,42,9,5
    dta 10,38,9,5
    dta 10,46,1,3
    dta 10,23,1,15
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 1,50,19,1
    dta 10,0,1,1
empty_end

; void
    dta TILE_VOID,[void_end-(* + 1)]/4
    dta 10,43,1,3
    dta 10,39,1,3
void_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 10,16
    dta 10,12
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,13
    dta 10,50
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 50
    dta 2
    dta 4
    dta 6
warps_end

    dta $ff
.endl ; level size: 138 bytes


; cowboy ; medium


.local level_13
    dta 1,0 ; starting pos - x,y
    dta 19,34 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $ac,$b4,$00,COLOR_PACMAD,$e4 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,0,1,1
    dta 1,1,19,5
    dta 6,3,9,7
    dta 1,3,3,9
    dta 17,3,3,9
    dta 8,7,5,5
    dta 3,11,4,4
    dta 14,11,4,4
    dta 6,13,8,1
    dta 6,15,9,7
    dta 4,21,3,5
    dta 14,21,3,5
    dta 2,25,4,7
    dta 15,25,4,7
    dta 8,17,5,7
    dta 1,31,19,3
    dta 19,34,1,1
    dta 19,0,1,1
dots_end

; void
    dta TILE_VOID,[void_end-(* + 1)]/4
    dta 2,1,17,1
    dta 2,33,17,1
void_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 8,7
    dta 12,7
    dta 4,21
    dta 16,21
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,18
    dta 19,0
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 5
    dta 1
    dta 31
    dta 33
warps_end

    dta $ff
.endl ; level size: 120 bytes


; whatta mess - hard

.local level_14
    dta 7,35 ; starting pos - x,y
    dta 19,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 16   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $1c,$26,$00,COLOR_PACMAD,$32 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 19,0,1,2
    dta 15,1,5,5
    dta 9,3,9,5
    dta 5,1,8,5
    dta 3,3,5,7
    dta 1,7,5,3
    dta 9,9,11,5
    dta 5,11,13,7
    dta 1,13,7,7
    dta 3,15,7,7
    dta 11,15,5,5
    dta 9,19,3,3
    dta 15,19,5,5
    dta 2,23,12,3
    dta 1,25,2,1
    dta 19,25,1,3
    dta 1,27,18,1
    dta 1,28,1,2
    dta 3,29,17,1
    dta 3,30,1,2
    dta 1,31,2,1
    dta 5,31,15,1
    dta 5,32,1,2
    dta 1,33,4,1
    dta 7,33,13,1
    dta 7,33,1,3
    dta 13,21,3,3
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 15,25,1,2
    dta 17,25,1,2
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 1,9
    dta 1,19
    dta 17,25
    dta 15,25
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 18,17
    dta 3,10
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 9
    dta 33
    dta 31
    dta 29
    dta 25
    dta 19
warps_end

    dta $ff
.endl ; level size: 158 bytes



;; zxmas tree - easy tactics

.local level_15
    dta 10,35 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $ec,$d8,$00,COLOR_PACMAD,$b2 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 10,0,1,3
    dta 7,6,7,7
    dta 5,10,11,7
    dta 3,14,15,7
    dta 1,18,19,7
    dta 3,22,15,5
    dta 9,2,3,27
    dta 13,28,6,6
    dta 2,28,6,6
    dta 9,28,3,3
    dta 4,30,13,6
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 10,28
    dta 10,24
    dta 10,20
    dta 10,16
    dta 10,12
    dta 10,6
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,30
    dta 10,26
    dta 10,22
    dta 10,18
    dta 10,14
    dta 10,10
spawners_end

    dta $ff
.endl ; level size: 88 bytes



; heart - hard hard hard -

.local level_16
    dta 10,15 ; starting pos - x,y
    dta 10,5 ; exit pos - x,y
    dta 7,7,7,7 ; ghost AI levels (1 dumb - 9 ninja)
    dta 3    ; ghost spawner delay in seconds
    dta 5   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $3b,$36,$00,COLOR_PACMAD,$32 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 9,4,3,1
    dta 11,3,2,1
    dta 8,3,2,1
    dta 7,2,2,1
    dta 4,1,4,1
    dta 12,2,2,1
    dta 13,1,4,1
    dta 16,2,2,1
    dta 17,3,2,1
    dta 3,2,2,1
    dta 2,3,2,1
    dta 2,4,1,3
    dta 18,4,1,3
    dta 17,6,1,3
    dta 3,6,1,3
    dta 4,8,1,3
    dta 16,8,1,3
    dta 5,10,1,2
    dta 15,10,1,2
    dta 6,11,1,2
    dta 14,11,1,2
    dta 7,12,1,2
    dta 13,12,1,2
    dta 8,13,5,1
    dta 9,14,3,1
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 10,5,1,1
    dta 10,15,1,1
empty_end

; void
    dta TILE_VOID,[void_end-(* + 1)]/4
    dta 10,13,1,1
void_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 10,4
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 2,7
    dta 17,4
spawners_end

    dta $ff
.endl ; level size: 142 bytes



; atari - medium tactics


.local level_17
    dta 10,1 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 4    ; ghost spawner delay in seconds
    dta 7   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $9e,$96,$00,COLOR_PACMAD,$92 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 8,2,1,10
    dta 8,9,1,1
    dta 7,9,1,5
    dta 6,11,1,4
    dta 4,12,2,4
    dta 10,2,1,14
    dta 2,13,2,3
    dta 12,2,1,10
    dta 13,9,1,5
    dta 14,11,1,4
    dta 15,12,2,4
    dta 17,13,2,3
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 10,0,1,2
    dta 8,1,5,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 2,15
    dta 18,15
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,15
spawners_end

    dta $ff
.endl ; level size: 84 bytes


; serpent runner - hard tactics

.local level_18
    dta 10,43 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $1d,$d6,$00,COLOR_PACMAD,$e4 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 2,1,11,5
    dta 8,3,11,7
    dta 3,7,10,7
    dta 8,11,10,7
    dta 4,15,9,7
    dta 8,19,9,7
    dta 5,23,8,7
    dta 8,27,8,7
    dta 6,31,7,7
    dta 8,35,7,5
    dta 10,0,1,1
    dta 10,39,1,5
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 12,31
    dta 12,23
    dta 12,15
    dta 12,7
    dta 12,1
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,36
    dta 10,28
    dta 10,20
    dta 10,12
    dta 10,4
spawners_end

    dta $ff
.endl ; level size: 88 bytes



;; boxes - easy

.local level_19
    dta 10,15 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 6    ; ghost spawner delay in seconds
    dta 12   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $fc,$26,$00,COLOR_PACMAD,$42 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,5,5
    dta 15,1,5,5
    dta 7,1,7,7
    dta 3,3,15,7
    dta 3,7,15,7
    dta 7,9,7,7
    dta 1,11,5,5
    dta 15,11,5,5
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 18,8,2,1
    dta 1,8,2,1
    dta 10,0,1,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 1,15
    dta 19,1
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,8
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 8
warps_end

    dta $ff
.endl ; level size: 75 bytes


;; big X - easy

.local level_20
    dta 10,13 ; starting pos - x,y
    dta 10,7 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $ac,$94,$00,COLOR_PACMAD,$82 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,5,5
    dta 15,1,5,5
    dta 13,3,5,5
    dta 3,3,5,5
    dta 5,5,5,5
    dta 11,5,5,5
    dta 7,7,5,5
    dta 9,7,5,5
    dta 9,9,3,5
    dta 9,13,5,5
    dta 7,13,5,5
    dta 5,15,5,5
    dta 11,15,5,5
    dta 13,17,5,5
    dta 3,17,5,5
    dta 1,19,5,5
    dta 15,19,5,5
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 1,1
    dta 19,1
    dta 1,23
    dta 19,23
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,15
    dta 10,9
spawners_end

    dta $ff
.endl ; level size: 105 bytes


;; azteca - hard

.local level_21
    dta 10,33 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 3,4,5,8 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $8e,$86,$00,COLOR_PACMAD,$82 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 2,1,7,3
    dta 12,1,7,3
    dta 10,0,1,6
    dta 4,5,13,3
    dta 6,3,9,7
    dta 2,9,8,3
    dta 11,9,8,3
    dta 6,11,9,5
    dta 1,13,4,4
    dta 16,13,4,4
    dta 4,13,13,5
    dta 6,15,5,7
    dta 10,15,5,7
    dta 8,19,5,10
    dta 5,23,4,3
    dta 12,23,4,3
    dta 14,27,4,3
    dta 3,27,4,3
    dta 15,24,5,4
    dta 1,24,5,4
    dta 10,29,1,5
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 1,6,3,1
    dta 17,6,3,1
    dta 15,19,5,1
    dta 1,19,5,1
empty_end

; void
    dta TILE_VOID,[void_end-(* + 1)]/4
    dta 10,9,1,1
    dta 10,18,1,1
    dta 7,11,2,1
    dta 12,11,2,1
    dta 7,3,1,1
    dta 13,3,1,1
void_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 7,25
    dta 13,25
    dta 18,11
    dta 2,11
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,8
    dta 10,27
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 6
    dta 19
warps_end

    dta $ff
.endl ; level size: 164 bytes


; boomerang easy

.local level_22
    dta 1,37 ; starting pos - x,y
    dta 17,19 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $7c,$66,$00,COLOR_PACMAD,$52 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,6,6
    dta 4,4,6,6
    dta 7,7,6,6
    dta 10,10,6,6
    dta 13,13,6,6
    dta 15,18,5,3
    dta 13,20,6,6
    dta 10,23,6,6
    dta 7,26,6,6
    dta 4,29,6,6
    dta 1,32,6,6
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 17,19,1,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 15,19
    dta 19,19
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 2,36
    dta 2,2
spawners_end

    dta $ff
.endl ; level size: 78 bytes


; snake - medium hard

.local level_23
    dta 10,42 ; starting pos - x,y
    dta 1,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $1c,$16,$00,COLOR_PACMAD,$12 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,3,3
    dta 3,2,3,3
    dta 5,3,3,3
    dta 7,4,3,3
    dta 9,5,3,3
    dta 11,6,3,3
    dta 13,7,3,3
    dta 15,8,3,3
    dta 17,9,3,3
    dta 15,10,3,3
    dta 13,11,3,3
    dta 11,12,3,3
    dta 9,13,3,3
    dta 7,14,3,3
    dta 5,15,3,3
    dta 3,16,3,3
    dta 1,17,3,3
    dta 1,10,11,1
    dta 3,8,5,5
    dta 1,6,3,9
    dta 3,18,3,3
    dta 5,19,3,3
    dta 7,20,3,3
    dta 9,21,3,3
    dta 11,22,3,3
    dta 13,23,3,3
    dta 15,24,3,3
    dta 13,25,3,3
    dta 11,26,3,3
    dta 9,27,3,3
    dta 7,28,3,3
    dta 5,29,3,3
    dta 7,30,3,3
    dta 9,31,3,3
    dta 11,32,3,3
    dta 9,33,3,3
    dta 8,35,3,3
    dta 9,37,3,3
    dta 10,40,1,3
    dta 9,18,11,1
    dta 17,14,3,9
    dta 13,16,5,5
    dta 18,25,2,1
    dta 1,25,9,1
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 1,0,1,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 11,10
    dta 9,18
    dta 9,25
    dta 9,30
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 2,18
    dta 6,30
    dta 2,2
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 10
    dta 18
    dta 25
warps_end

    dta $ff
.endl ; level size: 221 bytes


// butterfly - medium - tricky, no pill (do it quick)

.local level_24
    dta 10,14 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,1,3,5 ; ghost AI levels (1 dumb - 9 ninja)
    dta 11    ; ghost spawner delay in seconds
    dta 10   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $6c,$24,$00,COLOR_PACMAD,$92 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,8,3
    dta 12,1,8,3
    dta 3,3,7,4
    dta 11,3,7,4
    dta 5,6,5,6
    dta 11,6,5,6
    dta 2,11,7,5
    dta 12,11,7,5
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 10,0,1,4
    dta 10,11,1,4
    dta 19,11,1,1
    dta 1,11,1,1
    dta 1,6,2,1
    dta 18,6,2,1
    dta 19,15,1,1
    dta 1,15,1,1
empty_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,4
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 15
    dta 11
    dta 6
    dta 1
warps_end

    dta $ff
.endl ; level size: 92 bytes


;; chaos maze - medium tactics

.local level_25
    dta 10,0 ; starting pos - x,y
    dta 16,3 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 3    ; ghost spawner delay in seconds
    dta 15   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $1c,$16,$00,COLOR_PACMAD,$f2 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 10,0,1,2
    dta 7,1,4,1
    dta 7,1,1,4
    dta 3,3,14,1
    dta 12,2,1,7
    dta 4,6,11,1
    dta 2,1,1,8
    dta 1,8,1,1
    dta 17,8,3,1
    dta 16,5,1,8
    dta 6,10,11,1
    dta 9,5,1,4
    dta 6,8,1,6
    dta 13,10,1,7
    dta 11,14,7,1
    dta 2,12,8,1
    dta 8,13,1,4
    dta 1,16,11,1
    dta 15,16,5,1
    dta 18,15,1,6
    dta 4,14,1,10
    dta 2,18,14,1
    dta 3,22,17,1
    dta 11,16,1,5
    dta 6,20,1,4
    dta 8,20,8,1
    dta 14,20,1,4
    dta 3,10,4,1
    dta 4,6,1,3
    dta 17,10,2,1
    dta 11,12,1,2
    dta 17,12,2,1
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 7,3
    dta 18,15
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 12,1
    dta 16,18
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 16
    dta 8
warps_end

    dta $ff
.endl ; level size: 160 bytes




;; warp madness - easy (keep left-up pressed)

.local level_26
    dta 10,17 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 3,3,3,3 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 8   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $dc,$96,$00,COLOR_PACMAD,$e2 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,10,10,1
    dta 18,10,2,1
    dta 11,9,8,1
    dta 2,8,8,1
    dta 1,7,2,1
    dta 11,7,9,1
    dta 4,6,6,1
    dta 1,5,4,1
    dta 11,5,9,1
    dta 6,4,4,1
    dta 1,3,6,1
    dta 11,3,9,1
    dta 8,2,2,1
    dta 1,1,8,1
    dta 11,1,9,1
    dta 11,11,6,1
    dta 16,12,4,1
    dta 1,12,9,1
    dta 11,13,4,1
    dta 14,14,6,1
    dta 1,14,9,1
    dta 11,15,2,1
    dta 12,16,8,1
    dta 1,16,9,1
    dta 10,0,1,17
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 10,17,1,1
empty_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 10,14
    dta 10,4
    dta 10,9
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 11,16
    dta 9,1
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 16
    dta 14
    dta 12
    dta 10
    dta 7
    dta 5
    dta 3
    dta 1
warps_end

    dta $ff
.endl ; level size: 146 bytes


;; curved pipes - hard! - keep running (pill is a trap)

.local level_27
    dta 15,13 ; starting pos - x,y
    dta 5,1 ; exit pos - x,y
    dta 5,5,5,5 ; ghost AI levels (1 dumb - 9 ninja)
    dta 3    ; ghost spawner delay in seconds
    dta 2   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $1d,$44,$00,COLOR_PACMAD,$50 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 1,1,3,3
    dta 17,3,3,3
    dta 1,5,3,3
    dta 17,7,3,3
    dta 1,9,3,3
    dta 17,11,3,3
    dta 1,13,15,1
    dta 5,1,15,1
dots_end

; empty
    dta TILE_EMPTY,[empty_end-(* + 1)]/4
    dta 4,7,13,1
    dta 4,3,13,1
    dta 4,11,13,1
    dta 6,3,9,9
empty_end

; void
    dta TILE_VOID,[void_end-(* + 1)]/4
    dta 19,4,1,1
    dta 1,2,1,1
    dta 1,6,1,1
    dta 19,8,1,1
    dta 19,12,1,1
    dta 1,10,1,1
void_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 14,7
    dta 6,7
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,7
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 3
    dta 5
    dta 7
    dta 9
    dta 11
    dta 13
    dta 1
warps_end

    dta $ff
.endl ; level size: 111 bytes


;; square bubbles - hard 

.local level_28
    dta 10,46 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 15   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $9c,$94,$00,COLOR_PACMAD,$92 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 10,0,1,2 
    dta 3,1,15,5 
    dta 5,3,11,7 
    dta 7,7,7,7 
    dta 1,7,5,1 
    dta 15,7,5,1 
    dta 3,15,15,7 
    dta 1,17,5,13 
    dta 15,17,5,13 
    dta 9,11,3,19 
    dta 3,23,15,5 
    dta 7,19,7,7 
    dta 7,29,7,7 
    dta 3,32,15,8 
    dta 1,34,5,4 
    dta 15,34,5,4 
    dta 7,37,7,7 
    dta 9,41,3,5 
    dta 10,46,1,1 
    dta 10,3,1,7 
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 10,45 
    dta 10,29 
    dta 10,15 
    dta 10,5 
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 10,22 
    dta 10,42 
    dta 10,12 
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 7 
    dta 17 
    dta 29 
    dta 34 
    dta 37 
warps_end

    dta $ff
.endl ; level size: 121 bytes


;; carpet clean - hard 

.local level_29
    dta 10,30 ; starting pos - x,y
    dta 10,0 ; exit pos - x,y
    dta 1,2,3,4 ; ghost AI levels (1 dumb - 9 ninja)
    dta 5    ; ghost spawner delay in seconds
    dta 20   ; pill mode length in seconds
    dta a(0) ; how much dots can remain to open exit
    dta $bc,$c4,$00,COLOR_PACMAD,$d2 ; colors

; dots
    dta TILE_DOT,[dots_end-(* + 1)]/4
    dta 10,0,1,2 
    dta 1,1,10,1 
    dta 12,1,8,1 
    dta 12,2,1,2 
    dta 2,3,17,3 
    dta 2,7,17,3 
    dta 2,11,17,3 
    dta 4,3,3,13 
    dta 14,3,3,13 
    dta 9,3,3,13 
    dta 2,15,17,5 
    dta 4,17,13,7 
    dta 6,21,9,5 
    dta 8,17,5,11 
    dta 10,19,1,12 
dots_end

; pills
    dta TILE_PILL,[pills_end-(*+1)]/2
    dta 2,19 
    dta 18,19 
pills_end

; spawners
    dta TILE_SPAWNER,[spawners_end-(*+1)]/2
    dta 5,4 
    dta 15,6 
    dta 5,8 
    dta 15,10 
    dta 5,12 
    dta 15,14 
spawners_end

; warps
    dta TILE_WARP_LEFT,warps_end-(* + 1)
    dta 1 
warps_end

    dta $ff
.endl ; level size: 99 bytes


;; ************************** LEVELS END

    .print "LEVELS SIZE: ", (* - levels_list)
    .print "LEVELS:  ", levels_list , ".." , *
    .if *>$B000
        .error "level data exceeded $B000 limit"
    .endif
