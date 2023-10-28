export PREFIX := /usr

.PHONY: all
all: install

.PHONY: install
install:
	$(info INFO: install PREFIX: $(PREFIX))
	mkdir -p $(DESTDIR)$(PREFIX)/share/instantdotfiles
	git rev-parse --short HEAD > $(DESTDIR)$(PREFIX)/share/instantdotfiles/versionhash
	chmod +x *.sh
	chmod +x fonts/*.sh
	install -m644 -D LICENSE $(DESTDIR)$(PREFIX)/share/licenses/instantdotfiles/LICENSE
	cp -r ./* $(DESTDIR)$(PREFIX)/share/instantdotfiles/
	rm $(DESTDIR)$(PREFIX)/share/instantdotfiles/LICENSE
	rm $(DESTDIR)$(PREFIX)/share/instantdotfiles/README.md
	rm $(DESTDIR)$(PREFIX)/share/instantdotfiles/Makefile

.PHONY: uninstall
uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/share/instantdotfiles
	rm $(DESTDIR)$(PREFIX)/share/licenses/instantdotfiles/LICENSE


