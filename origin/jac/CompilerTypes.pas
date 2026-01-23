unit CompilerTypes;

interface


const
  MAXSTRLENGTH = 255;

type
  TString = String [MAXSTRLENGTH];

  TAsmBlock = String;
  TAsmBlockArray = array [0..4095] of TAsmBlock;

implementation

end.
