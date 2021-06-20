uses crt, smp, joystick;

{$r sample.rc}


const
	gun = $a45b;	// $b000 - 2981 = $a45b -> align to end of page

var
	sampl: TSMP;

begin
 writeln('IRQ Sample (press FIRE)');

 sampl.adr:=pointer(gun);
 sampl.len := 12;	// 2981 / 256 = 12 pages


 while true do begin

  sampl.play;

  while trig0 = 0 do;	// press FIRE
  while trig0 <> 0 do;

 end;

end.
