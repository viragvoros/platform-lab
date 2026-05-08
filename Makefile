# Mini IDP — common operations
# Run `make help` to see all targets.

.DEFAULT_GOAL := help
SHELL := /bin/bash

CLUSTER_NAME := idp

# ---------- Help ----------

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ---------- Cluster lifecycle ----------

.PHONY: bootstrap
bootstrap: ## Create cluster + install ingress + Argo CD (idempotent)
	./scripts/bootstrap.sh

.PHONY: destroy
destroy: ## Delete the kind cluster
	kind delete cluster --name $(CLUSTER_NAME)

.PHONY: reset
reset: destroy bootstrap ## Destroy and recreate from scratch

.PHONY: status
status: ## Show cluster + Argo CD status
	@echo "=== Nodes ==="
	@kubectl get nodes
	@echo
	@echo "=== Argo CD pods ==="
	@kubectl get pods -n argocd
	@echo
	@echo "=== Ingress ==="
	@kubectl get ingress -A

# ---------- Argo CD ----------

.PHONY: argocd-password
argocd-password: ## Print the initial admin password
	@kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" 2>/dev/null | base64 -d ; echo

.PHONY: argocd-ui
argocd-ui: ## Print the URL and admin credentials
	@echo "URL:      https://argocd.localtest.me"
	@echo "Username: admin"
	@printf "Password: " && $(MAKE) -s argocd-password

.PHONY: argocd-logs
argocd-logs: ## Tail argocd-server logs
	kubectl logs -n argocd deploy/argocd-server -f --tail=100

# ---------- Linting ----------

.PHONY: lint
lint: lint-shell lint-yaml lint-k8s ## Run all linters

.PHONY: lint-shell
lint-shell: ## Lint shell scripts with shellcheck
	@find scripts -name '*.sh' -print0 | xargs -0 shellcheck

.PHONY: lint-yaml
lint-yaml: ## Lint YAML files with yamllint
	@yamllint .

.PHONY: lint-k8s
lint-k8s: ## Validate Kubernetes manifests with kubeconform
	@find apps infra -name '*.yaml' -not -path '*/kind/*' -print0 \
		| xargs -0 kubeconform -strict -summary -ignore-missing-schemas

# ---------- Convenience ----------

.PHONY: ctx
ctx: ## Switch kubectl context to the kind cluster
	kubectl config use-context kind-$(CLUSTER_NAME)
