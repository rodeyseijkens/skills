# Agent Skills

A collection of agent skills for planning, development, and tooling.

Forked from [mattpocock/skills](https://github.com/mattpocock/skills)

## Skills are organized into categories

Skills live under `skills/{engineering,productivity}/<name>/SKILL.md`.

## Engineering

Skills for code work — development, debugging, triage, and architecture.

- **[diagnose](skills/engineering/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[grill-with-docs](skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[improve-codebase-architecture](skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase, informed by the domain language in `CONTEXT.md` and the decisions in `docs/adr/`.
- **[project-agent-setup](skills/engineering/project-agent-setup/SKILL.md)** — Scaffold per-repo agent config (local-markdown issue tracker under `.scratch/`, triage labels, domain-doc layout). Run once per repo before using the other engineering skills.
- **[tdd](skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[to-issues](skills/engineering/to-issues/SKILL.md)** — Break a plan, spec, or PRD into independently-grabbable issues on the project issue tracker using tracer-bullet vertical slices.
- **[to-prd](skills/engineering/to-prd/SKILL.md)** — Turn the current conversation context into a PRD and publish it to the project issue tracker.
- **[triage](skills/engineering/triage/SKILL.md)** — Triage issues through a state machine driven by triage roles.
- **[zoom-out](skills/engineering/zoom-out/SKILL.md)** — Tell the agent to zoom out and give broader context or a higher-level perspective on an unfamiliar section of code.

## Productivity

General workflow tools, not code-specific.

- **[caveman](skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
- **[grill-me](skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[write-a-skill](skills/productivity/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.

## License

MIT License - See LICENSE file

Original work Copyright (c) Matt Pocock
Modifications Copyright (c) Rodey Seijkens
