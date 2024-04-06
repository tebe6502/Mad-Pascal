
all:
	cd src ; make

test-setup:
	cd test ; make setup

test:
	cd test ; make test

clean:
	cd src ; make clean
	cd test ; make clean

.PHONY: all test test-setup clean
