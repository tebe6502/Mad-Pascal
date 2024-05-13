unit neo6502system;
(*
 @type: unit
 @author: Bartosz Zbytniewski (zbyti)
 @name: Overdrive standard supported functions of Mad Pascal

 @version: 0.1

 @description:
 <http://www.freepascal.org/docs-html/rtl/system/index-5.html>
*)

{

ArcTan
Sin
Cos
Str

}

//-----------------------------------------------------------------------------

interface

//-----------------------------------------------------------------------------

const

NEO_CURSOR_LEFT       = chr(1);
NEO_CURSOR_RIGHT      = chr(4);
NEO_INSERT            = chr(5);
NEO_PAGE_DOWN         = chr(6);
NEO_END               = chr(7);
NEO_BACKSPACE         = chr(8);
NEO_HTAB              = chr(9);   // horizontal tab
NEO_LINE_FEED         = chr(10);
NEO_CLEAR_SCREEN      = chr(12);
NEO_ENTER             = chr(13);
NEO_PAGE_UP           = chr(18);
NEO_CURSOR_DOWN       = chr(19);
NEO_CURSOR_HOME       = chr(20);
NEO_VTAB              = chr(22);  // vertical tab
NEO_CURSOR_UP         = chr(23);
NEO_CURSOR_REV        = chr(24);  // cursor reverse
NEO_DELETE            = chr(26);
NEO_ESCAPE            = chr(27);  // general break – e.g. exits BASIC

NEO_COLOR_BLACK       = chr($80);
NEO_COLOR_RED         = chr($81);
NEO_COLOR_GREEN       = chr($82);
NEO_COLOR_YELLOW      = chr($83);
NEO_COLOR_BLUE        = chr($84);
NEO_COLOR_MAGENTA     = chr($85);
NEO_COLOR_CYAN        = chr($86);
NEO_COLOR_WHITE       = chr($87);
NEO_COLOR_ALT_BLACK   = chr($88);
NEO_COLOR_DARK_GREY   = chr($89);
NEO_COLOR_DARK_GREEN  = chr($8A);
NEO_COLOR_ORANGE      = chr($8B);
NEO_COLOR_DARK_ORANGE = chr($8C);
NEO_COLOR_BROWN       = chr($8D);
NEO_COLOR_PINK        = chr($8E);
NEO_COLOR_LIGHT_GREY  = chr($8F);

//-----------------------------------------------------------------------------

var

ScreenWidth  : smallint = 40;    (* @var current screen width  *)
ScreenHeight : smallint = 24;    (* @var current screen height *)

//-----------------------------------------------------------------------------

function ArcTan(value: single) : single;    overload;
function Sin(x: single)        : single;    overload;
function Cos(x: single)        : single;    overload;

//-------------------------------------

procedure Str(a: integer;  var s: TString); overload; stdcall; assembler;
procedure Str(a: cardinal; var s: TString); overload; stdcall; assembler;
procedure Str(a: float;    var s: TString); overload; stdcall; assembler;

//-----------------------------------------------------------------------------

implementation

//-----------------------------------------------------------------------------

function ArcTan(value: single): single; overload;
(*
@description:
Arctan returns the Arctangent of Value, which can be any Real type.

The resulting angle is in radial units.

@param: value - single

@returns: single
*)
begin
    asm
        mva #MATH_ATAN     NEOMESSAGE_FUNC

        mva value   VAR0_B0
        mva value+1 VAR0_B1
        mva value+2 VAR0_B2
        mva value+3 VAR0_B3

        mva #VAR_FLOAT     VAR0_TYPE
        mva #STACK_ADDRESS NEOMESSAGE_PAR1W
        mva #STACK_SIZE1   NEOMESSAGE_PAR2W
        stz NEOMESSAGE_PAR1W+1
        stz NEOMESSAGE_PAR2W+1
        jsr @WaitMessage
        mva #MATH_GROUP    NEOMESSAGE_GROUP

        mva VAR0_B0 result
        mva VAR0_B1 result+1
        mva VAR0_B2 result+2
        mva VAR0_B3 result+3
    end;
end;

//-------------------------------------

function Sin(x: single): single; overload;
(*
@description:
Calculate sine of angle

@param: X - angle in radians (Single)

@returns: Single
*)
begin
    asm
        mva #MATH_SIN      NEOMESSAGE_FUNC

        mva x   VAR0_B0
        mva x+1 VAR0_B1
        mva x+2 VAR0_B2
        mva x+3 VAR0_B3

        mva #VAR_FLOAT     VAR0_TYPE
        mva #STACK_ADDRESS NEOMESSAGE_PAR1W
        mva #STACK_SIZE1   NEOMESSAGE_PAR2W
        stz NEOMESSAGE_PAR1W+1
        stz NEOMESSAGE_PAR2W+1
        jsr @WaitMessage
        mva #MATH_GROUP    NEOMESSAGE_GROUP

        mva VAR0_B0 result
        mva VAR0_B1 result+1
        mva VAR0_B2 result+2
        mva VAR0_B3 result+3
    end;
end;

//-------------------------------------

function Cos(x: single): single; overload;
(*
@description:
Calculate cosine of angle

@param: X - angle in radians (Single)

@returns: Single
*)
begin
    asm
        mva #MATH_COS      NEOMESSAGE_FUNC

        mva x   VAR0_B0
        mva x+1 VAR0_B1
        mva x+2 VAR0_B2
        mva x+3 VAR0_B3

        mva #VAR_FLOAT     VAR0_TYPE
        mva #STACK_ADDRESS NEOMESSAGE_PAR1W
        mva #STACK_SIZE1   NEOMESSAGE_PAR2W
        stz NEOMESSAGE_PAR1W+1
        stz NEOMESSAGE_PAR2W+1
        jsr @WaitMessage
        mva #MATH_GROUP    NEOMESSAGE_GROUP

        mva VAR0_B0 result
        mva VAR0_B1 result+1
        mva VAR0_B2 result+2
        mva VAR0_B3 result+3
    end;
end;

//-------------------------------------

procedure Str(a: integer; var s: TString); overload; stdcall; assembler;
(*
@description:
Convert a numerical value to a string

@param: a - integer
@param: s - string[32] - result
*)
asm
    mva #MATH_CONVERT_NUMBER_TO_STRING NEOMESSAGE_FUNC

    mva a   VAR0_B0
    mva a+1 VAR0_B1
    mva a+2 VAR0_B2
    mva a+3 VAR0_B3

    mwa s NEOMESSAGE_PAR3W

    stz VAR0_TYPE
    mva #STACK_ADDRESS NEOMESSAGE_PAR1W
    mva #STACK_SIZE1 NEOMESSAGE_PAR2W
    stz NEOMESSAGE_PAR1W+1
    stz NEOMESSAGE_PAR2W+1

    jsr @WaitMessage
    mva #MATH_GROUP NEOMESSAGE_GROUP
end;

//-------------------------------------

procedure Str(a: cardinal; var s: TString); overload; stdcall; assembler;
(*
@description:
Convert a numerical value to a string

@param: a - integer
@param: s - string[32] - result
*)
asm
    mva #MATH_CONVERT_NUMBER_TO_STRING NEOMESSAGE_FUNC

    mva a   VAR0_B0
    mva a+1 VAR0_B1
    mva a+2 VAR0_B2
    mva a+3 VAR0_B3

    mwa s NEOMESSAGE_PAR3W

    stz VAR0_TYPE
    mva #STACK_ADDRESS NEOMESSAGE_PAR1W
    mva #STACK_SIZE1 NEOMESSAGE_PAR2W
    stz NEOMESSAGE_PAR1W+1
    stz NEOMESSAGE_PAR2W+1

    jsr @WaitMessage
    mva #MATH_GROUP NEOMESSAGE_GROUP
end;

//-------------------------------------

procedure Str(a: float; var s: TString); overload; stdcall; assembler;
(*
@description:
Convert a numerical value to a string

@param: a - float
@param: s - string[32] - result
*)
asm
    mva #MATH_CONVERT_NUMBER_TO_STRING NEOMESSAGE_FUNC

    mva a   VAR0_B0
    mva a+1 VAR0_B1
    mva a+2 VAR0_B2
    mva a+3 VAR0_B3

    mwa s NEOMESSAGE_PAR3W

    mva #VAR_FLOAT VAR0_TYPE
    mva #STACK_ADDRESS NEOMESSAGE_PAR1W
    mva #STACK_SIZE1 NEOMESSAGE_PAR2W
    stz NEOMESSAGE_PAR1W+1
    stz NEOMESSAGE_PAR2W+1

    jsr @WaitMessage
    mva #MATH_GROUP NEOMESSAGE_GROUP
end;

//-----------------------------------------------------------------------------

end.