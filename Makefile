# Makefile for Eric Raymond's silly hex dumper

hex: hex.c

hex.tar: READ.ME hex.c hex.1
	tar -cvf hex.tar READ.ME Makefile hex.c hex.1 hex.lsm
hex.tar.gz: hex.tar
	gzip hex.tar

hex.shar: READ.ME hex.c hex.1
	shar READ.ME hex.c hex.1 hex.lsm >hex.shar

clean:
	rm -f hex hex.tar hex.shar
