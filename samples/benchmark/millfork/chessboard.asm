 
* = $1000
main:
; 
;line:93:chessboard.mfk
;       count = 0
    LDA #0
    STA $E6
; 
;line:7:chessboard.mfk
;       LDA RTCLOK
    LDA $14
; 
;line:8:chessboard.mfk
;       rt_check:
.ai__00030rt_check:
; 
;line:9:chessboard.mfk
;       CMP RTCLOK
    CMP $14
; 
;line:10:chessboard.mfk
;       BEQ rt_check
    BEQ .ai__00030rt_check
; 
;line:96:chessboard.mfk
;       RTCLOK = 0
    LDA #0
    STA $14
; 
;line:98:chessboard.mfk
;       while RTCLOK  < 150 {
    BEQ .he__00023
.wh__00022:
; 
;line:99:chessboard.mfk
;           drawBoard()
    JSR drawBoard
; 
;line:100:chessboard.mfk
;           count += 1
    INC $E6
; 
;line:98:chessboard.mfk
;       while RTCLOK  < 150 {
.he__00023:
    LDA $14
    CMP #$96
    BCC .wh__00022
; 
;line:23:chessboard.mfk
;       screen = $8400
    LDA #0
    STA $E8
    LDA #$84
    STA $E9
; 
;line:24:chessboard.mfk
;       SDMCTL = dl.addr
    LDA #lo(printScore$dl)
    STA $230
    LDA #hi(printScore$dl)
    STA $231
; 
;line:26:chessboard.mfk
;       tmp[0] = count >> 4
    LDA $E6
    LSR
    LSR
    LSR
    LSR
    STA printScore$tmp.array
; 
;line:27:chessboard.mfk
;       tmp[1] = count & %00001111
    LDA $E6
    AND #$F
    STA printScore$tmp.array + 1
; 
;line:29:chessboard.mfk
;       for iter:tmp {
    LDY #0
.ai__00031.do__00017:
; 
;line:30:chessboard.mfk
;           if tmp[iter] < 10 {
    LDA printScore$tmp.array, Y
    CMP #$A
    BCS .ai__00031.el__00020
; 
;line:31:chessboard.mfk
;               screen[iter] = tmp[iter] + $10
    LDA printScore$tmp.array, Y
    ADC #$10
; 
;line:30:chessboard.mfk
;           if tmp[iter] < 10 {
    JMP .ai__00031.fi__00021
.ai__00031.el__00020:
; 
;line:33:chessboard.mfk
;               screen[iter] = tmp[iter] + $17
    LDA printScore$tmp.array, Y
    CLC
    ADC #$17
; 
;line:30:chessboard.mfk
;           if tmp[iter] < 10 {
.ai__00031.fi__00021:
; 
;line:31:chessboard.mfk
;               screen[iter] = tmp[iter] + $10
    STA ($E8), Y
; 
;line:29:chessboard.mfk
;       for iter:tmp {
    INY
    CPY #2
    BNE .ai__00031.do__00017
; 
;line:105:chessboard.mfk
;       while (true){}
.wh__00026:
    BEQ .wh__00026
; 
;line
 
* = $105b
drawBoard:
; 
;line:71:chessboard.mfk
;       screen = $6010
    LDA #$10
    STA $E8
    LDA #$60
    STA $E9
; 
;line:72:chessboard.mfk
;       SDMCTL = dl.addr
    LDA #lo(drawBoard$dl)
    STA $230
    LDA #hi(drawBoard$dl)
    STA $231
; 
;line:74:chessboard.mfk
;       for i,7,downto,0 {
    LDA #8
    STA $E0
.do__00001:
    DEC $E0
; 
;line:75:chessboard.mfk
;           for j,23,downto,0 {
    LDA #$18
    STA $E2
.do__00004:
    DEC $E2
; 
;line:76:chessboard.mfk
;               for k,3,downto,0 {
    LDA #4
    STA $E4
.do__00007:
    DEC $E4
; 
;line:77:chessboard.mfk
;                   screen[0] = 255
    LDA #$FF
    LDY #0
    STA ($E8), Y
; 
;line:78:chessboard.mfk
;                   screen[1] = 255
    INY
    STA ($E8), Y
; 
;line:79:chessboard.mfk
;                   screen[2] = 255
    INY
    STA ($E8), Y
; 
;line:80:chessboard.mfk
;                   screen += 6
    CLC
    LDA $E8
    ADC #6
    STA $E8
    BCC .ah__00012
    INC $E9
.ah__00012:
; 
;line:76:chessboard.mfk
;               for k,3,downto,0 {
    LDA $E4
    BNE .do__00007
; 
;line:82:chessboard.mfk
;               screen += 16
    CLC
    LDA $E8
    ADC #$10
    STA $E8
    BCC .ah__00013
    INC $E9
.ah__00013:
; 
;line:75:chessboard.mfk
;           for j,23,downto,0 {
    LDA $E2
    BNE .do__00004
; 
;line:84:chessboard.mfk
;           if (i & 1) == 0 {
    LDA $E0
    AND #1
    BNE .el__00010
; 
;line:85:chessboard.mfk
;               screen -= 3
    SEC
    LDA $E8
    SBC #3
    STA $E8
    LDA $E9
    SBC #0
    STA $E9
; 
;line:84:chessboard.mfk
;           if (i & 1) == 0 {
    JMP .fi__00011
.el__00010:
; 
;line:87:chessboard.mfk
;               screen += 3
    CLC
    LDA $E8
    ADC #3
    STA $E8
    BCC .ah__00014
    INC $E9
.ah__00014:
; 
;line:84:chessboard.mfk
;           if (i & 1) == 0 {
.fi__00011:
; 
;line:74:chessboard.mfk
;       for i,7,downto,0 {
    LDA $E0
    BNE .do__00001
    ; DISCARD_AF
    ; DISCARD_XF
    ; DISCARD_YF
    RTS
; 
;line
* = $10cf
drawBoard$dl.array:
    !byte $70, $70, $70, $4F, $10, $60, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $4F, 0, $70, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F
    !byte $F, $F, $F, $F, $F, $F, $F, $41, 0, 0
* = $1199
printScore$dl.array:
    !byte $70, $70, $70, $42, 0, $84, $41, 0, 0
.ah__00012                     = $1096
.ah__00013                     = $10A5
.ah__00014                     = $10CA
.ai__00030rt_check             = $1006
.ai__00031.do__00017           = $103D
.ai__00031.el__00020           = $104C
.ai__00031.fi__00021           = $1052
.do__00001                     = $1071
.do__00004                     = $1077
.do__00007                     = $107D
.el__00010                     = $10BF
.fi__00011                     = $10CA
.he__00023                     = $1015
.wh__00022                     = $1010
.wh__00026                     = $1059
RTCLOK                         = $0014
SDMCTL                         = $0230
SDMCTL.hi                      = $0231
SDMCTL.lo                      = $0230
__heap_start                   = $1000
__reg                          = $0080
__rwdata_end                   = $0000
__rwdata_start                 = $0000
__zeropage_end                 = $00EA
__zeropage_first               = $0080
__zeropage_last                = $00E9
__zeropage_usage               = $006A
count                          = $00E6
drawBoard                      = $105B
drawBoard$dl.array             = $10CF
i                              = $00E0
j                              = $00E2
k                              = $00E4
main                           = $1000
printScore$dl.array            = $1199
printScore$iter                = $0084
printScore$tmp.array           = $0085
screen                         = $00E8
screen.hi                      = $00E9
screen.lo                      = $00E8
segment.default.bank           = $0000
segment.default.end            = $9FFF
segment.default.heapstart      = $1000
segment.default.length         = $8E5E
segment.default.start          = $11A2
    ; $0000 = __rwdata_end
    ; $0000 = __rwdata_start
    ; $0000 = segment.default.bank
    ; $0014 = RTCLOK
    ; $006A = __zeropage_usage
    ; $0080 = __reg
    ; $0080 = __zeropage_first
    ; $0084 = printScore$iter
    ; $0085 = printScore$tmp.array
    ; $00E0 = i
    ; $00E2 = j
    ; $00E4 = k
    ; $00E6 = count
    ; $00E8 = screen
    ; $00E8 = screen.lo
    ; $00E9 = __zeropage_last
    ; $00E9 = screen.hi
    ; $00EA = __zeropage_end
    ; $0230 = SDMCTL
    ; $0230 = SDMCTL.lo
    ; $0231 = SDMCTL.hi
    ; $1000 = __heap_start
    ; $1000 = main
    ; $1000 = segment.default.heapstart
    ; $1006 = .ai__00030rt_check
    ; $1010 = .wh__00022
    ; $1015 = .he__00023
    ; $103D = .ai__00031.do__00017
    ; $104C = .ai__00031.el__00020
    ; $1052 = .ai__00031.fi__00021
    ; $1059 = .wh__00026
    ; $105B = drawBoard
    ; $1071 = .do__00001
    ; $1077 = .do__00004
    ; $107D = .do__00007
    ; $1096 = .ah__00012
    ; $10A5 = .ah__00013
    ; $10BF = .el__00010
    ; $10CA = .ah__00014
    ; $10CA = .fi__00011
    ; $10CF = drawBoard$dl.array
    ; $1199 = printScore$dl.array
    ; $11A2 = segment.default.start
    ; $8E5E = segment.default.length
    ; $9FFF = segment.default.end