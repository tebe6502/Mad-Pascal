//
// Sokoban port for X65 by zbyti
//
// From https://github.com/zbyti/x65-playground/tree/master/src/pascal/sokoban

program Sokoban;

//-----------------------------------------------------------------------------

{$i 'inc/const.inc'}
{$i 'inc/levels.inc'}
{$i 'inc/registers.inc'}

//-----------------------------------------------------------------------------

var
  frame_counter    : byte absolute $ff;
  joy              : byte absolute $fe;
  moveTimer        : byte absolute $fd;

  isOddFrame       : boolean = false;
  lvX, lvY         : byte;
  playerX, playerY : byte;
  centered         : byte;
  crates           : byte;
  level            : PChar;
  gfx_pla          : byte;
  iLv              : byte;

  tmp              : byte = 0;

//-----------------------------------------------------------------------------

procedure vbl; assembler; interrupt; keep;
asm
  pha
  inc frame_counter
  mva GPIO_IN0 joy

  lda moveTimer
  beq *+4
  dec moveTimer
  pla

  sta CGIA_INT_STATUS
end;

//-----------------------------------------------------------------------------

procedure pause; assembler; overload; inline;
asm
  lda frame_counter
  cmp frame_counter
  beq *-2
end;

procedure pause(v: byte); assembler; register; overload;
asm
  lda v
  clc
  adc frame_counter
  cmp frame_counter
  bne *-2
end;

//-----------------------------------------------------------------------------

procedure Init;
begin

  asm
    sei       ; disable IRQ
    sec \ xce ; switch to emulation mode
    cld       ; turn off decimal mode
  end;

  CGIA_PLANES := 0;                       // disable all planes
  FillByte(pointer(CGIA_PLANE0), 10, 0);  // clear CGIA_PLANE0 registers

  CGIA_PLANE0_ROW_HEIGHT := 7;            // 8 rows per character

  CGIA_PLANE0_SHARED_COLOR1 := COL_BLACK;
  CGIA_PLANE0_SHARED_COLOR2 := COL_WIHTE;
  FillByte(pointer(LMS), SCR_OFFSET, SPACE_TILE);
  FillByte(pointer(LFS), SCR_OFFSET, COL_WIHTE);
  FillByte(pointer(LBS), SCR_OFFSET, COL_GROUND);

  CGIA_OFFSET0 := word(@DL);              // point plane0 to DL
  CGIA_PLANES := 1;                       // activate plane0

  CGIA_INT_ENABLE := %10000000;           // trigger NMI on VBL
end;

//-----------------------------------------------------------------------------

procedure getLv(lv: word);
var
  iX, iY : byte;
  offset : byte;
  row    : byte;
  tmpChr : byte;
begin
  offset := 0;
  crates := 0;

  level := levels[lv];
  lvX   := ord(level[0]) - 1;
  lvY   := ord(level[1]) - 1;
  level := levels[lv] + 2;
  row   := lvX + 1;

  centered := (MAX_X - lvX) shr 1 + ((MAX_Y - lvY + 2) shr 1) * MAX_X;

  for iY := 0 to lvY do begin
    for iX := 0 to lvX do begin
      tmpChr := ord(level[offset + iX]);

      if (tmpChr = S_PLA) or (tmpChr = S_PLD) then begin
        playerX := iX;
        playerY := iY
      end;

      if tmpChr = S_CRA then inc(crates);

      board[iY][iX] := tmpChr;
    end;
    inc(offset, row);
  end;
end;

//-----------------------------------------------------------------------------

procedure putTile(pos: word; tile: byte); register;
var
  pos_lms       : word;
  pos_lfs       : word;
  //pos_lbs       : word;
  t, t_c1, t_c2 : byte;
begin
  t    := tile_char[tile];
  t_c1 := tile_col1[tile];
  //t_c2 := tile_col2[tile];

  pos_lms := LMS + (pos shl 1);
  pos_lfs := pos_lms + SCR_OFFSET;
  //pos_lbs := pos_lfs + SCR_OFFSET;

  Poke(pos_lms, t);
  Poke(pos_lms + 1, t + 1);
  Poke(pos_lms + SCR_W, t + $10);
  Poke(pos_lms + SCR_W + 1, t + $11);

  Poke(pos_lfs, t_c1);
  Poke(pos_lfs + 1, t_c1);
  Poke(pos_lfs + SCR_W, t_c1);
  Poke(pos_lfs + SCR_W + 1, t_c1);

  //Poke(pos_lbs, t_c2);
  //Poke(pos_lbs + 1, t_c2);
  //Poke(pos_lbs + SCR_W, t_c2);
  //Poke(pos_lbs + SCR_W + 1, t_c2);
end;

//-----------------------------------------------------------------------------

procedure drawBoard;
var
  iX, iY   : byte;
  tile     : byte;
begin
  for iY := lvY downto 0  do begin
    for iX := lvX downto 0 do begin
      case ord(board[iY][iX]) of
        S_WAL : tile := GFX_WAL;
        S_FLO : tile := GFX_FLO;
        S_CRA : tile := GFX_CRA;
        S_CRD : tile := GFX_CRD;
        S_DEC : tile := GFX_DEC;
        S_GRA : tile := GFX_GRA;
        S_PLA : tile := gfx_pla;
        S_PLD : tile := gfx_pla;
      end;
      if tile <> GFX_GRA then
        putTile(centered + iY * SCR_W + iX, tile);
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure makeMove(joy: byte);
var
  updatePos           : boolean;
  pX, pY              : byte;
  step0, step1, step2 : PByte;
begin
  updatePos := false;
  pX := playerX; pY := playerY;
  step0 := @board[playerY][playerX];

  case joy of
    joy_right: begin
      step1 := step0 + 1;
      step2 := step1 + 1;
      inc(pX);
      gfx_pla := PLA_RIGHT;
    end;
    joy_left: begin
      step1 := step0 - 1;
      step2 := step1 - 1;
      dec(pX);
      gfx_pla := PLA_LEFT;
    end;
    joy_up: begin
      step1 := step0 - MAX_X;
      step2 := step1 - MAX_X;
      dec(pY);
      gfx_pla := PLA_UP;
    end;
    joy_down: begin
      step1 := step0 + MAX_X;
      step2 := step1 + MAX_X;
      inc(pY);
      gfx_pla := PLA_DOWN;
    end;
  end;

  if step1^ = S_FLO then
  begin
    step1^ := S_PLA; updatePos := true;
  end else

  if step1^ = S_DEC then
  begin
    step1^ := S_PLD; updatePos := true;
  end else

  if ((step1^ = S_CRA) or (step1^ = S_CRD)) and ((step2^ = S_FLO) or (step2^ = S_DEC)) then
  begin
    if step2^ = S_FLO then step2^ := S_CRA else step2^ := S_CRD;

    if (step1^ = S_CRA) and (step2^ = S_CRD) then dec(crates) else
    if (step1^ = S_CRD) and (step2^ = S_CRA) then inc(crates);

    if step1^ = S_CRA then step1^ := S_PLA else step1^ := S_PLD;

    updatePos := true;
  end;

  if updatePos then begin
    if step0^ = S_PLA then step0^ := S_FLO else step0^ := S_DEC;
    playerX := pX; playerY := pY;

    isOddFrame := not isOddFrame;
    if isOddFrame then begin
      tile_char[PLA_RIGHT] := tile_char[PLA_RIGHT] + 2;
      tile_char[PLA_LEFT]  := tile_char[PLA_LEFT]  + 2;
      tile_char[PLA_UP]    := tile_char[PLA_UP]    + 2;
      tile_char[PLA_DOWN]  := tile_char[PLA_DOWN]  + 2;
    end else begin
      tile_char[PLA_RIGHT] := tile_char[PLA_RIGHT] - 2;
      tile_char[PLA_LEFT]  := tile_char[PLA_LEFT]  - 2;
      tile_char[PLA_UP]    := tile_char[PLA_UP]    - 2;
      tile_char[PLA_DOWN]  := tile_char[PLA_DOWN]  - 2;
    end;

    drawBoard;

    moveTimer := JOY_DELAY;
  end;

end;

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------

begin
  Init;

  iLv := 255;
  crates := 0;
  isOddFrame := false;

  tile_char[PLA_RIGHT] := PLA_RIGHT_T;
  tile_char[PLA_LEFT]  := PLA_LEFT_T;
  tile_char[PLA_UP]    := PLA_UP_T;
  tile_char[PLA_DOWN]  := PLA_DOWN_T;

  pause;
  Move(pointer(TXT_INFO_1) + 1, pointer(LMS), TXT_INFO_1[0]);
  Move(pointer(TXT_INFO_2) + 1, pointer(LMS) + SCR_W * 2, TXT_INFO_2[0]);
  Move(pointer(TXT_INFO_3) + 1, pointer(LMS) + SCR_W * 3, TXT_INFO_3[0]);
  Move(pointer(TXT_INFO_4) + 1, pointer(LMS) + SCR_W * 4, TXT_INFO_4[0]);
  Move(pointer(TXT_INFO_5) + 1, pointer(LMS) + SCR_W * 6, TXT_INFO_5[0]);
  repeat until joy = JOY_SPACE;

  repeat
    if (crates = 0) then begin
      if iLv <= SET_SIZE then begin
        gfx_pla := PLA_WAVE;
        drawBoard;
        pause(30);
      end;
      joy := JOY_RIGHT and JOY_SPACE;
    end;

    if (joy <> %11111111) and (moveTimer = 0) then begin

      if
        (joy = JOY_UP)   or
        (joy = JOY_DOWN) or
        (joy = JOY_LEFT) or
        (joy = JOY_RIGHT)
      then
        makeMove(joy);

      case joy of
        JOY_RIGHT and JOY_SPACE : if iLv < SET_SIZE then inc(iLv) else iLv := 0;
        JOY_LEFT  and JOY_SPACE : if iLv > 0 then dec(iLv) else iLv := SET_SIZE;
      end;

      if joy < JOY_SPACE then begin
        pause; CGIA_PLANES := 0;

        FillByte(pointer(LFS), SCR_OFFSET, COL_WIHTE);
        FillByte(pointer(LMS), SCR_OFFSET, GROUND_TILE);

        //Print level number
        Poke(LMS + SCR_W - 3, $30 + iLv div 10);
        Poke(LMS + SCR_W - 2, $30 + iLv mod 10);

        gfx_pla := PLA_RIGHT;
        getLv(iLv);
        drawBoard;

        pause(30); CGIA_PLANES := 1;
      end;

    end;

    pause;
  until false;
end.

//-----------------------------------------------------------------------------
