unit x65;

(*
  @type: unit
  @author: zbyti
  @name: X65 CGIA hardware
  @version: 1.0
  @description: Register and constant definitions for the X65 CGIA chip.
  @see: https://docs.x65.zone/
*)

interface

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// CGIA mode constants
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
const
  CGIA_MODE_HIRES_BIT     = %00000001;
  CGIA_MODE_INTERLACE_BIT = %00000010;

  CGIA_REG_INT_FLAG_VBI = %10000000;
  CGIA_REG_INT_FLAG_DLI = %01000000;
  CGIA_REG_INT_FLAG_RSI = %00100000;

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Display List values
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  DL_INS_EMPTY_LINES            = $00;
  DL_INS_RESERVED_1             = $01;
  DL_INS_JUMP                   = $02;
  DL_INS_DL_INTERRUPT           = %10000000;
  DL_INS_LOAD_MEMORY            = $03;
  DL_INS_LM_MEMORY_SCAN         = %00010000;
  DL_INS_LM_FOREGROUND_SCAN     = %00100000;
  DL_INS_LM_BACKGROUND_SCAN     = %01000000;
  DL_INS_LM_CHARACTER_GENERATOR = %10000000;
  DL_INS_LOAD_REG8              = $04;
  DL_INS_LOAD_REG16             = $05;
  DL_INS_RESERVED_6             = $06;
  DL_INS_RESERVED_7             = $07;

  DL_MODE_PALETTE_TEXT          = $08;
  DL_MODE_PALETTE_BITMAP        = $09;
  DL_MODE_ATTRIBUTE_TEXT        = $0A;
  DL_MODE_ATTRIBUTE_BITMAP      = $0B;
  DL_MODE_HOLD_AND_MODIFY       = $0E;
  DL_MODE_AFFINE_TRANSFORM      = $0F;

  DL_MODE_BIT             = %00001000;
  DL_DOUBLE_WIDTH_BIT     = %00010000;
  DL_MULTICOLOR_BIT       = %00100000;
  DL_RESERVED_BIT         = %01000000;
  DL_DLI_BIT              = %10000000;

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Plane flags
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  PLANE_MASK_TRANSPARENT        = %00000001;
  PLANE_MASK_BORDER_TRANSPARENT = %00001000;
  PLANE_MASK_DOUBLE_WIDTH       = %00010000;
  PLANE_MASK_MULTICOLOR         = %00100000;
  PLANE_MASK_PIXEL_BITS         = %11000000;

  PLANE_MASK_FROM_DL = PLANE_MASK_DOUBLE_WIDTH or PLANE_MASK_MULTICOLOR;

  PLANE_BITS_1BPP = (%00 shl 6);
  PLANE_BITS_2BPP = (%01 shl 6);
  PLANE_BITS_3BPP = (%10 shl 6);
  PLANE_BITS_4BPP = (%11 shl 6);

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Sprite flags
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  SPRITE_MASK_WIDTH        = %00000111;
  SPRITE_MASK_RESERVED     = %00001000;
  SPRITE_MASK_DOUBLE_WIDTH = %00010000;
  SPRITE_MASK_MULTICOLOR   = %00100000;
  SPRITE_MASK_MIRROR_X     = %01000000;
  SPRITE_MASK_MIRROR_Y     = %10000000;

type
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Records for the individual plane modes (each one is exactly 16 bytes)
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  TCGIA_Plane_Bckgnd = record
    flags          : byte;
    border_columns : byte;
    row_height     : byte;
    stride         : byte;
    scroll_x       : byte;
    offset_x       : byte;
    scroll_y       : byte;
    offset_y       : byte;
    shared_color0  : byte;
    shared_color1  : byte;
    color2         : byte;
    color3         : byte;
    color4         : byte;
    color5         : byte;
    color6         : byte;
    color7         : byte;
  end;

  TCGIA_Plane_Ham = record
    flags          : byte;
    border_columns : byte;
    row_height     : byte;
    reserved       : array[0..4] of byte; // 5 bytes
    color0         : byte;
    color1         : byte;
    color2         : byte;
    color3         : byte;
    color4         : byte;
    color5         : byte;
    color6         : byte;
    color7         : byte;
  end;

  TCGIA_Plane_Affine = record
    flags          : byte;
    border_columns : byte;
    row_height     : byte;
    texture_bits   : byte;
    u              : word;
    v              : word;
    du             : word;
    dv             : word;
    dx             : word;
    dy             : word;
  end;

  TCGIA_Plane_Sprite = record
    active         : byte;
    border_columns : byte;
    start_y        : byte;
    stop_y         : byte;
    reserved       : array[0..11] of byte; // 12 bytes
  end;

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Main CGIA register record (size: 64 bytes / $40)
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  TCGIA_Regs = record
    mode          : byte;             // $FF00
    bckgnd_bank   : byte;             // $FF01
    sprite_bank   : byte;             // $FF02
    ctl_reserved  : array[0..12] of byte; // $FF03..$FF0F (13 bytes)
    raster        : word;             // $FF10..$FF11
    rst_status    : byte;             // $FF12
    rst_reserved1 : array[0..4] of byte;  // $FF13..$FF17 (5 bytes)
    int_raster    : word;             // $FF18..$FF19
    int_enable    : byte;             // $FF1A
    int_status    : byte;             // $FF1B
    rst_reserved2 : array[0..3] of byte;  // $FF1C..$FF1F (4 bytes)
    reserved      : array[0..15] of byte; // $FF20..$FF2F (16 bytes)

    // plane0/1/2/3, while preserving the original C documentation name
    // in the comment below.
    plane_ctrl    : byte;             // $FF30 (documentation: planes) | Plane enable and type [TTTTEEEE]

    order         : byte;             // $FF31
    pln_reserved1 : array[0..1] of byte;  // $FF32..$FF33 (2 bytes)
    back_color    : byte;             // $FF34
    pln_reserved2 : array[0..2] of byte;  // $FF35..$FF37 (3 bytes)
    offset0       : word;             // $FF38..$FF39
    offset1       : word;             // $FF3A..$FF3B
    offset2       : word;             // $FF3C..$FF3D
    offset3       : word;             // $FF3E..$FF3F
    // End of the structure at offset 64 ($40).
  end;

var
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Main access to the CGIA registers
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  [volatile] cgia: TCGIA_Regs absolute $FF00;

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // Plane mapping (equivalent to a C union)
  // Each plane occupies 16 bytes. They start at offset 64 ($40) from the
  // beginning of cgia.
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  // Plane 0 ($FF40)
  [volatile] plane0_bckgnd : TCGIA_Plane_Bckgnd absolute $FF40;
  [volatile] plane0_ham    : TCGIA_Plane_Ham    absolute $FF40;
  [volatile] plane0_affine : TCGIA_Plane_Affine absolute $FF40;
  [volatile] plane0_sprite : TCGIA_Plane_Sprite absolute $FF40;

  // Plane 1 ($FF50)
  [volatile] plane1_bckgnd : TCGIA_Plane_Bckgnd absolute $FF50;
  [volatile] plane1_ham    : TCGIA_Plane_Ham    absolute $FF50;
  [volatile] plane1_affine : TCGIA_Plane_Affine absolute $FF50;
  [volatile] plane1_sprite : TCGIA_Plane_Sprite absolute $FF50;

  // Plane 2 ($FF60)
  [volatile] plane2_bckgnd : TCGIA_Plane_Bckgnd absolute $FF60;
  [volatile] plane2_ham    : TCGIA_Plane_Ham    absolute $FF60;
  [volatile] plane2_affine : TCGIA_Plane_Affine absolute $FF60;
  [volatile] plane2_sprite : TCGIA_Plane_Sprite absolute $FF60;

  // Plane 3 ($FF70)
  [volatile] plane3_bckgnd : TCGIA_Plane_Bckgnd absolute $FF70;
  [volatile] plane3_ham    : TCGIA_Plane_Ham    absolute $FF70;
  [volatile] plane3_affine : TCGIA_Plane_Affine absolute $FF70;
  [volatile] plane3_sprite : TCGIA_Plane_Sprite absolute $FF70;

implementation

end.