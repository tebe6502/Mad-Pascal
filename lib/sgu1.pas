unit sgu1;

(*
  @type: unit
  @author: zbyti
  @name: SGU-1 — X65 sound generator register map
  @version: 2.0
  @description: Window $FEC0..$FEFF switched by the selector:
                $00..$08 = channel, $FF = service bank.
                Core: tildearrow Sound Unit; ESFM routing; SID filter; Paula PCM.
  @see: https://docs.x65.zone/A/G_sgu1/
*)

interface

const
  // --- Addresses and bank selection ----------------------------------------
  SGU_BASE_ADDR     = $FEC0;   // register window (64 bytes)
  SGU_SEL_ADDR      = $FEFF;   // CHANNEL_SELECT
  SGU_CHANNEL_COUNT = 9;       // valid values: $00..$08 and $FF;
  SGU_BANK_SERVICE  = $FF;     // $09..$FE reserved — do not write!

  // --- Chip clocks ----------------------------------------------------------
  SGU_SAMPLE_RATE    = 48000;  // I2S, fixed
  SGU_PCM_RATE_UNITY = 32768;  // FREQ in PCM mode: 32768 = native 48 kHz

  // --- FLAGS0 ($24): CTRL[7:4] PCM[3] ---[2] TRIG[1] GATE[0] ----------------
  // Key events (OR-ed into the shadow byte):
  //   GATE       key-down / legato — envelope keeps running, no restart
  //   GATE|TRIG  note-on           — restart from silence, from any state
  //   0          note-off          — release ramp
  //   TRIG       note-cut          — instant silence
  // TRIG self-clears within one sample; the driver's shadow must NEVER
  // contain TRIG, or every subsequent FLAGS0 write would retrigger the note.
  SGU_F0_GATE    = %00000001;
  SGU_F0_TRIG    = %00000010;
  SGU_F0_PCM     = %00001000;
  SGU_F0_RINGMOD = %00010000;  // ring mod with channel N+1 (8 wraps to 0)
  SGU_F0_LP      = %00100000;  // SVF low-pass tap  (CSV: nslow)
  SGU_F0_HP      = %01000000;  // SVF high-pass tap (CSV: nshigh)
  SGU_F0_BP      = %10000000;  // SVF band-pass tap (CSV: nsband)
  // Taps are summed (LP+HP = notch). No taps = filter bypassed.

  // --- FLAGS1 ($25) ----------------------------------------------------------
  SGU_F1_PHASE_RESET      = %00000001;  // one-shot: channel phase reset
  SGU_F1_FILT_PHASE_RESET = %00000010;  // one-shot: filter state reset
  SGU_F1_PCM_LOOP         = %00000100;
  SGU_F1_TIMER_SYNC       = %00001000;  // phase reset every RESTIMER samples
  SGU_F1_FREQ_SWEEP       = %00010000;  // sweep writes FREQ back —
  SGU_F1_VOL_SWEEP        = %00100000;  // ...VOL (runs even after note-off) —
  SGU_F1_CUT_SWEEP        = %01000000;  // ...CUTOFF; do not duplicate from CPU!
  SGU_F1_DIAG             = %10000000;  // window reads = live state (chip >= 1.1);
                                        // drivers must not set this bit

  // --- WAVE (R7[2:0]) --------------------------------------------------------
  SGU_WAVE_SINE     = 0;
  SGU_WAVE_TRIANGLE = 1;
  SGU_WAVE_SAW      = 2;
  SGU_WAVE_PULSE    = 3;   // WPAR=0 -> width from DUTY; 1..15 -> x/16
  SGU_WAVE_NOISE    = 4;   // long LFSR, clocked by the channel FREQ
  SGU_WAVE_PERIODIC = 5;   // short LFSR, taps in WPAR[1:0]
  SGU_WAVE_RESERVED = 6;   // silence
  SGU_WAVE_SAMPLE   = 7;   // 1024-byte wavetable based at PCMRST

  // --- Operator R0: [7]TRM [6]VIB [5:4]KSR [3:0]MUL --------------------------
  SGU_OP_TRM      = $80;   // operator follows the AM LFO
  SGU_OP_VIB      = $40;   // operator follows the PM LFO
  SGU_OP_KSR_MASK = $30;
  SGU_OP_MUL_MASK = $0F;   // MUL=0 means ×0.5!

  // --- Operator R1: [7:6]KSL [5:0]TL_lo6 -------------------------------------
  SGU_OP_KSL_MASK   = $C0;
  SGU_OP_TL_LO_MASK = $3F; // TL: 0.75 dB/step, 0 = loudest

  // --- Operator R4: [7:5]DT [4:0]SR ------------------------------------------
  SGU_OP_DT_MASK = $E0;    // DT 0 and 4 = none; 1..3 up, 5..7 down
  SGU_OP_SR_MASK = $1F;    // SR=0 freezes the level (second decay, OPN D2R)

  // --- Operator R5: [7:5]DELAY [4]FIX [3:0]WPAR -------------------------------
  SGU_OP_DELAY_MASK = $E0; // key-on delay: 2^(d+8) samples (10.7..683 ms)
  SGU_OP_FIX        = $10; // fixed frequency: MUL/DT = freq16
  SGU_OP_WPAR_MASK  = $0F;

  // --- Operator R6: [7]TRMD [6]VIBD [5]SYNC [4]RING [3:1]MOD [0]TL_msb --------
  SGU_OP_TRMD      = $80;  // deep tremolo (shallow = 1/4)
  SGU_OP_VIBD      = $40;  // deep vibrato (~±13.5 cents)
  SGU_OP_SYNC      = $20;  // hard sync with the previous operator
  SGU_OP_RING      = $10;  // 1-bit ring mod with the previous operator
  SGU_OP_MOD_MASK  = $0E;  // MOD: 6 dB steps; on OP1 this field = FEEDBACK
  SGU_OP_MOD_UNITY = $0E;  // MOD=7 (0 dB)
  SGU_OP_TL_MSB    = $01;

  // --- Operator R7: [7:5]OUT [4]AR_msb [3]DR_msb [2:0]WAVE --------------------
  SGU_OP_OUT_MASK  = $E0;  // OUT: contribution to the mix, 0 = disconnected, 6 dB steps
  SGU_OP_OUT_UNITY = $E0;  // OUT=7 (0 dB)
  SGU_OP_AR_MSB    = $10;
  SGU_OP_DR_MSB    = $08;
  SGU_OP_WAVE_MASK = $07;
  SGU_OP_CTRL_MASK = $F8;  // R7 without the WAVE field

  // --- LFOW ($3E): [1:0] AM shape [3:2] PM shape ------------------------------
  // Fixed rates: AM 2.93 Hz, PM 5.86 Hz; all channels stay in phase.
  SGU_LFO_SAW      = 0;
  SGU_LFO_SQUARE   = 1;
  SGU_LFO_TRIANGLE = 2;
  SGU_LFO_NOISE    = 3;
  SGU_LFO_PM_SHIFT = 2;

type
  // 8 operator registers. Docs number them OP0..OP3, CSV/tracker OP1..OP4.
  TSguOperatorRegs = record
    mulKsrVibTrem:     byte; // $x0
    levelKsl:          byte; // $x1
    attackDecayLo:     byte; // $x2: [7:4]AR_lo4 [3:0]DR_lo4
    sustainRelease:    byte; // $x3: [7:4]SL [3:0]RR; SL: 0 = full sustain, 15 = silence
    detuneSustainRate: byte; // $x4
    delayFixWaveParam: byte; // $x5
    modFlagsLevelMsb:  byte; // $x6
    outEnvMsbWave:     byte; // $x7
  end;

  // Hardware sweep. SPEED = samples between steps (0 = disabled).
  // Enabled in FLAGS1; the result is written back to the target register.
  TSguSweepRegs = record
    speedLo: byte;
    speedHi: byte;
    amount:  byte;  // step + direction + mode (vol: loop/bounce)
    bound:   byte;  // freq/cut: coarse target, saturates at BOUND<<8
  end;

  // Channel registers $00..$3E (63 bytes). The selector at $3F is SEPARATE
  // (sguSelector), so SizeOf(TSguChannelRegs) = the wipe range and copying
  // the record cannot switch banks. Valid when sguSelector = $00..$08.
  TSguChannelRegs = record
    op1: TSguOperatorRegs; // $00-$07 (docs: OP0)
    op2: TSguOperatorRegs; // $08-$0F
    op3: TSguOperatorRegs; // $10-$17
    op4: TSguOperatorRegs; // $18-$1F

    // FREQ: SID semantics, Hz = FREQ * 1e6 / 2^24 (A4 = 7382 = $1CD6).
    // In PCM mode: rate_Hz = 48000 * FREQ / 32768.
    freqLo:     byte;     // $20
    freqHi:     byte;     // $21
    volume:     shortint; // $22 |vol| = level, sign negates the sample; BEFORE the filter
    pan:        shortint; // $23 <0 left, >0 right, 0 center
    flags0:     byte;     // $24
    flags1:     byte;     // $25
    cutoffLo:   byte;     // $26
    cutoffHi:   byte;     // $27
    pulseDuty:  shortint; // $28 |duty| = low run out of 128; sign = position; 0 = all high
    resonance:  byte;     // $29 less damping AND more drive

    pcmPosLo:   byte;     // $2A
    pcmPosHi:   byte;     // $2B
    pcmBoundLo: byte;     // $2C
    pcmBoundHi: byte;     // $2D
    pcmResetLo: byte;     // $2E loop restart; also the wavetable base for WAVE=7
    pcmResetHi: byte;     // $2F

    sweepFreq: TSguSweepRegs; // $30-$33 exponential (portamento)
    sweepVol:  TSguSweepRegs; // $34-$37 linear, loop/bounce
    sweepCut:  TSguSweepRegs; // $38-$3B linear upward, multiplicative downward

    resTimerLo: byte;     // $3C phase-reset period in samples (with TIMER_SYNC)
    resTimerHi: byte;     // $3D
    lfoWave:    byte;     // $3E [1:0] AM shape [3:2] PM shape
  end;

  // Service bank — valid when sguSelector = SGU_BANK_SERVICE.
  // Independent of channel state; the sample port auto-increments the offset
  // (wraps $FFFF -> $0000) on every sampleData write/read.
  TSguServiceRegs = record
    // $00-$1B: UNDEFINED in the service bank (padding, do not touch).
    // Channel mode: op1..op3 + op4.R0-R3 -> see sgu.
    reserved0:      array[0..$1B] of byte;
    sampleOffsetLo: byte; // $1C
    sampleOffsetHi: byte; // $1D
    sampleBank:     byte; // $1E only bank 0 is backed by memory today
    sampleData:     byte; // $1F data port (write/read bumps the offset)
    masterVolume:   byte; // $20 reset = 0 (chip starts MUTED); after the limiter
    // $21-$2F: UNDEFINED in the service bank (padding, do not touch).
    // Channel mode: freqHi..pcmResetHi -> see sgu.
    reserved1:      array[0..$0E] of byte;
    mixLeftLo:      byte; // $30 read-only: live I2S L
    mixLeftHi:      byte; // $31
    mixRightLo:     byte; // $32 read-only: live I2S R
    mixRightHi:     byte; // $33
    sampleClockLo:  byte; // $34 read-only: 48 kHz sample counter (lo word)
    sampleClockHi:  byte; // $35
    lfoAmPhase:     byte; // $36 read-only: global AM phase
    lfoPmPhase:     byte; // $37 read-only: global PM phase
  end;

var
  [volatile] sgu:        TSguChannelRegs absolute SGU_BASE_ADDR;
  [volatile] sguService: TSguServiceRegs absolute SGU_BASE_ADDR;
  [volatile] sguSelector: byte absolute SGU_SEL_ADDR;

// Bring-up step 1: wipe every channel's registers (like a hardware reset).
// Leaves the selector on the last channel; master volume untouched,
// so the chip stays muted until the caller raises it.
procedure SGU_Reset;

implementation

// Bring-up step 1: wipe every channel's registers (like a hardware reset).
// Does not touch the selector byte itself or master volume — the chip stays muted.
procedure SGU_Reset;
var
  channelIndex: byte;
begin
  for channelIndex := 0 to SGU_CHANNEL_COUNT - 1 do
  begin
    sguSelector := channelIndex;
    FillChar(sgu, SizeOf(sgu), 0);
  end;
end;

end.
