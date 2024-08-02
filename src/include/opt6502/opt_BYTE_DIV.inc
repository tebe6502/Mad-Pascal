
(*

; https://forums.atariage.com/blogs/entry/10805-unsigned-integer-division-routines/
;
; Unsigned Integer Division Routines (rev 2)
; by Jeff Johnson (Omegamatrix)
;
; To use these routines begin with unsigned value to be divided (0-255) in the accumulator,
; and the routine will finish with the integer result in the accumulator.
;
; - All divisions (2-32) are covered below
; - X, Y, and BCD mode are not used by any of these routines
; - All these routines are constant cycles
; - Most routines require 1 temp register

*)

procedure opt_BYTE_DIV(k: byte);
begin

 case k of

     2: begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 4);
	end;

    3:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc #$15';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'adc ' + GetARG(0, x-1);
	  listing[l+9] := #9'ror @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'adc ' + GetARG(0, x-1);
	  listing[l+12] := #9'ror @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 15);
	end;


    4:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 5);
	end;


    5:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc #$0d';
	  listing[l+4] := #9'adc ' + GetARG(0, x-1);
	  listing[l+5] := #9'ror @';
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'adc ' + GetARG(0, x-1);
	  listing[l+9] := #9'ror @';
	  listing[l+10] := #9'adc ' + GetARG(0, x-1);
	  listing[l+11] := #9'ror @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 15);
	end;


    6:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'sta ' + GetARG(0, x-1);
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'adc ' + GetARG(0, x-1);
	  listing[l+7] := #9'ror @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'adc ' + GetARG(0, x-1);
	  listing[l+13] := #9'ror @';
	  listing[l+14] := #9'lsr @ ';
	  listing[l+15] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 16);
	end;


    7:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 14);
	end;


    8:	begin
	  listing[l+1] := #9'lsr @';
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 5);
	end;


    9:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 15);
	end;


    10:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'sta  ' + GetARG(0, x-1);
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc  ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'adc  ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'adc  ' + GetARG(0, x-1);
	  listing[l+12] := #9'ror @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 16);
	end;


    11:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'adc  ' + GetARG(0, x-1);
	  listing[l+5] := #9'ror @';
	  listing[l+6] := #9'adc  ' + GetARG(0, x-1);
	  listing[l+7] := #9'ror @';
	  listing[l+8] := #9'adc  ' + GetARG(0, x-1);
	  listing[l+9] := #9'ror @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'adc  ' + GetARG(0, x-1);
	  listing[l+12] := #9'ror @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 17);
	end;


    12:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'sta ' + GetARG(0, x-1);
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'adc ' + GetARG(0, x-1);
	  listing[l+7] := #9'ror @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'adc ' + GetARG(0, x-1);
	  listing[l+13] := #9'ror @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 16);
	end;


    13:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc ' + GetARG(0, x-1);
	  listing[l+4] := #9'ror @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'add ' + GetARG(0, x-1);
	  listing[l+12] := #9'ror @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 17);
	end;


    14:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 15);
	end;


    15:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc #$04';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 13);
	end;


    16:	begin
	  listing[l+1] := #9'lsr @';
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 6);
	end;


    17:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc ' + GetARG(0, x-1);
	  listing[l+4] := #9'ror @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'adc #$00';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 15);
	end;


    18:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 16);
	end;


    19:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc ' + GetARG(0, x-1);
	  listing[l+4] := #9'ror @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'adc ' + GetARG(0, x-1);
	  listing[l+7] := #9'ror @';
	  listing[l+8] := #9'adc ' + GetARG(0, x-1);
	  listing[l+9] := #9'ror @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 15);
	end;


    20:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'sta ' + GetARG(0, x-1);
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'adc ' + GetARG(0, x-1);
	  listing[l+7] := #9'ror @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'adc ' + GetARG(0, x-1);
	  listing[l+11] := #9'ror @';
	  listing[l+12] := #9'adc ' + GetARG(0, x-1);
	  listing[l+13] := #9'ror @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 17);
	end;


    21:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc ' + GetARG(0, x-1);
	  listing[l+4] := #9'ror @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'adc ' + GetARG(0, x-1);
	  listing[l+12] := #9'ror @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'lsr @';
	  listing[l+17] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 18);
	end;


    22:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'cmp #$21';
	  listing[l+4] := #9'adc #$00';
	  listing[l+5] := #9'sta ' + GetARG(0, x-1);
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'adc ' + GetARG(0, x-1);
	  listing[l+10] := #9'ror @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'adc ' + GetARG(0, x-1);
	  listing[l+13] := #9'ror @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'lsr @';
	  listing[l+17] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 18);
	end;


    23:	begin
    	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'adc ' + GetARG(0, x-1);
	  listing[l+11] := #9'ror @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 17);
	end;


    24:	begin
	  listing[l+1] := #9'lsr @';
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'sta ' + GetARG(0, x-1);
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'adc ' + GetARG(0, x-1);
	  listing[l+11] := #9'ror @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 14);
	end;


    25:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc ' + GetARG(0, x-1);
	  listing[l+6] := #9'ror @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'adc ' + GetARG(0, x-1);
	  listing[l+9] := #9'ror @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 15);
	end;


    26:	begin
	  listing[l+1] := #9'lsr @';
	  listing[l+2] := #9'sta ' + GetARG(0, x-1);
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'adc ' + GetARG(0, x-1);
	  listing[l+5] := #9'ror @';
	  listing[l+6] := #9'adc ' + GetARG(0, x-1);
	  listing[l+7] := #9'ror @';
	  listing[l+8] := #9'adc ' + GetARG(0, x-1);
	  listing[l+9] := #9'ror @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'adc ' + GetARG(0, x-1);
	  listing[l+13] := #9'ror @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'lsr @';
	  listing[l+17] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 18);
	end;


    27:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'adc ' + GetARG(0, x-1);
	  listing[l+4] := #9'ror @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 14);
	end;


    28:	begin
	  listing[l+1] := #9'lsr @';
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'sta ' + GetARG(0, x-1);
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'adc #$02';
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'lsr @';
	  listing[l+8] := #9'adc ' + GetARG(0, x-1);
	  listing[l+9] := #9'ror @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 13);
	end;


    29:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'adc ' + GetARG(0, x-1);
	  listing[l+5] := #9'ror @';
	  listing[l+6] := #9'adc ' + GetARG(0, x-1);
	  listing[l+7] := #9'ror @';
	  listing[l+8] := #9'lsr @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'adc ' + GetARG(0, x-1);
	  listing[l+12] := #9'ror @';
	  listing[l+13] := #9'lsr @';
	  listing[l+14] := #9'lsr @';
	  listing[l+15] := #9'lsr @';
	  listing[l+16] := #9'lsr @';
	  listing[l+17] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 18);
	end;


    30:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'sec';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 14);
	end;


    31:	begin
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'lsr @';
	  listing[l+7] := #9'adc ' + GetARG(0, x-1);
	  listing[l+8] := #9'ror @';
	  listing[l+9] := #9'lsr @';
	  listing[l+10] := #9'lsr @';
	  listing[l+11] := #9'lsr @';
	  listing[l+12] := #9'lsr @';
	  listing[l+13] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 14);
	end;

    32:	begin
	  listing[l+1] := #9'lsr @';
	  listing[l+2] := #9'lsr @';
	  listing[l+3] := #9'lsr @';
	  listing[l+4] := #9'lsr @';
	  listing[l+5] := #9'lsr @';
	  listing[l+6] := #9'sta ' + GetARG(0, x-1);

	  inc(l, 7);
	end;

 end;

end;