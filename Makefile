#
# Copyright 2025-2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# Makefile: Validation and lifecycle commands for the Paperless-ngx stack.
#

#
# Makefile target names.
#
ALL=all
BUILD_DEPENDS=build-depends
CHECK_ENV=check-env
CHECK_COMPOSE_ENV=check-compose-env
CONFIG=config
CONFIG_EXAMPLE=config-example
VALIDATE=validate
PULL=pull
UP=up
DOWN=down
RESTART=restart
PS=ps
LOGS=logs
HELP=help

TARGETS= \
	$(ALL) \
	$(BUILD_DEPENDS) \
	$(CHECK_ENV) \
	$(CHECK_COMPOSE_ENV) \
	$(CONFIG) \
	$(CONFIG_EXAMPLE) \
	$(VALIDATE) \
	$(PULL) \
	$(UP) \
	$(DOWN) \
	$(RESTART) \
	$(PS) \
	$(LOGS) \
	$(HELP)

#
# Repository-owned validation commands.
#
CHECK_ENV_COMMAND         ?= test/check-env.sh
CHECK_COMPOSE_ENV_COMMAND ?= test/check-compose-env.sh

#
# Docker Compose files and lifecycle options.
#
COMPOSE_FILE          ?= docker-compose.yml
COMPOSE_ENV_FILE      ?= $(ENV_FILE)
COMPOSE_DOWN_TIMEOUT  ?= 30
COMPOSE_DOWN_OPTIONS  ?= --timeout $(COMPOSE_DOWN_TIMEOUT) --remove-orphans
COMPOSE_UP_OPTIONS    ?= --detach --remove-orphans
COMPOSE_LOGS_OPTIONS  ?= --follow

#
# Docker Compose command compatible with 'docker compose' (v2) and
# 'docker-compose' (v1).
#
DOCKER_COMPOSE := $(shell \
	if docker compose version >/dev/null 2>&1; then \
		echo "docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		echo "docker-compose"; \
	else \
		echo ""; \
	fi)

#
# Docker Compose commands for the active and checked-in example environments.
#
COMPOSE = $(DOCKER_COMPOSE) --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE)
EXAMPLE_COMPOSE = PAPERLESS_SECRET_KEY=ci-only-paperless-secret-key-that-is-not-used \
	REDIS_PASSWORD=ci-only-redis-password \
	PAPERLESS_REDIS=redis://:ci-only-redis-password@redis:6379 \
	POSTGRES_PASSWORD=ci-only-postgres-password \
	PAPERLESS_ADMIN_PASSWORD=ci-only-admin-password \
	$(DOCKER_COMPOSE) --env-file $(EXAMPLE_ENV_FILE) -f $(COMPOSE_FILE)

#
# Help line formatting function.
#
define help_line
	@printf "  %-24s %s\n" "$(1)" "$(2)"
endef

#
# Build dependencies.
#
DEPENDENCIES=docker

#
# Environment file paths.
#
ENV_FILE=.env
EXAMPLE_ENV_FILE=example.env

#
# Targets that are not files (i.e. never up-to-date); these will run every
# time the target is called or required.
#
.PHONY: $(TARGETS)

#
# $(ALL): Default Makefile target. Validate and start the complete stack.
#
# Dependencies:
#   $(UP) - Validate, create, and start every service in the stack.
#
$(ALL): $(UP)

#
# $(BUILD_DEPENDS): Ensure Docker and Docker Compose are available.
#
$(BUILD_DEPENDS):
	$(foreach exe,$(DEPENDENCIES), \
		$(if $(shell which $(exe) 2> /dev/null),,$(error "No $(exe) in PATH")))
	@$(DOCKER_COMPOSE) version >/dev/null 2>&1 || { \
		echo "Docker Compose is not available."; \
		echo "Install docker compose or docker-compose, then retry."; \
		exit 1; \
	}

#
# $(CHECK_ENV): Reject missing, unsafe, or incompatible deployment settings.
#
$(CHECK_ENV):
	@$(CHECK_ENV_COMMAND) "$(ENV_FILE)"

#
# $(CHECK_COMPOSE_ENV): Keep Compose interpolation and example.env synchronized.
#
$(CHECK_COMPOSE_ENV):
	@$(CHECK_COMPOSE_ENV_COMMAND) "$(COMPOSE_FILE)" "$(EXAMPLE_ENV_FILE)"

#
# $(CONFIG): Validate the active Docker Compose configuration.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are available.
#   $(CHECK_ENV) - Reject unsafe or incompatible active settings.
#   $(CHECK_COMPOSE_ENV) - Keep Compose and example environment keys synchronized.
#
$(CONFIG): $(BUILD_DEPENDS) $(CHECK_ENV) $(CHECK_COMPOSE_ENV)
	@$(COMPOSE) config --quiet

#
# $(CONFIG_EXAMPLE): Validate the checked-in example Compose configuration.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are available.
#   $(CHECK_COMPOSE_ENV) - Keep Compose and example environment keys synchronized.
#
$(CONFIG_EXAMPLE): $(BUILD_DEPENDS) $(CHECK_COMPOSE_ENV)
	@$(EXAMPLE_COMPOSE) config --quiet

#
# $(VALIDATE): Run every repository-owned configuration validation.
#
# Dependencies:
#   $(CONFIG_EXAMPLE) - Validate the complete checked-in example deployment.
#
$(VALIDATE): $(CONFIG_EXAMPLE)
	@echo "The example filing cabinet is structurally sound. 🗃️"

#
# $(PULL): Pull every configured service image without starting the stack.
#
# Dependencies:
#   $(CONFIG) - Validate active deployment settings before pulling images.
#
$(PULL): $(CONFIG)
	@echo "Pulling reviewed service images. 📦"
	@$(COMPOSE) pull

#
# $(UP): Validate, create, and start every service in the stack.
#
# Dependencies:
#   $(CONFIG) - Validate active deployment settings before starting services.
#
$(UP): $(CONFIG)
	@echo "Opening the Paperless-ngx filing cabinet. 🗃️"
	@$(COMPOSE) up $(COMPOSE_UP_OPTIONS)

#
# $(DOWN): Stop the stack without deleting persistent application data.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are available.
#
$(DOWN): $(BUILD_DEPENDS)
	@echo "Closing the filing cabinet without shredding its contents. 🔒"
	@$(COMPOSE) down $(COMPOSE_DOWN_OPTIONS)

#
# $(RESTART): Recreate the complete stack with the active configuration.
#
# Dependencies:
#   $(CONFIG) - Validate active deployment settings before recreation.
#
$(RESTART): $(CONFIG)
	@echo "Re-indexing the cabinet doors without touching stored documents. 🔄"
	@$(COMPOSE) down $(COMPOSE_DOWN_OPTIONS)
	@$(COMPOSE) up $(COMPOSE_UP_OPTIONS)

#
# $(PS): Display the current status of every Compose service.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are available.
#
$(PS): $(BUILD_DEPENDS)
	@$(COMPOSE) ps

#
# $(LOGS): Follow output from every service in the stack.
#
# Dependencies:
#   $(BUILD_DEPENDS) - Ensure Docker and Docker Compose are available.
#
$(LOGS): $(BUILD_DEPENDS)
	@echo "Following the paper trail. 🔎"
	@$(COMPOSE) logs $(COMPOSE_LOGS_OPTIONS)

#
# $(HELP): Display the supported repository commands.
#
$(HELP):
	@echo "Usage: make [TARGET]"
	@echo ""
	@echo "Paperless-ngx filing cabinet targets:"
	$(call help_line,$(ALL),Validates and starts the complete stack.)
	$(call help_line,$(BUILD_DEPENDS),Ensures Docker and Docker Compose are available.)
	$(call help_line,$(CHECK_ENV),Rejects missing or unsafe active settings.)
	$(call help_line,$(CHECK_COMPOSE_ENV),Checks Compose and example.env key parity.)
	$(call help_line,$(CONFIG),Validates the active Compose configuration.)
	$(call help_line,$(CONFIG_EXAMPLE),Validates the checked-in example configuration.)
	$(call help_line,$(VALIDATE),Runs repository-owned configuration checks.)
	$(call help_line,$(PULL),Pulls configured service images.)
	$(call help_line,$(UP),Starts or updates the complete stack.)
	$(call help_line,$(DOWN),Stops the stack without deleting persistent data.)
	$(call help_line,$(RESTART),Recreates the complete stack.)
	$(call help_line,$(PS),Displays current service status.)
	$(call help_line,$(LOGS),Follows service logs.)
	$(call help_line,$(HELP),Displays this help message.)
