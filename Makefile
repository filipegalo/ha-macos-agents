.DEFAULT_GOAL := help
SHELL := /bin/bash

# Agents to install: name:interval-in-seconds. Override, e.g. AGENTS=activity:60
AGENTS ?= activity:60 camera:5

PREFIX      := ha-macos-agents
REPO        := $(CURDIR)
CONFIG      := $(HOME)/.config/$(PREFIX)/config
LAUNCHD_DIR := $(HOME)/Library/LaunchAgents
LOG_DIR     := $(HOME)/Library/Logs/$(PREFIX)
DOMAIN      := gui/$(shell id -u)

help: ## List targets
	@grep -hE '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

build: build/camera-in-use ## Compile the native camera detector

build/camera-in-use: src/camera-in-use.swift
	@mkdir -p build
	swiftc -O $< -o $@

config: ## Create the config file from config.example if missing
	@mkdir -p $(dir $(CONFIG))
	@if [[ -e $(CONFIG) ]]; then echo "$(CONFIG) exists"; \
	else cp config.example $(CONFIG) && echo "created $(CONFIG): edit it"; fi

token: ## Store a Home Assistant access token in the login Keychain
	@source $(CONFIG); service=$${HA_KEYCHAIN_SERVICE:-$(PREFIX)}; \
	read -rsp "Paste long-lived access token: " t; echo; \
	t=$${t//[[:space:]]/}; [[ -n "$$t" ]] || { echo "empty token" >&2; exit 1; }; \
	security add-generic-password -U -a "$$USER" -s "$$service" -w "$$t" \
	&& echo "stored in Keychain service '$$service'"

# Only the camera agent needs the native helper, and with it swiftc.
install: $(if $(filter camera:%,$(AGENTS)),build) ## Install and start the launchd agents in AGENTS
	@[[ -r $(CONFIG) ]] || { echo "run 'make config' first" >&2; exit 1; }
	@mkdir -p $(LAUNCHD_DIR) $(LOG_DIR)
	@for spec in $(AGENTS); do \
	  name=$${spec%%:*}; label=$(PREFIX).$$name; plist=$(LAUNCHD_DIR)/$$label.plist; \
	  sed -e "s|@LABEL@|$$label|" -e "s|@PROGRAM@|$(REPO)/bin/ha-$$name|" \
	      -e "s|@INTERVAL@|$${spec##*:}|" -e "s|@LOG@|$(LOG_DIR)/$$name.log|" \
	      launchd/agent.plist.in > $$plist; \
	  launchctl bootout $(DOMAIN)/$$label 2>/dev/null || true; \
	  launchctl bootstrap $(DOMAIN) $$plist && echo "started $$label"; \
	done

uninstall: ## Stop and remove the launchd agents in AGENTS
	@for spec in $(AGENTS); do \
	  label=$(PREFIX).$${spec%%:*}; \
	  launchctl bootout $(DOMAIN)/$$label 2>/dev/null || true; \
	  rm -f $(LAUNCHD_DIR)/$$label.plist && echo "removed $$label"; \
	done

status: ## Show each agent's last exit code and recent log lines
	@for spec in $(AGENTS); do \
	  label=$(PREFIX).$${spec%%:*}; \
	  launchctl list | awk -v l=$$label '$$3 == l {print l ": last exit " $$2}' | grep . || echo "$$label: not loaded"; \
	  tail -n 3 $(LOG_DIR)/$${spec%%:*}.log 2>/dev/null | sed 's/^/  /'; \
	done

check: ## Lint the shell scripts
	bash -n lib/ha.sh bin/*
	@if command -v shellcheck >/dev/null; then shellcheck -x lib/ha.sh bin/*; \
	else echo "shellcheck not installed; syntax check only"; fi

clean: ## Remove build output
	rm -rf build

.PHONY: help build config token install uninstall status check clean
