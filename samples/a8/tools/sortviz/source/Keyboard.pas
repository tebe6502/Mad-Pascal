unit Keyboard;

interface

const
  KEY_ESC = 28;
  KEY_TAB = 44;
  KEY_RETURN = 12;
  KEY_SPACE = 33;
  KEY_MINUS = 14;
  KEY_PLUS = 6;

  KEY_0 = 50;
  KEY_1 = 31;
  KEY_2 = 30;
  KEY_3 = 26;
  KEY_4 = 24;
  KEY_5 = 29;
  KEY_6 = 27;
  KEY_9 = 48;

  KEY_A = 63;
  KEY_B = 21;
  KEY_C = 18;
  KEY_D = 58;
  KEY_E = 42;
  KEY_G = 61;
  KEY_H = 57;
  KEY_I = 13;
  KEY_L = 0;
  KEY_M = 37;
  KEY_N = 35;
  KEY_O = 8;
  KEY_P = 10;
  KEY_Q = 47;
  KEY_R = 40;
  KEY_S = 62;
  KEY_T = 45;
  KEY_U = 11;
  KEY_V = 16;
  KEY_Y = 43;
  KEY_Z = 23;

function GetKey: Byte;

implementation

uses Core;

const
  NO_KEY = 255;

function GetKey: Byte;
begin
  repeat
    Result := CH;
  until Result <> NO_KEY;
  
  CH := NO_KEY;
end;

end.