Program RDCTest;

Uses
  rdc;

Var
  fin, fout : File;

BEGIN

{$IFDEF ATARI}
  Assign(fin, 'D:KORONIS.MIC');
{$ELSE}
  Assign(fin, 'KORONIS.MIC');
{$ENDIF}
  
  Reset(fin, 1);

{$IFDEF ATARI}
  Assign(fout, 'D:KORONIS.RDC');
{$ELSE}
  Assign(fout, 'KORONIS.RDC');
{$ENDIF}

  Rewrite(fout, 1);

  Comp_FileToFile(fin, fout);

  Close(fin);
  Close(fout);


{$IFDEF ATARI}
  Assign(fin, 'D:KORONIS.RDC');
{$ELSE}
  Assign(fin, 'KORONIS.RDC');
{$ENDIF}

  Reset(fin, 1);

{$IFDEF ATARI}
  Assign(fout, 'D:KORONIS.DAT');
{$ELSE}
  Assign(fout, 'KORONIS.DAT');
{$ENDIF}

  Rewrite(fout, 1);

  Decomp_FileToFile(fin, fout);

  Close(fin);
  Close(fout);
END.

// 4467
