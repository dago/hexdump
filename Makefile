# Makefile for Eric Raymond's silly hex dumper

# Note: When the version changes, you also have to change
#  * the name of the containing directory
#  * the RPM spec file
VERS=1.1

hex: hex.c

SOURCES = READ.ME Makefile hex.c hex.1 hex.lsm hex.spec

hex-$(VERS).tar: $(SOURCES)
	tar --name-prefix "hex-$(VERS)/" -cvf hex-$(VERS).tar $(SOURCES)
hex-$(VERS).tar.gz: hex-$(VERS).tar
	gzip -f hex-$(VERS).tar

hex.shar: $(SOURCES)
	shar $(SOURCES) >hex.shar

clean:
	rm -f hex hex.tar hex.shar

TOPDIR=/usr/src/rpm
rpm: hex.tar.gz
	cp hex.tar.gz $(TOPDIR)/SOURCES/hex-$(VERS).tar.gz
	cp hex.spec $(TOPDIR)/SPECS/hex-$(VERS)-1.spec
	rpm -ba hex-$(VERS)-1.spec
