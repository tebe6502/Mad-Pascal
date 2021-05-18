REACH_GOAL = %0
NO_SHADOWS = %1
NO_BLOCKS = %10
NO_MARBLES = %100

COLOR_BLUE = %1
COLOR_GREEN = %10
COLOR_YELLOW = %100
COLOR_ORANGE = %1000
COLOR_RED = %10000
COLOR_BGROUND = %100000
COLOR_ALL = %111111

HLINE = $a0
VLINE = $b0
FRAME = $c0

T_30S = 5
T_60S = 11
T_90S = 17
T_120S = 23
T_150S = 29
T_180S = 34
T_210S = 40
T_240S = 46
T_270S = 52
T_300S = 58


levels_list
    dta a(level_01)
    dta a(level_02)
    dta a(level_03)
    dta a(level_04)
    dta a(level_05)
    dta a(level_06)
    dta a(level_07)
    dta a(level_08)
    dta a(level_09)
    dta a(level_10)
    dta a(level_11)
    dta a(level_12)
    dta a(level_13)
    dta a(level_14)
    dta a(level_15)
    dta a(level_16)
    dta a(level_17)
    dta a(level_18)
    dta a(level_19)
    dta a(level_20)
    dta a(0);
    dta a(level_survival)
    dta a(level_endless)

level_01
    dta b(1) ; goal1 ( * 1000 )
    dta b(2) ; goal2 ( * 1000 )
    dta b(4) ; goal3 ( * 1000 )
    dta b(T_60S) ; time limit 
    dta b(0) ; moves limit
    dta b(REACH_GOAL) ; wining conditions 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($73) ; bgcolor
    dta b(0) ; black occurence
    dta b(0) ; bomb occurence
    dta a(o_frame1) ; voids
    dta a(o_empty) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_empty) ; marbles

level_02
    dta b(5) ; goal1 ( * 1000 )
    dta b(10) ; goal2 ( * 1000 )
    dta b(15) ; goal3 ( * 1000 )
    dta b(0) ; time limit 
    dta b(24) ; moves limit
    dta b(REACH_GOAL) ; wining conditions 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($a3) ; bgcolor
    dta b(0) ; black occurence
    dta b(0) ; bomb occurence
    dta a(o_empty) ; voids
    dta a(o_brackets1) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_empty) ; marbles

level_03
    dta b(1) ; goal1 ( * 1000 )
    dta b(2) ; goal2 ( * 1000 )
    dta b(4) ; goal3 ( * 1000 )
    dta b(T_120S) ; time limit 
    dta b(0) ; moves limit
    dta b(REACH_GOAL) ; wining conditions 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE | COLOR_ORANGE); colors
    dta b($43) ; bgcolor
    dta b(0) ; black occurence
    dta b(0) ; bomb occurence
    dta a(o_corners2) ; voids
    dta a(o_frame4_o) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_empty) ; marbles

level_04
    dta b(8) ; goal1 ( * 1000 )
    dta b(10) ; goal2 ( * 1000 )
    dta b(12) ; goal3 ( * 1000 )
    dta b(0) ; time limit 
    dta b(20) ; moves limit
    dta b(NO_MARBLES) ; wining conditions 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($13) ; bgcolor
    dta b(0) ; black occurence
    dta b(0) ; bomb occurence
    dta a(o_funnel2) ; voids
    dta a(o_empty) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_dots1) ; marbles

level_05
    dta b(4) ; goal1 ( * 1000 )
    dta b(6) ; goal2 ( * 1000 )
    dta b(8) ; goal3 ( * 1000 )
    dta b(T_120S) ; time limit 
    dta b(0) ; moves limit
    dta b(NO_MARBLES) ; wining conditions 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($d3) ; bgcolor
    dta b(0) ; black occurence
    dta b(0) ; bomb occurence
    dta a(o_funnel4) ; voids
    dta a(o_empty) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_dots2) ; marbles


level_06
    dta b(2) ; goal1 ( * 1000 )
    dta b(4) ; goal2 ( * 1000 )
    dta b(6) ; goal3 ( * 1000 )
    dta b(0) ; time limit 
    dta b(16) ; moves limit
    dta b(NO_MARBLES) ; wining conditions 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($13) ; bgcolor
    dta b(0) ; black occurence
    dta b(0) ; bomb occurence
    dta a(o_slash0) ; voids
    dta a(o_empty) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_dots5r) ; marbles

level_07
    dta b(5) ; goal1 ( * 1000 )
    dta b(7) ; goal2 ( * 1000 )
    dta b(10) ; goal3 ( * 1000 )
    dta b(0) ; time limit 
    dta b(24) ; moves limit
    dta b(NO_BLOCKS) ; wining conditions 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($43) ; bgcolor
    dta b(0) ; black occurence
    dta b(10) ; bomb occurence
    dta a(o_brackets1) ; voids
    dta a(o_bottom9) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_empty) ; marbles

level_08
    dta b(4) ; goal1 ( * 1000 )
    dta b(8) ; goal2 ( * 1000 )
    dta b(12) ; goal3 ( * 1000 )
    dta b(T_120S) ; time limit 
    dta b(0) ; moves limit
    dta b(NO_BLOCKS) ; wining conditions 
    dta b(COLOR_ORANGE | COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($63) ; bgcolor
    dta b(0) ; black occurence
    dta b(10) ; bomb occurence
    dta a(o_corners2) ; voids
    dta a(o_frame4_o) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_empty) ; marbles

level_09
    dta b(4) ; goal1 ( * 1000 )
    dta b(8) ; goal2 ( * 1000 )
    dta b(12) ; goal3 ( * 1000 )
    dta b(T_120S) ; time limit 
    dta b(0) ; moves limit
    dta b(NO_BLOCKS) ; wining conditions 
    dta b(COLOR_ORANGE | COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta b($63) ; bgcolor
    dta b(0) ; black occurence
    dta b(10) ; bomb occurence
    dta a(o_corners2) ; voids
    dta a(o_frame4_o) ; blocks
    dta a(o_empty) ; shadows
    dta a(o_empty) ; marbles

level_10
level_11
level_12
level_13
level_14
level_15
level_16
level_17
level_18
level_19
level_20

    dta 1, 2, 5, 0, 4
    dta b(REACH_GOAL) 
    dta b(COLOR_YELLOW | COLOR_GREEN | COLOR_RED | COLOR_BLUE); colors
    dta $33,0,25 
    dta a(o_empty),a(o_empty),a(o_empty),a(o_empty)


o_empty
    dta $ff

o_frame1
    dta FRAME,$11,$88
o_frame0
    dta FRAME,$00,$99
    dta $ff
    
o_frame4_o
    dta FRAME,$44,$55
    dta $ff

o_brackets1
    dta VLINE | 10,$10
    dta VLINE | 10,$80
o_brackets0
    dta VLINE | 10,$00
    dta VLINE | 10,$90
    dta $ff

o_corners
    dta $00,$09,$99,$90
    dta $ff

o_corners2
    dta FRAME,$00,$11
    dta FRAME,$80,$91
    dta FRAME,$08,$19
    dta FRAME,$88,$99
    dta $ff

o_hline0 
    dta HLINE | 10,$00
    dta $ff

o_hline3 
    dta HLINE | 10,$03
    dta $ff

o_hline4 
    dta HLINE | 10,$04
    dta $ff

o_hline5
    dta HLINE | 10,$04
    dta $ff

o_hline6
    dta HLINE | 10,$04
    dta $ff

o_bottom9 
    dta HLINE | 6,$29
    dta $ff

o_funnel2
    dta VLINE | 8,$02
    dta VLINE | 8,$92
    dta VLINE | 6,$14
    dta VLINE | 6,$84
    dta VLINE | 4,$26
    dta VLINE | 4,$76
    ;dta VLINE | 2,$38
    ;dta VLINE | 2,$68
    dta $ff
    
o_funnel4
    dta VLINE | 6,$04
    dta VLINE | 6,$94
    dta VLINE | 5,$15
    dta VLINE | 5,$85
    dta VLINE | 4,$26
    dta VLINE | 4,$76
    ;dta VLINE | 2,$38
    ;dta VLINE | 2,$68
    dta $ff
    
o_slash0
    dta VLINE | 5,$00
    dta VLINE | 4,$10
    dta VLINE | 3,$20
    dta VLINE | 2,$30
    dta VLINE | 1,$40
    dta VLINE | 5,$95
    dta VLINE | 4,$86
    dta VLINE | 3,$77
    dta VLINE | 2,$68
    dta VLINE | 1,$59
    dta $ff
        
    
o_dots2 
    dta $10,$80
o_dots1 
    dta $31,$61
    dta $ff
o_dots5r 
    dta HLINE | 5,$50
    dta $ff


level_survival
    dta 0, 0, 0, 0, 0
    dta b(REACH_GOAL) 
    dta b(COLOR_ALL); colors
    dta $0a,0,0 
    dta a(o_empty),a(o_empty),a(o_empty),a(o_empty)

level_endless
    dta 0, 0, 0, 0, 0
    dta b(REACH_GOAL) 
    dta b(COLOR_ALL); colors
    dta $66,0,0 
    dta a(o_empty),a(o_empty),a(o_empty),a(o_empty)
    
    .print "global levels size: ",(* - levels_list)
    .print "levels data ends at: ",*
