#
# Copyright 2025-2026 Scott Gigawatt
#
# Licensed under the Apache License, Version 2.0.
#
# Makefile: Validation and lifecycle commands for the Paperless-ngx stack.
#

ENV_FILE ?= .env
EXAMPLE_ENV_FILE ?= example.env
COMPOSE_FILE ?= docker-compose.yml
COMPOSE_DOWN_TIMEOUT ?= 30

DOCKER_COMPOSE := $(shell \
	if docker compose version >/dev/null 2>&1; then \
		echo "docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		echo "docker-compose"; \
	else \
		echo ""; \
	fi)

COMPOSE = $(DOCKER_COMPOSE) --env-file $(ENV_FILE) -f $(COMPOSE_FILE)
EXAMPLE_COMPOSE = PAPERLESS_SECRET_KEY=ci-only-paperless-secret-key-that-is-not-used \
	REDIS_PASSWORD=ci-only-redis-password \
	PAPERLESS_REDIS=redis://:ci-only-redis-password@redis:6379 \
	POSTGRES_PASSWORD=ci-only-postgres-password \
	PAPERLESS_ADMIN_PASSWORD=ci-only-admin-password \
	$(DOCKER_COMPOSE) --env-file $(EXAMPLE_ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: all help build-depends check-env check-compose-env config \
	config-example validate pull up down restart ps logs

all: up

help:
	@printf "Paperless-ngx filing cabinet commands:\n"
	@printf "  %-20s %s\n" "make check-env" "Reject missing or placeholder secrets in .env"
	@printf "  %-20s %s\n" "make config" "Validate the active Compose configuration"
	@printf "  %-20s %s\n" "make config-example" "Validate the checked-in example configuration"
	@printf "  %-20s %s\n" "make validate" "Run repository-owned configuration checks"
	@printf "  %-20s %s\n" "make pull" "Pull configured service images"
	@printf "  %-20s %s\n" "make up" "Start or update the stack"
	@printf "  %-20s %s\n" "make down" "Stop the stack without deleting persistent data"
	@printf "  %-20s %s\n" "make restart" "Recreate the stack"
	@printf "  %-20s %s\n" "make ps" "Show service status"
	@printf "  %-20s %s\n" "make logs" "Follow stack logs"

build-depends:
	@if [ -z "$(DOCKER_COMPOSE)" ]; then \
		echo "Docker Compose is required. Install Docker Compose v2 or docker-compose v1."; \
		exit 1; \
	fi

check-env:
	@test/check-env.sh "$(ENV_FILE)"

check-compose-env:
	@test/check-compose-env.sh "$(COMPOSE_FILE)" "$(EXAMPLE_ENV_FILE)"

config: build-depends check-env check-compose-env
	@$(COMPOSE) config --quiet

config-example: build-depends check-compose-env
	@$(EXAMPLE_COMPOSE) config --quiet

validate: config-example

pull: config
	@$(COMPOSE) pull

up: config
	@$(COMPOSE) up --detach --remove-orphans

down: build-depends
	@$(COMPOSE) down --timeout $(COMPOSE_DOWN_TIMEOUT) --remove-orphans

restart: down up

ps: build-depends
	@$(COMPOSE) ps

logs: build-depends
	@$(COMPOSE) logs --follow
