# Setup

Tools to install on Ubuntu 22.04+ (or equivalent) before running the bootstrap.

## Required

- [Docker](https://docs.docker.com/engine/install/ubuntu/) — kind runs nodes as containers
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) — local Kubernetes
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) — Kubernetes CLI
- [Helm](https://helm.sh/docs/intro/install/) — used by Argo CD-managed charts in later phases
- [Argo CD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) — optional but useful for debugging

## Linting (for local development)

- [shellcheck](https://github.com/koalaman/shellcheck) — `sudo apt install shellcheck`
- [yamllint](https://yamllint.readthedocs.io/) — `sudo apt install yamllint`
- [kubeconform](https://github.com/yannh/kubeconform) — binary release
- [pre-commit](https://pre-commit.com/) — `sudo apt install pre-commit`

After cloning the repo:

```bash
pre-commit install
```

This wires the linters to run automatically on every `git commit`.

## DNS workaround

Ubuntu's `systemd-resolved` filters DNS responses pointing to loopback
(a defense against DNS rebinding attacks). The `localtest.me` domain
resolves to `127.0.0.1` and is blocked by default.

Workaround — add the hostnames you'll use to `/etc/hosts`:

```bash
echo "127.0.0.1 argocd.localtest.me" | sudo tee -a /etc/hosts
```

Add more lines as services are deployed (Grafana, platform-api, etc.).

## Verify

```bash
docker --version
kind --version
kubectl version --client
helm version
shellcheck --version
yamllint --version
kubeconform -v
pre-commit --version
```

If all return versions, you're ready to run `./scripts/bootstrap.sh`.
