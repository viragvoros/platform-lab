# 3. Treat the local cluster as disposable

Date: 2026-05-15

## Status
Accepted

## Context
The local kind cluster is a development environment, not a system of record.
Anything important must survive cluster destruction; anything that doesn't
survive isn't important enough to preserve.

## Decision
The cluster is destroyed and recreated frequently — typically between work
sessions. `scripts/bootstrap.sh` (invoked via `make bootstrap`) reproduces
the entire stack from git in a few minutes.

## Consequences
- The bootstrap script is exercised continuously, catching rot early.
- Drift between "what the script claims to install" and "what's actually
  running" is impossible — the script is the source of truth.
- Anything not committed to git is lost on `make destroy`. This is a feature:
  it forces all configuration through GitOps.
- Long-running experiments (e.g. Crossplane reconciliation observations,
  certificate renewals) need explicit pause windows where the cluster is
  preserved.
- Mirrors production patterns where clusters are increasingly disposable
  (Cluster API, managed Kubernetes services).
