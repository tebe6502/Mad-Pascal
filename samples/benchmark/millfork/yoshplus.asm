 
* = $1000
main:
; 
;line:36:yoshplus.mfk
;       i = 0
    LDA #0
    STA $E0
    STA $E1
; 
;line:37:yoshplus.mfk
;       a = 0
    STA $E2
    STA $E3
; 
;line:38:yoshplus.mfk
;       b = 0
    STA $E4
    STA $E5
; 
;line:7:yoshplus.mfk
;       LDA RTCLOK
    LDA $14
; 
;line:8:yoshplus.mfk
;       rt_check:
.ai__00021rt_check:
; 
;line:9:yoshplus.mfk
;       CMP RTCLOK
    CMP $14
; 
;line:10:yoshplus.mfk
;       BEQ rt_check
    BEQ .ai__00021rt_check
; 
;line:41:yoshplus.mfk
;       RTCLOK = 0;
    LDA #0
    STA $14
; 
;line:43:yoshplus.mfk
;       while RTCLOK < 100 {
    BEQ .he__00011
.wh__00010:
; 
;line:44:yoshplus.mfk
;           a += 1
    INC $E2
    BNE .in__00014
    INC $E3
.in__00014:
; 
;line:45:yoshplus.mfk
;           b = a
    LDA $E3
    STA $E5
    LDA $E2
    STA $E4
; 
;line:46:yoshplus.mfk
;           b += 1
    INC $E4
    BNE .in__00015
    INC $E5
.in__00015:
; 
;line:47:yoshplus.mfk
;           a = b
    LDA $E4
    STA $E2
    LDA $E5
    STA $E3
; 
;line:48:yoshplus.mfk
;           i += 1
    INC $E0
    BNE .in__00016
    INC $E1
.in__00016:
; 
;line:43:yoshplus.mfk
;       while RTCLOK < 100 {
.he__00011:
    LDA $14
    CMP #$64
    BCC .wh__00010
; 
;line:51:yoshplus.mfk
;       printScore()
    JSR printScore
; 
;line:53:yoshplus.mfk
;       while true {}
.wh__00017:
    JMP .wh__00017
; 
;line
 
* = $1048
printScore:
; 
;line:18:yoshplus.mfk
;       screen = SAVMSC
    LDA $59
    STA $E7
    LDA $58
    STA $E6
; 
;line:20:yoshplus.mfk
;       tmp[0] = i.hi >> 4
    LDA $E1
    LSR
    LSR
    LSR
    LSR
    STA printScore$tmp.array
; 
;line:21:yoshplus.mfk
;       tmp[1] = i.hi & %00001111
    LDA $E1
    AND #$F
    STA printScore$tmp.array + 1
; 
;line:22:yoshplus.mfk
;       tmp[2] = i.lo >> 4
    LDA $E0
    LSR
    LSR
    LSR
    LSR
    STA printScore$tmp.array + 2
; 
;line:23:yoshplus.mfk
;       tmp[3] = i.lo & %00001111
    LDA $E0
    AND #$F
    STA printScore$tmp.array + 3
; 
;line:25:yoshplus.mfk
;       for iter:tmp {
    LDY #0
.do__00005:
; 
;line:26:yoshplus.mfk
;           if tmp[iter] < 10 {
    LDA printScore$tmp.array, Y
    CMP #$A
    BCS .el__00008
; 
;line:27:yoshplus.mfk
;               tmp[iter] += $10
    LDA printScore$tmp.array, Y
    ADC #$10
; 
;line:26:yoshplus.mfk
;           if tmp[iter] < 10 {
    JMP .fi__00009
.el__00008:
; 
;line:29:yoshplus.mfk
;               tmp[iter] += $17
    LDA printScore$tmp.array, Y
    CLC
    ADC #$17
; 
;line:26:yoshplus.mfk
;           if tmp[iter] < 10 {
.fi__00009:
; 
;line:27:yoshplus.mfk
;               tmp[iter] += $10
    STA printScore$tmp.array, Y
; 
;line:31:yoshplus.mfk
;           screen[iter] = tmp[iter]
    STA ($E6), Y
; 
;line:25:yoshplus.mfk
;       for iter:tmp {
    INY
    CPY #4
    BNE .do__00005
    ; DISCARD_AF
    ; DISCARD_XF
    ; DISCARD_YF
    RTS
; 
;line
.ai__00021rt_check             = $1010
.do__00005                     = $106E
.el__00008                     = $107D
.fi__00009                     = $1083
.he__00011                     = $103C
.in__00014                     = $1020
.in__00015                     = $102E
.in__00016                     = $103C
.wh__00010                     = $101A
.wh__00017                     = $1045
RTCLOK                         = $0014
SAVMSC                         = $0058
SAVMSC.hi                      = $0059
SAVMSC.lo                      = $0058
__heap_start                   = $1000
__reg                          = $0080
__rwdata_end                   = $0000
__rwdata_start                 = $0000
__zeropage_end                 = $00E8
__zeropage_first               = $0080
__zeropage_last                = $00E7
__zeropage_usage               = $0068
a                              = $00E2
a.hi                           = $00E3
a.lo                           = $00E2
b                              = $00E4
b.hi                           = $00E5
b.lo                           = $00E4
i                              = $00E0
i.hi                           = $00E1
i.lo                           = $00E0
main                           = $1000
printScore                     = $1048
printScore$iter                = $0084
printScore$tmp.array           = $0085
screen                         = $00E6
screen.hi                      = $00E7
screen.lo                      = $00E6
segment.default.bank           = $0000
segment.default.end            = $9FFF
segment.default.heapstart      = $1000
segment.default.length         = $8F72
segment.default.start          = $108E
    ; $0000 = __rwdata_end
    ; $0000 = __rwdata_start
    ; $0000 = segment.default.bank
    ; $0014 = RTCLOK
    ; $0058 = SAVMSC
    ; $0058 = SAVMSC.lo
    ; $0059 = SAVMSC.hi
    ; $0068 = __zeropage_usage
    ; $0080 = __reg
    ; $0080 = __zeropage_first
    ; $0084 = printScore$iter
    ; $0085 = printScore$tmp.array
    ; $00E0 = i
    ; $00E0 = i.lo
    ; $00E1 = i.hi
    ; $00E2 = a
    ; $00E2 = a.lo
    ; $00E3 = a.hi
    ; $00E4 = b
    ; $00E4 = b.lo
    ; $00E5 = b.hi
    ; $00E6 = screen
    ; $00E6 = screen.lo
    ; $00E7 = __zeropage_last
    ; $00E7 = screen.hi
    ; $00E8 = __zeropage_end
    ; $1000 = __heap_start
    ; $1000 = main
    ; $1000 = segment.default.heapstart
    ; $1010 = .ai__00021rt_check
    ; $101A = .wh__00010
    ; $1020 = .in__00014
    ; $102E = .in__00015
    ; $103C = .he__00011
    ; $103C = .in__00016
    ; $1045 = .wh__00017
    ; $1048 = printScore
    ; $106E = .do__00005
    ; $107D = .el__00008
    ; $1083 = .fi__00009
    ; $108E = segment.default.start
    ; $8F72 = segment.default.length
    ; $9FFF = segment.default.end