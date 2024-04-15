
SRC = mp.pas \
  Common.pas \
  Diagnostic.pas \
  Messages.pas \
  Optimize.pas \
  Parser.pas \
  Scanner.pas \
  SplitString.pas

BINDIR = ../bin
BIN = $(BINDIR)/mp

$(BIN): $(SRC)
	fpc -Mdelphi -v -O3 $< -o$(BIN)

clean:
	rm -fv $(BIN) $(BINDIR)/*.o $(BINDIR)/*.ppu

.PHONY: clean
