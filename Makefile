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
	@envsubst < lib/$(NAME).service > /tmp/$(NAME).service
	@echo /tmp/$(NAME).service
	@envsubst < lib/$(NAME).timer > /tmp/$(NAME).timer
	@echo /tmp/$(NAME).timer

service: service-build
	@echo ">> installing $(NAME) user service"
	install -m 0644 -t $(SYSTEMD_DIR)/ /tmp/$(NAME).service /tmp/$(NAME).timer
	@echo
	@echo ">> to enable lowbatt automatically:"
	@echo -e "	\033[1;37msudo systemctl enable --now lowbatt.timer"
	@echo

docs:
	@echo ">> installing docs"
	@mkdir -p $(DOC_DIR)
	install -m 0644 -t $(DOC_DIR)/ README.md LICENSE
	@echo ">> installing manpages"
	@mkdir -p $(MAN_DIR)/man1
	install -m 0644 -t $(MAN_DIR)/man1/ man/$(NAME).1
