all: wire

wire:
	crystal build --release src/wire.cr -o bin/wire
wiredbg:
	crystal build --verbose --stats --debug --release src/wire.cr -o bin/wire

dev:
	crystal build src/wire.cr -o bin/wire
devdbg:
	crystal build --verbose --stats --debug src/wire.cr -o bin/wire

PREFIX ?= /usr/local

install: wire
	install -d $(PREFIX)/bin
	install bin/wire $(PREFIX)/bin

