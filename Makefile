# Makefile for Eric Raymond's CP/M-like hex dumper

VERS=1.8

hexdump: hexdump.c
	$(CC) -DRELEASE=\"$(VERS)\" -O hexdump.c -o hexdump

SOURCES = README COPYING NEWS control Makefile hexdump.c hexdump.xml

hexdump-$(VERS).tar.gz: $(SOURCES) hexdump.1 
	@ls $(SOURCES) hexdump.1 | sed s:^:hexdump-$(VERS)/: >MANIFEST
	@(cd ..; ln -s hexdump hexdump-$(VERS))
	(cd ..; tar -czf hexdump/hexdump-$(VERS).tar.gz `cat hexdump/MANIFEST`)
	@(cd ..; rm hexdump-$(VERS))

hexdump.1: hexdump.xml
	xmlto man hexdump.xml

hexdump.html: hexdump.xml
	xmlto html-nochunks hexdump.xml

install: hexdump.1 uninstall
	cp hexdump /usr/bin
	cp hexdump.1 /usr/share/man/man1/hexdump.1

uninstall:
	rm -f /usr/bin/hexdump /usr/share/man/man1/hexdump.

clean:
	rm -f hexdump hexdump-$(VERS).tar.gz *.rpm *.1 *.html MANIFEST SHIPPER.*

cppcheck:
	cppcheck --template gcc --enable=all hexdump.c

dist: hexdump-$(VERS).tar.gz

release: hexdump-$(VERS).tar.gz hexdump.html
	shipper -u -m -t; make clean
