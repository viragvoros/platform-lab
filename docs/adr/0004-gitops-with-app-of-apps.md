# 4. GitOps via Argo CD's app-of-apps pattern

Date: 2026-05-15

## Status
Accepted

## Context
The platform needs a way to deploy and manage Kubernetes workloads
declaratively, with git as the source of truth. Several patterns exist
for organizing this with Argo CD:

1. **Per-app `kubectl apply`** — apply one Application resource per service
   manually. Simple, but reintroduces the imperative step we're trying to
   eliminate.

2. **App-of-apps** — a single root Application points at a directory of
   child Application manifests. Adding a service means adding a file to
   that directory; Argo CD picks it up automatically.

3. **ApplicationSet** — a CRD that templates Applications from generators
   (git directories, lists, clusters, etc.). More powerful, more abstract,
   and adds a layer of indirection that's overkill for a small project.

## Decision
Use the **app-of-apps** pattern.

A root Application (`infra/argocd/root-app.yaml`) is applied imperatively
once during bootstrap. It points at `apps/_apps/`, a directory containing
one child Application per service. Each child Application points at its
own workload manifests under `apps/<service>/`.

```
infra/argocd/root-app.yaml      ← applied once via kubectl
        │
        ▼
apps/_apps/                     ← watched by root
├── hello.yaml                  ← Application: watches apps/hello/
└── (more as services are added)
        │
        ▼
apps/hello/                     ← watched by hello Application
├── namespace.yaml              ← actual workload resources
├── deployment.yaml
└── service.yaml
```

Sync policy on all Applications: `automated`, with `prune: true` and
`selfHeal: true`. Git is the absolute source of truth — manual cluster
changes get reverted.

## Consequences
- **Adding a service = two files in git.** A child Application in
  `apps/_apps/` and workload manifests under `apps/<service>/`.
  No more `kubectl apply`.
- **Removing a service = deleting those files.** Argo CD prunes the
  cluster resources automatically.
- **Drift between git and cluster is impossible** in the steady state —
  selfHeal reconciles deviation within the polling interval.
- **The bootstrap step is required once** to install the root Application.
  This is an unavoidable chicken-and-egg: Argo CD can't manage itself
  before it exists. After bootstrap, no imperative apply ever again.
- **Considered ApplicationSet but rejected for now.** It solves a problem
  we don't have yet (template-driven Applications across many similar
  services or clusters). If the platform grows to manage multi-cluster
  fleets or per-tenant generation, we'll revisit.

## Related
- ADR-0003 (disposable clusters) — bootstrap is fast precisely because
  app-of-apps reduces it to one apply.
