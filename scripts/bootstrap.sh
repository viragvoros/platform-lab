#!/usr/bin/env bash
# One-command bootstrap: create kind cluster, install Argo CD, sync root app.
set -euo pipefail

echo "==> Creating kind cluster"
kind create cluster --config infra/kind/kind-config.yaml

echo "==> Installing ingress-nginx"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "==> Installing Argo CD"
# TODO: kubectl apply -n argocd -f infra/argocd/install.yaml
# TODO: kubectl apply -f infra/argocd/root-app.yaml

echo "==> Done. Access Argo CD with: kubectl -n argocd port-forward svc/argocd-server 8080:443"
