{ Test: The array SHIPS[x*8+1] is filled with the '1'..'4'.

        Expected result: 0,1,2,3,4
}

uses crt, sysutils;

type

  TShip = packed record
    mcode: Byte; // manufacture ship code
    sindex: Byte; // ship index
    swait: Byte; // ship wait time
    scu_max: Word;
    scu: Word;
    speed: Byte;
    lenght: Byte;
    mass: Word;
    qf_max: Word;
    qf : Word;  // quantum fuel
    cargoindex: array [0..7] of Word;
    cargoquantity: array [0..7] of Word;
  end;

var

 shipmatrix: array [0..4] of ^TShip;


 ships: array [0..39] of string = (
  'C-35 Osprey','0' ,'10','300','25','200','300','2',
  'Raider','1','46','240','35','240','450','4',
  'Commando','2','96','150','62','439','600','8',
  'Antares Max','3','122','220','38','336','720','4',
  'Dreamlifter','4','180','80','155','9500','900','20'
   );


  s0,s1,s2,s3,s4: TShip;

  b: byte;

begin

shipmatrix[0]:=@s0;
shipmatrix[1]:=@s1;
shipmatrix[2]:=@s2;
shipmatrix[3]:=@s3;
shipmatrix[4]:=@s4;


for b:=0 to 4 do shipmatrix[b].sindex := StrToInt(ships[b*8+1]);

for b:=0 to 4 do writeln(shipmatrix[b].sindex);


repeat until keypressed;

end.
