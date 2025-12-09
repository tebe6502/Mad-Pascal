unit OptimizerTest;


interface


procedure Test;


implementation

uses SysUtils, CommonIO, CompilerTypes, FileIO, Common, Optimizer;

procedure Test;
var
  SourceFile: TSourceFile;
  SourceLocation: TSourceLocation;
  OutFile: ITextFile;
  LineArray: TStringArray;
  AsmBlockArray: TAsmBlockArray;
  Writer: IWriter; // TStringArrayWriter;
  Optimizer: IOptimizer;

  OptimizeCode: Boolean;
  CodeSize: Integer;
  IsInterrupt: Boolean;
begin
  SourceFile := TSourceFile.Create;
  SourceFile.Name := 'UnitTest';
  SourceFile.Path := 'Example/UnitTest.pas';
  AsmBlockArray := Default(TAsmBlockArray);
  Optimizer := CreateDefaultOptimizer();
  OutFile := TFileSystem.CreateTextFile();
  OutFile.Assign('..\samples\tests\tests-debug\debug-unittest.a65');
  OutFile.Rewrite();

  Writer := TFileWriter.Create(OutFile); // TStringArrayWriter.Create;
  Optimizer.Initialize(Writer, AsmBlockArray, 0, Target);

  sourceLocation := Default(TSourceLocation);
  SourceLocation.SourceFile := SourceFile;
  sourceLocation.Line := 1;
  OptimizeCode := False;
  CodeSize := 1;
  IsInterrupt := False;
  Optimizer.StartOptimization(sourceLocation);
  Optimizer.AssembleLine(#9'inx', '', OptimizeCode, CodeSize, IsInterrupt);
(*
  Optimizer.AssembleLine(#9'mva P :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN+STACKWIDTH*3,x', '');
  Optimizer.AssembleLine(#9'sta :STACKORIGIN+STACKWIDTH*3,x', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN+STACKWIDTH*2,x', '');
  Optimizer.AssembleLine(#9'sta :STACKORIGIN+STACKWIDTH*2,x', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'sta :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN+STACKWIDTH,x', '');
  Optimizer.AssembleLine(#9'asl :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'rol @', '');
  Optimizer.AssembleLine(#9'sta :STACKORIGIN+STACKWIDTH,x', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'sta :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'add MONSTER', '');
  Optimizer.AssembleLine(#9'sta :TMP', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN+STACKWIDTH,x', '');
  Optimizer.AssembleLine(#9'adc MONSTER+1', '');
  Optimizer.AssembleLine(#9'sta :TMP+1', '');
  Optimizer.AssembleLine(#9'ldy #$00', '');
  Optimizer.AssembleLine(#9'lda (:TMP);,y', '');
  Optimizer.AssembleLine(#9'sta :bp2', '');
  Optimizer.AssembleLine(#9'iny', '');
  Optimizer.AssembleLine(#9'lda (:TMP);,y', '');
  Optimizer.AssembleLine(#9'sta :bp2+1', '');
  Optimizer.AssembleLine(#9'ldy #$00', '');
  Optimizer.AssembleLine(#9'lda (:bp2);,y', '');
  Optimizer.AssembleLine(#9'sta :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'inx', '');
  Optimizer.AssembleLine(#9'mva #$02 :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'jsr addAL_CL', '');
  Optimizer.AssembleLine(#9'dex', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN-1,x', '');
  Optimizer.AssembleLine(#9'add #$00', '');
  Optimizer.AssembleLine(#9'tay', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN-1+STACKWIDTH,x', '');
  Optimizer.AssembleLine(#9'adc #$00', '');
  Optimizer.AssembleLine(#9'sta :STACKORIGIN-1+STACKWIDTH,x', '');
  Optimizer.AssembleLine(#9'lda adr.MONSTER,y', '');
  Optimizer.AssembleLine(#9'sta :bp2', '');
  Optimizer.AssembleLine(#9'lda adr.MONSTER+1,y', '');
  Optimizer.AssembleLine(#9'sta :bp2+1', '');
  Optimizer.AssembleLine(#9'ldy #$00', '');
  Optimizer.AssembleLine(#9'lda :STACKORIGIN,x', '');
  Optimizer.AssembleLine(#9'sta (:bp2);,y', '');
  Optimizer.AssembleLine(#9'dex', '');
  Optimizer.AssembleLine(#9'dex', '');
  Optimizer.AssembleLine('', '');
  *)
  Optimizer.AssembleLine('', '', False, CodeSize, IsInterrupt);
  Optimizer.Finalize;

  OutFile.Close;

  //lineArray := Writer.GetLines;

end;

end.
