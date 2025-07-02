unit pm_config;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: PokeyMAX config library.
* @version: 0.3.0

* @description:
* Set of useful constants, and structures to work with ATARI PokeyMAX. 
* Usefull to read and write configuration register of PokeyMAX.
*)

interface

uses pm_detect;


const 
    // Masks
    CONFIG_MODE_CHANNEL = $4;
    CONFIG_MODE_MIXING = $1;               // old name Saturate
    CONFIG_MODE_IRQ = $8;
    CONFIG_MODE_MONO = $10;
    CONFIG_MODE_PHI = $20;                 // old name PAL

    CONFIG_DIV_CH0 = $3;
    CONFIG_DIV_CH1 = $c;
    CONFIG_DIV_CH2 = $30;
    CONFIG_DIV_CH3 = $C0;

    CONFIG_GTIA_CH0 = $1;
    CONFIG_GTIA_CH1 = $2;
    CONFIG_GTIA_CH2 = $4;
    CONFIG_GTIA_CH3 = $8;

    CONFIG_OUT_CH0 = $1;
    CONFIG_OUT_CH1 = $2;
    CONFIG_OUT_CH2 = $4;
    CONFIG_OUT_CH3 = $8;
    CONFIG_OUT_CH4 = $10;

    CONFIG_RESTRICT_POKEY = $3;
    CONFIG_RESTRICT_SID = $4;
    CONFIG_RESTRICT_PSG = $8;
    CONFIG_RESTRICT_COVOX = $10; 

    CONFIG_PSGMODE_FREQ = $3;
    CONFIG_PSGMODE_STEREO = $c;
    CONFIG_PSGMODE_ENVELOPE = $10;
    CONFIG_PSGMODE_VOLUME = $60;
    
    CONFIG_SIDMODE_SID1TYPE = $1;
    CONFIG_SIDMODE_SID1DIGI = $2;
    CONFIG_SIDMODE_SID2TYPE = $10;
    CONFIG_SIDMODE_SID2DIGI = $20;

    

type
    // Window handle info
    TPMAX_CONFIG = record
        mode_pokey: Byte;       // 1 = Mono             2 = Stereo          3 = Quad
        mode_sid: Byte;         // 0 = Disabled         1 = Enabled                                                 SID
        mode_psg: Byte;         // 0 = Disabled         1 = Enabled                                                 PSG
        mode_covox: Byte;       // 0 = Disabled         1 = Enabled                                                 Covox
        mode_mono: Byte;        // 1 = Left only        2 = Both Channels                                           Mono
        mode_phi: Byte;         // 1 = NTSC             2 = PAL                                                    PHI2->1Mhz
        core_div1: Byte;        // 1 = 1                2 = 2               3 = 4                   4 = 8
        core_div2: Byte;        // 1 = 1                2 = 2               3 = 4                   4 = 8
        core_div3: Byte;        // 1 = 1                2 = 2               3 = 4                   4 = 8
        core_div4: Byte;        // 1 = 1                2 = 2               3 = 4                   4 = 8
        core_gtia1: Byte;       // 0 = Disabled         1 = Enabled                                                 GTIA Channel Mixing
        core_gtia2: Byte;       // 0 = Disabled         1 = Enabled         
        core_gtia3: Byte;       // 0 = Disabled         1 = Enabled         
        core_gtia4: Byte;       // 0 = Disabled         1 = Enabled         
        core_out1: Byte;        // 0 = Disabled         1 = Enabled                                                 High R
        core_out2: Byte;        // 0 = Disabled         1 = Enabled                                                 High L
        core_out3: Byte;        // 0 = Disabled         1 = Enabled                                                 Low R
        core_out4: Byte;        // 0 = Disabled         1 = Enabled                                                 Low L
        core_out5: Byte;        // 0 = Disabled         1 = Enabled                                                 SPDIF
        pokey_mixing: Byte;     // 1 = Non-linear       2 = Linear
        pokey_channel: Byte;    // 1 = Off              2 = On
        pokey_irq: Byte;        // 1 = One              2 = All
        psg_freq: Byte;         // 1 = 2MHz             2 = 1MHz            3 = PHI2
        psg_stereo: Byte;       // 1 = Mono             2 = Polish          3 = Czech               4 = L/R
        psg_envelope: Byte;     // 1 = 32               2 = 16
        psg_volume: Byte;       // 1 = AY Log           2 = YM2149 Log 1    3 = YM2149 Log 2        4 = Linear
        sid_1: Byte;            // 1 = 6581             2 = 8580            3 = 8580 Digi
        sid_2: Byte;            // 1 = 6581             2 = 8580            3 = 8580 Digi
        pagesize: Word;         // 1024                 512
        max_address: LongWord;  // $d600                $e600               $19800
    end;

var 
    pmax_config: TPMAX_CONFIG;


procedure PMAX_ReadConfig;
(*
* @description:
* Reads PokeyMAX config settings and saves data in pmax_config record.
*)

procedure PMAX_WriteConfig;
(*
* @description:
* Reads pmax_config record and updates PokeyMAX config settings.
*)

procedure PMAX_ReadFlashType;
(*
* @description:
* Reads PokeyMAX flash type and saves data in pmax_config record.
*)

implementation

procedure PMAX_ReadConfig;
begin
    case (config[CONFIG_MODE] and CONFIG_MODE_MIXING) of
        0: pmax_config.pokey_mixing:= 1;
        1: pmax_config.pokey_mixing:= 2;
    end;
    case (config[CONFIG_MODE] and CONFIG_MODE_CHANNEL) of
        0: pmax_config.pokey_channel:= 1;
        4: pmax_config.pokey_channel:= 2;
    end;
    case (config[CONFIG_MODE] and CONFIG_MODE_IRQ) of
        0: pmax_config.pokey_irq:= 1;
        8: pmax_config.pokey_irq:= 2;
    end;
    case (config[CONFIG_MODE] and CONFIG_MODE_MONO) of
        0: pmax_config.mode_mono:= 1;
        16: pmax_config.mode_mono:= 2;
    end;
    case (config[CONFIG_MODE] and CONFIG_MODE_PHI) of
        0: pmax_config.mode_phi:= 1;
        32: pmax_config.mode_phi:= 2;
    end;
    case (config[CONFIG_RESTRICT] and CONFIG_RESTRICT_POKEY) of
        0: pmax_config.mode_pokey:= 1;
        1: pmax_config.mode_pokey:= 2;
        2: pmax_config.mode_pokey:= 3;
    end;
    case (config[CONFIG_RESTRICT] and CONFIG_RESTRICT_SID) of
        0: pmax_config.mode_sid:= 0;
        4: pmax_config.mode_sid:= 1;
    end;
    case (config[CONFIG_RESTRICT] and CONFIG_RESTRICT_PSG) of
        0: pmax_config.mode_psg:= 0;
        8: pmax_config.mode_psg:= 1;
    end;
    case (config[CONFIG_RESTRICT] and CONFIG_RESTRICT_COVOX) of
        0: pmax_config.mode_covox:= 0;
        16: pmax_config.mode_covox:= 1;
    end;
    case (config[CONFIG_DIV] and CONFIG_DIV_CH0) of
        0: pmax_config.core_div1:= 1;
        1: pmax_config.core_div1:= 2;
        2: pmax_config.core_div1:= 3;
        3: pmax_config.core_div1:= 4;
    end;
    case (config[CONFIG_DIV] and CONFIG_DIV_CH1) of
        0: pmax_config.core_div2:= 1;
        4: pmax_config.core_div2:= 2;
        8: pmax_config.core_div2:= 3;
        12: pmax_config.core_div2:= 4;
    end;
    case (config[CONFIG_DIV] and CONFIG_DIV_CH2) of
        0: pmax_config.core_div3:= 1;
        16: pmax_config.core_div3:= 2;
        32: pmax_config.core_div3:= 3;
        48: pmax_config.core_div3:= 4;
    end;
    case (config[CONFIG_DIV] and CONFIG_DIV_CH3) of
        0: pmax_config.core_div4:= 1;
        64: pmax_config.core_div4:= 2;
        128: pmax_config.core_div4:= 3;
        192: pmax_config.core_div4:= 4;
    end;
    case (config[CONFIG_GTIA] and CONFIG_GTIA_CH0) of
        0: pmax_config.core_gtia1:= 0;
        1: pmax_config.core_gtia1:= 1;
    end;
    case (config[CONFIG_GTIA] and CONFIG_GTIA_CH1) of
        0: pmax_config.core_gtia2:= 0;
        2: pmax_config.core_gtia2:= 1;
    end;
    case (config[CONFIG_GTIA] and CONFIG_GTIA_CH2) of
        0: pmax_config.core_gtia3:= 0;
        4: pmax_config.core_gtia3:= 1;
    end;
    case (config[CONFIG_GTIA] and CONFIG_GTIA_CH3) of
        0: pmax_config.core_gtia4:= 0;
        8: pmax_config.core_gtia4:= 1;
    end;
    case (config[CONFIG_OUTPUT] and CONFIG_OUT_CH0) of
        0: pmax_config.core_out1:= 0;
        1: pmax_config.core_out1:= 1;
    end;
    case (config[CONFIG_OUTPUT] and CONFIG_OUT_CH1) of
        0: pmax_config.core_out2:= 0;
        2: pmax_config.core_out2:= 1;
    end;
    case (config[CONFIG_OUTPUT] and CONFIG_OUT_CH2) of
        0: pmax_config.core_out3:= 0;
        4: pmax_config.core_out3:= 1;
    end;
    case (config[CONFIG_OUTPUT] and CONFIG_OUT_CH3) of
        0: pmax_config.core_out4:= 0;
        8: pmax_config.core_out4:= 1;
    end;
    case (config[CONFIG_OUTPUT] and CONFIG_OUT_CH4) of
        0: pmax_config.core_out5:= 0;
        16: pmax_config.core_out5:= 1;
    end;
    case (config[CONFIG_PSGMODE] and CONFIG_PSGMODE_FREQ) of
        0: pmax_config.psg_freq:= 1;
        1: pmax_config.psg_freq:= 2;
        2: pmax_config.psg_freq:= 3;
    end;
    case (config[CONFIG_PSGMODE] and CONFIG_PSGMODE_STEREO) of
        0: pmax_config.psg_stereo:= 1;
        4: pmax_config.psg_stereo:= 2;
        8: pmax_config.psg_stereo:= 3;
        12: pmax_config.psg_stereo:= 4;
    end;
    case (config[CONFIG_PSGMODE] and CONFIG_PSGMODE_ENVELOPE) of
        0: pmax_config.psg_envelope:= 1;
        16: pmax_config.psg_envelope:= 2;
    end;
    case (config[CONFIG_PSGMODE] and CONFIG_PSGMODE_VOLUME) of
        0: pmax_config.psg_volume:= 1;
        32: pmax_config.psg_volume:= 2;
        64: pmax_config.psg_volume:= 3;
        96: pmax_config.psg_volume:= 4; 
    end;

    if (config[CONFIG_SIDMODE] and CONFIG_SIDMODE_SID1TYPE) = 1 then pmax_config.sid_1:= 1
    else if (config[CONFIG_SIDMODE] and CONFIG_SIDMODE_SID1DIGI) = 0 then pmax_config.sid_1:= 2
    else pmax_config.sid_1:= 3;
    
    if (config[CONFIG_SIDMODE] and CONFIG_SIDMODE_SID2TYPE) = 1 then pmax_config.sid_2:= 1
    else if (config[CONFIG_SIDMODE] and CONFIG_SIDMODE_SID1DIGI) = 0 then pmax_config.sid_2:= 2
    else pmax_config.sid_2:= 3;

end;

procedure PMAX_WriteConfig;
begin
    case pmax_config.pokey_mixing of
        1: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_MIXING) or 0;
        2: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_MIXING) or 1;
    end;
    case pmax_config.pokey_channel of
        1: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_CHANNEL) or 0;
        2: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_CHANNEL) or 4;
    end;
    case pmax_config.pokey_irq of
        1: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_IRQ) or 0;
        2: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_IRQ) or 8;
    end;
    case pmax_config.mode_mono of
        1: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_MONO) or 0;
        2: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_MONO) or 16;
    end;
    case pmax_config.mode_phi of
        1: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_PHI) or 0;
        2: config[CONFIG_MODE]:=(config[CONFIG_MODE] and not CONFIG_MODE_PHI) or 32;
    end;
    case pmax_config.mode_pokey of
        1: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_POKEY) or 0;
        2: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_POKEY) or 1;
        3: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_POKEY) or 2;
    end;
    case pmax_config.mode_sid of
        0: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_SID) or 0;
        1: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_SID) or 4;
    end;
    case pmax_config.mode_psg of
        0: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_PSG) or 0;
        1: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_PSG) or 8;
    end;
    case pmax_config.mode_covox of
        0: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_COVOX) or 0;
        1: config[CONFIG_RESTRICT]:=(config[CONFIG_RESTRICT] and not CONFIG_RESTRICT_COVOX) or 16;
    end;
    case pmax_config.core_div1 of
        1: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH0) or 0;
        2: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH0) or 1;
        3: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH0) or 2;
        4: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH0) or 3;
    end;
    case pmax_config.core_div2 of
        1: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH1) or 0;
        2: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH1) or 4;
        3: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH1) or 8;
        4: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH1) or 12;
    end;
    case pmax_config.core_div3 of
        1: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH2) or 0;
        2: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH2) or 16;
        3: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH2) or 32;
        4: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH2) or 48;
    end;
    case pmax_config.core_div4 of
        1: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH3) or 0;
        2: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH3) or 64;
        3: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH3) or 128;
        4: config[CONFIG_DIV]:=(config[CONFIG_DIV] and not CONFIG_DIV_CH3) or 192;
    end;
    case pmax_config.core_gtia1 of
        0: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH0) or 0;
        1: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH0) or 1;
    end;
    case pmax_config.core_gtia2 of
        0: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH1) or 0;
        1: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH1) or 2;
    end;
    case pmax_config.core_gtia3 of
        0: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH2) or 0;
        1: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH2) or 4;
    end;
    case pmax_config.core_gtia4 of
        0: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH3) or 0;
        1: config[CONFIG_GTIA]:=(config[CONFIG_GTIA] and not CONFIG_GTIA_CH3) or 8;
    end;
    case pmax_config.core_out1 of
        0: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH0) or 0;
        1: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH0) or 1;
    end;
    case pmax_config.core_out2 of
        0: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH1) or 0;
        1: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH1) or 2;
    end;
    case pmax_config.core_out3 of
        0: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH2) or 0;
        1: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH2) or 4;
    end;
    case pmax_config.core_out4 of
        0: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH3) or 0;
        1: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH3) or 8;
    end;
    case pmax_config.core_out5 of
        0: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH4) or 0;
        1: config[CONFIG_OUTPUT]:=(config[CONFIG_OUTPUT] and not CONFIG_OUT_CH4) or 16;
    end;
    case pmax_config.psg_freq of
        1: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_FREQ) or 0;
        2: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_FREQ) or 1;
        3: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_FREQ) or 2;
    end;
    case pmax_config.psg_stereo of
        1: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_STEREO) or 0;
        2: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_STEREO) or 4; 
        3: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_STEREO) or 8;
        4: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_STEREO) or 12;
    end;
    case pmax_config.psg_envelope of
        1: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_ENVELOPE) or 0;
        2: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_ENVELOPE) or 16;
    end;
    case pmax_config.psg_volume of
        1: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_VOLUME) or 32;
        2: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_VOLUME) or 0; 
        3: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_VOLUME) or 64;
        4: config[CONFIG_PSGMODE]:=(config[CONFIG_PSGMODE] and not CONFIG_PSGMODE_VOLUME) or 96;
    end;

    if pmax_config.sid_1 = 1 then
    begin
     config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID1TYPE) or 1;
     config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID1DIGI) or 0;
    end
    else if pmax_config.sid_1 = 2 then
    begin
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID1TYPE) or 0;
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID1DIGI) or 0;
    end
    else begin
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID1TYPE) or 0;
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID1DIGI) or 1;
    end;

    if pmax_config.sid_2 = 1 then
    begin
     config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID2TYPE) or 1;
     config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID2DIGI) or 0;
    end
    else if pmax_config.sid_2 = 2 then
    begin
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID2TYPE) or 0;
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID2DIGI) or 0;
    end
    else begin
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID2TYPE) or 0;
        config[CONFIG_SIDMODE]:=(config[CONFIG_SIDMODE] and not CONFIG_SIDMODE_SID2DIGI) or 1;
    end;
end;

procedure PMAX_ReadFlashType;
begin
    core_version := 5;
    case char(core_version) of
        '8':    begin   // flash M04
                    pmax_config.pagesize:= 512;
                    pmax_config.max_address:= $e600;
                end;
        '6':    begin   // flash M16
                    pmax_config.pagesize:= 1024;
                    pmax_config.max_address:= $19800;
                end;
        '4':    begin   // flash M04
                    pmax_config.pagesize:= 512;
                    pmax_config.max_address:= $d600;
                end;
        // else begin
        //         pmax_config.pagesize:= 512;
        //         pmax_config.max_address:= $e600;
        // end;
    end;
end;

end. 