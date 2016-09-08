all: wire

wire:
	crystal build src/wire.cr -o bin/wire

PREFIX ?= /usr/local

install: wire
	install -d $(PREFIX)/bin
	install bin/wire $(PREFIX)/bin

