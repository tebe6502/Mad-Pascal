
(***************************************************
 * RDC Unit                                        *
 *                                                 *
 * This is a Pascal port of C code from an article *
 * In "The C Users Journal", 1/92 Written by       *
 * Ed Ross.                                        *
 *                                                 *
 * The compression is not quite as good as PKZIP   *
 * but it decompresses about 5 times faster.       *
 ***************************************************)
Unit rdc;

Interface

Const
  BUFF_LEN = 8192;     { size of disk io buffer }

Var
  inputbuffer,
  outputbuffer : array [0..BUFF_LEN-1] of byte;

Procedure Comp_FileToFile(Var infile, outfile: File);
Procedure Decomp_FileToFile(Var infile, outfile: File);

Function RDC_Compress(inbuff     : PByte;
                      outbuff    : PByte;
                      inbuff_len : Word) : smallint;

Function RDC_Decompress(inbuff     : PByte;
                        outbuff    : PByte;
                        inbuff_len : Word) : smallint;

Implementation
Const
  HASH_LEN =  4096;    { # hash table entries }
  HASH_SIZE = HASH_LEN * Sizeof(word);

Var
  HashPtr      : array [0..HASH_SIZE-1] of word;


(*
 compress inbuff_len bytes of inbuff into outbuff
 using hash_len entries in hash_tbl.

 return length of outbuff, or "0 - inbuff_len"
 if inbuff could not be compressed.
*)
Function RDC_Compress(inbuff     : PByte;
                      outbuff    : PByte;
                      inbuff_len : Word) : smallint;
Var
  in_idx      : PByte;
  in_idxa     : PByte absolute in_idx;
  inbuff_end  : PByte;
  anchor      : PByte;
  pat_idx     : PByte;
  cnt         : Word;
  gap         : Word;
  c           : Word;
  hash        : Word;
  hashlen     : Word;
  ctrl_idx    : PWord;
  ctrl_bits   : Word;
  ctrl_cnt    : Word;
  out_idx     : PByte;
  outbuff_end : PByte;
Begin

  FillByte(HashPtr, sizeof(HashPtr), 0);
  
  in_idx := inbuff;
  
  inbuff_end := Pointer(inbuff + inbuff_len);
  ctrl_idx := Pointer(outbuff);
  ctrl_cnt := 0;

  out_idx := Pointer(outbuff + Sizeof(Word));
  outbuff_end := Pointer(outbuff + inbuff_len - 48);

  { skip the compression for a small buffer }

  If inbuff_len <= 18 Then
  Begin
    Move(outbuff, inbuff, inbuff_len);
    rdc_compress := 0 - inbuff_len;
    Exit;
  End;

  { adjust # hash entries so hash algorithm can
    use 'and' instead of 'mod' }

  hashlen := HASH_LEN - 1;

  { scan thru inbuff }

  While in_idx < inbuff_end Do
  Begin
    { make room for the control bits
      and check for outbuff overflow }

    If ctrl_cnt = 16 Then
    Begin
      ctrl_idx^ := ctrl_bits;
      ctrl_cnt := 1;
      ctrl_idx := Pointer(out_idx);
      Inc(out_idx, 2);
      If out_idx > outbuff_end Then
      Begin
        Move(outbuff, inbuff, inbuff_len);
        rdc_compress := inbuff_len;
        Exit;
      End;
    End
    Else
      Inc(ctrl_cnt);

      { look for rle }

      anchor := in_idx;
      c := in_idx^;
      Inc(in_idx);

      While (in_idx < inbuff_end)
            And (in_idx^ = c)
            And (word(in_idx - anchor) < (HASH_LEN + 18)) Do
        Inc(in_idx);

      { store compression code if character is
        repeated more than 2 times }

      cnt := word(in_idx - anchor);
      If cnt > 2 Then
      Begin
        If cnt <= 18 Then     { short rle }
        Begin
          out_idx^ := cnt - 3;
          Inc(out_idx);
          out_idx^ := c;
          Inc(out_idx);
        End
        Else                    { long rle }
        Begin
          Dec(cnt, 19);
          out_idx^ := 16 + (cnt and $0F);
          Inc(out_idx);
          out_idx^ := cnt Shr 4;
          Inc(out_idx);
          out_idx^ := c;
          Inc(out_idx);
        End;

        ctrl_bits := (ctrl_bits Shl 1) Or 1;
        Continue;
      End;

      { look for pattern if 2 or more characters
        remain in the input buffer }

      in_idx := anchor;

      If word(inbuff_end - in_idx) > 2 Then
      Begin
        { locate offset of possible pattern
          in sliding dictionary }

        hash := ((((in_idxa[0] And 15) Shl 8) Or in_idxa[1]) Xor
                 ((in_idxa[0] Shr 4) Or (in_idxa[2] Shl 4)))
                 And hashlen;

        pat_idx := in_idx;
        pat_idx^ := HashPtr[hash];
        HashPtr[hash] := Word(in_idx);

        { compare characters if we're within 4098 bytes }

        gap := word(in_idx - pat_idx);
        If (gap <= HASH_LEN + 2) Then
        Begin
          While (in_idx < inbuff_end)
                And (pat_idx < anchor)
                And (pat_idx^ = in_idx^)
                And (word(in_idx - anchor) < 271) Do
          Begin
            Inc(in_idx);
            Inc(pat_idx);
          End;

          { store pattern if it is more than 2 characters }

          cnt := word(in_idx - anchor);
          If cnt > 2 Then
          Begin
            Dec(gap, 3);

            If cnt <= 15 Then     { short pattern }
            Begin
              out_idx^ := (cnt Shl 4) or (gap And $0F);
              Inc(out_idx);
              out_idx^ := gap Shr 4;
              Inc(out_idx);
            End
            Else                    { long pattern }
            Begin
              out_idx^ := 32 + (gap And $0F);
              Inc(out_idx);
              out_idx^ := gap Shr 4;
              Inc(out_idx);
              out_idx^ := cnt - 16;
              Inc(out_idx);
            End;

            ctrl_bits := (ctrl_bits Shl 1) Or 1;
            Continue;
          End;
        End;
      End;

      { can't compress this character
        so copy it to outbuff }

      out_idx^ := c;
      Inc(out_idx);
      Inc(anchor);
      in_idx := anchor;
      ctrl_bits := ctrl_bits Shl 1;
  End;

  { save last load of control bits }

  ctrl_bits := ctrl_bits Shl (16 - ctrl_cnt);
  ctrl_idx^ := ctrl_bits;

  { and return size of compressed buffer }

  rdc_compress := smallint(out_idx - outbuff);
End;

(*
 decompress inbuff_len bytes of inbuff into outbuff.

 return length of outbuff.
*)
Function RDC_Decompress(inbuff     : PByte;
                        outbuff    : PByte;
                        inbuff_len : Word) : smallint;
Var
  ctrl_bits    : Word;
  ctrl_mask    : Word;
  inbuff_idx   : PByte;
  outbuff_idx  : PByte;
  inbuff_end   : PByte;
  cmd, cnt     : Word;
  ofs, len     : Word;
  outbuff_src  : PByte;
Begin
  ctrl_mask := 0;
  inbuff_idx := inbuff;
  outbuff_idx := outbuff;
  inbuff_end := Pointer(inbuff + inbuff_len);

  { process each item in inbuff }
  While inbuff_idx < inbuff_end Do
  Begin
    { get new load of control bits if needed }
    ctrl_mask := ctrl_mask Shr 1;
    If ctrl_mask = 0 Then
    Begin
      ctrl_bits := PWord(inbuff_idx)^;
      Inc(inbuff_idx, 2);
      ctrl_mask := $8000;
    End;

    { just copy this char if control bit is zero }
    If (ctrl_bits And ctrl_mask) = 0 Then
    Begin
      outbuff_idx^ := inbuff_idx^;
      Inc(outbuff_idx);
      Inc(inbuff_idx);
      Continue;
    End;

    { undo the compression code }
    cmd := (inbuff_idx^ Shr 4) And $0F;
    cnt := inbuff_idx^ And $0F;
    Inc(inbuff_idx);

    Case byte(cmd) Of
      0 :     { short rle }
      Begin
        Inc(cnt, 3);
        FillChar(outbuff_idx^, cnt, inbuff_idx^);
        Inc(inbuff_idx);
        Inc(outbuff_idx, cnt);
      End;

      1 :     { long rle }
      Begin
        Inc(cnt,  inbuff_idx^ Shl 4);
        Inc(inbuff_idx);
        Inc(cnt, 19);
        FillChar(outbuff_idx^, cnt, inbuff_idx^);
        Inc(inbuff_idx);
        Inc(outbuff_idx, cnt);
      End;

      2 :     { long pattern }
      Begin
        ofs := cnt + 3;
        Inc(ofs, inbuff_idx^ Shl 4);
        Inc(inbuff_idx);
        cnt := inbuff_idx^;
        Inc(inbuff_idx);
        Inc(cnt, 16);
        outbuff_src := Pointer(outbuff_idx - ofs);
        Move(outbuff_src^, outbuff_idx^, cnt);
        Inc(outbuff_idx, cnt);
      End;

      Else    { short pattern}
      Begin
        ofs := cnt + 3;
        Inc(ofs, inbuff_idx^ Shl 4);
        Inc(inbuff_idx);
        outbuff_src := Pointer(outbuff_idx - ofs);
        Move(outbuff_src^, outbuff_idx^, cmd);
        Inc(outbuff_idx, cmd);
      End;
    End;
  End;

  { return length of decompressed buffer }
  RDC_Decompress := smallint(outbuff_idx - outbuff);
End;

Procedure Comp_FileToFile(Var infile, outfile: File);
Var
  code         : smallint;
  bytes_read   : smallint;
  compress_len : smallint;
Begin

  { read infile BUFF_LEN bytes at a time }

  bytes_read := BUFF_LEN;
  While bytes_read = BUFF_LEN Do
  Begin
    Blockread(infile, inputbuffer, BUFF_LEN, bytes_read);

    { compress this load of bytes }
    compress_len := RDC_Compress(inputbuffer, outputbuffer, bytes_read);

    { write length of compressed buffer }
    Blockwrite(outfile, compress_len, 2, code);

    { check for negative length indicating the buffer could not be compressed }
    If compress_len < 0 Then
      compress_len := 0 - compress_len;

    { write the buffer }
    Blockwrite(outfile, outputbuffer, compress_len, code);
    { we're done if less than full buffer was read }
  End;

  { add trailer to indicate End of File }
  compress_len := 0;
  Blockwrite(outfile, compress_len, 2, code);
  {
  If (code <> 2) then
     err_exit('Error writing trailer.'+#13+#10);
  }
End;

Procedure Decomp_FileToFile(Var infile, outfile: File);
Var
  code         : smallint;
  block_len    : smallint;
  decomp_len   : smallint;
Begin
  { read infile BUFF_LEN bytes at a time }
  block_len := 1;
  While block_len <> 0 do
  Begin
    Blockread(infile, block_len, 2, code);
    {
    If (code <> 2) then
      err_exit('Can''t read block length.'+#13+#10);
    }
    { check for End-of-file flag }
    If block_len <> 0 Then
    Begin
      If (block_len < 0) Then { copy uncompressed chars }
      Begin
        decomp_len := 0 - block_len;
        Blockread(infile, outputbuffer, decomp_len, code);
        {
        If code <> decomp_len) then
          err_exit('Can''t read uncompressed block.'+#13+#10);
        }
      End
      Else                { decompress this buffer }
      Begin
        Blockread(infile, inputbuffer, block_len, code);
        {
        If (code <> block_len) then
          err_exit('Can''t read compressed block.'+#13+#10);
        }
        decomp_len := RDC_Decompress(inputbuffer, outputbuffer, block_len);
      End;
      { and write this buffer outfile }
      Blockwrite(outfile, outputbuffer, decomp_len, code);
      {
      if (code <> decomp_len) then
        err_exit('Error writing uncompressed data.'+#13+#10);
      }
    End;
  End;

End;

END.
