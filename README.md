# platform-lab

Mini Internal Developer Platform — home lab project showcasing platform engineering and DevEx skills.

## Quickstart

Prerequisites: docker, kind, kubectl. See [docs/setup.md](docs/setup.md) for full install instructions.

```bash
# One-time: add hostname to /etc/hosts so DNS rebinding protection
# doesn't strip the loopback answer for localtest.me
echo "127.0.0.1 argocd.localtest.me" | sudo tee -a /etc/hosts

# Bootstrap the cluster (idempotent)
./scripts/bootstrap.sh
```

Then open https://argocd.localtest.me and accept the TLS warning.

## What's inside

- **platform-api/** — FastAPI service that self-serves Kubernetes environments
- **platctl/** — Go CLI wrapping the platform API
- **infra/** — cluster bootstrap, Argo CD, Crossplane, observability stack
- **apps/** — GitOps-managed workloads (watched by Argo CD)
- **docs/** — architecture, ADRs, runbooks

## Architecture

_TODO: diagram_

## Phase status

- [x] Phase 1: Cluster + GitOps foundation _(in progress — Argo CD installed, app-of-apps pending)_
- [ ] Phase 2: Observability stack
- [ ] Phase 3: Platform API + dev/prod overlays
- [ ] Phase 4: Go CLI
- [ ] Phase 5: Crossplane + prod promotion
- [ ] Phase 6: Migrate to Pi/k3s
