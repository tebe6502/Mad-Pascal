unit mypmg;
interface
uses _atari;
const
    PMG_vdelay_m0 = %00000001;
    PMG_vdelay_m1 = %00000010;
    PMG_vdelay_m2 = %00000100;
    PMG_vdelay_m3 = %00001000;
    PMG_vdelay_p0 = %00010000;
    PMG_vdelay_p1 = %00100000;
    PMG_vdelay_p2 = %01000000;
    PMG_vdelay_p3 = %10000000;

    PMG_gractl_missiles = %00000001;
    PMG_gractl_players = %00000010;
    PMG_gractl_latch = %00000100;
    PMG_gractl_default = PMG_gractl_missiles or PMG_gractl_players;

    PMG_sdmctl_DMA_missile = %00000100;
    PMG_sdmctl_DMA_player = %00001000;
    PMG_sdmctl_DMA_both = %00001100;
    PMG_sdmctl_oneline = %00010000;
    PMG_sdmctl_default = PMG_sdmctl_DMA_both;

    PMG_5player = %00010000;
    PMG_overlap = %00100000;

var
    PMG_oneline: boolean;
    PMG_base: pointer;
    PMG_size: word;

procedure PMG_init(base: byte); overload;
procedure PMG_init(base, sdmctl: byte); overload;
procedure PMG_init(base, sdmctl, gractl: byte); overload;
procedure PMG_clear;
procedure PMG_close;

implementation

procedure PMG_init(base, sdmctl, gractl: byte); overload;
var sdmctl_flags:byte;
begin
    _PMBASE := base;
    PMG_base := pointer(base*256);
    _GRACTL := gractl;
    sdmctl_flags := (_SDMCTL_ and %11100011) or sdmctl;
    _SDMCTL := sdmctl_flags;
    _SDMCTL_ := sdmctl_flags;
    if sdmctl and 16 <> 0 then begin
        PMG_oneline := true;
        PMG_size := $0800;
    end else begin
        PMG_oneline := false;
        PMG_size := $0400;
    end;
end;

procedure PMG_init(base, sdmctl: byte); overload;
var gractl: byte = PMG_gractl_default;
begin
    PMG_init(base, sdmctl, gractl);
end;

procedure PMG_init(base: byte); overload;
var sdmctl: byte = PMG_sdmctl_default;
begin
    PMG_init(base, sdmctl);
end;

procedure PMG_clear;
begin
    FillChar(PMG_base,PMG_size,0);
end;

procedure PMG_close;
begin
    _GRACTL := 0;
    _SDMCTL := 0;
end;

end.
