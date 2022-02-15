export NAME = lowbatt
export PREFIX ?= /usr
export DOC_DIR ?= $(PREFIX)/share/doc/$(NAME)
export MAN_DIR ?= $(PREFIX)/share/man
export BIN_DIR ?= $(PREFIX)/bin
export SYSTEMD_DIR ?= $(PREFIX)/lib/systemd/system

default: service-build
install: docs binary service

clean:
	@rm -rf $(DOC_DIR)
	@rm -f $(MAN_DIR)/man1/$(NAME).1
	@rm -f $(SYSTEMD_DIR)/$(NAME).timer
	@rm -f $(SYSTEMD_DIR)/$(NAME).service
	@rm -f $(BIN_DIR)/$(NAME)

binary:
	@echo ">> installing $(NAME) binary"
	install -m 0755 bin/$(NAME).sh $(BIN_DIR)/$(NAME)

service-build:
	@echo ">> generating service and timer"
	@envsubst < lib/template/$(NAME).service > lib/$(NAME).service
	@echo lib/$(NAME).service
	@envsubst < lib/template/$(NAME).timer > lib/$(NAME).timer
	@echo lib/$(NAME).timer

service: service-build
	@echo ">> installing $(NAME) user service"
	install -m 0644 -t $(SYSTEMD_DIR)/ lib/$(NAME).service lib/$(NAME).timer
	@echo
	@echo ">> to enable lowbatt automatically:"
	@echo -e "	\033[1;37msudo systemctl enable --now lowbatt.timer"
	@echo

docs-rebuild:
	@echo ">> rebuilding manpage from readme"
	@sphinx-build -E -b man . man

docs:
	@echo ">> installing docs"
	@mkdir -p $(DOC_DIR)
	install -m 0644 -t $(DOC_DIR)/ README.rst LICENSE
	@echo ">> installing manpages"
	@mkdir -p $(MAN_DIR)/man1
	install -m 0644 -t $(MAN_DIR)/man1/ man/$(NAME).1
