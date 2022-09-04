Var F : File;
    I : cardinal;

begin

  Assign (F,'D:TEST.TMP');

  { Create the file. Recordsize is 4 }
  Rewrite (F,Sizeof(I));

  For I:=1 to 10 do
    BlockWrite (F,I,1);

  close (f);
  { F contains now a binary representation of
    10 cardinals going from 1 to 10 }

end.

