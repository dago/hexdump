Name: hex
Version: 1.3
Release: 1
Summary: yet another hex dumper
Source: http://www.tuxedo.org/~esr/hex-1.3.tar.gz
Copyright: BSD-like
Group: Development/Tools

%%description 
Hex dumper that does CP/M format and EBCDIC; has internationalization.

%prep
%setup

%build
make

%install
make install

%files
/usr/share/man/man1/hex.1
/usr/bin/hex
