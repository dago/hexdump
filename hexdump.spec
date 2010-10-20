Name: hexdump
Version: 1.6
Release: 1
Summary: yet another hex dumper
URL: http://www.catb.org/~esr/hexdump/
Source0: %{name}-%{version}.tar.gz
License: BSD
Group: Development/Tools
BuildRoot: %{_tmppath}/%{name}-root

%%description 
Yes, it's yet another hex dumper.  This one produces a nice CP/M-like
format by default and can do EBCDIC.  It's internationalized, too.
Has many nifty formatting functions.

%prep
%setup -q

%build
make hexdump hexdump.1

%install
[ "$RPM_BUILD_ROOT" -a "$RPM_BUILD_ROOT" != / ] && rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT"/usr/bin
mkdir -p "$RPM_BUILD_ROOT"/usr/share/man/man1/
cp hexdump "$RPM_BUILD_ROOT"/usr/bin
cp hexdump.1 "$RPM_BUILD_ROOT"/usr/share/man/man1/

%clean
[ "$RPM_BUILD_ROOT" -a "$RPM_BUILD_ROOT" != / ] && rm -rf "$RPM_BUILD_ROOT"

%files
%doc README COPYING
%defattr(-,root,root,-)
%{_mandir}/man1/hexdump.1*
%{_bindir}/hexdump

%changelog
* Wed Oct 20 2010 Eric S. Raymond <esr@snark.thyrsus.com> 1.7-1
- License changed to BSD.

* Mon Dec 29 2003 Eric S. Raymond <esr@snark.thyrsus.com> 1.6-1
- Source RPMs no longer depend on --define myversion

