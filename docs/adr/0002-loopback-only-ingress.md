# 2. Loopback-only ingress for local kind cluster

Date: 2026-05-08

## Status
Accepted

## Context
The kind cluster runs on a development laptop that frequently connects to
untrusted networks (coffee shops, conferences). Default kind port mappings
bind to 0.0.0.0, exposing cluster ingress to anyone on the same network
the moment the cluster comes up.

## Decision
Configure kind `extraPortMappings` with `listenAddress: "127.0.0.1"` for
ports 80 and 443. Cluster is reachable only from the laptop itself.

## Consequences
- LAN devices (phone, second laptop) cannot reach the cluster — would need
  to revert to 0.0.0.0 or set up an SSH tunnel for cross-device demos.
- When migrating to Pi/k3s on a fixed home LAN, this constraint will be
  revisited; the proper answer there is TLS + auth, not network isolation.
- Provides a defense-in-depth layer against accidental exposure even when
  TLS and auth are in place.
