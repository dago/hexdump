# Makefile for Eric Raymond's silly hex dumper

hex: hex.c

hex.tar: READ.ME hex.c hex.1
	tar -cvf hex.tar READ.ME Makefile hex.c hex.1

clean:
	rm -f hex hex.tar
