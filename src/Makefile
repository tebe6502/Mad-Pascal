
SRC = mp.pas \
  Common.pas \
  Diagnostic.pas \
  Messages.pas \
  Optimize.pas \
  Parser.pas \
  Scanner.pas \
  SplitString.pas

mp: $(SRC)
	fpc -Mdelphi -v -O3 $<

clean:
	rm -fv mp *.o *.ppu

.PHONY: clean
