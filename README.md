# platform-lab

Mini Internal Developer Platform — home lab project showcasing platform engineering and DevEx skills.

## What's inside
- **platform-api/** — FastAPI service that self-serves Kubernetes environments
- **platctl/** — Go CLI wrapping the platform API
- **infra/** — cluster bootstrap, Argo CD, Crossplane, observability stack
- **apps/** — GitOps-managed workloads (watched by Argo CD)
- **docs/** — architecture, ADRs, runbooks

## Architecture
_TODO: diagram (Excalidraw or Mermaid)_

## Demo
_TODO: gif or asciinema_

## Run locally
\`\`\`bash
./scripts/bootstrap.sh
\`\`\`
