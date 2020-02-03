# For complete documentation of this file, please see Geany's main documentation
[styling]
# Edit these in the colorscheme .conf file instead
default=default
comment=comment_line
commentblock=comment
commentdirective=comment
number=number_1
string=string_1
operator=operator
identifier=identifier_1
cpuinstruction=keyword_1
mathinstruction=keyword_2
register=type
directive=preprocessor
directiveoperand=keyword_3
character=character
stringeol=string_eol
extinstruction=keyword_4

[keywords]
# all items must be in one line
# this is by default a very simple instruction set; not of Intel or so
instructions=lda ldx ldy sta stx sty adc and asl sbc jsr jmp lsr ora cmp cpy cpx dec inc eor rol ror brk clc cli clv cld php plp pha pla rti rts sec sei sed iny inx dey dex txa tya txs tay tax tsx nop bpl bmi bne bcc bcs beq bvc bvs bit lda.b ldx.b ldy.b sta.b stx.b sty.b lda.z ldx.z ldy.z sta.z stx.z sty.z lda.a ldx.a ldy.a sta.a stx.a sty.a lda.w ldx.w ldy.w sta.w stx.w sty.w lda.q ldx.q ldy.q sta.q stx.q sty.q aso rln lse rrd sax lax dcp isb anc alr arr ane anx sbx las sha shs shx shy npo cim req rne rpl rmi rcc rcs rvc rvs seq sne spl smi scc scs svc svs jeq jne jpl jmi jcc jcs jvc jvs add sub adb sbb adw sbw phr plr inw inl ind dew del ded mva mvx mvy mwa mwx mwy cpb cpw cpl cpd
registers=
directives=org eif ift els eli opt ins icl dta run ini end sin cos rnd blk label nmb rmb lmb set .asize .isize .align .array .enda .aend .def .define .udef .enum .ende .eend .error .extrn .print .ds .local .ifdef .if .else .elseif .endif .endl .ifndef .link .macro .endm .mend .exitm .exit .nowarn .pafes .endpg .pgend .public .global .globl .proc .endp .pend .reg .var .rept .endr .rend .r .reloc .struct .ends .send .symbol .segdef .segment .endseg .using .use .zpvar .end .en .byte .word .long .dword .or .and .xor .not .lo .hi .dbyte .by .wo .he .sb .cb .fl .adr .len .sizeof .filesize .get .wget .lget .dget .put .sav 

[settings]
# default extension used when saving files
extension=asm

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file
comment_single=;
# multiline comments
#comment_open=
#comment_close=

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=

[indentation]
#width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
#type=1

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
compiler=nasm "%f"

