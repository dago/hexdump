# Makefile for Eric Raymond's silly hex dumper

# Note: When the version changes, you also have to change
#  * the name of the containing directory
#  * the RPM spec file
V=1.0

hex: hex.c

SOURCES = READ.ME Makefile hex.c hex.1 hex.lsm hex.spec

hex.tar: $(SOURCES)
	(cd ..; tar -cvf hex-$(V)/hex.tar `echo $(SOURCES) | sed "/\(^\| \)/s// hex-$(V)\//g"`)
hex.tar.gz: hex.tar
	gzip -f hex.tar

hex.shar: $(SOURCES)
	shar $(SOURCES) >hex.shar

clean:
	rm -f hex hex.tar hex.shar

TOPDIR=/usr/src/rpm
rpm: hex.tar.gz
	cp hex.tar.gz $(TOPDIR)/SOURCES/hex-$(V).tar.gz
	cp hex.spec $(TOPDIR)/SPECS/hex-$(V)-1.spec
	rpm -ba hex-$(V)-1.spec
