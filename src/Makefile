# See https://stackoverflow.com/questions/714100/os-detecting-makefile

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

BINBASEDIR = ../bin
ifeq ($(OS),Windows_NT)
	BINDIR = $(BINBASEDIR)/windows_x86_64
	BIN = $(BINDIR)/mp.exe
else
		UNAME_S := $(shell uname -s)
		UNAME_P := $(shell uname -p)
		ifeq ($(UNAME_S),Linux)
				# TODO
		# BINDIR = $(BINBASEDIR)/linux_$(UNAME_P)
		BIN = $(BINDIR)/mp
		endif
		ifeq ($(UNAME_S),Darwin)A
		ifneq ($(filter arm%,$(UNAME_P)),)
					BINDIR = $(BINBASEDIR)/macosx_aarch64
			endif
			 ifeq ($(UNAME_P),x86_64)
					BINDIR = $(BINBASEDIR)/macosx_x86_64
		 endif
			 BIN = $(BINDIR)/mp
		endif
endif

$(BIN): $(SRC)
	echo "Compiling on $(OS)"
	mkdir -p $(BINDIR)
	fpc -Mdelphi -v -O3 $< -o$(BIN)

clean:
	rm -fv  *.o *.ppu $(BIN) $(BINDIR)/*.o $(BINDIR)/*.ppu

.PHONY: clean

