Name: hex
Version: 1.4
Release: 1
Summary: yet another hex dumper
URL: http://www.catb.org/~esr/hex/
Source0: %{name}-%{version}.tar.gz
License: BSD-like
Group: Development/Tools

%%description 
Yes, it's yet another hex dumper.  This one produces a nice CP/M-like
format by default and can do EBCDIC.  It's internationalized, too.
Has many nifty formatting functions.

%prep
%setup

%build
make

%install
make install

%files
/usr/share/man/man1/hex.1
/usr/bin/hex
