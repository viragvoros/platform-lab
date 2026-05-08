# 1. Record architecture decisions

Date: 2026-05-08

## Status
Accepted

## Context
Building a platform involves many decisions whose rationale is easily lost
once the implementation exists. Future contributors (and future-me) need to
understand *why* a tool, pattern, or trade-off was chosen — not just what
the current state is. Code answers "what"; ADRs answer "why".

## Decision
Use Architecture Decision Records as described by Michael Nygard
(https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

ADRs live in `docs/adr/`, numbered sequentially, and follow this template:

- **Title** — short noun phrase
- **Status** — Proposed, Accepted, Deprecated, Superseded by NNNN
- **Context** — the forces at play, what problem we are solving
- **Decision** — the choice we made, in active voice
- **Consequences** — what becomes easier and harder as a result

Each ADR is immutable once Accepted. If the decision changes, add a new ADR
and mark the old one Superseded.

## Consequences
- Every meaningful platform choice (tool selection, pattern, trade-off) is
  documented at the moment it is made, while the reasoning is fresh.
- New contributors can read the ADR log to understand the platform's
  evolution without archaeology in commit messages.
- Writing ADRs takes a few minutes per decision — small ongoing cost.
- The ADR log itself becomes a portfolio artifact: it shows engineering
  judgement, not just engineering output.
