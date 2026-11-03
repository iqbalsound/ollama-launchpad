.PHONY: help install docker ollama models webui webui-bridge firewall health compose-up compose-down lint
help:        ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n",$$1,$$2}'
install:     ## Interactive installer menu
	./install.sh
docker:      ## Install Docker
	./scripts/01-install-docker.sh
ollama:      ## Install Ollama
	./scripts/02-install-ollama.sh
models:      ## Pull the starter models
	./scripts/03-pull-models.sh
webui:       ## Start Open WebUI (host mode, :8080)
	./scripts/04-run-open-webui.sh host
webui-bridge: ## Start Open WebUI (bridge mode, :3000)
	./scripts/04-run-open-webui.sh bridge
firewall:    ## Open firewall port 8080
	./scripts/05-firewall.sh 8080
health:      ## Run health check
	./scripts/healthcheck.sh
compose-up:  ## docker compose up -d
	docker compose up -d
compose-down: ## docker compose down
	docker compose down
lint:        ## ShellCheck all scripts
	shellcheck -S warning install.sh scripts/*.sh
