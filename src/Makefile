
SRC = mp.pas \
  Common.pas \
  Diagnostic.pas \
  FileIO.pas \
  MathEvaluate.pas \
  Messages.pas \
  Numbers.pas \
  Optimize.pas \
  Parser.pas \
  Scanner.pas \
  StringUtilities.pas \
  TestUnits.pas \
  Utilities.pas \
  include/*.inc \
  include/opt6502/*.inc \
  include/opt65c02/*.inc \
  targets/*.inc

BINDIR = ../bin
ifeq ($(OS),Windows_NT)
  BIN = $(BINDIR)/mp.exe
else
  BIN = $(BINDIR)/mp
endif

$(BIN): $(SRC)
	fpc -Mdelphi -v -O3 $< -o$(BIN)

clean:
	rm -fv  *.o *.ppu $(BIN) $(BINDIR)/*.o $(BINDIR)/*.ppu

.PHONY: clean
