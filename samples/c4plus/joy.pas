const
  JOY_SELECT_1 = %00000010;
  JOY_SELECT_2 = %00000100;

var
  joy      : byte absolute $ff08;
  keyPio   : byte absolute $fd30;

var
  tmp      : byte;

begin
  repeat
    joy := JOY_SELECT_1; keyPio := $ff;
    tmp := joy xor $ff;
    case tmp of
      1  : writeln('UP    = ', tmp);
      2  : writeln('DOWN  = ', tmp);
      4  : writeln('LEFT  = ', tmp);
      8  : writeln('RIGHT = ', tmp);
      64 : writeln('FIRE  = ', tmp);
    end;
    pause(2);
  until false;
end.
