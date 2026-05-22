# platform-lab

Mini Internal Developer Platform — a home lab project showcasing platform engineering and DevEx skills.

End-to-end GitOps with Argo CD, scripted from-zero bootstrap, observability stack, a self-service platform API, a CLI, declarative infrastructure with Crossplane, and a planned migration from local kind to k3s on a Raspberry Pi.

## Quickstart

Prerequisites: docker, kind, kubectl. See [docs/setup.md](docs/setup.md) for the full install list, host kernel settings, and the linters used for local development.

```bash
# One-time: allow localtest.me through systemd-resolved's DNS-rebinding filter
echo "127.0.0.1 argocd.localtest.me"  | sudo tee -a /etc/hosts
echo "127.0.0.1 grafana.localtest.me" | sudo tee -a /etc/hosts

# Bootstrap everything: cluster + ingress + Argo CD + root Application
make bootstrap
```

After a few minutes Argo CD will sync the example `hello` workload and the
observability stack. Verify:

```bash
kubectl get applications -n argocd     # all apps Synced/Healthy
kubectl get pods -n hello              # workload running
make argocd-ui                         # prints URL and admin password
```

Then open <https://argocd.localtest.me> and accept the self-signed TLS warning.

Grafana is at <https://grafana.localtest.me> (admin/admin) once the monitoring
stack syncs — metrics via Prometheus, logs via Loki, in one place.

For day-to-day operations see [docs/runbooks/daily-flow.md](docs/runbooks/daily-flow.md).

## What's inside

- **platform-api/** — FastAPI service that self-serves Kubernetes environments *(phase 3)*
- **platctl/** — Go CLI wrapping the platform API *(phase 4)*
- **infra/** — cluster bootstrap, Argo CD install, Crossplane, observability stack
- **apps/** — GitOps-managed workloads (watched by Argo CD)
- **docs/** — architecture, ADRs, runbooks
- **scripts/bootstrap.sh** — idempotent one-command bootstrap

## Architecture

_TODO: diagram_

For now, see [docs/architecture.md](docs/architecture.md) for the component list and [the ADRs](docs/adr/) for the reasoning behind each major decision.

## Phase status

- [x] Phase 1: Cluster + GitOps foundation
- [x] Phase 1.5: Developer ergonomics — Makefile, linters, pre-commit, CI
- [x] Phase 2: Observability stack
- [ ] Phase 3: Platform API + dev/prod overlays
- [ ] Phase 4: Go CLI
- [ ] Phase 5: Crossplane + prod promotion
- [ ] Phase 6: Migrate to Pi/k3s

## Design decisions

Key choices are documented as Architecture Decision Records:

- [ADR-0001 — Record architecture decisions](docs/adr/0001-record-architecture-decisions.md)
- [ADR-0002 — Loopback-only ingress for local kind](docs/adr/0002-loopback-only-ingress.md)
- [ADR-0003 — Treat the local cluster as disposable](docs/adr/0003-disposable-clusters.md)
- [ADR-0004 — GitOps via Argo CD's app-of-apps pattern](docs/adr/0004-gitops-with-app-of-apps.md)
- [ADR-0005 — Observability stack: Prometheus + Loki + Promtail](docs/adr/0005-observability-stack.md)
