# Description: Makefile for setting up the project

export VAULT_ADDR=http://localhost:8300
export VAULT_TOKEN=$(shell grep -o 'VAULT_TOKEN=\K.*' act.secrets)
export GITHUB_ORG=$(shell grep -o 'GITHUB_ORG=\K.*' act.secrets)
KIND_CLUSTER_NAME=konnect-platform-ops-demo
RUNNER_IMAGE ?= pantsel/gh-runner:latest

prepare: check-deps actrc docker prep-act-secrets vault-pki ## Prepare the project

actrc: ## Setup .actrc
	@echo "Setting up .actrc"
	@./scripts/prep-actrc.sh

prep-act-secrets: ## Prepare secrets
	@echo "Preparing secrets.."
	@./scripts/prep-act-secrets.sh

docker: ## Spin up docker containers
	@echo "Spinning up containers"
	@docker-compose up -d

vault-pki: ## Setup vault pki
	@echo "Setting up vault pki."
	@./scripts/check-vault.sh
	@docker exec vault chmod +x /vault-pki-setup.sh
	@docker exec -it vault /vault-pki-setup.sh $(VAULT_ADDR) $(VAULT_TOKEN) $(GITHUB_ORG)
	
check-deps: ## Check dependencies
	@echo "Checking dependencies.."
	@./scripts/check-deps.sh

stop: ## Stop all containers
	@echo "Stopping containers.."
	@docker-compose down

clean: stop ## Clean everything up
	@echo "Cleaning up.."
	@rm -rf .tls
	@rm -rf act.secrets
	@rm -rf .tmp

help: ## Show this help
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\n"} \
	/^[a-zA-Z_-]+:.*##/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: prepare actrc prep-act-secrets docker vault-secrets vault-pki clean stop check-deps