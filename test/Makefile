
# Config example
#CONFIG = config_example.ini

# This one is made more suitable for Unix-like env.
CONFIG = config_example2.ini

VENV = .venv
PIP3 = $(VENV)/bin/pip3
PYTEST = $(VENV)/bin/pytest
PY65EMU = py65emu/build/lib/py65emu/py65emu.py
MPBIN = ../bin/mp
#MPBIN = mp


default:
	@echo "No default rule - do 'make test' to setup and run tests" \
	      "or 'make setup' to just setup the test environment."

test: setup
#	$(PYTEST) --log-file test_output.log   # no output...
#	$(PYTEST) | tee test_output.log        # log ok, but no failure status returned...
	$(PYTEST)                              # without the log file (only stdout/err output)

setup: $(PIP3) $(PYTEST) $(PY65EMU) config.ini mp

config.ini:
	cp -v $(CONFIG) config.ini

#mp: $(MPBIN) blibs dlibs lib wlibs
mp: blibs dlibs lib wlibs
	cp -v $(MPBIN) mp

blibs:
	ln -s ../blibs
dlibs:
	ln -s ../dlibs
lib:
	ln -s ../lib
wlibs:
	ln -s ../wlibs


$(PYTEST): 
	@echo "Installing pytest"
	$(PIP3) install pytest

$(PY65EMU): $(PIP3)
	@echo "Building py65emu"
	# $(PIP3) install setuptools
	cd py65emu/ ; ../$(VENV)/bin/python setup.py install

$(PIP3):
	@echo "Creating Python venv in $(VENV)"
	python3 -m venv $(VENV)

clean:
	@echo "Removing test environment"
	rm -rf config.ini $(VENV) py65emu/build .pytest_cache \
            test_temp \
            tests/__pycache__ \
            tests/testutils\__pycache__ \
            test_output.log \
            mp blibs dlibs lib wlibs

.PHONY: default test setup clean
