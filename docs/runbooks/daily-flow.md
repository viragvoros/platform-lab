# Daily Development Flow

The cluster is treated as disposable (see ADR-0003). This runbook covers
typical session starts, ends, and common operations.

## Start of session

```bash
git pull                       # ensure local matches remote
make bootstrap                 # ~2-3 minutes; idempotent
make argocd-ui                 # prints URL + admin password
```

Cluster is ready when:

```bash
kubectl get applications -n argocd
# All Applications show: Synced / Healthy
```

## End of session

```bash
git status                     # confirm everything pushed
git push                       # safety
make destroy                   # tear down
```

Anything not in git is lost on destroy — this is a feature.

## Pushing a change

```bash
# Edit files...
make lint                      # local pre-flight (pre-commit also runs)
git add -A
git commit -m "..."
git push
```

Argo CD picks up the change within ~3 minutes (poll interval) or
immediately if you `argocd app sync <name>` or click Sync in the UI.

## Common tasks

- **See cluster state:** `make status`
- **Argo CD admin password:** `make argocd-password`
- **Tail Argo CD logs:** `make argocd-logs`
- **Force-sync an app:** `argocd app sync <name>`
- **Reset everything:** `make reset` (destroy + bootstrap)

## Troubleshooting

**`make bootstrap` fails on ingress-nginx**: usually a stale cluster
left over. Run `kind delete cluster --name idp` and retry.

**Argo CD UI not reachable**: verify `/etc/hosts` has `127.0.0.1 argocd.localtest.me`
and that the ingress controller pod is on the control-plane node:
```bash
kubectl get pods -n ingress-nginx -o wide
```

**Application stuck OutOfSync**: check the Argo CD UI for the error.
Common causes: typo in manifest, missing CRD, repo URL wrong.
