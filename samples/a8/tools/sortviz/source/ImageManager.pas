unit ImageManager;

interface

type
  TImageKind = (
    ikNone,
    ikTriangle,
    ikImage
  );

procedure NextImage;

implementation

uses Core, DisplayList;

var
  imageKind: TImageKind;

procedure ClearImage;
begin
  color0Value := 0;
  color1Value := 0;
  color2Value := 0;
  FillChar(Pointer(IMAGE_ADDR), IMAGE_SIZE, 0);
end;

procedure PrepareSplashScreen;
const
  SIZE = LINE_STEP * (TABLE_SIZE - SPLASH_LINES);
  ADDR = IMAGE_ADDR + SPLASH_LINES * LINE_STEP;
begin
  FillChar(Pointer(ADDR), SIZE, 0);
end;

procedure CopyImage;
begin
  ChangeToMode($0E);

  Move(Pointer(IMAGE_1_ADDR), Pointer(IMAGE_ADDR), IMAGE_SIZE);
  
  if PALNTS = 15 then
  begin
    color0Value := $34;
    color1Value := $36;
    color2Value := $3A;
  end
  else begin
    color0Value := $14;
    color1Value := $16;
    color2Value := $1A;
  end;

  imageKind := ikImage;
end;

procedure ImagePrepareTriangle;
var
  i, j, k: Byte;
  addr: Word;
  val: Byte;
const
  VALUES: array[0..7] of Byte = (
    %10000000,
    %11000000,
    %11100000,
    %11110000,
    %11111000,
    %11111100,
    %11111110,
    %11111111);
begin
  ChangeToMode($0F);

  for i := 0 to MAX_INDEX do
  begin
    addr := ImageLineLoAddr[i] + 256 * ImageLineHiAddr[i];
    k := i div 8;
    if k > 0 then
    begin
      for j := 0 to k - 1 do
      begin
        Poke(addr + j, 255);
      end;
    end;
    Inc(addr, k);
    val := VALUES[i mod 8];
    Poke(addr, val);
  end;

  if PALNTS = 15 then
  begin
    color1Value := $9C;
    color2Value := $90;
  end
  else begin
    color1Value := $7C;
    color2Value := $70;
  end;

  imageKind := ikTriangle;
end;

procedure NextImage;
begin
  ClearImage;

  case imageKind of
    ikNone, ikImage: ImagePrepareTriangle;
    ikTriangle: CopyImage;
  end;
end;

initialization
begin
  color0Value := 0;
  color1Value := 0;
  color2Value := 0;
  PrepareSplashScreen;
  imageKind := ikNone;
end;

end.