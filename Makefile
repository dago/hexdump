# Makefile for Eric Raymond's silly hex dumper

VERS=1.5

hexdump: hexdump.c
	$(CC) -DRELEASE=\"$(VERS)\" -O hexdump.c -o hexdump

SOURCES = READ.ME COPYING Makefile hexdump.c hexdump.xml hexdump.spec

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
	rm -f hexdump hexdump-$(VERS).tar.gz *.rpm

dist: hexdump-$(VERS).tar.gz

RPMROOT=/usr/src/redhat
rpm: dist
	rpmbuild --define 'myversion $(VERS)' -ta hexdump-$(VERS).tar.gz
	cp $(RPMROOT)/RPMS/*/hexdump-$(VERS)*.rpm .
	cp $(RPMROOT)/SRPMS/hexdump-$(VERS)*.src.rpm .
