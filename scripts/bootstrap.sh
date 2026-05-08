#!/usr/bin/env bash
# Bootstrap a local mini-IDP from zero.
# Idempotent: safe to re-run; will skip steps already complete.
# Prerequisites: docker, kind, kubectl installed (see README).

set -euo pipefail

CLUSTER_NAME="idp"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$*" >&2; }

# ---------- 1. kind cluster ----------
if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  log "Cluster '${CLUSTER_NAME}' already exists — skipping creation"
else
  log "Creating kind cluster '${CLUSTER_NAME}'"
  kind create cluster --config "${REPO_ROOT}/infra/kind/kind-config.yaml"
fi

kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null

# ---------- 2. ingress-nginx ----------
log "Installing ingress-nginx"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Pin the controller to the control-plane node.
# The upstream kind manifest currently ships with a permissive nodeSelector
# (kubernetes.io/os: linux) that allows scheduling on workers — but kind's
# port mappings only forward to the control-plane, so the controller MUST
# land there for ingress to be reachable from the host.
log "Patching ingress-nginx nodeSelector to pin to control-plane"
kubectl patch deploy -n ingress-nginx ingress-nginx-controller \
  --type='strategic' \
  -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true","kubernetes.io/os":"linux"}}}}}'

log "Waiting for ingress-nginx controller"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

# ---------- 3. Argo CD ----------
log "Installing Argo CD"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

log "Waiting for Argo CD deployments"
kubectl wait --for=condition=available --timeout=300s \
  -n argocd deployment --all

log "Applying Argo CD ingress"
kubectl apply -f "${REPO_ROOT}/infra/argocd/ingress.yaml"

# ---------- 4. Root app (app-of-apps) ----------
# Will be added in step 4 of phase 1.
# kubectl apply -f "${REPO_ROOT}/infra/argocd/root-app.yaml"

# ---------- 5. /etc/hosts reminder ----------
if ! grep -q "argocd.localtest.me" /etc/hosts; then
  warn "Reminder: add this line to /etc/hosts (DNS rebinding protection blocks localtest.me):"
  warn "  127.0.0.1 argocd.localtest.me"
fi

# ---------- 6. Done ----------
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "(rotated or not yet generated)")

log "Bootstrap complete"
echo
echo "  Argo CD UI:  https://argocd.localtest.me"
echo "  Username:    admin"
echo "  Password:    ${ADMIN_PASSWORD}"
echo
echo "  Note: accept the self-signed cert warning in your browser."
