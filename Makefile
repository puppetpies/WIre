all: wire

wire:
	crystal build --release src/wire.cr -o bin/wire

PREFIX ?= /usr/local

install: wire
	install -d $(PREFIX)/bin
	install bin/wire $(PREFIX)/bin

