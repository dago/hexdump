# Makefile for Eric Raymond's silly hex dumper

# Note: When the version changes, you also have to change the RPM spec file
VERS=1.3

hex: hex.c
	$(CC) -DVERSION=\"$(VERS)\" -O hex.c -o hex

SOURCES = READ.ME Makefile hex.c hex.xml hex.lsm hex.spec

hex-$(VERS).tar.gz: $(SRC) hex.1 
	@ls $(SRC) hex.1 | sed s:^:hex-$(VERS)/: >MANIFEST
	@(cd ..; ln -s hex hex-$(VERS))
	(cd ..; tar -czvf hex/hex-$(VERS).tar.gz `cat hex/MANIFEST`)
	@(cd ..; rm hex-$(VERS))

hex.1: hex.xml
	xmlto man hex.xml

install: hex.1 uninstall
	cp hex /usr/bin
	cp hex.1 /usr/share/man/man1/hex.1

uninstall:
	rm -f /usr/bin/hex /usr/share/man/man1/hex.
	rm -f hex.1 manpage.links manpage.refs

clean:
	rm -f hex hex-$(VERS).tar.gz *.rpm

dist: hex-$(VERS).tar.gz

RPMROOT=/usr/src/redhat
RPM = rpm
RPMFLAGS = -ba
rpm: dist
	cp hex-$(VERS).tar.gz $(RPMROOT)/SOURCES;
	cp hex.spec $(RPMROOT)/SPECS
	cd $(RPMROOT)/SPECS; $(RPM) $(RPMFLAGS) hex.spec	
	cp $(RPMROOT)/RPMS/`arch|sed 's/i[4-9]86/i386/'`/hex-$(VERS)*.rpm .
	cp $(RPMROOT)/SRPMS/hex-$(VERS)*.src.rpm .
