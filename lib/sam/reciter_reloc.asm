// https://github.com/sidneycadot/sam/blob/main/assembly/reciter.s

; Source code for the SAM reciter.
;
; The "reciter" program performs English-to-SAM phoneme translation.
;
; It is designed to be called through entry points in the SAM program.

; ----------------------------------------------------------------------------

ZP_SAM_BUFFER_INDEX     = $F5          ; Destination index in the SAM_BUFFER.
ZP_TEMP1                = $F6          ;
ZP_RB_SUFFIX_INDEX      = $F7          ; Reciter buffer suffix index.
ZP_RB_PREFIX_INDEX      = $F8          ; Reciter buffer prefix index.
ZP_RB_LAST_CHAR_INDEX   = $F9          ;
ZP_RECITER_BUFFER_INDEX = $FA          ; Source index in the RECITER_BUFFER.

ZP_RULE_PTR             = $FB          ; rule pointer
ZP_RULE_PTR_LO          = $FB          ; rule pointer, LSB
ZP_RULE_PTR_HI          = $FC          ; rule pointer, MSB

ZP_TEMP2                = $FD          ;
ZP_RULE_SUFFIX_INDEX    = $FE          ;
ZP_RULE_PREFIX_INDEX    = $FF          ;

; ----------------------------------------------------------------------------

;        .extrn WARMST .byte
;        .extrn MEMLO .word
;        .extrn BASIC .word

; ----------------------------------------------------------------------------

        .extrn SAM_ZP_CD .byte                   ; Defined by SAM.

        .extrn SAM_BUFFER .word                  ; 256-byte buffer where SAM receives its phoneme representation to be rendered as sound.
                                                 ; Also used to receive the initial English text.
;        .extrn SAM_SAY_PHONEMES .word            ; Play the phonemes in SAM_BUFFER as sound.
;        .extrn SAM_COPY_BASIC_SAM_STRING  .word  ; Routine to find and copy SAM$ into the SAM_BUFFER.
        .extrn SAM_SAVE_ZP_ADDRESSES .word       ; Save zero-page addresses used by SAM.
        .extrn SAM_ERROR_SOUND .word             ; Routine to signal error using a distinctive error sound.

; ----------------------------------------------------------------------------

;        .public RECITER_VIA_SAM_FROM_BASIC
        .public RECITER_VIA_SAM_FROM_MACHINE_LANGUAGE

; ----------------------------------------------------------------------------

        .reloc

; ----------------------------------------------------------------------------

RECITER_BUFFER	:256 brk

; ----------------------------------------------------------------------------

;        dta c'COPYRIGHT 1982 DON''T ASK'

; ----------------------------------------------------------------------------

CHARACTER_PROPERTIES:

        ; Properties of the 96 characters we support.
        ;
        ; Value 0x00: ignore the character
        ; bit 0 (0x01): 0-9                                                  (digits)
        ; bit 1 (0x02): ! " # $ % & ' * + , - . 0-9 : ; < = > ? @ ^          (special characters and digits)
        ; bit 2 (0x04):       D           J   L   N       R S T           Z
        ; bit 3 (0x08):   B   D     G     J   L M N       R       V W     Z
        ; bit 4 (0x10):     C       G     J                 S         X   Z
        ; bit 5 (0x20):   B C D   F G H   J K L M N   P Q R S T   V W X   Z  (consonants)
        ; bit 6 (0x40): A       E       I           O           U       Y    (vowels)
        ; bit 7 (0x80): A-Z and single quote (') character                   (all letters and single quote)

        :32 dta %00000000                       ; ASCII control characters 0x00..0x1F are all 0x00 (ignore).

        .byte   %00000000                       ; space
        .byte   %00000010                       ; !
        .byte   %00000010                       ; "
        .byte   %00000010                       ; #
        .byte   %00000010                       ; $
        .byte   %00000010                       ; %
        .byte   %00000010                       ; &
        .byte   %10000010                       ; '     -- The single quote has bit 7 set, like A-Z. For things like "brother's" and "haven't".
        .byte   %00000000                       ; (     -- ignore.
        .byte   %00000000                       ; )     -- ignore.
        .byte   %00000010                       ; *
        .byte   %00000010                       ; +
        .byte   %00000010                       ; ,
        .byte   %00000010                       ; -
        .byte   %00000010                       ; .
        .byte   %00000010                       ; /
        .byte   %00000011                       ; 0
        .byte   %00000011                       ; 1
        .byte   %00000011                       ; 2
        .byte   %00000011                       ; 3
        .byte   %00000011                       ; 4
        .byte   %00000011                       ; 5
        .byte   %00000011                       ; 6
        .byte   %00000011                       ; 7
        .byte   %00000011                       ; 8
        .byte   %00000011                       ; 9
        .byte   %00000010                       ; :
        .byte   %00000010                       ; ;
        .byte   %00000010                       ; <
        .byte   %00000010                       ; =
        .byte   %00000010                       ; >
        .byte   %00000010                       ; ?
        .byte   %00000010                       ; @
        .byte   %11000000                       ; A
        .byte   %10101000                       ; B
        .byte   %10110000                       ; C
        .byte   %10101100                       ; D
        .byte   %11000000                       ; E
        .byte   %10100000                       ; F
        .byte   %10111000                       ; G
        .byte   %10100000                       ; H
        .byte   %11000000                       ; I
        .byte   %10111100                       ; J
        .byte   %10100000                       ; K
        .byte   %10101100                       ; L
        .byte   %10101000                       ; M
        .byte   %10101100                       ; N
        .byte   %11000000                       ; O
        .byte   %10100000                       ; P
        .byte   %10100000                       ; Q
        .byte   %10101100                       ; R
        .byte   %10110100                       ; S
        .byte   %10100100                       ; T
        .byte   %11000000                       ; U
        .byte   %10101000                       ; V
        .byte   %10101000                       ; W
        .byte   %10110000                       ; X
        .byte   %11000000                       ; Y
        .byte   %10111100                       ; Z
        .byte   %00000000                       ; [    -- ignore.
        .byte   %00000000                       ; \    -- ignore.
        .byte   %00000000                       ; ]    -- ignore.
        .byte   %00000010                       ; ^
        .byte   %00000000                       ; _    -- ignore.

; ----------------------------------------------------------------------------

;RECITER_VIA_SAM_FROM_BASIC:

        ; Reciter when entered from BASIC, through a call to the USR(8200) function.
        ; When entering here, the number of arguments is already popped from the 6502 stack.

 ;       jsr     SAM_COPY_BASIC_SAM_STRING       ; Find and copy SAM$.

; ----------------------------------------------------------------------------

RECITER_VIA_SAM_FROM_MACHINE_LANGUAGE:

        ; The SAM Reciter when entered from machine code.
        ;
        ; The documented way to get here is by calling into "SAM_RUN_RECITER_FROM_MACHINE_LANGUAGE"
        ; (jsr $200B), which is simply a jump to RECITER_VIA_SAM_FROM_MACHINE_LANGUAGE.
        ;
        ; When entering, the English-language string to be translated should be in the SAM_BUFFER.
        ; Here, we're going to copy it to the Reciter buffer, sanatizing the characters on the fly.

        jsr     SAM_SAVE_ZP_ADDRESSES           ; Save ZP registers.

        ; Copy content of SAM buffer to RECITER buffer, with some character remapping.
        ; The translation performed first zeroes then most significant bit of each character,
        ; to ensure it is an ASCII character.
        ;
        ; Then, it maps the 32 highest ASCII characters (0x60..0x7f, which include the
        ; lowercase letters) to 0x40..0x5F.
        ;
        ; To summarize the effects:
        ;
        ; The end-of-line character 0x9b map to 0x1b (the escape character).
        ;
        ; `   (backtick)            maps to '@'.
        ; a-z (lowercase letters)   map  to A-Z.
        ; {   (curly bracket open)  maps to '[' (angle bracket open).
        ; |   (pipe)                maps to '\' (backslash).
        ; }   (curly bracket close) maps to ']' (angle bracket close).
        ; ~   (tilde)               maps to '^' (caret).
        ; DEL (0x7f)                maps to '_' (underscore).
        ;
        ; What remains are 96 characters that need to be handled:
        ;
        ; * 32 ASCII control characters 0x00 .. 0x1f, including escape (0x1f) that is used as an end-of-string marker.
        ; * 16 characters ' ' (space), '!', '"', '#', '$', '%', '&', single-quote, '(', ')', '*', '+', ',', '-', '.', '/'
        ; * 10 characters '0' .. '9'.
        ; *  7 characters ':', ';', '<', '=', '>', '?', '@'
        ; * 26 characters 'A' .. 'Z'
        ; *  5 characters '[', '\', ']', '^', '_'

        lda     #' '                            ; Put a space character at the start of the RECITER buffer.
        sta     RECITER_BUFFER                  ;
        ldx     #1                              ; Prepare the character copy loop.
        ldy     #0                              ;

@loop:  lda     SAM_BUFFER,y                    ; Start of character copy loop; load character.
        and     #$7F                            ; Set bit 7 of the character to zero. Note that this turns end-of-line, 0x9b, into 0x1b.
        cmp     #$70                            ;
        bcc     @1                              ;
        and     #$5F                            ; Characters $70..$7F: zero bit #5.
        jmp     @2                              ;
@1:     cmp     #$60                            ;
        bcc     @2                              ;
        and     #$4F                            ; Characters $60..$6F: zero bits #4 and #5.
@2:     sta     RECITER_BUFFER,x                ; Store sanitized character and proceed to the next one.
        inx                                     ;
        iny                                     ;
        cpy     #$FF                            ;
        bne     @loop                           ; End of character copy loop.

        ldx     #$FF                            ; Store $1B at the end of the RECITER buffer.
        lda     #$1B                            ; This ensures the RECITER buffer's string will end in $1B.
        sta     RECITER_BUFFER,x                ;

        ; The string to be translated from English is now in the RECITER_BUFFER.
        ; Translate the RECITER_BUFFER (English) to the SAM_BUFFER (phonemes), then
        ; call into SAM to say the phonemes.

;        jsr     TRANSLATE_ENGLISH_TO_PHONEMES   ;

; ----------------------------------------------------------------------------

;SAY_PHONEMES:

;        jsr     SAM_SAY_PHONEMES                ; Call subroutine in SAM.
;        rts                                     ; Done.

; ----------------------------------------------------------------------------

TRANSLATE_ENGLISH_TO_PHONEMES:

        ; Translate English text in the RECITER_BUFFER to phonemes in the SAM_BUFFER.

        lda     #$FF                            ; Point to one before the English language input buffer.
        sta     ZP_RECITER_BUFFER_INDEX         ;

TRANSLATE_NEXT_CHUNK:

        lda     #$FF                            ; Point to one before the SAM phonetic output buffer.
        sta     ZP_SAM_BUFFER_INDEX             ;

; ----------------------------------------------------------------------------

TRANSLATE_NEXT_CHARACTER:

        inc     ZP_RECITER_BUFFER_INDEX         ; Proceed to next character in the source (English) text.
        ldx     ZP_RECITER_BUFFER_INDEX         ;

        lda     RECITER_BUFFER,x                ; Store English character to process in ZP_TEMP2.
        sta     ZP_TEMP2                        ;

        cmp     #$1B                            ; Is the current character the end-of-string character $1B?
        bne     @proceed_1                      ; Nope, proceed.

        inc     ZP_SAM_BUFFER_INDEX             ; Process end-of-string character.
        ldx     ZP_SAM_BUFFER_INDEX             ; Append end-of-string character to the SAM phoneme buffer.
        lda     #$9B                            ;
        sta     SAM_BUFFER,x                    ;
        rts                                     ; Return. The final chunk will be passed to SAM by the caller.

@proceed_1:

        ; Detect and handle end-of-sentence.
        ;
        ; A period character that is not followed by a digit is copied into the SAM phoneme buffer verbatim,
        ; as an "end-of-sentence" indicator to.
        ;
        ; However, periods that are followed by a digit are assumed to be part of a number, and those will be
        ; rendered as "POYNT" by a miscellaneous pronunciation rule later.

        cmp     #'.'                            ; Compare current character to period ('.').
        bne     @proceed_2                      ;
        inx                                     ; Is the period following the period a digit (0-9)?
        lda     RECITER_BUFFER,x                ; Load the next character.
        tay                                     ; Is it a digit (0-9)?
        lda     CHARACTER_PROPERTIES,y          ;
        and     #$01                            ;
        bne     @proceed_2                      ; Yes; the period is not an end-of-sentence indicator. Skip to @proceed_2.

        inc     ZP_SAM_BUFFER_INDEX             ; Handle end-of-sentence period.
        ldx     ZP_SAM_BUFFER_INDEX             ; Append a period character to the SAM phoneme buffer.
        lda     #'.'                            ;
        sta     SAM_BUFFER,x                    ;
        jmp     TRANSLATE_NEXT_CHARACTER        ; Proceed to the next English character.

@proceed_2:                                     ; The current character is not a period, or it is a period followed by a digit.

        lda     ZP_TEMP2                        ; Check if the English character is in the "miscellaneous symbols including digits" class.
        tay                                     ;
        lda     CHARACTER_PROPERTIES,y          ;
        sta     ZP_TEMP1                        ;
        and     #$02                            ;
        beq     @proceed_3                      ; No: proceed.

        lda     <PTAB_MISC                      ; Apply miscellaneous pronunciation rules.
        sta     ZP_RULE_PTR_LO                  ;
        lda     >PTAB_MISC                      ;
        sta     ZP_RULE_PTR_HI                  ;
        jmp     TRY_NEXT_RULE                   ;

@proceed_3:

        lda     ZP_TEMP1                        ; Check if the character is "space-like" (i.e., it properties flags are all zero).
        bne     TRANSLATE_ALPHABETIC_CHARACTER  ; If not, proceed to match an alphabetic character.

        lda     #' '                            ; Replace the character in the source (english) buffer by a space.
        sta     RECITER_BUFFER,x                ;

        inc     ZP_SAM_BUFFER_INDEX             ; Increment the SAM phoneme buffer index.
        ldx     ZP_SAM_BUFFER_INDEX             ;
                                                ; We're rendering a space; this would be a good time to flush the buffer.
        cpx     #$78                            ; Is the SAM phoneme buffer approximately half full?
        bcs     FLUSH_SAM_BUFFER                ; Yes! Flush (say) the current phoneme buffer.

        sta     SAM_BUFFER,x                    ; Store a space character to the SAM phoneme buffer.
        jmp     TRANSLATE_NEXT_CHARACTER        ; Proceed with next character.

; ----------------------------------------------------------------------------

;SAVE_RECITER_BUFFER_INDEX: .byte 0              ; Temporary storage for ZP_RECITER_BUFFER_INDEX while flushing the phoneme buffer.

FLUSH_SAM_BUFFER:

        lda     #$9B                            ; Add an end-of-line to the phoneme buffer.
        sta     SAM_BUFFER,x                    ;

        lda     ZP_RECITER_BUFFER_INDEX         ; Save reciter buffer index.
        sta     SAVE_RECITER_BUFFER_INDEX       ;

        sta     SAM_ZP_CD                       ; Store non-zero here to let SAM_SAY_PHONEMES know that this is not
                                                ; the last time it is called. This prevents SAM_SAY_PHONEMES from
                                                ; restoring ZP addresses and re-enabling interrupts when it's done.
                                                ;
                                                ; SAM_SAY_PHONEMES will reset the value of SAM_ZP_CD to zero.

;        jsr     SAY_PHONEMES                    ; Speak the current phonemes in the SAM_BUFFER.

        lda     SAVE_RECITER_BUFFER_INDEX: #$00 ; Restore the reciter buffer index.
        sta     ZP_RECITER_BUFFER_INDEX         ;

        jmp     TRANSLATE_NEXT_CHUNK            ; Render the next chunk.

; ----------------------------------------------------------------------------

TRANSLATE_ALPHABETIC_CHARACTER:

        lda     ZP_TEMP1                        ; Verify that ZP_TEMP1 contains a value with its most significant bit set.
        ;and     #$80                            ;
        ;bne     @good                           ; Character is alphabetic, or a single quote.
	bmi     @good
        rts
        ;brk                                     ; Abort. Unexpected character type.

@good:  lda     ZP_TEMP2                        ; Load the English character to be processed from ZP_TEMP5.
        sec                                     ; Set ZP_RULE_PTR to the table entry corresponding to the letter.
        sbc     #'A'                            ;
        tax                                     ;
        lda     PTAB_INDEX_LO,x                 ;
        sta     ZP_RULE_PTR_LO                  ;
        lda     PTAB_INDEX_HI,x                 ;
        sta     ZP_RULE_PTR_HI                  ;

TRY_NEXT_RULE:

        ; Scan forward to find a new rule which we will try to match.
        ;
        ; ZP_RULE_PTR is incremented until it points to a value with its most significant bit set.
        ; The rule to be matched comes right after that.
        ; This will be used as the base pointer while attempting to match the text in the RECITER_BUFFER with the rule.

        ldy     #0                              ; Set Y=0 for accessing ZP_RULE_PTR later on.

@
;        clc                                     ; Increment ZP_RULE_PTR by one.
;        lda     ZP_RULE_PTR_LO                  ;
;        adc     <1                              ;
;        sta     ZP_RULE_PTR_LO                  ;
;        lda     ZP_RULE_PTR_HI                  ;
;        adc     >1                              ;
;        sta     ZP_RULE_PTR_HI                  ;

        inw     ZP_RULE_PTR_LO

        lda     (ZP_RULE_PTR),y                 ; Load byte at address pointed to by ZP_RULE_PTR.
        bpl     @-                              ; Repeat increment until we find a value with its most significant bit set.

        iny                                     ;
@       lda     (ZP_RULE_PTR),y                 ; Find '(' character in rule definition.
        cmp     #'('                            ;
        beq     PROCESS_RULE                    ; Found it. process the current rule.
        iny                                     ; Try next character.
        jmp     @-

; ----------------------------------------------------------------------------

PROCESS_RULE:

        ; ZP_RULE_PTR points to a character in front of a rule (which has bit #7 set).
        ; (ZP_RULE_PTR),y is a left-parenthesis character.

        sty     ZP_RULE_PREFIX_INDEX            ; ZP_RULE_PREFIX_INDEX is the offset for the '(' character in the rule.

@       iny                                     ; Scan the rule for the ')' character.
        lda     (ZP_RULE_PTR),y                 ;
        cmp     #')'                            ;
        bne     @-                              ;

        sty     ZP_RULE_SUFFIX_INDEX            ; ZP_RULE_SUFFIX_INDEX is the offset for the ')' character in the rule.

@       iny                                     ; Scan the rule definition for the '=' character.
        lda     (ZP_RULE_PTR),y                 ;
        and     #$7F                            ; The '=' character may be the last character, so set bit 7 to zero.
        cmp     #'='                            ;   before comparing.
        bne     @-                              ;

        sty     ZP_TEMP2                        ; ZP_TEMP2 is the Y offset for '=' character.

        ; We will now determine if the rule matches, and we start by looking at the stem pattern.
        ; The stem pattern of a rule definition is the characters between the '(' and the ')'.
        ; The stem pattern characters are always matched literally; no wildcards are used.

        ldx     ZP_RECITER_BUFFER_INDEX         ; Initialize ZP_RB_LAST_CHAR_INDEX with current reciter buffer index.
        stx     ZP_RB_LAST_CHAR_INDEX           ;
        ldy     ZP_RULE_PREFIX_INDEX            ; Check for literal match of the rule's stem stem pattern, i.e.,
        iny                                     ;   everything between the '(' and ')' characters in the rule definition.

@stem_match_loop:

        lda     RECITER_BUFFER,x                ; Parenthesized character is a literal match?
        sta     ZP_TEMP1                        ;
        lda     (ZP_RULE_PTR),y                 ;
        cmp     ZP_TEMP1                        ;
        beq     @stem_character_matched         ;
        jmp     TRY_NEXT_RULE                   ; Mismatch: no literal match of stem character.

@stem_character_matched:

        iny                                     ; Increment stem index.
        cpy     ZP_RULE_SUFFIX_INDEX            ; Have we reached the end of the stem?
        bne     @5                              ;
        jmp     MATCH_PREFIX                    ; Literal match of stem successful. Proceed to match the prefix pattern.

@5:     inx                                     ; Increment ZP_RB_LAST_CHAR_INDEX.
        stx     ZP_RB_LAST_CHAR_INDEX           ;
        jmp     @stem_match_loop                ;


MATCH_PREFIX:

        ; After successfully matching the stem pattern, try to match the prefix pattern.
        ; The prefix pattern of a rule definition is the characters in front of the '('.
        ; Unlike the stem pattern, the prefix pattern may include wildcard characters.

        lda     ZP_RECITER_BUFFER_INDEX         ; Index to the anchor character in the English source text.
        sta     ZP_RB_PREFIX_INDEX              ;

MATCH_NEXT_PREFIX_CHARACTER:

        ldy     ZP_RULE_PREFIX_INDEX            ; Load the next character of the prefix pattern, going from right to left.
        dey                                     ;
        sty     ZP_RULE_PREFIX_INDEX            ;
        lda     (ZP_RULE_PTR),y                 ;
        sta     ZP_TEMP1                        ; The prefix pattern character to be matched.
        bpl     @+                              ; If most significant bit is set, we've reached the end of the prefix pattern.
        jmp     MATCH_SUFFIX                    ; The match was successful; proceed to matching the suffix pattern.

@       and     #$7F                            ; Set most significant bit to zero, even though it is already zero when we get here.
        tax                                     ; Get character properties of the current prefix pattern character.
        lda     CHARACTER_PROPERTIES,x          ;
        ;and     #$80                            ; A-Z and the single quote character are matched directly below.
        ;beq     MATCH_PREFIX_WILDCARD           ; Anything else is handled by MATCH_PREFIX_WILDCARD.
        bpl     MATCH_PREFIX_WILDCARD           ; Anything else is handled by MATCH_PREFIX_WILDCARD.

        ldx     ZP_RB_PREFIX_INDEX              ; Load the source character.
        dex                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     ZP_TEMP1                        ; Compare prefix pattern character with source character.
        beq     MATCH_PREFIX_SUCCESS_1          ; They are identical. Proceed to the next character.
        jmp     TRY_NEXT_RULE                   ; Match failure. Abandon the current rule and proceed to the next one.

; ----------------------------------------------------------------------------

MATCH_PREFIX_SUCCESS_1:

        stx     ZP_RB_PREFIX_INDEX              ;
        jmp     MATCH_NEXT_PREFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD:

        ; Check for a match of a prefix pattern wildcard character.

        lda     ZP_TEMP1                        ; Load the prefix pattern wildcard character.

        cmp     #' '                            ; Handle ' ' wildcard (space).
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_SPACE     ;
@       cmp     #'#'                            ; Handle '#' wildcard (vowel).
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_HASH      ;
@       cmp     #'.'                            ; Handle '.' wildcard.
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_PERIOD    ;
@       cmp     #'&'                            ; Handle '&' wildcard.
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_AMPERSAND ;
@       cmp     #'@'                            ; Handle '@' wildcard.
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_AT_SIGN   ;
@       cmp     #'^'                            ; Handle '^' wildcard (consonant).
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_CARET     ;
@       cmp     #'+'                            ; Handle '+' wildcard (E/I/Y).
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_PLUS      ;
@       cmp     #':'                            ; Handle ':' wildcard.
        bne     @+                              ;
        jmp     MATCH_PREFIX_WILDCARD_COLON     ;

@       jmp     SAM_ERROR_SOUND                 ; Any other wildcard character: signal error.
        ;brk                                     ; This should never happen. Abort.

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_SPACE:

        ; A space character in a rule matches a small pause in the vocalisation -- a "space".
        ;
        ; Any character that is not A-Z or a single quote matches this.
        ; Single quotes are assumed to also imply that the character is preceded by a letter,
        ; e.g. "haven't" or "brother's".

        jsr     GET_PREFIX_CHARACTER_PROPERTIES ;
        ;and     #$80                            ;
        ;beq     MATCH_PREFIX_SUCCESS_2          ; Match: space.
        bpl     MATCH_PREFIX_SUCCESS_2          ; Match: space.
	
        jmp     TRY_NEXT_RULE                   ; Mismatch: character is a letter or a single quote character.

; ----------------------------------------------------------------------------

MATCH_PREFIX_SUCCESS_2:

        stx     ZP_RB_PREFIX_INDEX              ;
        jmp     MATCH_NEXT_PREFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_HASH:

        ; A '#' character in a rule matches a vowel, i.e., any of:
        ;     {A, E, I, O, U, Y}.

        jsr     GET_PREFIX_CHARACTER_PROPERTIES ;
        and     #$40                            ;
        bne     MATCH_PREFIX_SUCCESS_2          ; Match: vowel.
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_PERIOD:

        ; A '.' character in a rule matches any of the letters {B, D, G, J, L, M, N, R, V, W, Z}.

        jsr     GET_PREFIX_CHARACTER_PROPERTIES ;
        and     #$08                            ;
        bne     MATCH_PREFIX_SUCCESS_3          ; Match: {B, D, G, J, L, M, N, R, V, W, Z}.
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_PREFIX_SUCCESS_3:

        stx     ZP_RB_PREFIX_INDEX              ;
        jmp     MATCH_NEXT_PREFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_AMPERSAND:

        ; A '&' character in the rule matches any of the letters {C, G, J, S, X, Z} or a two-letter combination {CH, SH}.

        jsr     GET_PREFIX_CHARACTER_PROPERTIES ;
        and     #$10                            ;
        bne     MATCH_PREFIX_SUCCESS_3          ; Match: {C, G, J, S, X, Z}.
        lda     RECITER_BUFFER,x                ;
        cmp     #'H'                            ;
        beq     @+                              ;
        jmp     TRY_NEXT_RULE                   ; Mismatch.

@       dex                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'C'                            ;
        beq     MATCH_PREFIX_SUCCESS_3          ; Match: "CH".
        cmp     #'S'                            ;
        beq     MATCH_PREFIX_SUCCESS_3          ; Match: "SH".
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_AT_SIGN:

        ; A '@' character in the rule being matched indicates any of the letters {D, J, L, N, R, S, T, Z} or a two-letter combination {TH, CH, SH}.

        jsr     GET_PREFIX_CHARACTER_PROPERTIES ;
        and     #$04                            ;
        bne     MATCH_PREFIX_SUCCESS_3          ; Match: {D, J, L, N, R, S, T, Z}.
        lda     RECITER_BUFFER,x                ;
        cmp     #'H'                            ;
        beq     @+                              ;
        jmp     TRY_NEXT_RULE                   ; Mismatch.

@       cmp     #'T'                            ; *** BUG *** Forgot to go to the next letter, yikes!
        beq     MATCH_PREFIX_SUCCESS_4          ; All comparisons will fail.
        cmp     #'C'                            ;
        beq     MATCH_PREFIX_SUCCESS_4          ;
        cmp     #'S'                            ;
        beq     MATCH_PREFIX_SUCCESS_4          ;
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_PREFIX_SUCCESS_4:

        stx     ZP_RB_PREFIX_INDEX              ;
        jmp     MATCH_NEXT_PREFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_CARET:

        ; A '^' character matches a consonant, i.e., any of:
        ;     {B, C, D, F, G, H, J, K, L, M, N, P, Q, R, S, T, V, W, X, Z}.

        jsr     GET_PREFIX_CHARACTER_PROPERTIES ;
        and     #$20                            ;
        bne     MATCH_PREFIX_SUCCESS_5          ; Match: consonant.
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_PREFIX_SUCCESS_5:

        stx     ZP_RB_PREFIX_INDEX              ;
        jmp     MATCH_NEXT_PREFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_PLUS:

        ; A '+' character matches any of the letters {E, I, Y}.

        ldx     ZP_RB_PREFIX_INDEX              ;
        dex                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'E'                            ;
        beq     MATCH_PREFIX_SUCCESS_5          ; Match: "E".
        cmp     #'I'                            ;
        beq     MATCH_PREFIX_SUCCESS_5          ; Match: "I".
        cmp     #'Y'                            ;
        beq     MATCH_PREFIX_SUCCESS_5          ; Match: "Y".
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_PREFIX_WILDCARD_COLON:

        ; Match zero or more consonants.

        jsr     GET_PREFIX_CHARACTER_PROPERTIES ;
        and     #$20                            ;
        bne     @consonant                      ;
        jmp     MATCH_NEXT_PREFIX_CHARACTER     ; Not a consonant. Proceed to the next prefix pattern character.
@consonant:
        stx     ZP_RB_PREFIX_INDEX              ;
        jmp     MATCH_PREFIX_WILDCARD_COLON     ;

; ----------------------------------------------------------------------------

GET_PREFIX_CHARACTER_PROPERTIES:

        ldx     ZP_RB_PREFIX_INDEX              ;
        dex                                     ;
        lda     RECITER_BUFFER,x                ;
        tay                                     ;
        lda     CHARACTER_PROPERTIES,y          ;
        rts                                     ;

; ----------------------------------------------------------------------------

GET_SUFFIX_CHARACTER_PROPERTIES:

        ldx     ZP_RB_SUFFIX_INDEX              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        tay                                     ;
        lda     CHARACTER_PROPERTIES,y          ;
        rts                                     ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_PERCENT:

        ldx     ZP_RB_SUFFIX_INDEX              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'E'                            ;
        bne     _2                              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        tay                                     ;
        dex                                     ;
        lda     CHARACTER_PROPERTIES,y          ;
        ;and     #$80                            ;
        ;beq     @MATCH_SUFFIX_SUCCESS_1         ;
        bpl     @MATCH_SUFFIX_SUCCESS_1         ;
	
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'R'                            ;

        bne     @continue                       ;

; ----------------------------------------------------------------------------

@MATCH_SUFFIX_SUCCESS_1:

        stx     ZP_RB_SUFFIX_INDEX              ;
        jmp     MATCH_NEXT_SUFFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

@continue:

        cmp     #'S'                            ;
        beq     @MATCH_SUFFIX_SUCCESS_1         ;
        cmp     #'D'                            ;
        beq     @MATCH_SUFFIX_SUCCESS_1         ;
        cmp     #'L'                            ;
        bne     _1                              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'Y'                            ;
        bne     _3                              ;
        beq     @MATCH_SUFFIX_SUCCESS_1         ;
_1      cmp     #'F'                            ;
        bne     _3                              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'U'                            ;
        bne     _3                              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'L'                            ;
        beq     @MATCH_SUFFIX_SUCCESS_1         ;
        bne     _3                              ;
_2      cmp     #'I'                            ;
        bne     _3                              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'N'                            ;
        bne     _3                              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'G'                            ;
        beq     @MATCH_SUFFIX_SUCCESS_1         ;
_3      jmp     TRY_NEXT_RULE                   ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX:

        ; After successfully matching the stem pattern and the prefix pattern, try to match the suffix pattern.
        ; The suffix pattern of a rule definition is the characters after the ')' and before the '='.
        ; Like the prefix pattern, the suffix pattern may include wildcard characters.

        lda     ZP_RB_LAST_CHAR_INDEX           ; Index to the anchor character in the English source text.
        sta     ZP_RB_SUFFIX_INDEX              ;

; ----------------------------------------------------------------------------

MATCH_NEXT_SUFFIX_CHARACTER:

        ldy     ZP_RULE_SUFFIX_INDEX            ; Load the next character of the suffix pattern, going from left to right.
        iny                                     ;
        cpy     ZP_TEMP2                        ; Compare to location of '=' character in rule.
        bne     @+                              ;
        jmp     APPLY_RULE                      ; We've reached the end of the suffix pattern. The match was successful, apply the rule.

@       sty     ZP_RULE_SUFFIX_INDEX            ;
        lda     (ZP_RULE_PTR),y                 ;
        sta     ZP_TEMP1                        ; The suffix pattern character to be matched.
        tax                                     ;
        lda     CHARACTER_PROPERTIES,x          ;
        ;and     #$80                            ; A-Z and the single quote character are matched directly below.
        ;beq     MATCH_SUFFIX_WILDCARD           ; Anything else is handled by MATCH_SUFFIX_WILDCARD.
        bpl     MATCH_SUFFIX_WILDCARD           ; Anything else is handled by MATCH_SUFFIX_WILDCARD.

        ldx     ZP_RB_SUFFIX_INDEX              ; Load the source character.
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     ZP_TEMP1                        ; Compare suffix pattern character with source character.
        beq     MATCH_SUFFIX_SUCCESS_2          ; They are identical. Proceed to the next character.
        jmp     TRY_NEXT_RULE                   ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX_SUCCESS_2:

        stx     ZP_RB_SUFFIX_INDEX              ;
        jmp     MATCH_NEXT_SUFFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD:

        ; Check for match of a suffix pattern wildcard character.

        lda     ZP_TEMP1                        ; Load the match rule placeholder character.

        cmp     #' '                            ; Handle ' ' wildcard (space).
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_SPACE     ;
@       cmp     #'#'                            ; Handle '#' wildcard (vowel).
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_HASH      ;
@       cmp     #'.'                            ; Handle '.' wildcard.
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_PERIOD    ;
@       cmp     #'&'                            ; Handle '&' wildcard.
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_AMPERSAND ;
@       cmp     #'@'                            ; Handle '@' wildcard.
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_AT_SIGN   ;
@       cmp     #'^'                            ; Handle '^' wildcard (consonant).
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_CARET     ;
@       cmp     #'+'                            ; Handle '+' wildcard (E/I/Y).
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_PLUS      ;
@       cmp     #':'                            ; Handle ':' wildcard.
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_COLON     ;
@       cmp     #'%'                            ; Handle '%' wildcard.
        bne     @+                              ;
        jmp     MATCH_SUFFIX_WILDCARD_PERCENT   ;

@       jmp     SAM_ERROR_SOUND                 ; Any other wildcard character: signal error.
        ;brk                                     ; This should never happen. Abort.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_SPACE:

        ; A space character matches a small pause in the vocalisation -- a "space".
        ;
        ; Any character that is not A-Z or a single quote matches this.
        ; Single quotes are assumed to also imply that the character is preceded by a letter,
        ; e.g. "haven't" or "brother's".

        jsr     GET_SUFFIX_CHARACTER_PROPERTIES ;
        ;and     #$80                            ;
        ;beq     MATCH_SUFFIX_SUCCESS_3          ; Match: space.
        bpl     MATCH_SUFFIX_SUCCESS_3          ; Match: space.
	
        jmp     TRY_NEXT_RULE                   ; Mismatch: character is a letter or a single quote character.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_SUCCESS_3:

        stx     ZP_RB_SUFFIX_INDEX              ;
        jmp     MATCH_NEXT_SUFFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_HASH:

        ; A '#' character in the rule matches a vowel, i.e., any of:
        ;     {A, E, I, O, U, Y}.

        jsr     GET_SUFFIX_CHARACTER_PROPERTIES ;
        and     #$40                            ;
        bne     MATCH_SUFFIX_SUCCESS_3          ; Match: vowel.
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_PERIOD:

        ; A '.' character in the rule matches any of the letters {B, D, G, J, L, M, N, R, V, W, Z}.

        jsr     GET_SUFFIX_CHARACTER_PROPERTIES ;
        and     #$08                            ;
        bne     MATCH_SUFFIX_SUCCESS_4          ; Match: {B, D, G, J, L, M, N, R, V, W, Z}.
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_SUCCESS_4:

        stx     ZP_RB_SUFFIX_INDEX              ;
        jmp     MATCH_NEXT_SUFFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_AMPERSAND:

        ; A '&' character in the rule tries to match any of the letters {C, G, J, S, X, Z} or a two-letter combination {CH, SH}.
        ;
        ; That's the intention, but there is a bug here.
        ;
        ; *** BUG *** This code is more-or-less identical to the code in MATCH_PREFIX_AMPERSAND,
        ;             but here we're scanning from left-to-right, which is makes a difference for
        ;             handling the two-character matches.
        ;
        ; Intended behavior : match C / G / J / S / X / Z / CH / SH
        ; Actual behavior   : match C / G / J / S / X / Z / HC / HS

        jsr     GET_SUFFIX_CHARACTER_PROPERTIES ;
        and     #$10                            ;
        bne     MATCH_SUFFIX_SUCCESS_4          ; Match: {C, G, J, S, X, Z}.
        lda     RECITER_BUFFER,x                ;
        cmp     #'H'                            ;
        beq     @+                              ;
        jmp     TRY_NEXT_RULE                   ;

@       inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'C'                            ;
        beq     MATCH_SUFFIX_SUCCESS_4          ; Match: "HC".
        cmp     #'S'                            ;
        beq     MATCH_SUFFIX_SUCCESS_4          ; Match: "HS".
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_AT_SIGN:

        ; A '@' character in the rule tries to match any of the letters {D / J / L / N / R / S / T / Z}
        ;   or a two-letter combination {TH, CH, SH}.
        ;
        ; That's the intention, but there is a bug here.
        ;
        ; *** BUG *** This code is more-or-less identical to the code in MATCH_PREFIX_AT_SIGN,
        ;             but here we're scanning from left-to-right, which is makes a difference for
        ;             handling the two-character matches.
        ;
        ; Intended behavior : match D / J / L / N / R / S / T / Z / TH / CH / SH.
        ; Actual behavior   : match D / J / L / N / R / S / T / Z / HT / HC / HS.

        jsr     GET_SUFFIX_CHARACTER_PROPERTIES ;
        and     #$04                            ;
        bne     MATCH_SUFFIX_SUCCESS_4          ; Match: {D, J, L, N, R, S, T, Z}.
        lda     RECITER_BUFFER,x                ;
        cmp     #'H'                            ;
        beq     @+                              ;
        jmp     TRY_NEXT_RULE                   ; Mismatch.

@       cmp     #'T'                            ;
        beq     MATCH_SUFFIX_SUCCESS_5          ; Match: "HT".
        cmp     #'C'                            ;
        beq     MATCH_SUFFIX_SUCCESS_5          ; Match: "HC".
        cmp     #'S'                            ;
        beq     MATCH_SUFFIX_SUCCESS_5          ; Match: "HS".
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_SUCCESS_5:

        stx     ZP_RB_SUFFIX_INDEX              ;
        jmp     MATCH_NEXT_SUFFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_CARET:

        ; A '^' character matches a consonant, i.e., any of:
        ;     {B, C, D, F, G, H, J, K, L, M, N, P, Q, R, S, T, V, W, X, Z}.

        jsr     GET_SUFFIX_CHARACTER_PROPERTIES ;
        and     #$20                            ;
        bne     MATCH_SUFFIX_SUCCESS_6          ; Match: consonant.
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_SUCCESS_6:

        stx     ZP_RB_SUFFIX_INDEX              ;
        jmp     MATCH_NEXT_SUFFIX_CHARACTER     ;

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_PLUS:

        ; A '+' character matches any of the letters {E, I, Y}.

        ldx     ZP_RB_SUFFIX_INDEX              ;
        inx                                     ;
        lda     RECITER_BUFFER,x                ;
        cmp     #'E'                            ;
        beq     MATCH_SUFFIX_SUCCESS_6          ; Match "E".
        cmp     #'I'                            ;
        beq     MATCH_SUFFIX_SUCCESS_6          ; Match "I".
        cmp     #'Y'                            ;
        beq     MATCH_SUFFIX_SUCCESS_6          ; Match "Y".
        jmp     TRY_NEXT_RULE                   ; Mismatch.

; ----------------------------------------------------------------------------

MATCH_SUFFIX_WILDCARD_COLON:

        ; Match zero or more consonants.

        jsr     GET_SUFFIX_CHARACTER_PROPERTIES ;
        and     #$20                            ;
        bne     _consonant                      ; consonant.
        jmp     MATCH_NEXT_SUFFIX_CHARACTER     ; non-consonant.
_consonant:
        stx     ZP_RB_SUFFIX_INDEX              ;
        jmp     MATCH_SUFFIX_WILDCARD_COLON     ;

; ----------------------------------------------------------------------------

APPLY_RULE:

        ; The rule fully matches; perform the translation.

        ldy     ZP_TEMP2                        ; Location of '=' character.
        lda     ZP_RB_LAST_CHAR_INDEX           ;
        sta     ZP_RECITER_BUFFER_INDEX         ; Update ZP_RECITER_BUFFER_INDEX.
_loop:  lda     (ZP_RULE_PTR),y                 ; Load rule character.
        sta     ZP_TEMP1                        ; Save to ZP_TEMP1, for end-of-loop sign bit check.
        and     #$7F                            ; Make sure sign bit is not set.
        cmp     #'='                            ; Is it an '=' character?
        beq     _skip                           ; Yes, skip character copy.
        inc     ZP_SAM_BUFFER_INDEX             ; Copy rule replacement character to the SAM_BUFFER,
        ldx     ZP_SAM_BUFFER_INDEX             ; and increment ZP_SAM_BUFFER_INDEX.
        sta     SAM_BUFFER,x                    ;
_skip:  bit     ZP_TEMP1                        ; Was the most significant bit of the rule character set?
        bpl     _proceed                        ; No: proceed to next rule character.

        jmp     TRANSLATE_NEXT_CHARACTER        ; Yes: Done copying; proceed with the next character.

_proceed:

        iny                                     ; Proceed to next rule character.
        jmp     _loop                           ;

; ----------------------------------------------------------------------------

PTAB_INDEX_LO:                  ; LSB of starting address of pronunciation rules specific to A..Z.

        dta l(PTAB_A,PTAB_B,PTAB_C,PTAB_D,PTAB_E,PTAB_F,PTAB_G,PTAB_H,PTAB_I,PTAB_J,PTAB_K,PTAB_L,PTAB_M)
        dta l(PTAB_N,PTAB_O,PTAB_P,PTAB_Q,PTAB_R,PTAB_S,PTAB_T,PTAB_U,PTAB_V,PTAB_W,PTAB_X,PTAB_Y,PTAB_Z)

PTAB_INDEX_HI:                  ; MSB of starting address of pronunciation rules specific to A..Z.

        dta h(PTAB_A,PTAB_B,PTAB_C,PTAB_D,PTAB_E,PTAB_F,PTAB_G,PTAB_H,PTAB_I,PTAB_J,PTAB_K,PTAB_L,PTAB_M)
        dta h(PTAB_N,PTAB_O,PTAB_P,PTAB_Q,PTAB_R,PTAB_S,PTAB_T,PTAB_U,PTAB_V,PTAB_W,PTAB_X,PTAB_Y,PTAB_Z)

; ----------------------------------------------------------------------------
/*
        ; This is the startup code.
        ; RUNAD will point here after opening the file, so exection starts here.

        ; Store TRAILER address into MEMLO, and into $864 / $869. The latter is a DOS patch, perhaps?


_start: lda     <TRAILER
        sta     MEMLO
        sta     $864
        lda     >TRAILER
        sta     MEMLO+1
        sta     $869
        lda     #0                               ; Reset WARMST to zero.
        sta     WARMST
        rts
*/
; ----------------------------------------------------------------------------

                       ; List of the 442 pronunciation rules.

PTAB_MISC

; pronunciation_rule     "(A)"        , ""
	.he  28 
	.he  41 
	.he  29 
	.he  BD 
; pronunciation_rule     "(!)"        , "."
	.he  28 
	.he  21 
	.he  29 
	.he  3D 
	.he  AE 
; pronunciation_rule     "(\") "      , "-AH5NKWOWT-"
	.he  28 
	.he  22 
	.he  29 
	.he  20 
	.he  3D 
	.he  2D 
	.he  41 
	.he  48 
	.he  35 
	.he  4E 
	.he  4B 
	.he  57 
	.he  4F 
	.he  57 
	.he  54 
	.he  AD 
; pronunciation_rule     "(\")"       , "KWOW4T-"
	.he  28 
	.he  22 
	.he  29 
	.he  3D 
	.he  4B 
	.he  57 
	.he  4F 
	.he  57 
	.he  34 
	.he  54 
	.he  AD 
; pronunciation_rule     "(#)"        , " NAH4MBER"
	.he  28 
	.he  23 
	.he  29 
	.he  3D 
	.he  20 
	.he  4E 
	.he  41 
	.he  48 
	.he  34 
	.he  4D 
	.he  42 
	.he  45 
	.he  D2 
; pronunciation_rule     "($)"        , " DAA4LER"
	.he  28 
	.he  24 
	.he  29 
	.he  3D 
	.he  20 
	.he  44 
	.he  41 
	.he  41 
	.he  34 
	.he  4C 
	.he  45 
	.he  D2 
; pronunciation_rule     "(%)"        , " PERSEH4NT"
	.he  28 
	.he  25 
	.he  29 
	.he  3D 
	.he  20 
	.he  50 
	.he  45 
	.he  52 
	.he  53 
	.he  45 
	.he  48 
	.he  34 
	.he  4E 
	.he  D4 
; pronunciation_rule     "(&)"        , " AEND"
	.he  28 
	.he  26 
	.he  29 
	.he  3D 
	.he  20 
	.he  41 
	.he  45 
	.he  4E 
	.he  C4 
; pronunciation_rule     "(')"        , ""
	.he  28 
	.he  27 
	.he  29 
	.he  BD 
; pronunciation_rule     "(*)"        , " AE4STERIHSK"
	.he  28 
	.he  2A 
	.he  29 
	.he  3D 
	.he  20 
	.he  41 
	.he  45 
	.he  34 
	.he  53 
	.he  54 
	.he  45 
	.he  52 
	.he  49 
	.he  48 
	.he  53 
	.he  CB 
; pronunciation_rule     "(+)"        , " PLAH4S"
	.he  28 
	.he  2B 
	.he  29 
	.he  3D 
	.he  20 
	.he  50 
	.he  4C 
	.he  41 
	.he  48 
	.he  34 
	.he  D3 
; pronunciation_rule     "(,)"        , ","
	.he  28 
	.he  2C 
	.he  29 
	.he  3D 
	.he  AC 
; pronunciation_rule     " (-) "      , "-"
	.he  20 
	.he  28 
	.he  2D 
	.he  29 
	.he  20 
	.he  3D 
	.he  AD 
; pronunciation_rule     "(-)"        , ""
	.he  28 
	.he  2D 
	.he  29 
	.he  BD 
; pronunciation_rule     "(.)"        , " POYNT"
	.he  28 
	.he  2E 
	.he  29 
	.he  3D 
	.he  20 
	.he  50 
	.he  4F 
	.he  59 
	.he  4E 
	.he  D4 
; pronunciation_rule     "(/)"        , " SLAE4SH"
	.he  28 
	.he  2F 
	.he  29 
	.he  3D 
	.he  20 
	.he  53 
	.he  4C 
	.he  41 
	.he  45 
	.he  34 
	.he  53 
	.he  C8 
; pronunciation_rule     "(0)"        , " ZIY4ROW"
	.he  28 
	.he  30 
	.he  29 
	.he  3D 
	.he  20 
	.he  5A 
	.he  49 
	.he  59 
	.he  34 
	.he  52 
	.he  4F 
	.he  D7 
; pronunciation_rule     " (1ST)"     , "FER4ST"
	.he  20 
	.he  28 
	.he  31 
	.he  53 
	.he  54 
	.he  29 
	.he  3D 
	.he  46 
	.he  45 
	.he  52 
	.he  34 
	.he  53 
	.he  D4 
; pronunciation_rule     " (10TH)"    , "TEH4NTH"
	.he  20 
	.he  28 
	.he  31 
	.he  30 
	.he  54 
	.he  48 
	.he  29 
	.he  3D 
	.he  54 
	.he  45 
	.he  48 
	.he  34 
	.he  4E 
	.he  54 
	.he  C8 
; pronunciation_rule     "(1)"        , " WAH4N"
	.he  28 
	.he  31 
	.he  29 
	.he  3D 
	.he  20 
	.he  57 
	.he  41 
	.he  48 
	.he  34 
	.he  CE 
; pronunciation_rule     " (2ND)"     , "SEH4KUND"
	.he  20 
	.he  28 
	.he  32 
	.he  4E 
	.he  44 
	.he  29 
	.he  3D 
	.he  53 
	.he  45 
	.he  48 
	.he  34 
	.he  4B 
	.he  55 
	.he  4E 
	.he  C4 
; pronunciation_rule     "(2)"        , " TUW4"
	.he  28 
	.he  32 
	.he  29 
	.he  3D 
	.he  20 
	.he  54 
	.he  55 
	.he  57 
	.he  B4 
; pronunciation_rule     " (3RD)"     , "THER4D"
	.he  20 
	.he  28 
	.he  33 
	.he  52 
	.he  44 
	.he  29 
	.he  3D 
	.he  54 
	.he  48 
	.he  45 
	.he  52 
	.he  34 
	.he  C4 
; pronunciation_rule     "(3)"        , " THRIY4"
	.he  28 
	.he  33 
	.he  29 
	.he  3D 
	.he  20 
	.he  54 
	.he  48 
	.he  52 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "(4)"        , " FOH4R"
	.he  28 
	.he  34 
	.he  29 
	.he  3D 
	.he  20 
	.he  46 
	.he  4F 
	.he  48 
	.he  34 
	.he  D2 
; pronunciation_rule     " (5TH)"     , "FIH4FTH"
	.he  20 
	.he  28 
	.he  35 
	.he  54 
	.he  48 
	.he  29 
	.he  3D 
	.he  46 
	.he  49 
	.he  48 
	.he  34 
	.he  46 
	.he  54 
	.he  C8 
; pronunciation_rule     "(5)"        , " FAY4V"
	.he  28 
	.he  35 
	.he  29 
	.he  3D 
	.he  20 
	.he  46 
	.he  41 
	.he  59 
	.he  34 
	.he  D6 
; pronunciation_rule     "(6)"        , " SIH4KS"
	.he  28 
	.he  36 
	.he  29 
	.he  3D 
	.he  20 
	.he  53 
	.he  49 
	.he  48 
	.he  34 
	.he  4B 
	.he  D3 
; pronunciation_rule     "(7)"        , " SEH4VUN"
	.he  28 
	.he  37 
	.he  29 
	.he  3D 
	.he  20 
	.he  53 
	.he  45 
	.he  48 
	.he  34 
	.he  56 
	.he  55 
	.he  CE 
; pronunciation_rule     " (8TH)"     , "EY4TH"
	.he  20 
	.he  28 
	.he  38 
	.he  54 
	.he  48 
	.he  29 
	.he  3D 
	.he  45 
	.he  59 
	.he  34 
	.he  54 
	.he  C8 
; pronunciation_rule     "(8)"        , " EY4T"
	.he  28 
	.he  38 
	.he  29 
	.he  3D 
	.he  20 
	.he  45 
	.he  59 
	.he  34 
	.he  D4 
; pronunciation_rule     "(9)"        , " NAY4N"
	.he  28 
	.he  39 
	.he  29 
	.he  3D 
	.he  20 
	.he  4E 
	.he  41 
	.he  59 
	.he  34 
	.he  CE 
; pronunciation_rule     "(:)"        , "."
	.he  28 
	.he  3A 
	.he  29 
	.he  3D 
	.he  AE 
; pronunciation_rule     "(;)"        , "."
	.he  28 
	.he  3B 
	.he  29 
	.he  3D 
	.he  AE 
; pronunciation_rule     "(<)"        , " LEH4S DHAEN"
	.he  28 
	.he  3C 
	.he  29 
	.he  3D 
	.he  20 
	.he  4C 
	.he  45 
	.he  48 
	.he  34 
	.he  53 
	.he  20 
	.he  44 
	.he  48 
	.he  41 
	.he  45 
	.he  CE 
; pronunciation_rule     "(=)"        , " IY4KWULZ"
	.he  28 
	.he  3D 
	.he  29 
	.he  3D 
	.he  20 
	.he  49 
	.he  59 
	.he  34 
	.he  4B 
	.he  57 
	.he  55 
	.he  4C 
	.he  DA 
; pronunciation_rule     "(>)"        , " GREY4TER DHAEN"
	.he  28 
	.he  3E 
	.he  29 
	.he  3D 
	.he  20 
	.he  47 
	.he  52 
	.he  45 
	.he  59 
	.he  34 
	.he  54 
	.he  45 
	.he  52 
	.he  20 
	.he  44 
	.he  48 
	.he  41 
	.he  45 
	.he  CE 
; pronunciation_rule     "(?)"        , "."
	.he  28 
	.he  3F 
	.he  29 
	.he  3D 
	.he  AE 
; pronunciation_rule     "(@)"        , " AE6T"
	.he  28 
	.he  40 
	.he  29 
	.he  3D 
	.he  20 
	.he  41 
	.he  45 
	.he  36 
	.he  D4 
; pronunciation_rule     "(^)"        , " KAE4RIXT"
	.he  28 
	.he  5E 
	.he  29 
	.he  3D 
	.he  20 
	.he  4B 
	.he  41 
	.he  45 
	.he  34 
	.he  52 
	.he  49 
	.he  58 
	.he  D4 
PTAB_A:		; pronunciation_index    "A"
	.he  5D 
	.he  C1 
; pronunciation_rule     " (A.)"      , "EH4Y. "
	.he  20 
	.he  28 
	.he  41 
	.he  2E 
	.he  29 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  59 
	.he  2E 
	.he  A0 
; pronunciation_rule     "(A) "       , "AH"
	.he  28 
	.he  41 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  C8 
; pronunciation_rule     " (ARE) "    , "AAR"
	.he  20 
	.he  28 
	.he  41 
	.he  52 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  41 
	.he  D2 
; pronunciation_rule     " (AR)O"     , "AXR"
	.he  20 
	.he  28 
	.he  41 
	.he  52 
	.he  29 
	.he  4F 
	.he  3D 
	.he  41 
	.he  58 
	.he  D2 
; pronunciation_rule     "(AR)#"      , "EH4R"
	.he  28 
	.he  41 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  D2 
; pronunciation_rule     " ^(AS)#"    , "EY4S"
	.he  20 
	.he  5E 
	.he  28 
	.he  41 
	.he  53 
	.he  29 
	.he  23 
	.he  3D 
	.he  45 
	.he  59 
	.he  34 
	.he  D3 
; pronunciation_rule     "(A)WA"      , "AX"
	.he  28 
	.he  41 
	.he  29 
	.he  57 
	.he  41 
	.he  3D 
	.he  41 
	.he  D8 
; pronunciation_rule     "(AW)"       , "AO5"
	.he  28 
	.he  41 
	.he  57 
	.he  29 
	.he  3D 
	.he  41 
	.he  4F 
	.he  B5 
; pronunciation_rule     " :(ANY)"    , "EH4NIY"
	.he  20 
	.he  3A 
	.he  28 
	.he  41 
	.he  4E 
	.he  59 
	.he  29 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  4E 
	.he  49 
	.he  D9 
; pronunciation_rule     "(A)^+#"     , "EY5"
	.he  28 
	.he  41 
	.he  29 
	.he  5E 
	.he  2B 
	.he  23 
	.he  3D 
	.he  45 
	.he  59 
	.he  B5 
; pronunciation_rule     "#:(ALLY)"   , "ULIY"
	.he  23 
	.he  3A 
	.he  28 
	.he  41 
	.he  4C 
	.he  4C 
	.he  59 
	.he  29 
	.he  3D 
	.he  55 
	.he  4C 
	.he  49 
	.he  D9 
; pronunciation_rule     " (AL)#"     , "UL"
	.he  20 
	.he  28 
	.he  41 
	.he  4C 
	.he  29 
	.he  23 
	.he  3D 
	.he  55 
	.he  CC 
; pronunciation_rule     "(AGAIN)"    , "AXGEH4N"
	.he  28 
	.he  41 
	.he  47 
	.he  41 
	.he  49 
	.he  4E 
	.he  29 
	.he  3D 
	.he  41 
	.he  58 
	.he  47 
	.he  45 
	.he  48 
	.he  34 
	.he  CE 
; pronunciation_rule     "#:(AG)E"    , "IHJ"
	.he  23 
	.he  3A 
	.he  28 
	.he  41 
	.he  47 
	.he  29 
	.he  45 
	.he  3D 
	.he  49 
	.he  48 
	.he  CA 
; pronunciation_rule     "(A)^%"      , "EY"
	.he  28 
	.he  41 
	.he  29 
	.he  5E 
	.he  25 
	.he  3D 
	.he  45 
	.he  D9 
; pronunciation_rule     "(A)^+:#"    , "AE"
	.he  28 
	.he  41 
	.he  29 
	.he  5E 
	.he  2B 
	.he  3A 
	.he  23 
	.he  3D 
	.he  41 
	.he  C5 
; pronunciation_rule     " :(A)^+ "   , "EY4"
	.he  20 
	.he  3A 
	.he  28 
	.he  41 
	.he  29 
	.he  5E 
	.he  2B 
	.he  20 
	.he  3D 
	.he  45 
	.he  59 
	.he  B4 
; pronunciation_rule     " (ARR)"     , "AXR"
	.he  20 
	.he  28 
	.he  41 
	.he  52 
	.he  52 
	.he  29 
	.he  3D 
	.he  41 
	.he  58 
	.he  D2 
; pronunciation_rule     "(ARR)"      , "AE4R"
	.he  28 
	.he  41 
	.he  52 
	.he  52 
	.he  29 
	.he  3D 
	.he  41 
	.he  45 
	.he  34 
	.he  D2 
; pronunciation_rule     " ^(AR) "    , "AA5R"
	.he  20 
	.he  5E 
	.he  28 
	.he  41 
	.he  52 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  41 
	.he  35 
	.he  D2 
; pronunciation_rule     "(AR)"       , "AA5R"
	.he  28 
	.he  41 
	.he  52 
	.he  29 
	.he  3D 
	.he  41 
	.he  41 
	.he  35 
	.he  D2 
; pronunciation_rule     "(AIR)"      , "EH4R"
	.he  28 
	.he  41 
	.he  49 
	.he  52 
	.he  29 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  D2 
; pronunciation_rule     "(AI)"       , "EY4"
	.he  28 
	.he  41 
	.he  49 
	.he  29 
	.he  3D 
	.he  45 
	.he  59 
	.he  B4 
; pronunciation_rule     "(AY)"       , "EY5"
	.he  28 
	.he  41 
	.he  59 
	.he  29 
	.he  3D 
	.he  45 
	.he  59 
	.he  B5 
; pronunciation_rule     "(AU)"       , "AO4"
	.he  28 
	.he  41 
	.he  55 
	.he  29 
	.he  3D 
	.he  41 
	.he  4F 
	.he  B4 
; pronunciation_rule     "#:(AL) "    , "UL"
	.he  23 
	.he  3A 
	.he  28 
	.he  41 
	.he  4C 
	.he  29 
	.he  20 
	.he  3D 
	.he  55 
	.he  CC 
; pronunciation_rule     "#:(ALS) "   , "ULZ"
	.he  23 
	.he  3A 
	.he  28 
	.he  41 
	.he  4C 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  55 
	.he  4C 
	.he  DA 
; pronunciation_rule     "(ALK)"      , "AO4K"
	.he  28 
	.he  41 
	.he  4C 
	.he  4B 
	.he  29 
	.he  3D 
	.he  41 
	.he  4F 
	.he  34 
	.he  CB 
; pronunciation_rule     "(AL)^"      , "AOL"
	.he  28 
	.he  41 
	.he  4C 
	.he  29 
	.he  5E 
	.he  3D 
	.he  41 
	.he  4F 
	.he  CC 
; pronunciation_rule     " :(ABLE)"   , "EY4BUL"
	.he  20 
	.he  3A 
	.he  28 
	.he  41 
	.he  42 
	.he  4C 
	.he  45 
	.he  29 
	.he  3D 
	.he  45 
	.he  59 
	.he  34 
	.he  42 
	.he  55 
	.he  CC 
; pronunciation_rule     "(ABLE)"     , "AXBUL"
	.he  28 
	.he  41 
	.he  42 
	.he  4C 
	.he  45 
	.he  29 
	.he  3D 
	.he  41 
	.he  58 
	.he  42 
	.he  55 
	.he  CC 
; pronunciation_rule     "(A)VO"      , "EY4"
	.he  28 
	.he  41 
	.he  29 
	.he  56 
	.he  4F 
	.he  3D 
	.he  45 
	.he  59 
	.he  B4 
; pronunciation_rule     "(ANG)+"     , "EY4NJ"
	.he  28 
	.he  41 
	.he  4E 
	.he  47 
	.he  29 
	.he  2B 
	.he  3D 
	.he  45 
	.he  59 
	.he  34 
	.he  4E 
	.he  CA 
; pronunciation_rule     "(ATARI)"    , "AHTAA4RIY"
	.he  28 
	.he  41 
	.he  54 
	.he  41 
	.he  52 
	.he  49 
	.he  29 
	.he  3D 
	.he  41 
	.he  48 
	.he  54 
	.he  41 
	.he  41 
	.he  34 
	.he  52 
	.he  49 
	.he  D9 
; pronunciation_rule     "(A)TOM"     , "AE"
	.he  28 
	.he  41 
	.he  29 
	.he  54 
	.he  4F 
	.he  4D 
	.he  3D 
	.he  41 
	.he  C5 
; pronunciation_rule     "(A)TTI"     , "AE"
	.he  28 
	.he  41 
	.he  29 
	.he  54 
	.he  54 
	.he  49 
	.he  3D 
	.he  41 
	.he  C5 
; pronunciation_rule     " (AT) "     , "AET"
	.he  20 
	.he  28 
	.he  41 
	.he  54 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  45 
	.he  D4 
; pronunciation_rule     " (A)T"      , "AH"
	.he  20 
	.he  28 
	.he  41 
	.he  29 
	.he  54 
	.he  3D 
	.he  41 
	.he  C8 
; pronunciation_rule     "(A)"        , "AE"
	.he  28 
	.he  41 
	.he  29 
	.he  3D 
	.he  41 
	.he  C5 
PTAB_B:		; pronunciation_index    "B"
	.he  5D 
	.he  C2 
; pronunciation_rule     " (B) "      , "BIY4"
	.he  20 
	.he  28 
	.he  42 
	.he  29 
	.he  20 
	.he  3D 
	.he  42 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     " (BE)^#"    , "BIH"
	.he  20 
	.he  28 
	.he  42 
	.he  45 
	.he  29 
	.he  5E 
	.he  23 
	.he  3D 
	.he  42 
	.he  49 
	.he  C8 
; pronunciation_rule     "(BEING)"    , "BIY4IHNX"
	.he  28 
	.he  42 
	.he  45 
	.he  49 
	.he  4E 
	.he  47 
	.he  29 
	.he  3D 
	.he  42 
	.he  49 
	.he  59 
	.he  34 
	.he  49 
	.he  48 
	.he  4E 
	.he  D8 
; pronunciation_rule     " (BOTH) "   , "BOW4TH"
	.he  20 
	.he  28 
	.he  42 
	.he  4F 
	.he  54 
	.he  48 
	.he  29 
	.he  20 
	.he  3D 
	.he  42 
	.he  4F 
	.he  57 
	.he  34 
	.he  54 
	.he  C8 
; pronunciation_rule     " (BUS)#"    , "BIH4Z"
	.he  20 
	.he  28 
	.he  42 
	.he  55 
	.he  53 
	.he  29 
	.he  23 
	.he  3D 
	.he  42 
	.he  49 
	.he  48 
	.he  34 
	.he  DA 
; pronunciation_rule     "(BREAK)"    , "BREY5K"
	.he  28 
	.he  42 
	.he  52 
	.he  45 
	.he  41 
	.he  4B 
	.he  29 
	.he  3D 
	.he  42 
	.he  52 
	.he  45 
	.he  59 
	.he  35 
	.he  CB 
; pronunciation_rule     "(BUIL)"     , "BIH4L"
	.he  28 
	.he  42 
	.he  55 
	.he  49 
	.he  4C 
	.he  29 
	.he  3D 
	.he  42 
	.he  49 
	.he  48 
	.he  34 
	.he  CC 
; pronunciation_rule     "(B)"        , "B"
	.he  28 
	.he  42 
	.he  29 
	.he  3D 
	.he  C2 
PTAB_C:		; pronunciation_index    "C"
	.he  5D 
	.he  C3 
; pronunciation_rule     " (C) "      , "SIY4"
	.he  20 
	.he  28 
	.he  43 
	.he  29 
	.he  20 
	.he  3D 
	.he  53 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     " (CH)^"     , "K"
	.he  20 
	.he  28 
	.he  43 
	.he  48 
	.he  29 
	.he  5E 
	.he  3D 
	.he  CB 
; pronunciation_rule     "^E(CH)"     , "K"
	.he  5E 
	.he  45 
	.he  28 
	.he  43 
	.he  48 
	.he  29 
	.he  3D 
	.he  CB 
; pronunciation_rule     "(CHA)R#"    , "KEH5"
	.he  28 
	.he  43 
	.he  48 
	.he  41 
	.he  29 
	.he  52 
	.he  23 
	.he  3D 
	.he  4B 
	.he  45 
	.he  48 
	.he  B5 
; pronunciation_rule     "(CH)"       , "CH"
	.he  28 
	.he  43 
	.he  48 
	.he  29 
	.he  3D 
	.he  43 
	.he  C8 
; pronunciation_rule     " S(CI)#"    , "SAY4"
	.he  20 
	.he  53 
	.he  28 
	.he  43 
	.he  49 
	.he  29 
	.he  23 
	.he  3D 
	.he  53 
	.he  41 
	.he  59 
	.he  B4 
; pronunciation_rule     "(CI)A"      , "SH"
	.he  28 
	.he  43 
	.he  49 
	.he  29 
	.he  41 
	.he  3D 
	.he  53 
	.he  C8 
; pronunciation_rule     "(CI)O"      , "SH"
	.he  28 
	.he  43 
	.he  49 
	.he  29 
	.he  4F 
	.he  3D 
	.he  53 
	.he  C8 
; pronunciation_rule     "(CI)EN"     , "SH"
	.he  28 
	.he  43 
	.he  49 
	.he  29 
	.he  45 
	.he  4E 
	.he  3D 
	.he  53 
	.he  C8 
; pronunciation_rule     "(CITY)"     , "SIHTIY"
	.he  28 
	.he  43 
	.he  49 
	.he  54 
	.he  59 
	.he  29 
	.he  3D 
	.he  53 
	.he  49 
	.he  48 
	.he  54 
	.he  49 
	.he  D9 
; pronunciation_rule     "(C)+"       , "S"
	.he  28 
	.he  43 
	.he  29 
	.he  2B 
	.he  3D 
	.he  D3 
; pronunciation_rule     "(CK)"       , "K"
	.he  28 
	.he  43 
	.he  4B 
	.he  29 
	.he  3D 
	.he  CB 
; pronunciation_rule     "(COM)"      , "KAHM"
	.he  28 
	.he  43 
	.he  4F 
	.he  4D 
	.he  29 
	.he  3D 
	.he  4B 
	.he  41 
	.he  48 
	.he  CD 
; pronunciation_rule     "(CUIT)"     , "KIHT"
	.he  28 
	.he  43 
	.he  55 
	.he  49 
	.he  54 
	.he  29 
	.he  3D 
	.he  4B 
	.he  49 
	.he  48 
	.he  D4 
; pronunciation_rule     "(CREA)"     , "KRIYEY"
	.he  28 
	.he  43 
	.he  52 
	.he  45 
	.he  41 
	.he  29 
	.he  3D 
	.he  4B 
	.he  52 
	.he  49 
	.he  59 
	.he  45 
	.he  D9 
; pronunciation_rule     "(C)"        , "K"
	.he  28 
	.he  43 
	.he  29 
	.he  3D 
	.he  CB 
PTAB_D:		; pronunciation_index    "D"
	.he  5D 
	.he  C4 
; pronunciation_rule     " (D) "      , "DIY4"
	.he  20 
	.he  28 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     " (DR.) "    , "DAA4KTER"
	.he  20 
	.he  28 
	.he  44 
	.he  52 
	.he  2E 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  41 
	.he  41 
	.he  34 
	.he  4B 
	.he  54 
	.he  45 
	.he  D2 
; pronunciation_rule     "#:(DED) "   , "DIHD"
	.he  23 
	.he  3A 
	.he  28 
	.he  44 
	.he  45 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  49 
	.he  48 
	.he  C4 
; pronunciation_rule     ".E(D) "     , "D"
	.he  2E 
	.he  45 
	.he  28 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  C4 
; pronunciation_rule     "#:^E(D) "   , "T"
	.he  23 
	.he  3A 
	.he  5E 
	.he  45 
	.he  28 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  D4 
; pronunciation_rule     " (DE)^#"    , "DIH"
	.he  20 
	.he  28 
	.he  44 
	.he  45 
	.he  29 
	.he  5E 
	.he  23 
	.he  3D 
	.he  44 
	.he  49 
	.he  C8 
; pronunciation_rule     " (DO) "     , "DUW"
	.he  20 
	.he  28 
	.he  44 
	.he  4F 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  55 
	.he  D7 
; pronunciation_rule     " (DOES)"    , "DAHZ"
	.he  20 
	.he  28 
	.he  44 
	.he  4F 
	.he  45 
	.he  53 
	.he  29 
	.he  3D 
	.he  44 
	.he  41 
	.he  48 
	.he  DA 
; pronunciation_rule     "(DONE) "    , "DAH5N"
	.he  28 
	.he  44 
	.he  4F 
	.he  4E 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  41 
	.he  48 
	.he  35 
	.he  CE 
; pronunciation_rule     "(DOING)"    , "DUW4IHNX"
	.he  28 
	.he  44 
	.he  4F 
	.he  49 
	.he  4E 
	.he  47 
	.he  29 
	.he  3D 
	.he  44 
	.he  55 
	.he  57 
	.he  34 
	.he  49 
	.he  48 
	.he  4E 
	.he  D8 
; pronunciation_rule     " (DOW)"     , "DAW"
	.he  20 
	.he  28 
	.he  44 
	.he  4F 
	.he  57 
	.he  29 
	.he  3D 
	.he  44 
	.he  41 
	.he  D7 
; pronunciation_rule     "#(DU)A"     , "JUW"
	.he  23 
	.he  28 
	.he  44 
	.he  55 
	.he  29 
	.he  41 
	.he  3D 
	.he  4A 
	.he  55 
	.he  D7 
; pronunciation_rule     "#(DU)^#"    , "JAX"
	.he  23 
	.he  28 
	.he  44 
	.he  55 
	.he  29 
	.he  5E 
	.he  23 
	.he  3D 
	.he  4A 
	.he  41 
	.he  D8 
; pronunciation_rule     "(D)"        , "D"
	.he  28 
	.he  44 
	.he  29 
	.he  3D 
	.he  C4 
PTAB_E:		; pronunciation_index    "E"
	.he  5D 
	.he  C5 
; pronunciation_rule     " (E) "      , "IYIY4"
	.he  20 
	.he  28 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  49 
	.he  59 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "#:(E) "     , ""
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  29 
	.he  20 
	.he  BD 
; pronunciation_rule     "':^(E) "    , ""
	.he  27 
	.he  3A 
	.he  5E 
	.he  28 
	.he  45 
	.he  29 
	.he  20 
	.he  BD 
; pronunciation_rule     " :(E) "     , "IY"
	.he  20 
	.he  3A 
	.he  28 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  49 
	.he  D9 
; pronunciation_rule     "#(ED) "     , "D"
	.he  23 
	.he  28 
	.he  45 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  C4 
; pronunciation_rule     "#:(E)D "    , ""
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  29 
	.he  44 
	.he  20 
	.he  BD 
; pronunciation_rule     "(EV)ER"     , "EH4V"
	.he  28 
	.he  45 
	.he  56 
	.he  29 
	.he  45 
	.he  52 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  D6 
; pronunciation_rule     "(E)^%"      , "IY4"
	.he  28 
	.he  45 
	.he  29 
	.he  5E 
	.he  25 
	.he  3D 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "(ERI)#"     , "IY4RIY"
	.he  28 
	.he  45 
	.he  52 
	.he  49 
	.he  29 
	.he  23 
	.he  3D 
	.he  49 
	.he  59 
	.he  34 
	.he  52 
	.he  49 
	.he  D9 
; pronunciation_rule     "(ERI)"      , "EH4RIH"
	.he  28 
	.he  45 
	.he  52 
	.he  49 
	.he  29 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  52 
	.he  49 
	.he  C8 
; pronunciation_rule     "#:(ER)#"    , "ER"
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  45 
	.he  D2 
; pronunciation_rule     "(ERROR)"    , "EH4ROHR"
	.he  28 
	.he  45 
	.he  52 
	.he  52 
	.he  4F 
	.he  52 
	.he  29 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  52 
	.he  4F 
	.he  48 
	.he  D2 
; pronunciation_rule     "(ERASE)"    , "IHREY5S"
	.he  28 
	.he  45 
	.he  52 
	.he  41 
	.he  53 
	.he  45 
	.he  29 
	.he  3D 
	.he  49 
	.he  48 
	.he  52 
	.he  45 
	.he  59 
	.he  35 
	.he  D3 
; pronunciation_rule     "(ER)#"      , "EHR"
	.he  28 
	.he  45 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  45 
	.he  48 
	.he  D2 
; pronunciation_rule     "(ER)"       , "ER"
	.he  28 
	.he  45 
	.he  52 
	.he  29 
	.he  3D 
	.he  45 
	.he  D2 
; pronunciation_rule     " (EVEN)"    , "IYVEHN"
	.he  20 
	.he  28 
	.he  45 
	.he  56 
	.he  45 
	.he  4E 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  56 
	.he  45 
	.he  48 
	.he  CE 
; pronunciation_rule     "#:(E)W"     , ""
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  29 
	.he  57 
	.he  BD 
; pronunciation_rule     "@(EW)"      , "UW"
	.he  40 
	.he  28 
	.he  45 
	.he  57 
	.he  29 
	.he  3D 
	.he  55 
	.he  D7 
; pronunciation_rule     "(EW)"       , "YUW"
	.he  28 
	.he  45 
	.he  57 
	.he  29 
	.he  3D 
	.he  59 
	.he  55 
	.he  D7 
; pronunciation_rule     "(E)O"       , "IY"
	.he  28 
	.he  45 
	.he  29 
	.he  4F 
	.he  3D 
	.he  49 
	.he  D9 
; pronunciation_rule     "#:&(ES) "   , "IHZ"
	.he  23 
	.he  3A 
	.he  26 
	.he  28 
	.he  45 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  49 
	.he  48 
	.he  DA 
; pronunciation_rule     "#:(E)S "    , ""
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  29 
	.he  53 
	.he  20 
	.he  BD 
; pronunciation_rule     "#:(ELY) "   , "LIY"
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  4C 
	.he  59 
	.he  29 
	.he  20 
	.he  3D 
	.he  4C 
	.he  49 
	.he  D9 
; pronunciation_rule     "#:(EMENT)"  , "MEHNT"
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  4D 
	.he  45 
	.he  4E 
	.he  54 
	.he  29 
	.he  3D 
	.he  4D 
	.he  45 
	.he  48 
	.he  4E 
	.he  D4 
; pronunciation_rule     "(EFUL)"     , "FUHL"
	.he  28 
	.he  45 
	.he  46 
	.he  55 
	.he  4C 
	.he  29 
	.he  3D 
	.he  46 
	.he  55 
	.he  48 
	.he  CC 
; pronunciation_rule     "(EE)"       , "IY4"
	.he  28 
	.he  45 
	.he  45 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "(EARN)"     , "ER5N"
	.he  28 
	.he  45 
	.he  41 
	.he  52 
	.he  4E 
	.he  29 
	.he  3D 
	.he  45 
	.he  52 
	.he  35 
	.he  CE 
; pronunciation_rule     " (EAR)^"    , "ER5"
	.he  20 
	.he  28 
	.he  45 
	.he  41 
	.he  52 
	.he  29 
	.he  5E 
	.he  3D 
	.he  45 
	.he  52 
	.he  B5 
; pronunciation_rule     "(EAD)"      , "EHD"
	.he  28 
	.he  45 
	.he  41 
	.he  44 
	.he  29 
	.he  3D 
	.he  45 
	.he  48 
	.he  C4 
; pronunciation_rule     "#:(EA) "    , "IYAX"
	.he  23 
	.he  3A 
	.he  28 
	.he  45 
	.he  41 
	.he  29 
	.he  20 
	.he  3D 
	.he  49 
	.he  59 
	.he  41 
	.he  D8 
; pronunciation_rule     "(EA)SU"     , "EH5"
	.he  28 
	.he  45 
	.he  41 
	.he  29 
	.he  53 
	.he  55 
	.he  3D 
	.he  45 
	.he  48 
	.he  B5 
; pronunciation_rule     "(EA)"       , "IY5"
	.he  28 
	.he  45 
	.he  41 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  B5 
; pronunciation_rule     "(EIGH)"     , "EY4"
	.he  28 
	.he  45 
	.he  49 
	.he  47 
	.he  48 
	.he  29 
	.he  3D 
	.he  45 
	.he  59 
	.he  B4 
; pronunciation_rule     "(EI)"       , "IY4"
	.he  28 
	.he  45 
	.he  49 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     " (EYE)"     , "AY4"
	.he  20 
	.he  28 
	.he  45 
	.he  59 
	.he  45 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  B4 
; pronunciation_rule     "(EY)"       , "IY"
	.he  28 
	.he  45 
	.he  59 
	.he  29 
	.he  3D 
	.he  49 
	.he  D9 
; pronunciation_rule     "(EU)"       , "YUW5"
	.he  28 
	.he  45 
	.he  55 
	.he  29 
	.he  3D 
	.he  59 
	.he  55 
	.he  57 
	.he  B5 
; pronunciation_rule     "(EQUAL)"    , "IY4KWUL"
	.he  28 
	.he  45 
	.he  51 
	.he  55 
	.he  41 
	.he  4C 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  34 
	.he  4B 
	.he  57 
	.he  55 
	.he  CC 
; pronunciation_rule     "(E)"        , "EH"
	.he  28 
	.he  45 
	.he  29 
	.he  3D 
	.he  45 
	.he  C8 
PTAB_F:		; pronunciation_index    "F"
	.he  5D 
	.he  C6 
; pronunciation_rule     " (F) "      , "EH4F"
	.he  20 
	.he  28 
	.he  46 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  C6 
; pronunciation_rule     "(FUL)"      , "FUHL"
	.he  28 
	.he  46 
	.he  55 
	.he  4C 
	.he  29 
	.he  3D 
	.he  46 
	.he  55 
	.he  48 
	.he  CC 
; pronunciation_rule     "(FRIEND)"   , "FREH5ND"
	.he  28 
	.he  46 
	.he  52 
	.he  49 
	.he  45 
	.he  4E 
	.he  44 
	.he  29 
	.he  3D 
	.he  46 
	.he  52 
	.he  45 
	.he  48 
	.he  35 
	.he  4E 
	.he  C4 
; pronunciation_rule     "(FATHER)"   , "FAA4DHER"
	.he  28 
	.he  46 
	.he  41 
	.he  54 
	.he  48 
	.he  45 
	.he  52 
	.he  29 
	.he  3D 
	.he  46 
	.he  41 
	.he  41 
	.he  34 
	.he  44 
	.he  48 
	.he  45 
	.he  D2 
; pronunciation_rule     "(F)F"       , ""
	.he  28 
	.he  46 
	.he  29 
	.he  46 
	.he  BD 
; pronunciation_rule     "(F)"        , "F"
	.he  28 
	.he  46 
	.he  29 
	.he  3D 
	.he  C6 
PTAB_G:		; pronunciation_index    "G"
	.he  5D 
	.he  C7 
; pronunciation_rule     " (G) "      , "JIY4"
	.he  20 
	.he  28 
	.he  47 
	.he  29 
	.he  20 
	.he  3D 
	.he  4A 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "(GIV)"      , "GIH5V"
	.he  28 
	.he  47 
	.he  49 
	.he  56 
	.he  29 
	.he  3D 
	.he  47 
	.he  49 
	.he  48 
	.he  35 
	.he  D6 
; pronunciation_rule     " (G)I^"     , "G"
	.he  20 
	.he  28 
	.he  47 
	.he  29 
	.he  49 
	.he  5E 
	.he  3D 
	.he  C7 
; pronunciation_rule     "(GE)T"      , "GEH5"
	.he  28 
	.he  47 
	.he  45 
	.he  29 
	.he  54 
	.he  3D 
	.he  47 
	.he  45 
	.he  48 
	.he  B5 
; pronunciation_rule     "SU(GGES)"   , "GJEH4S"
	.he  53 
	.he  55 
	.he  28 
	.he  47 
	.he  47 
	.he  45 
	.he  53 
	.he  29 
	.he  3D 
	.he  47 
	.he  4A 
	.he  45 
	.he  48 
	.he  34 
	.he  D3 
; pronunciation_rule     "(GG)"       , "G"
	.he  28 
	.he  47 
	.he  47 
	.he  29 
	.he  3D 
	.he  C7 
; pronunciation_rule     " B#(G)"     , "G"
	.he  20 
	.he  42 
	.he  23 
	.he  28 
	.he  47 
	.he  29 
	.he  3D 
	.he  C7 
; pronunciation_rule     "(G)+"       , "J"
	.he  28 
	.he  47 
	.he  29 
	.he  2B 
	.he  3D 
	.he  CA 
; pronunciation_rule     "(GREAT)"    , "GREY4T"
	.he  28 
	.he  47 
	.he  52 
	.he  45 
	.he  41 
	.he  54 
	.he  29 
	.he  3D 
	.he  47 
	.he  52 
	.he  45 
	.he  59 
	.he  34 
	.he  D4 
; pronunciation_rule     "(GON)E"     , "GAO5N"
	.he  28 
	.he  47 
	.he  4F 
	.he  4E 
	.he  29 
	.he  45 
	.he  3D 
	.he  47 
	.he  41 
	.he  4F 
	.he  35 
	.he  CE 
; pronunciation_rule     "#(GH)"      , ""
	.he  23 
	.he  28 
	.he  47 
	.he  48 
	.he  29 
	.he  BD 
; pronunciation_rule     " (GN)"      , "N"
	.he  20 
	.he  28 
	.he  47 
	.he  4E 
	.he  29 
	.he  3D 
	.he  CE 
; pronunciation_rule     "(G)"        , "G"
	.he  28 
	.he  47 
	.he  29 
	.he  3D 
	.he  C7 
PTAB_H:		; pronunciation_index    "H"
	.he  5D 
	.he  C8 
; pronunciation_rule    " (H) "       , "EY4CH"
	.he  20 
	.he  28 
	.he  48 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  59 
	.he  34 
	.he  43 
	.he  C8 
; pronunciation_rule    " (HAV)"      , "/HAE6V"
	.he  20 
	.he  28 
	.he  48 
	.he  41 
	.he  56 
	.he  29 
	.he  3D 
	.he  2F 
	.he  48 
	.he  41 
	.he  45 
	.he  36 
	.he  D6 
; pronunciation_rule    " (HERE)"     , "/HIYR"
	.he  20 
	.he  28 
	.he  48 
	.he  45 
	.he  52 
	.he  45 
	.he  29 
	.he  3D 
	.he  2F 
	.he  48 
	.he  49 
	.he  59 
	.he  D2 
; pronunciation_rule    " (HOUR)"     , "AW5ER"
	.he  20 
	.he  28 
	.he  48 
	.he  4F 
	.he  55 
	.he  52 
	.he  29 
	.he  3D 
	.he  41 
	.he  57 
	.he  35 
	.he  45 
	.he  D2 
; pronunciation_rule    "(HOW)"       , "/HAW"
	.he  28 
	.he  48 
	.he  4F 
	.he  57 
	.he  29 
	.he  3D 
	.he  2F 
	.he  48 
	.he  41 
	.he  D7 
; pronunciation_rule    "(H)#"        , "/H"
	.he  28 
	.he  48 
	.he  29 
	.he  23 
	.he  3D 
	.he  2F 
	.he  C8 
; pronunciation_rule    "(H)"         , ""
	.he  28 
	.he  48 
	.he  29 
	.he  BD 
PTAB_I:		; pronunciation_index    "I"
	.he  5D 
	.he  C9 
; pronunciation_rule    " (IN)"       , "IHN"
	.he  20 
	.he  28 
	.he  49 
	.he  4E 
	.he  29 
	.he  3D 
	.he  49 
	.he  48 
	.he  CE 
; pronunciation_rule    " (I) "       , "AY4"
	.he  20 
	.he  28 
	.he  49 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  59 
	.he  B4 
; pronunciation_rule    "(I) "        , "AY"
	.he  28 
	.he  49 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule    "(IN)D"       , "AY5N"
	.he  28 
	.he  49 
	.he  4E 
	.he  29 
	.he  44 
	.he  3D 
	.he  41 
	.he  59 
	.he  35 
	.he  CE 
; pronunciation_rule    "SEM(I)"      , "IY"
	.he  53 
	.he  45 
	.he  4D 
	.he  28 
	.he  49 
	.he  29 
	.he  3D 
	.he  49 
	.he  D9 
; pronunciation_rule    " ANT(I)"     , "AY"
	.he  20 
	.he  41 
	.he  4E 
	.he  54 
	.he  28 
	.he  49 
	.he  29 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule    "(IER)"       , "IYER"
	.he  28 
	.he  49 
	.he  45 
	.he  52 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  45 
	.he  D2 
; pronunciation_rule    "#:R(IED) "   , "IYD"
	.he  23 
	.he  3A 
	.he  52 
	.he  28 
	.he  49 
	.he  45 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  49 
	.he  59 
	.he  C4 
; pronunciation_rule    "(IED) "      , "AY5D"
	.he  28 
	.he  49 
	.he  45 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  59 
	.he  35 
	.he  C4 
; pronunciation_rule    "(IEN)"       , "IYEHN"
	.he  28 
	.he  49 
	.he  45 
	.he  4E 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  45 
	.he  48 
	.he  CE 
; pronunciation_rule    "(IE)T"       , "AY4EH"
	.he  28 
	.he  49 
	.he  45 
	.he  29 
	.he  54 
	.he  3D 
	.he  41 
	.he  59 
	.he  34 
	.he  45 
	.he  C8 
; pronunciation_rule    "(I')"        , "AY5"
	.he  28 
	.he  49 
	.he  27 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  B5 
; pronunciation_rule    " :(I)^%"     , "AY5"
	.he  20 
	.he  3A 
	.he  28 
	.he  49 
	.he  29 
	.he  5E 
	.he  25 
	.he  3D 
	.he  41 
	.he  59 
	.he  B5 
; pronunciation_rule    " :(IE) "     , "AY4"
	.he  20 
	.he  3A 
	.he  28 
	.he  49 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  59 
	.he  B4 
; pronunciation_rule    "(I)%"        , "IY"
	.he  28 
	.he  49 
	.he  29 
	.he  25 
	.he  3D 
	.he  49 
	.he  D9 
; pronunciation_rule    "(IE)"        , "IY4"
	.he  28 
	.he  49 
	.he  45 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule    " (IDEA)"     , "AYDIY5AH"
	.he  20 
	.he  28 
	.he  49 
	.he  44 
	.he  45 
	.he  41 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  44 
	.he  49 
	.he  59 
	.he  35 
	.he  41 
	.he  C8 
; pronunciation_rule    "(I)^+:#"     , "IH"
	.he  28 
	.he  49 
	.he  29 
	.he  5E 
	.he  2B 
	.he  3A 
	.he  23 
	.he  3D 
	.he  49 
	.he  C8 
; pronunciation_rule    "(IR)#"       , "AYR"
	.he  28 
	.he  49 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  41 
	.he  59 
	.he  D2 
; pronunciation_rule    "(IZ)%"       , "AYZ"
	.he  28 
	.he  49 
	.he  5A 
	.he  29 
	.he  25 
	.he  3D 
	.he  41 
	.he  59 
	.he  DA 
; pronunciation_rule    "(IS)%"       , "AYZ"
	.he  28 
	.he  49 
	.he  53 
	.he  29 
	.he  25 
	.he  3D 
	.he  41 
	.he  59 
	.he  DA 
; pronunciation_rule    "I^(I)^#"     , "IH"
	.he  49 
	.he  5E 
	.he  28 
	.he  49 
	.he  29 
	.he  5E 
	.he  23 
	.he  3D 
	.he  49 
	.he  C8 
; pronunciation_rule    "+^(I)^+"     , "AY"
	.he  2B 
	.he  5E 
	.he  28 
	.he  49 
	.he  29 
	.he  5E 
	.he  2B 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule    "#:^(I)^+"    , "IH"
	.he  23 
	.he  3A 
	.he  5E 
	.he  28 
	.he  49 
	.he  29 
	.he  5E 
	.he  2B 
	.he  3D 
	.he  49 
	.he  C8 
; pronunciation_rule    "(I)^+"       , "AY"
	.he  28 
	.he  49 
	.he  29 
	.he  5E 
	.he  2B 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule    "(IR)"        , "ER"
	.he  28 
	.he  49 
	.he  52 
	.he  29 
	.he  3D 
	.he  45 
	.he  D2 
; pronunciation_rule    "(IGH)"       , "AY4"
	.he  28 
	.he  49 
	.he  47 
	.he  48 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  B4 
; pronunciation_rule    "(ILD)"       , "AY5LD"
	.he  28 
	.he  49 
	.he  4C 
	.he  44 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  35 
	.he  4C 
	.he  C4 
; pronunciation_rule    " (IGN)"      , "IHGN"
	.he  20 
	.he  28 
	.he  49 
	.he  47 
	.he  4E 
	.he  29 
	.he  3D 
	.he  49 
	.he  48 
	.he  47 
	.he  CE 
; pronunciation_rule    "(IGN) "      , "AY4N"
	.he  28 
	.he  49 
	.he  47 
	.he  4E 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  59 
	.he  34 
	.he  CE 
; pronunciation_rule    "(IGN)^"      , "AY4N"
	.he  28 
	.he  49 
	.he  47 
	.he  4E 
	.he  29 
	.he  5E 
	.he  3D 
	.he  41 
	.he  59 
	.he  34 
	.he  CE 
; pronunciation_rule    "(IGN)%"      , "AY4N"
	.he  28 
	.he  49 
	.he  47 
	.he  4E 
	.he  29 
	.he  25 
	.he  3D 
	.he  41 
	.he  59 
	.he  34 
	.he  CE 
; pronunciation_rule    "(ICRO)"      , "AY4KROH"
	.he  28 
	.he  49 
	.he  43 
	.he  52 
	.he  4F 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  34 
	.he  4B 
	.he  52 
	.he  4F 
	.he  C8 
; pronunciation_rule    "(IQUE)"      , "IY4K"
	.he  28 
	.he  49 
	.he  51 
	.he  55 
	.he  45 
	.he  29 
	.he  3D 
	.he  49 
	.he  59 
	.he  34 
	.he  CB 
; pronunciation_rule    "(I)"         , "IH"
	.he  28 
	.he  49 
	.he  29 
	.he  3D 
	.he  49 
	.he  C8 
PTAB_J:		; pronunciation_index    "J"
	.he  5D 
	.he  CA 
; pronunciation_rule    " (J) "       , "JEY4"
	.he  20 
	.he  28 
	.he  4A 
	.he  29 
	.he  20 
	.he  3D 
	.he  4A 
	.he  45 
	.he  59 
	.he  B4 
; pronunciation_rule    "(J)"         , "J"
	.he  28 
	.he  4A 
	.he  29 
	.he  3D 
	.he  CA 
PTAB_K:		; pronunciation_index    "K"
	.he  5D 
	.he  CB 
; pronunciation_rule    " (K) "       , "KEY4"
	.he  20 
	.he  28 
	.he  4B 
	.he  29 
	.he  20 
	.he  3D 
	.he  4B 
	.he  45 
	.he  59 
	.he  B4 
; pronunciation_rule    " (K)N"       , ""
	.he  20 
	.he  28 
	.he  4B 
	.he  29 
	.he  4E 
	.he  BD 
; pronunciation_rule    "(K)"         , "K"
	.he  28 
	.he  4B 
	.he  29 
	.he  3D 
	.he  CB 
PTAB_L:		; pronunciation_index    "L"
	.he  5D 
	.he  CC 
; pronunciation_rule    " (L) "       , "EH4L"
	.he  20 
	.he  28 
	.he  4C 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  CC 
; pronunciation_rule    "(LO)C#"      , "LOW"
	.he  28 
	.he  4C 
	.he  4F 
	.he  29 
	.he  43 
	.he  23 
	.he  3D 
	.he  4C 
	.he  4F 
	.he  D7 
; pronunciation_rule    "L(L)"        , ""
	.he  4C 
	.he  28 
	.he  4C 
	.he  29 
	.he  BD 
; pronunciation_rule    "#:^(L)%"     , "UL"
	.he  23 
	.he  3A 
	.he  5E 
	.he  28 
	.he  4C 
	.he  29 
	.he  25 
	.he  3D 
	.he  55 
	.he  CC 
; pronunciation_rule    "(LEAD)"      , "LIYD"
	.he  28 
	.he  4C 
	.he  45 
	.he  41 
	.he  44 
	.he  29 
	.he  3D 
	.he  4C 
	.he  49 
	.he  59 
	.he  C4 
; pronunciation_rule    " (LAUGH)"    , "LAE4F"
	.he  20 
	.he  28 
	.he  4C 
	.he  41 
	.he  55 
	.he  47 
	.he  48 
	.he  29 
	.he  3D 
	.he  4C 
	.he  41 
	.he  45 
	.he  34 
	.he  C6 
; pronunciation_rule    "(L)"         , "L"
	.he  28 
	.he  4C 
	.he  29 
	.he  3D 
	.he  CC 
PTAB_M:		; pronunciation_index    "M"
	.he  5D 
	.he  CD 
; pronunciation_rule    " (M) "       , "EH4M"
	.he  20 
	.he  28 
	.he  4D 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  CD 
; pronunciation_rule    " (MR.) "     , "MIH4STER"
	.he  20 
	.he  28 
	.he  4D 
	.he  52 
	.he  2E 
	.he  29 
	.he  20 
	.he  3D 
	.he  4D 
	.he  49 
	.he  48 
	.he  34 
	.he  53 
	.he  54 
	.he  45 
	.he  D2 
; pronunciation_rule    " (MS.)"      , "MIH5Z"
	.he  20 
	.he  28 
	.he  4D 
	.he  53 
	.he  2E 
	.he  29 
	.he  3D 
	.he  4D 
	.he  49 
	.he  48 
	.he  35 
	.he  DA 
; pronunciation_rule    " (MRS.) "    , "MIH4SIXZ"
	.he  20 
	.he  28 
	.he  4D 
	.he  52 
	.he  53 
	.he  2E 
	.he  29 
	.he  20 
	.he  3D 
	.he  4D 
	.he  49 
	.he  48 
	.he  34 
	.he  53 
	.he  49 
	.he  58 
	.he  DA 
; pronunciation_rule    "(MOV)"       , "MUW4V"
	.he  28 
	.he  4D 
	.he  4F 
	.he  56 
	.he  29 
	.he  3D 
	.he  4D 
	.he  55 
	.he  57 
	.he  34 
	.he  D6 
; pronunciation_rule    "(MACHIN)"    , "MAHSHIY5N"
	.he  28 
	.he  4D 
	.he  41 
	.he  43 
	.he  48 
	.he  49 
	.he  4E 
	.he  29 
	.he  3D 
	.he  4D 
	.he  41 
	.he  48 
	.he  53 
	.he  48 
	.he  49 
	.he  59 
	.he  35 
	.he  CE 
; pronunciation_rule    "M(M)"        , ""
	.he  4D 
	.he  28 
	.he  4D 
	.he  29 
	.he  BD 
; pronunciation_rule    "(M)"         , "M"
	.he  28 
	.he  4D 
	.he  29 
	.he  3D 
	.he  CD 
PTAB_N:		; pronunciation_index    "N"
	.he  5D 
	.he  CE 
; pronunciation_rule     " (N) "      , "EH4N"
	.he  20 
	.he  28 
	.he  4E 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  CE 
; pronunciation_rule     "E(NG)+"     , "NJ"
	.he  45 
	.he  28 
	.he  4E 
	.he  47 
	.he  29 
	.he  2B 
	.he  3D 
	.he  4E 
	.he  CA 
; pronunciation_rule     "(NG)R"      , "NXG"
	.he  28 
	.he  4E 
	.he  47 
	.he  29 
	.he  52 
	.he  3D 
	.he  4E 
	.he  58 
	.he  C7 
; pronunciation_rule     "(NG)#"      , "NXG"
	.he  28 
	.he  4E 
	.he  47 
	.he  29 
	.he  23 
	.he  3D 
	.he  4E 
	.he  58 
	.he  C7 
; pronunciation_rule     "(NGL)%"     , "NXGUL"
	.he  28 
	.he  4E 
	.he  47 
	.he  4C 
	.he  29 
	.he  25 
	.he  3D 
	.he  4E 
	.he  58 
	.he  47 
	.he  55 
	.he  CC 
; pronunciation_rule     "(NG)"       , "NX"
	.he  28 
	.he  4E 
	.he  47 
	.he  29 
	.he  3D 
	.he  4E 
	.he  D8 
; pronunciation_rule     "(NK)"       , "NXK"
	.he  28 
	.he  4E 
	.he  4B 
	.he  29 
	.he  3D 
	.he  4E 
	.he  58 
	.he  CB 
; pronunciation_rule     " (NOW) "    , "NAW4"
	.he  20 
	.he  28 
	.he  4E 
	.he  4F 
	.he  57 
	.he  29 
	.he  20 
	.he  3D 
	.he  4E 
	.he  41 
	.he  57 
	.he  B4 
; pronunciation_rule     "N(N)"       , ""
	.he  4E 
	.he  28 
	.he  4E 
	.he  29 
	.he  BD 
; pronunciation_rule     "(NON)E"     , "NAH4N"
	.he  28 
	.he  4E 
	.he  4F 
	.he  4E 
	.he  29 
	.he  45 
	.he  3D 
	.he  4E 
	.he  41 
	.he  48 
	.he  34 
	.he  CE 
; pronunciation_rule     "(N)"        , "N"
	.he  28 
	.he  4E 
	.he  29 
	.he  3D 
	.he  CE 
PTAB_O:		; pronunciation_index    "O"
	.he  5D 
	.he  CF 
; pronunciation_rule     " (O) "      , "OH4W"
	.he  20 
	.he  28 
	.he  4F 
	.he  29 
	.he  20 
	.he  3D 
	.he  4F 
	.he  48 
	.he  34 
	.he  D7 
; pronunciation_rule     "(OF) "      , "AHV"
	.he  28 
	.he  4F 
	.he  46 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  48 
	.he  D6 
; pronunciation_rule     " (OH) "     , "OW5"
	.he  20 
	.he  28 
	.he  4F 
	.he  48 
	.he  29 
	.he  20 
	.he  3D 
	.he  4F 
	.he  57 
	.he  B5 
; pronunciation_rule     "(OROUGH)"   , "ER4OW"
	.he  28 
	.he  4F 
	.he  52 
	.he  4F 
	.he  55 
	.he  47 
	.he  48 
	.he  29 
	.he  3D 
	.he  45 
	.he  52 
	.he  34 
	.he  4F 
	.he  D7 
; pronunciation_rule     "#:(OR) "    , "ER"
	.he  23 
	.he  3A 
	.he  28 
	.he  4F 
	.he  52 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  D2 
; pronunciation_rule     "#:(ORS) "   , "ERZ"
	.he  23 
	.he  3A 
	.he  28 
	.he  4F 
	.he  52 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  52 
	.he  DA 
; pronunciation_rule     "(OR)"       , "AOR"
	.he  28 
	.he  4F 
	.he  52 
	.he  29 
	.he  3D 
	.he  41 
	.he  4F 
	.he  D2 
; pronunciation_rule     " (ONE)"     , "WAHN"
	.he  20 
	.he  28 
	.he  4F 
	.he  4E 
	.he  45 
	.he  29 
	.he  3D 
	.he  57 
	.he  41 
	.he  48 
	.he  CE 
; pronunciation_rule     "#(ONE) "    , "WAHN"
	.he  23 
	.he  28 
	.he  4F 
	.he  4E 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  57 
	.he  41 
	.he  48 
	.he  CE 
; pronunciation_rule     "(OW)"       , "OW"
	.he  28 
	.he  4F 
	.he  57 
	.he  29 
	.he  3D 
	.he  4F 
	.he  D7 
; pronunciation_rule     " (OVER)"    , "OW5VER"
	.he  20 
	.he  28 
	.he  4F 
	.he  56 
	.he  45 
	.he  52 
	.he  29 
	.he  3D 
	.he  4F 
	.he  57 
	.he  35 
	.he  56 
	.he  45 
	.he  D2 
; pronunciation_rule     "PR(O)V"     , "UW4"
	.he  50 
	.he  52 
	.he  28 
	.he  4F 
	.he  29 
	.he  56 
	.he  3D 
	.he  55 
	.he  57 
	.he  B4 
; pronunciation_rule     "(OV)"       , "AH4V"
	.he  28 
	.he  4F 
	.he  56 
	.he  29 
	.he  3D 
	.he  41 
	.he  48 
	.he  34 
	.he  D6 
; pronunciation_rule     "(O)^%"      , "OW5"
	.he  28 
	.he  4F 
	.he  29 
	.he  5E 
	.he  25 
	.he  3D 
	.he  4F 
	.he  57 
	.he  B5 
; pronunciation_rule     "(O)^EN"     , "OW"
	.he  28 
	.he  4F 
	.he  29 
	.he  5E 
	.he  45 
	.he  4E 
	.he  3D 
	.he  4F 
	.he  D7 
; pronunciation_rule     "(O)^I#"     , "OW5"
	.he  28 
	.he  4F 
	.he  29 
	.he  5E 
	.he  49 
	.he  23 
	.he  3D 
	.he  4F 
	.he  57 
	.he  B5 
; pronunciation_rule     "(OL)D"      , "OW4L"
	.he  28 
	.he  4F 
	.he  4C 
	.he  29 
	.he  44 
	.he  3D 
	.he  4F 
	.he  57 
	.he  34 
	.he  CC 
; pronunciation_rule     "(OUGHT)"    , "AO5T"
	.he  28 
	.he  4F 
	.he  55 
	.he  47 
	.he  48 
	.he  54 
	.he  29 
	.he  3D 
	.he  41 
	.he  4F 
	.he  35 
	.he  D4 
; pronunciation_rule     "(OUGH)"     , "AH5F"
	.he  28 
	.he  4F 
	.he  55 
	.he  47 
	.he  48 
	.he  29 
	.he  3D 
	.he  41 
	.he  48 
	.he  35 
	.he  C6 
; pronunciation_rule     " (OU)"      , "AW"
	.he  20 
	.he  28 
	.he  4F 
	.he  55 
	.he  29 
	.he  3D 
	.he  41 
	.he  D7 
; pronunciation_rule     "H(OU)S#"    , "AW4"
	.he  48 
	.he  28 
	.he  4F 
	.he  55 
	.he  29 
	.he  53 
	.he  23 
	.he  3D 
	.he  41 
	.he  57 
	.he  B4 
; pronunciation_rule     "(OUS)"      , "AXS"
	.he  28 
	.he  4F 
	.he  55 
	.he  53 
	.he  29 
	.he  3D 
	.he  41 
	.he  58 
	.he  D3 
; pronunciation_rule     "(OUR)"      , "OHR"
	.he  28 
	.he  4F 
	.he  55 
	.he  52 
	.he  29 
	.he  3D 
	.he  4F 
	.he  48 
	.he  D2 
; pronunciation_rule     "(OULD)"     , "UH5D"
	.he  28 
	.he  4F 
	.he  55 
	.he  4C 
	.he  44 
	.he  29 
	.he  3D 
	.he  55 
	.he  48 
	.he  35 
	.he  C4 
; pronunciation_rule     "(OU)^L"     , "AH5"
	.he  28 
	.he  4F 
	.he  55 
	.he  29 
	.he  5E 
	.he  4C 
	.he  3D 
	.he  41 
	.he  48 
	.he  B5 
; pronunciation_rule     "(OUP)"      , "UW5P"
	.he  28 
	.he  4F 
	.he  55 
	.he  50 
	.he  29 
	.he  3D 
	.he  55 
	.he  57 
	.he  35 
	.he  D0 
; pronunciation_rule     "(OU)"       , "AW"
	.he  28 
	.he  4F 
	.he  55 
	.he  29 
	.he  3D 
	.he  41 
	.he  D7 
; pronunciation_rule     "(OY)"       , "OY"
	.he  28 
	.he  4F 
	.he  59 
	.he  29 
	.he  3D 
	.he  4F 
	.he  D9 
; pronunciation_rule     "(OING)"     , "OW4IHNX"
	.he  28 
	.he  4F 
	.he  49 
	.he  4E 
	.he  47 
	.he  29 
	.he  3D 
	.he  4F 
	.he  57 
	.he  34 
	.he  49 
	.he  48 
	.he  4E 
	.he  D8 
; pronunciation_rule     "(OI)"       , "OY5"
	.he  28 
	.he  4F 
	.he  49 
	.he  29 
	.he  3D 
	.he  4F 
	.he  59 
	.he  B5 
; pronunciation_rule     "(OOR)"      , "OH5R"
	.he  28 
	.he  4F 
	.he  4F 
	.he  52 
	.he  29 
	.he  3D 
	.he  4F 
	.he  48 
	.he  35 
	.he  D2 
; pronunciation_rule     "(OOK)"      , "UH5K"
	.he  28 
	.he  4F 
	.he  4F 
	.he  4B 
	.he  29 
	.he  3D 
	.he  55 
	.he  48 
	.he  35 
	.he  CB 
; pronunciation_rule     "F(OOD)"     , "UW5D"
	.he  46 
	.he  28 
	.he  4F 
	.he  4F 
	.he  44 
	.he  29 
	.he  3D 
	.he  55 
	.he  57 
	.he  35 
	.he  C4 
; pronunciation_rule     "L(OOD)"     , "AH5D"
	.he  4C 
	.he  28 
	.he  4F 
	.he  4F 
	.he  44 
	.he  29 
	.he  3D 
	.he  41 
	.he  48 
	.he  35 
	.he  C4 
; pronunciation_rule     "M(OOD)"     , "UW5D"
	.he  4D 
	.he  28 
	.he  4F 
	.he  4F 
	.he  44 
	.he  29 
	.he  3D 
	.he  55 
	.he  57 
	.he  35 
	.he  C4 
; pronunciation_rule     "(OOD)"      , "UH5D"
	.he  28 
	.he  4F 
	.he  4F 
	.he  44 
	.he  29 
	.he  3D 
	.he  55 
	.he  48 
	.he  35 
	.he  C4 
; pronunciation_rule     "F(OOT)"     , "UH5T"
	.he  46 
	.he  28 
	.he  4F 
	.he  4F 
	.he  54 
	.he  29 
	.he  3D 
	.he  55 
	.he  48 
	.he  35 
	.he  D4 
; pronunciation_rule     "(OO)"       , "UW5"
	.he  28 
	.he  4F 
	.he  4F 
	.he  29 
	.he  3D 
	.he  55 
	.he  57 
	.he  B5 
; pronunciation_rule     "(O')"       , "OH"
	.he  28 
	.he  4F 
	.he  27 
	.he  29 
	.he  3D 
	.he  4F 
	.he  C8 
; pronunciation_rule     "(O)E"       , "OW"
	.he  28 
	.he  4F 
	.he  29 
	.he  45 
	.he  3D 
	.he  4F 
	.he  D7 
; pronunciation_rule     "(O) "       , "OW"
	.he  28 
	.he  4F 
	.he  29 
	.he  20 
	.he  3D 
	.he  4F 
	.he  D7 
; pronunciation_rule     "(OA)"       , "OW4"
	.he  28 
	.he  4F 
	.he  41 
	.he  29 
	.he  3D 
	.he  4F 
	.he  57 
	.he  B4 
; pronunciation_rule     " (ONLY)"    , "OW4NLIY"
	.he  20 
	.he  28 
	.he  4F 
	.he  4E 
	.he  4C 
	.he  59 
	.he  29 
	.he  3D 
	.he  4F 
	.he  57 
	.he  34 
	.he  4E 
	.he  4C 
	.he  49 
	.he  D9 
; pronunciation_rule     " (ONCE)"    , "WAH4NS"
	.he  20 
	.he  28 
	.he  4F 
	.he  4E 
	.he  43 
	.he  45 
	.he  29 
	.he  3D 
	.he  57 
	.he  41 
	.he  48 
	.he  34 
	.he  4E 
	.he  D3 
; pronunciation_rule     "(ON'T)"     , "OW4NT"
	.he  28 
	.he  4F 
	.he  4E 
	.he  27 
	.he  54 
	.he  29 
	.he  3D 
	.he  4F 
	.he  57 
	.he  34 
	.he  4E 
	.he  D4 
; pronunciation_rule     "C(O)N"      , "AA"
	.he  43 
	.he  28 
	.he  4F 
	.he  29 
	.he  4E 
	.he  3D 
	.he  41 
	.he  C1 
; pronunciation_rule     "(O)NG"      , "AO"
	.he  28 
	.he  4F 
	.he  29 
	.he  4E 
	.he  47 
	.he  3D 
	.he  41 
	.he  CF 
; pronunciation_rule     " :^(O)N"    , "AH"
	.he  20 
	.he  3A 
	.he  5E 
	.he  28 
	.he  4F 
	.he  29 
	.he  4E 
	.he  3D 
	.he  41 
	.he  C8 
; pronunciation_rule     "I(ON)"      , "UN"
	.he  49 
	.he  28 
	.he  4F 
	.he  4E 
	.he  29 
	.he  3D 
	.he  55 
	.he  CE 
; pronunciation_rule     "#:(ON) "    , "UN"
	.he  23 
	.he  3A 
	.he  28 
	.he  4F 
	.he  4E 
	.he  29 
	.he  20 
	.he  3D 
	.he  55 
	.he  CE 
; pronunciation_rule     "#^(ON)"     , "UN"
	.he  23 
	.he  5E 
	.he  28 
	.he  4F 
	.he  4E 
	.he  29 
	.he  3D 
	.he  55 
	.he  CE 
; pronunciation_rule     "(O)ST "     , "OW"
	.he  28 
	.he  4F 
	.he  29 
	.he  53 
	.he  54 
	.he  20 
	.he  3D 
	.he  4F 
	.he  D7 
; pronunciation_rule     "(OF)^"      , "AO4F"
	.he  28 
	.he  4F 
	.he  46 
	.he  29 
	.he  5E 
	.he  3D 
	.he  41 
	.he  4F 
	.he  34 
	.he  C6 
; pronunciation_rule     "(OTHER)"    , "AH5DHER"
	.he  28 
	.he  4F 
	.he  54 
	.he  48 
	.he  45 
	.he  52 
	.he  29 
	.he  3D 
	.he  41 
	.he  48 
	.he  35 
	.he  44 
	.he  48 
	.he  45 
	.he  D2 
; pronunciation_rule     "R(O)B"      , "RAA"
	.he  52 
	.he  28 
	.he  4F 
	.he  29 
	.he  42 
	.he  3D 
	.he  52 
	.he  41 
	.he  C1 
; pronunciation_rule     "^R(O):#"    , "OW5"
	.he  5E 
	.he  52 
	.he  28 
	.he  4F 
	.he  29 
	.he  3A 
	.he  23 
	.he  3D 
	.he  4F 
	.he  57 
	.he  B5 
; pronunciation_rule     "(OSS) "     , "AO5S"
	.he  28 
	.he  4F 
	.he  53 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  4F 
	.he  35 
	.he  D3 
; pronunciation_rule     "#:^(OM)"    , "AHM"
	.he  23 
	.he  3A 
	.he  5E 
	.he  28 
	.he  4F 
	.he  4D 
	.he  29 
	.he  3D 
	.he  41 
	.he  48 
	.he  CD 
; pronunciation_rule     "(O)"        , "AA"
	.he  28 
	.he  4F 
	.he  29 
	.he  3D 
	.he  41 
	.he  C1 
PTAB_P:		; pronunciation_index    "P"
	.he  5D 
	.he  D0 
; pronunciation_rule     " (P) "      , "PIY4"
	.he  20 
	.he  28 
	.he  50 
	.he  29 
	.he  20 
	.he  3D 
	.he  50 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "(PH)"       , "F"
	.he  28 
	.he  50 
	.he  48 
	.he  29 
	.he  3D 
	.he  C6 
; pronunciation_rule     "(PEOPL)"    , "PIY5PUL"
	.he  28 
	.he  50 
	.he  45 
	.he  4F 
	.he  50 
	.he  4C 
	.he  29 
	.he  3D 
	.he  50 
	.he  49 
	.he  59 
	.he  35 
	.he  50 
	.he  55 
	.he  CC 
; pronunciation_rule     "(POW)"      , "PAW4"
	.he  28 
	.he  50 
	.he  4F 
	.he  57 
	.he  29 
	.he  3D 
	.he  50 
	.he  41 
	.he  57 
	.he  B4 
; pronunciation_rule     "(PUT) "     , "PUHT"
	.he  28 
	.he  50 
	.he  55 
	.he  54 
	.he  29 
	.he  20 
	.he  3D 
	.he  50 
	.he  55 
	.he  48 
	.he  D4 
; pronunciation_rule     "(P)P"       , ""
	.he  28 
	.he  50 
	.he  29 
	.he  50 
	.he  BD 
; pronunciation_rule     " (P)S"      , ""
	.he  20 
	.he  28 
	.he  50 
	.he  29 
	.he  53 
	.he  BD 
; pronunciation_rule     " (P)N"      , ""
	.he  20 
	.he  28 
	.he  50 
	.he  29 
	.he  4E 
	.he  BD 
; pronunciation_rule     " (PROF.)"   , "PROHFEH4SER"
	.he  20 
	.he  28 
	.he  50 
	.he  52 
	.he  4F 
	.he  46 
	.he  2E 
	.he  29 
	.he  3D 
	.he  50 
	.he  52 
	.he  4F 
	.he  48 
	.he  46 
	.he  45 
	.he  48 
	.he  34 
	.he  53 
	.he  45 
	.he  D2 
; pronunciation_rule     "(P)"        , "P"
	.he  28 
	.he  50 
	.he  29 
	.he  3D 
	.he  D0 
PTAB_Q:		; pronunciation_index    "Q"
	.he  5D 
	.he  D1 
; pronunciation_rule     " (Q) "      , "KYUW4"
	.he  20 
	.he  28 
	.he  51 
	.he  29 
	.he  20 
	.he  3D 
	.he  4B 
	.he  59 
	.he  55 
	.he  57 
	.he  B4 
; pronunciation_rule     "(QUAR)"     , "KWOH5R"
	.he  28 
	.he  51 
	.he  55 
	.he  41 
	.he  52 
	.he  29 
	.he  3D 
	.he  4B 
	.he  57 
	.he  4F 
	.he  48 
	.he  35 
	.he  D2 
; pronunciation_rule     "(QU)"       , "KW"
	.he  28 
	.he  51 
	.he  55 
	.he  29 
	.he  3D 
	.he  4B 
	.he  D7 
; pronunciation_rule     "(Q)"        , "K"
	.he  28 
	.he  51 
	.he  29 
	.he  3D 
	.he  CB 
PTAB_R:		; pronunciation_index    "R"
	.he  5D 
	.he  D2 
; pronunciation_rule     " (R) "      , "AA5R"
	.he  20 
	.he  28 
	.he  52 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  41 
	.he  35 
	.he  D2 
; pronunciation_rule     " (RE)^#"    , "RIY"
	.he  20 
	.he  28 
	.he  52 
	.he  45 
	.he  29 
	.he  5E 
	.he  23 
	.he  3D 
	.he  52 
	.he  49 
	.he  D9 
; pronunciation_rule     "(R)R"       , ""
	.he  28 
	.he  52 
	.he  29 
	.he  52 
	.he  BD 
; pronunciation_rule     "(R)"        , "R"
	.he  28 
	.he  52 
	.he  29 
	.he  3D 
	.he  D2 
PTAB_S:		; pronunciation_index    "S"
	.he  5D 
	.he  D3 
; pronunciation_rule     " (S) "      , "EH4S"
	.he  20 
	.he  28 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  D3 
; pronunciation_rule     "(SH)"       , "SH"
	.he  28 
	.he  53 
	.he  48 
	.he  29 
	.he  3D 
	.he  53 
	.he  C8 
; pronunciation_rule     "#(SION)"    , "ZHUN"
	.he  23 
	.he  28 
	.he  53 
	.he  49 
	.he  4F 
	.he  4E 
	.he  29 
	.he  3D 
	.he  5A 
	.he  48 
	.he  55 
	.he  CE 
; pronunciation_rule     "(SOME)"     , "SAHM"
	.he  28 
	.he  53 
	.he  4F 
	.he  4D 
	.he  45 
	.he  29 
	.he  3D 
	.he  53 
	.he  41 
	.he  48 
	.he  CD 
; pronunciation_rule     "#(SUR)#"    , "ZHER"
	.he  23 
	.he  28 
	.he  53 
	.he  55 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  5A 
	.he  48 
	.he  45 
	.he  D2 
; pronunciation_rule     "(SUR)#"     , "SHER"
	.he  28 
	.he  53 
	.he  55 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  53 
	.he  48 
	.he  45 
	.he  D2 
; pronunciation_rule     "#(SU)#"     , "ZHUW"
	.he  23 
	.he  28 
	.he  53 
	.he  55 
	.he  29 
	.he  23 
	.he  3D 
	.he  5A 
	.he  48 
	.he  55 
	.he  D7 
; pronunciation_rule     "#(SSU)#"    , "SHUW"
	.he  23 
	.he  28 
	.he  53 
	.he  53 
	.he  55 
	.he  29 
	.he  23 
	.he  3D 
	.he  53 
	.he  48 
	.he  55 
	.he  D7 
; pronunciation_rule     "#(SED) "    , "ZD"
	.he  23 
	.he  28 
	.he  53 
	.he  45 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  5A 
	.he  C4 
; pronunciation_rule     "#(S)#"      , "Z"
	.he  23 
	.he  28 
	.he  53 
	.he  29 
	.he  23 
	.he  3D 
	.he  DA 
; pronunciation_rule     "(SAID)"     , "SEHD"
	.he  28 
	.he  53 
	.he  41 
	.he  49 
	.he  44 
	.he  29 
	.he  3D 
	.he  53 
	.he  45 
	.he  48 
	.he  C4 
; pronunciation_rule     "^(SION)"    , "SHUN"
	.he  5E 
	.he  28 
	.he  53 
	.he  49 
	.he  4F 
	.he  4E 
	.he  29 
	.he  3D 
	.he  53 
	.he  48 
	.he  55 
	.he  CE 
; pronunciation_rule     "(S)S"       , ""
	.he  28 
	.he  53 
	.he  29 
	.he  53 
	.he  BD 
; pronunciation_rule     ".(S) "      , "Z"
	.he  2E 
	.he  28 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  DA 
; pronunciation_rule     "#:.E(S) "   , "Z"
	.he  23 
	.he  3A 
	.he  2E 
	.he  45 
	.he  28 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  DA 
; pronunciation_rule     "#:^#(S) "   , "S"
	.he  23 
	.he  3A 
	.he  5E 
	.he  23 
	.he  28 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  D3 
; pronunciation_rule     "U(S) "      , "S"
	.he  55 
	.he  28 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  D3 
; pronunciation_rule     " :#(S) "    , "Z"
	.he  20 
	.he  3A 
	.he  23 
	.he  28 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  DA 
; pronunciation_rule     "##(S) "     , "Z"
	.he  23 
	.he  23 
	.he  28 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  DA 
; pronunciation_rule     " (SCH)"     , "SK"
	.he  20 
	.he  28 
	.he  53 
	.he  43 
	.he  48 
	.he  29 
	.he  3D 
	.he  53 
	.he  CB 
; pronunciation_rule     "(S)C+"      , ""
	.he  28 
	.he  53 
	.he  29 
	.he  43 
	.he  2B 
	.he  BD 
; pronunciation_rule     "#(SM)"      , "ZUM"
	.he  23 
	.he  28 
	.he  53 
	.he  4D 
	.he  29 
	.he  3D 
	.he  5A 
	.he  55 
	.he  CD 
; pronunciation_rule     "#(SN)'"     , "ZUN"
	.he  23 
	.he  28 
	.he  53 
	.he  4E 
	.he  29 
	.he  27 
	.he  3D 
	.he  5A 
	.he  55 
	.he  CE 
; pronunciation_rule     "(STLE)"     , "SUL"
	.he  28 
	.he  53 
	.he  54 
	.he  4C 
	.he  45 
	.he  29 
	.he  3D 
	.he  53 
	.he  55 
	.he  CC 
; pronunciation_rule     "(S)"        , "S"
	.he  28 
	.he  53 
	.he  29 
	.he  3D 
	.he  D3 
PTAB_T:		; pronunciation_index    "T"
	.he  5D 
	.he  D4 
; pronunciation_rule     " (T) "      , "TIY4"
	.he  20 
	.he  28 
	.he  54 
	.he  29 
	.he  20 
	.he  3D 
	.he  54 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     " (THE) #"   , "DHIY"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  29 
	.he  20 
	.he  23 
	.he  3D 
	.he  44 
	.he  48 
	.he  49 
	.he  D9 
; pronunciation_rule     " (THE) "    , "DHAX"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  48 
	.he  41 
	.he  D8 
; pronunciation_rule     "(TO) "      , "TUX"
	.he  28 
	.he  54 
	.he  4F 
	.he  29 
	.he  20 
	.he  3D 
	.he  54 
	.he  55 
	.he  D8 
; pronunciation_rule     " (THAT)"    , "DHAET"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  41 
	.he  54 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  41 
	.he  45 
	.he  D4 
; pronunciation_rule     " (THIS) "   , "DHIHS"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  49 
	.he  53 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  48 
	.he  49 
	.he  48 
	.he  D3 
; pronunciation_rule     " (THEY)"    , "DHEY"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  59 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  45 
	.he  D9 
; pronunciation_rule     " (THERE)"   , "DHEHR"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  52 
	.he  45 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  45 
	.he  48 
	.he  D2 
; pronunciation_rule     "(THER)"     , "DHER"
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  52 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  45 
	.he  D2 
; pronunciation_rule     "(THEIR)"    , "DHEHR"
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  49 
	.he  52 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  45 
	.he  48 
	.he  D2 
; pronunciation_rule     " (THAN) "   , "DHAEN"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  41 
	.he  4E 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  48 
	.he  41 
	.he  45 
	.he  CE 
; pronunciation_rule     " (THEM) "   , "DHEHM"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  4D 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  48 
	.he  45 
	.he  48 
	.he  CD 
; pronunciation_rule     "(THESE) "   , "DHIYZ"
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  53 
	.he  45 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  48 
	.he  49 
	.he  59 
	.he  DA 
; pronunciation_rule     " (THEN)"    , "DHEHN"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  45 
	.he  4E 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  45 
	.he  48 
	.he  CE 
; pronunciation_rule     "(THROUGH)"  , "THRUW4"
	.he  28 
	.he  54 
	.he  48 
	.he  52 
	.he  4F 
	.he  55 
	.he  47 
	.he  48 
	.he  29 
	.he  3D 
	.he  54 
	.he  48 
	.he  52 
	.he  55 
	.he  57 
	.he  B4 
; pronunciation_rule     "(THOSE)"    , "DHOHZ"
	.he  28 
	.he  54 
	.he  48 
	.he  4F 
	.he  53 
	.he  45 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  4F 
	.he  48 
	.he  DA 
; pronunciation_rule     "(THOUGH) "  , "DHOW"
	.he  28 
	.he  54 
	.he  48 
	.he  4F 
	.he  55 
	.he  47 
	.he  48 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  48 
	.he  4F 
	.he  D7 
; pronunciation_rule     "(TODAY)"    , "TUXDEY"
	.he  28 
	.he  54 
	.he  4F 
	.he  44 
	.he  41 
	.he  59 
	.he  29 
	.he  3D 
	.he  54 
	.he  55 
	.he  58 
	.he  44 
	.he  45 
	.he  D9 
; pronunciation_rule     "(TOMO)RROW" , "TUMAA5"
	.he  28 
	.he  54 
	.he  4F 
	.he  4D 
	.he  4F 
	.he  29 
	.he  52 
	.he  52 
	.he  4F 
	.he  57 
	.he  3D 
	.he  54 
	.he  55 
	.he  4D 
	.he  41 
	.he  41 
	.he  B5 
; pronunciation_rule     "(TO)TAL"    , "TOW5"
	.he  28 
	.he  54 
	.he  4F 
	.he  29 
	.he  54 
	.he  41 
	.he  4C 
	.he  3D 
	.he  54 
	.he  4F 
	.he  57 
	.he  B5 
; pronunciation_rule     " (THUS)"    , "DHAH4S"
	.he  20 
	.he  28 
	.he  54 
	.he  48 
	.he  55 
	.he  53 
	.he  29 
	.he  3D 
	.he  44 
	.he  48 
	.he  41 
	.he  48 
	.he  34 
	.he  D3 
; pronunciation_rule     "(TH)"       , "TH"
	.he  28 
	.he  54 
	.he  48 
	.he  29 
	.he  3D 
	.he  54 
	.he  C8 
; pronunciation_rule     "#:(TED) "   , "TIXD"
	.he  23 
	.he  3A 
	.he  28 
	.he  54 
	.he  45 
	.he  44 
	.he  29 
	.he  20 
	.he  3D 
	.he  54 
	.he  49 
	.he  58 
	.he  C4 
; pronunciation_rule     "S(TI)#N"    , "CH"
	.he  53 
	.he  28 
	.he  54 
	.he  49 
	.he  29 
	.he  23 
	.he  4E 
	.he  3D 
	.he  43 
	.he  C8 
; pronunciation_rule     "(TI)O"      , "SH"
	.he  28 
	.he  54 
	.he  49 
	.he  29 
	.he  4F 
	.he  3D 
	.he  53 
	.he  C8 
; pronunciation_rule     "(TI)A"      , "SH"
	.he  28 
	.he  54 
	.he  49 
	.he  29 
	.he  41 
	.he  3D 
	.he  53 
	.he  C8 
; pronunciation_rule     "(TIEN)"     , "SHUN"
	.he  28 
	.he  54 
	.he  49 
	.he  45 
	.he  4E 
	.he  29 
	.he  3D 
	.he  53 
	.he  48 
	.he  55 
	.he  CE 
; pronunciation_rule     "(TUR)#"     , "CHER"
	.he  28 
	.he  54 
	.he  55 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  43 
	.he  48 
	.he  45 
	.he  D2 
; pronunciation_rule     "(TU)A"      , "CHUW"
	.he  28 
	.he  54 
	.he  55 
	.he  29 
	.he  41 
	.he  3D 
	.he  43 
	.he  48 
	.he  55 
	.he  D7 
; pronunciation_rule     " (TWO)"     , "TUW"
	.he  20 
	.he  28 
	.he  54 
	.he  57 
	.he  4F 
	.he  29 
	.he  3D 
	.he  54 
	.he  55 
	.he  D7 
; pronunciation_rule     "&(T)EN "    , ""
	.he  26 
	.he  28 
	.he  54 
	.he  29 
	.he  45 
	.he  4E 
	.he  20 
	.he  BD 
; pronunciation_rule     "(T)"        , "T"
	.he  28 
	.he  54 
	.he  29 
	.he  3D 
	.he  D4 
PTAB_U:		; pronunciation_index    "U"
	.he  5D 
	.he  D5 
; pronunciation_rule     " (U) "      , "YUW4"
	.he  20 
	.he  28 
	.he  55 
	.he  29 
	.he  20 
	.he  3D 
	.he  59 
	.he  55 
	.he  57 
	.he  B4 
; pronunciation_rule     " (UN)I"     , "YUWN"
	.he  20 
	.he  28 
	.he  55 
	.he  4E 
	.he  29 
	.he  49 
	.he  3D 
	.he  59 
	.he  55 
	.he  57 
	.he  CE 
; pronunciation_rule     " (UN)"      , "AHN"
	.he  20 
	.he  28 
	.he  55 
	.he  4E 
	.he  29 
	.he  3D 
	.he  41 
	.he  48 
	.he  CE 
; pronunciation_rule     " (UPON)"    , "AXPAON"
	.he  20 
	.he  28 
	.he  55 
	.he  50 
	.he  4F 
	.he  4E 
	.he  29 
	.he  3D 
	.he  41 
	.he  58 
	.he  50 
	.he  41 
	.he  4F 
	.he  CE 
; pronunciation_rule     "@(UR)#"     , "UH4R"
	.he  40 
	.he  28 
	.he  55 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  55 
	.he  48 
	.he  34 
	.he  D2 
; pronunciation_rule     "(UR)#"      , "YUH4R"
	.he  28 
	.he  55 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  59 
	.he  55 
	.he  48 
	.he  34 
	.he  D2 
; pronunciation_rule     "(UR)"       , "ER"
	.he  28 
	.he  55 
	.he  52 
	.he  29 
	.he  3D 
	.he  45 
	.he  D2 
; pronunciation_rule     "(U)^ "      , "AH"
	.he  28 
	.he  55 
	.he  29 
	.he  5E 
	.he  20 
	.he  3D 
	.he  41 
	.he  C8 
; pronunciation_rule     "(U)^^"      , "AH5"
	.he  28 
	.he  55 
	.he  29 
	.he  5E 
	.he  5E 
	.he  3D 
	.he  41 
	.he  48 
	.he  B5 
; pronunciation_rule     "(UY)"       , "AY5"
	.he  28 
	.he  55 
	.he  59 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  B5 
; pronunciation_rule     " G(U)#"     , ""
	.he  20 
	.he  47 
	.he  28 
	.he  55 
	.he  29 
	.he  23 
	.he  BD 
; pronunciation_rule     "G(U)%"      , ""
	.he  47 
	.he  28 
	.he  55 
	.he  29 
	.he  25 
	.he  BD 
; pronunciation_rule     "G(U)#"      , "W"
	.he  47 
	.he  28 
	.he  55 
	.he  29 
	.he  23 
	.he  3D 
	.he  D7 
; pronunciation_rule     "#N(U)"      , "YUW"
	.he  23 
	.he  4E 
	.he  28 
	.he  55 
	.he  29 
	.he  3D 
	.he  59 
	.he  55 
	.he  D7 
; pronunciation_rule     "@(U)"       , "UW"
	.he  40 
	.he  28 
	.he  55 
	.he  29 
	.he  3D 
	.he  55 
	.he  D7 
; pronunciation_rule     "(U)"        , "YUW"
	.he  28 
	.he  55 
	.he  29 
	.he  3D 
	.he  59 
	.he  55 
	.he  D7 
PTAB_V:		; pronunciation_index    "V"
	.he  5D 
	.he  D6 
; pronunciation_rule     " (V) "      , "VIY4"
	.he  20 
	.he  28 
	.he  56 
	.he  29 
	.he  20 
	.he  3D 
	.he  56 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "(VIEW)"     , "VYUW5"
	.he  28 
	.he  56 
	.he  49 
	.he  45 
	.he  57 
	.he  29 
	.he  3D 
	.he  56 
	.he  59 
	.he  55 
	.he  57 
	.he  B5 
; pronunciation_rule     "(V)"        , "V"
	.he  28 
	.he  56 
	.he  29 
	.he  3D 
	.he  D6 
PTAB_W:		; pronunciation_index    "W"
	.he  5D 
	.he  D7 
; pronunciation_rule     " (W) "      , "DAH4BULYUW"
	.he  20 
	.he  28 
	.he  57 
	.he  29 
	.he  20 
	.he  3D 
	.he  44 
	.he  41 
	.he  48 
	.he  34 
	.he  42 
	.he  55 
	.he  4C 
	.he  59 
	.he  55 
	.he  D7 
; pronunciation_rule     " (WERE)"    , "WER"
	.he  20 
	.he  28 
	.he  57 
	.he  45 
	.he  52 
	.he  45 
	.he  29 
	.he  3D 
	.he  57 
	.he  45 
	.he  D2 
; pronunciation_rule     "(WA)SH"     , "WAA"
	.he  28 
	.he  57 
	.he  41 
	.he  29 
	.he  53 
	.he  48 
	.he  3D 
	.he  57 
	.he  41 
	.he  C1 
; pronunciation_rule     "(WA)ST"     , "WEY"
	.he  28 
	.he  57 
	.he  41 
	.he  29 
	.he  53 
	.he  54 
	.he  3D 
	.he  57 
	.he  45 
	.he  D9 
; pronunciation_rule     "(WA)S"      , "WAH"
	.he  28 
	.he  57 
	.he  41 
	.he  29 
	.he  53 
	.he  3D 
	.he  57 
	.he  41 
	.he  C8 
; pronunciation_rule     "(WA)T"      , "WAA"
	.he  28 
	.he  57 
	.he  41 
	.he  29 
	.he  54 
	.he  3D 
	.he  57 
	.he  41 
	.he  C1 
; pronunciation_rule     "(WHERE)"    , "WHEHR"
	.he  28 
	.he  57 
	.he  48 
	.he  45 
	.he  52 
	.he  45 
	.he  29 
	.he  3D 
	.he  57 
	.he  48 
	.he  45 
	.he  48 
	.he  D2 
; pronunciation_rule     "(WHAT)"     , "WHAHT"
	.he  28 
	.he  57 
	.he  48 
	.he  41 
	.he  54 
	.he  29 
	.he  3D 
	.he  57 
	.he  48 
	.he  41 
	.he  48 
	.he  D4 
; pronunciation_rule     "(WHOL)"     , "/HOWL"
	.he  28 
	.he  57 
	.he  48 
	.he  4F 
	.he  4C 
	.he  29 
	.he  3D 
	.he  2F 
	.he  48 
	.he  4F 
	.he  57 
	.he  CC 
; pronunciation_rule     "(WHO)"      , "/HUW"
	.he  28 
	.he  57 
	.he  48 
	.he  4F 
	.he  29 
	.he  3D 
	.he  2F 
	.he  48 
	.he  55 
	.he  D7 
; pronunciation_rule      "(WH)"      , "WH"
	.he  28 
	.he  57 
	.he  48 
	.he  29 
	.he  3D 
	.he  57 
	.he  C8 
; pronunciation_rule     "(WAR)#"     , "WEHR"
	.he  28 
	.he  57 
	.he  41 
	.he  52 
	.he  29 
	.he  23 
	.he  3D 
	.he  57 
	.he  45 
	.he  48 
	.he  D2 
; pronunciation_rule     "(WAR)"      , "WAOR"
	.he  28 
	.he  57 
	.he  41 
	.he  52 
	.he  29 
	.he  3D 
	.he  57 
	.he  41 
	.he  4F 
	.he  D2 
; pronunciation_rule     "(WOR)^"     , "WER"
	.he  28 
	.he  57 
	.he  4F 
	.he  52 
	.he  29 
	.he  5E 
	.he  3D 
	.he  57 
	.he  45 
	.he  D2 
; pronunciation_rule     "(WR)"       , "R"
	.he  28 
	.he  57 
	.he  52 
	.he  29 
	.he  3D 
	.he  D2 
; pronunciation_rule     "(WOM)A"     , "WUHM"
	.he  28 
	.he  57 
	.he  4F 
	.he  4D 
	.he  29 
	.he  41 
	.he  3D 
	.he  57 
	.he  55 
	.he  48 
	.he  CD 
; pronunciation_rule     "(WOM)E"     , "WIHM"
	.he  28 
	.he  57 
	.he  4F 
	.he  4D 
	.he  29 
	.he  45 
	.he  3D 
	.he  57 
	.he  49 
	.he  48 
	.he  CD 
; pronunciation_rule     "(WEA)R"     , "WEH"
	.he  28 
	.he  57 
	.he  45 
	.he  41 
	.he  29 
	.he  52 
	.he  3D 
	.he  57 
	.he  45 
	.he  C8 
; pronunciation_rule     "(WANT)"     , "WAA5NT"
	.he  28 
	.he  57 
	.he  41 
	.he  4E 
	.he  54 
	.he  29 
	.he  3D 
	.he  57 
	.he  41 
	.he  41 
	.he  35 
	.he  4E 
	.he  D4 
; pronunciation_rule     "ANS(WER)"   , "ER"
	.he  41 
	.he  4E 
	.he  53 
	.he  28 
	.he  57 
	.he  45 
	.he  52 
	.he  29 
	.he  3D 
	.he  45 
	.he  D2 
; pronunciation_rule     "(W)"        , "W"
	.he  28 
	.he  57 
	.he  29 
	.he  3D 
	.he  D7 
PTAB_X:		; pronunciation_index    "X"
	.he  5D 
	.he  D8 
; pronunciation_rule     " (X) "      , "EH4KS"
	.he  20 
	.he  28 
	.he  58 
	.he  29 
	.he  20 
	.he  3D 
	.he  45 
	.he  48 
	.he  34 
	.he  4B 
	.he  D3 
; pronunciation_rule     " (X)"       , "Z"
	.he  20 
	.he  28 
	.he  58 
	.he  29 
	.he  3D 
	.he  DA 
; pronunciation_rule     "(X)"        , "KS"
	.he  28 
	.he  58 
	.he  29 
	.he  3D 
	.he  4B 
	.he  D3 
PTAB_Y:		; pronunciation_index    "Y"
	.he  5D 
	.he  D9 
; pronunciation_rule     " (Y) "      , "WAY4"
	.he  20 
	.he  28 
	.he  59 
	.he  29 
	.he  20 
	.he  3D 
	.he  57 
	.he  41 
	.he  59 
	.he  B4 
; pronunciation_rule     "(YOUNG)"    , "YAHNX"
	.he  28 
	.he  59 
	.he  4F 
	.he  55 
	.he  4E 
	.he  47 
	.he  29 
	.he  3D 
	.he  59 
	.he  41 
	.he  48 
	.he  4E 
	.he  D8 
; pronunciation_rule     " (YOUR)"    , "YOHR"
	.he  20 
	.he  28 
	.he  59 
	.he  4F 
	.he  55 
	.he  52 
	.he  29 
	.he  3D 
	.he  59 
	.he  4F 
	.he  48 
	.he  D2 
; pronunciation_rule     " (YOU)"     , "YUW"
	.he  20 
	.he  28 
	.he  59 
	.he  4F 
	.he  55 
	.he  29 
	.he  3D 
	.he  59 
	.he  55 
	.he  D7 
; pronunciation_rule     " (YES)"     , "YEHS"
	.he  20 
	.he  28 
	.he  59 
	.he  45 
	.he  53 
	.he  29 
	.he  3D 
	.he  59 
	.he  45 
	.he  48 
	.he  D3 
; pronunciation_rule     " (Y)"       , "Y"
	.he  20 
	.he  28 
	.he  59 
	.he  29 
	.he  3D 
	.he  D9 
; pronunciation_rule     "F(Y)"       , "AY"
	.he  46 
	.he  28 
	.he  59 
	.he  29 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule     "PS(YCH)"    , "AYK"
	.he  50 
	.he  53 
	.he  28 
	.he  59 
	.he  43 
	.he  48 
	.he  29 
	.he  3D 
	.he  41 
	.he  59 
	.he  CB 
; pronunciation_rule     "#:^(Y) "    , "IY"
	.he  23 
	.he  3A 
	.he  5E 
	.he  28 
	.he  59 
	.he  29 
	.he  20 
	.he  3D 
	.he  49 
	.he  D9 
; pronunciation_rule     "#:^(Y)I"    , "IY"
	.he  23 
	.he  3A 
	.he  5E 
	.he  28 
	.he  59 
	.he  29 
	.he  49 
	.he  3D 
	.he  49 
	.he  D9 
; pronunciation_rule     " :(Y) "     , "AY"
	.he  20 
	.he  3A 
	.he  28 
	.he  59 
	.he  29 
	.he  20 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule     " :(Y)#"     , "AY"
	.he  20 
	.he  3A 
	.he  28 
	.he  59 
	.he  29 
	.he  23 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule     " :(Y)^+:#"  , "IH"
	.he  20 
	.he  3A 
	.he  28 
	.he  59 
	.he  29 
	.he  5E 
	.he  2B 
	.he  3A 
	.he  23 
	.he  3D 
	.he  49 
	.he  C8 
; pronunciation_rule     " :(Y)^#"    , "AY"
	.he  20 
	.he  3A 
	.he  28 
	.he  59 
	.he  29 
	.he  5E 
	.he  23 
	.he  3D 
	.he  41 
	.he  D9 
; pronunciation_rule     "(Y)"        , "IH"
	.he  28 
	.he  59 
	.he  29 
	.he  3D 
	.he  49 
	.he  C8 
PTAB_Z:		; pronunciation_index    "Z"
	.he  5D 
	.he  DA 
; pronunciation_rule     " (Z) "      , "ZIY4"
	.he  20 
	.he  28 
	.he  5A 
	.he  29 
	.he  20 
	.he  3D 
	.he  5A 
	.he  49 
	.he  59 
	.he  B4 
; pronunciation_rule     "(Z)"        , "Z"
	.he  28 
	.he  5A 
	.he  29 
	.he  3D 
	.he  DA 
/*
; ----------------------------------------------------------------------------

TRAILER: .byte   $EA,$A0                         ; Trailing bytes -- probably not important. MEMLO is set to TRAILER on start.

; ----------------------------------------------------------------------------
*/