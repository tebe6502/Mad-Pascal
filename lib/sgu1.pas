unit sgu1;

(*
  @type: unit
  @author: zbyti
  @name: SGU-1 Sound Generation Unit (Corrected with X65 Memory Map)
  @version: 1.0
  @description: Exact SGU-1 register mapping based on the X65 Memory Map CSV.
  @see: https://docs.x65.zone/
*)

interface

const
  SGU_BASE_ADDR = $FEC0;
  SGU_SEL_ADDR  = $FEFF;

  SGU_BANK_SERVICE = $FF;

  // FLAGS0 (Offset $24)
  SGU_F0_GATE    = %00000001;
  SGU_F0_TRIG    = %00000010;
  SGU_F0_PCM     = %00001000;
  SGU_F0_RINGMOD = %00010000;
  SGU_F0_LP      = %00100000;
  SGU_F0_HP      = %01000000;
  SGU_F0_BP      = %10000000;

  // FLAGS1 (Offset $25)
  SGU_F1_PHASE_RESET      = %00000001;
  SGU_F1_FILT_PHASE_RESET = %00000010;
  SGU_F1_PCM_LOOP         = %00000100;
  SGU_F1_TIMER_SYNC       = %00001000;
  SGU_F1_FREQ_SWEEP       = %00010000;
  SGU_F1_VOL_SWEEP        = %00100000;
  SGU_F1_CUT_SWEEP        = %01000000;
  SGU_F1_DIAG             = %10000000;

  // WAVE (bits 0-2 in operator R7)
  SGU_WAVE_SINE     = 0;
  SGU_WAVE_TRIANGLE = 1;
  SGU_WAVE_SAW      = 2;
  SGU_WAVE_PULSE    = 3;
  SGU_WAVE_NOISE    = 4;
  SGU_WAVE_PERIODIC = 5;
  SGU_WAVE_RESERVED = 6;
  SGU_WAVE_SAMPLE   = 7;

type
  // Structure of 8 registers of one Operator (size: 8 bytes)
  TOperatorRegs = record
    r0_mul_ksr_vib_trm: byte; // $x0: [7]TRM [6]VIB [5:4]KSR [3:0]MUL
    r1_tl_ksl         : byte; // $x1: [7:6]KSL [5:0]TL_lo6
    r2_ar_dr          : byte; // $x2: [7:4]AR_lo4 [3:0]DR_lo4
    r3_sl_rr          : byte; // $x3: [7:4]SL [3:0]RR
    r4_dt_sr          : byte; // $x4: [7:5]DT [4:0]SR
    r5_fix_wpar_delay : byte; // $x5: [7:5]DELAY [4]FIX [3:0]WPAR
    r6_tl_mod_sync_ring_vibd_trmd: byte; // $x6: [7]TRMD [6]VIBD [5]SYNC [4]RING [3:1]MOD [0]TL_msb
    r7_out_ar_msb_dr_msb_wave: byte; // $x7: [7:5]OUT [4]AR_msb [3]DR_msb [2:0]WAVE
  end;

  // Hardware Sweep structure (size: 4 bytes)
  TSweepRegs = record
    speed_lo: byte;
    speed_hi: byte;
    amt     : byte;
    bound   : byte;
  end;

  // Full 64-byte channel register (compatible with CSV memory map)
  TSGU_ChannelRegs = record
    // 4 Operators (32 bytes) - CSV names them OP1..OP4, docs call them OP0..OP3
    op1: TOperatorRegs; // Offset $00-$07
    op2: TOperatorRegs; // Offset $08-$0F
    op3: TOperatorRegs; // Offset $10-$17
    op4: TOperatorRegs; // Offset $18-$1F

    // Main channel registers (10 bytes)
    freq_lo: byte; // $20
    freq_hi: byte; // $21
    vol    : byte; // $22
    pan    : byte; // $23
    flags0 : byte; // $24
    flags1 : byte; // $25
    cut_lo : byte; // $26
    cut_hi : byte; // $27
    duty   : byte; // $28
    reson  : byte; // $29

    // PCM (6 bytes)
    pcmpos_lo: byte; // $2A
    pcmpos_hi: byte; // $2B
    pcmbnd_lo: byte; // $2C
    pcmbnd_hi: byte; // $2D
    pcmrst_lo: byte; // $2E
    pcmrst_hi: byte; // $2F

    // Sweeps (12 bytes)
    sw_freq: TSweepRegs; // $30-$33
    sw_vol : TSweepRegs; // $34-$37
    sw_cut : TSweepRegs; // $38-$3B

    // Misc (3 bytes)
    restimer_lo: byte; // $3C
    restimer_hi: byte; // $3D
    lfo_w      : byte; // $3E

    // Selector (1 byte)
    channel_select: byte; // $3F
  end;

var
  // Main record mapped to the hardware window
  [volatile] sgu: TSGU_ChannelRegs absolute SGU_BASE_ADDR;
  
  // Direct access to the selector
  [volatile] sgu_selector: byte absolute SGU_SEL_ADDR;
  
  // Clever trick: in channel mode offset $20 is freq_lo.
  // But when sgu_selector = SGU_BANK_SERVICE, offset $20 is Master Volume!
  [volatile] sgu_master_vol: byte absolute SGU_BASE_ADDR + $20;

implementation
end.
