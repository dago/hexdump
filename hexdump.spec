Name: hex
Version: 1.1
Release: 1
Summary: yet another hex dumper
Source: locke.ccil.org:/pub/esr/hex-1.1.tar.gz
Copyright: BSD-like
Group: Development/Tools

%%description 
Hex dumper that does CP/M format and EBCDIC; has internationalization.

%prep
%setup

%build
make

%install
rm -f /usr/bin/hex
cp hex /usr/bin
cp hex.1 /usr/man/man1/hex.1

%files
/usr/man/man1/hex.1
/usr/bin/hex
