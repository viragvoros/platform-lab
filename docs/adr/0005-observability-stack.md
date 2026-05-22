# 5. Observability stack: kube-prometheus-stack + Loki + Promtail

Date: 2026-05-21

## Status
Accepted

## Context
The platform needs metrics and logs, viewable in one place, deployed the
same GitOps way as everything else. Several decisions were required:
which metrics stack, which logging stack, whether to split per environment,
and how to size resources for a laptop that will later become a Pi.

## Decision

**Metrics: kube-prometheus-stack.** A single Helm chart bundling Prometheus,
Grafana, Alertmanager, node-exporter, and kube-state-metrics, with
preconfigured dashboards and scrape rules. Chosen over assembling the
components individually because the wiring (Grafana-to-Prometheus,
dashboards, scrape configs) is done for us and it is the de-facto standard.

**Logs: Loki (SingleBinary) + Promtail.** Loki is "Prometheus for logs" —
label-based, lightweight, native Grafana integration, far lighter than
Elasticsearch/ELK (which matters for the Pi). SingleBinary mode collapses
Loki's production multi-component architecture into one pod. Promtail ships
logs as a DaemonSet.

**Promtail over Grafana Alloy.** Alloy is Grafana's strategic direction and
Promtail is in maintenance mode, but Promtail's config is trivial and
sufficient for this lab. Alloy's River-syntax config adds learning overhead
without benefit here. If the project grows, migrating to Alloy is the path.

**Shared, not per-environment.** A single observability stack serves all
environments. Running duplicate Prometheus + Grafana + Loki per environment
is wasteful on a Pi and adds no learning value. Real production with SLAs
per environment would split these; documented as an explicit scope choice.

**Tight, iteratively-tuned resource limits.** All components got conservative
requests/limits from the start to keep the stack Pi-friendly. These were
treated as initial guesses to be corrected by observation — and were:
Grafana 13 OOMKilled at 256Mi and was raised to 512Mi after watching the
restarts. This is the intended workflow: set conservative limits, deploy,
measure, adjust.

**Everything via Argo CD.** No `helm install`. Each component is an Argo CD
Application (multi-source: upstream chart + values from this repo). The
stack reproduces identically on `make destroy && make bootstrap`.

## Consequences
- Metrics and logs are both visible in one Grafana, queryable via PromQL
  and LogQL respectively.
- The stack is the heaviest part of the platform; it is the component most
  likely to need tuning on the Pi.
- Storage is ephemeral (emptyDir, no PersistentVolumes) — metrics and logs
  reset on pod restart. Acceptable for a disposable lab; a real deployment
  would use persistent storage and an object store for Loki.
- Two host-level prerequisites surfaced (see docs/setup.md): an /etc/hosts
  entry for grafana.localtest.me, and raised inotify limits for Promtail.

## Related
- ADR-0003 (disposable clusters) — ephemeral storage is a deliberate
  consequence of treating the cluster as disposable.
- ADR-0004 (app-of-apps) — each observability component is just another
  child Application.
