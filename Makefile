PREFIX ?= /usr/local

install:
	install -d $(PREFIX)/bin
	install -m 755 spy $(PREFIX)/bin/spy

uninstall:
	rm -f $(PREFIX)/bin/spy
