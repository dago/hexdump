# Makefile for Eric Raymond's silly hex dumper

VERS=$(shell sed <hexdump.spec -n -e '/Version: \(.*\)/s//\1/p')

hexdump: hexdump.c
	$(CC) -DRELEASE=\"$(VERS)\" -O hexdump.c -o hexdump

SOURCES = README COPYING Makefile hexdump.c hexdump.xml hexdump.spec

hexdump-$(VERS).tar.gz: $(SOURCES) hexdump.1 
	@ls $(SOURCES) hexdump.1 | sed s:^:hexdump-$(VERS)/: >MANIFEST
	@(cd ..; ln -s hexdump hexdump-$(VERS))
	(cd ..; tar -czvf hexdump/hexdump-$(VERS).tar.gz `cat hexdump/MANIFEST`)
	@(cd ..; rm hexdump-$(VERS))

hexdump.1: hexdump.xml
	xmlto man hexdump.xml

install: hexdump.1 uninstall
	cp hexdump /usr/bin
	cp hexdump.1 /usr/share/man/man1/hexdump.1

uninstall:
	rm -f /usr/bin/hexdump /usr/share/man/man1/hexdump.

clean:
	rm -f hexdump hexdump-$(VERS).tar.gz *.rpm *.html MANIFEST SHIPPER.*

dist: hexdump-$(VERS).tar.gz

release: hexdump-$(VERS).tar.gz hexdump.html
	shipper -u -m -t; make clean
