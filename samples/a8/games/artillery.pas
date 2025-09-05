(*
* artillery
* fire a shell at an enemy outpost
*)

program artillery;// (input, output);

uses sysutils, crt;

const
numshells = 10; (* allowed 10 shells per target *)
mindist = 100; (* minimum distance for a target *)
maxdist = 1000; (* maximum distance for a target *)

velocity = 200.0; (* initial velocity of 200 ft/sec^2 *)
gravity = 32.2; (* gravity of 32.2 ft/sec^2 *)
pi = 3.14159;

var
angle : real; (* angle to shoot at *)
enemy : integer; (* how far away the enemy is *)
killed : integer; (* how many we have hit *)
shots : 0..numshells; (* number of shells left *)
ch : char; (* used to answer questions *)
hit : boolean; (* whether the enemy has been hit *)
sangle: TString;

lmargin: byte absolute $52;

(*
* dist
* returns how far the shell went
*)

function dist:integer;

(*
* timeinair
* figures out how long the shell
* stays in the air
*)

function timeinair:real;

begin
Result := (2*velocity * sin(angle))/gravity

end;

begin
Result := round((velocity * cos(angle))*timeinair)
end;

(*
* fire
* the user fires at enemy
*)

procedure fire;

begin
randomize;
enemy := mindist + random(maxdist-mindist);
writeln('The enemy is ',enemy:3,' feet away!!!');
shots := numshells;
repeat
write('What angle? ');
readln(sangle);

angle:=StrToFloat(sangle);

angle := (angle * pi)/180.0;
hit := abs(enemy-dist) <= 1;
if hit then
begin
killed := killed + 1;
writeln('You hit him!!!');
writeln('It took you ',numshells-shots,' shots.');
if killed = 1 then
writeln('You have killed one enemy.')
else
writeln('You have now destroyed ',killed,' enemies of democracy.')
end
else
begin
shots := shots - 1;
if dist > enemy then
write('You overshot by ')
else
write('You under shot by ');
writeln(abs(enemy-dist))
end
until (shots = 0) or hit;
if shots = 0 then
writeln('You have run out of ammo.')
end;

begin
lmargin:=0;
ClrScr;

writeln('Welcome to artillery');
writeln;
writeln('You are in the middle of a war (depressing, no?) and are being');
writeln('charged by thousands of enemies.');
writeln('Your job is to destroy their ouytposts. You have at your disposal');
writeln('a cannon, which you can shoot at any angle. As this is war,');
writeln('supplies are short, so you only have ',numshells,' per target.');
writeln;

killed := 0;
repeat
writeln('****************************************');
fire;
write('I see another one, care to shoot again? ');
readln(ch);
while not ( (ch ='y') or (ch='n') or (ch='Y') or (ch='N') ) do
begin
writeln('Please answer yes or no');
write('Want to try again? ');
readln(ch)
end
until (ch<>'y') and (ch<>'Y');
writeln;
writeln('You killed ',killed,' of the enemy.')
end.

