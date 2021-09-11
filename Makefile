PROG ?= grave
PREFIX ?= /usr
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib
SYSTEM_EXTENSION_DIR ?= $(LIBDIR)/password-store/extensions
BASHCOMPDIR ?= $(PREFIX)/share/bash-completion/completions

all:
	@echo "pass-$(PROG) is a shell script and does not need compilation, it can be simply executed."
	@echo ""
	@echo "To install it try \"make install\" instead."
	@echo
	@echo "To run pass $(PROG), you need to have password-store, tar, and gzip installed on your system"

install:
	@install -Dm0755 $(PROG).bash "$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash"
	@install -Dm0644 pass-$(PROG).bash.completion "$(DESTDIR)$(BASHCOMPDIR)/pass-$(PROG)"
	@echo
	@echo "pass-$(PROG) is installed successfully"
	@echo

uninstall:
	rm -vrf \
		"$(DESTDIR)$(SYSTEM_EXTENSION_DIR)/$(PROG).bash" \
		"$(DESTDIR)$(BASHCOMPDIR)/pass-$(PROG)"

lint:
	shellcheck -s bash $(PROG).bash
	$(MAKE) -C test lint

test:
	$(MAKE) -C test

.PHONY: install uninstall lint test
