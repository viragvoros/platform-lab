# Observability Troubleshooting

Issues encountered deploying kube-prometheus-stack + Loki + Promtail, and
their fixes.

## Grafana pod restarts / browser blips (OOMKilled)

Symptom: grafana pod restart count climbs; `grafana.localtest.me` briefly
unreachable. `kubectl get pod ... -o jsonpath` shows lastState exitCode 137.

Cause: memory limit too low for Grafana 13.

Fix: raise the limit in kube-prometheus-stack-values.yaml
(grafana.resources.limits.memory). 512Mi is comfortable.

## Loki CrashLoopBackOff: "mkdir /var/loki: read-only file system"

Cause: persistence disabled + read-only container rootfs leaves Loki with
nowhere to write.

Fix: mount an emptyDir at /var/loki via singleBinary.extraVolumes /
extraVolumeMounts in loki-values.yaml.

## Promtail: "too many open files"

Cause: host inotify limits too low for a per-node log watcher.

Fix: raise fs.inotify.max_user_instances and max_user_watches on the host
(see docs/setup.md), then `kubectl rollout restart daemonset/promtail -n monitoring`.

## "Readiness probe failed: connection refused" right after a pod starts

Usually NOT an error — the probe checks faster than the app boots. Confirm by
checking restart count (0 = just slow boot) vs climbing (= actual crash).
Large images (e.g. Grafana ~348MB) make first-boot slow; subsequent boots
use the cached image.

## Loki data source missing in Grafana

The datasource sidecar may not have reloaded. Try:
`kubectl rollout restart deploy/monitoring-grafana -n monitoring`

## No logs in Grafana Explore

- Confirm Promtail pods are Running (3, one per node) and logs are clean.
- Widen the time range in Explore (Last 1 hour).
- Check Promtail can reach Loki:
  `kubectl logs -n monitoring -l app.kubernetes.io/name=promtail --tail=20`
