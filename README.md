# Agent Skills

Agent skills for planning, development, and tooling — small, composable, and model-agnostic.

Forked from [mattpocock/skills](https://github.com/mattpocock/skills).

## Quickstart

```sh
npx skills@latest add rodeyseijkens/skills
```

Pick the skills you want and the coding agents you want them installed on.

## Reference

Skills split on one axis: **who can invoke them**.

- **User-invoked** skills are reachable only when you type them (e.g. `/grill-me`); they orchestrate.
- **Model-invoked** skills can be invoked by you *or* reached for automatically by the agent when the task fits; they hold the reusable discipline.

A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Engineering

Skills for code work — development, debugging, triage, and architecture.

**User-invoked**

- **[skill-router](skills/engineering/skill-router/SKILL.md)** — Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[grill-with-docs](skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[triage](skills/engineering/triage/SKILL.md)** — Triage issues through a state machine driven by triage roles.
- **[improve-codebase-architecture](skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase, informed by the domain language in `CONTEXT.md` and the decisions in `docs/adr/`.
- **[project-agent-setup](skills/engineering/project-agent-setup/SKILL.md)** — Scaffold per-repo agent config (local-markdown issue tracker under `.scratch/`, triage labels, domain-doc layout). Run once per repo before using the other engineering skills.
- **[to-issues](skills/engineering/to-issues/SKILL.md)** — Break a plan, spec, or PRD into independently-grabbable issues on the project issue tracker using tracer-bullet vertical slices.
- **[to-prd](skills/engineering/to-prd/SKILL.md)** — Turn the current conversation context into a PRD and publish it to the project issue tracker.
- **[prototype](skills/engineering/prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design before committing to it — runnable terminal app for state/business-logic, or several radically different UI variations.
- **[implement](skills/engineering/implement/SKILL.md)** — Implement a piece of work based on a PRD or set of issues, using `/tdd` at pre-agreed seams.
- **[resolving-merge-conflicts](skills/engineering/resolving-merge-conflicts/SKILL.md)** — Resolve an in-progress git merge/rebase conflict by understanding both intents and running the project's automated checks.

**Model-invoked**

- **[diagnosing-bugs](skills/engineering/diagnosing-bugs/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[tdd](skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[domain-modeling](skills/engineering/domain-modeling/SKILL.md)** — Build and sharpen a project's domain model — challenge terms against the glossary, stress-test with edge-case scenarios, update `CONTEXT.md` and ADRs inline.
- **[codebase-design](skills/engineering/codebase-design/SKILL.md)** — Shared vocabulary for designing deep modules: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface.
- **[git-atomic-commit](skills/engineering/git-atomic-commit/SKILL.md)** — Analyze unpushed git changes, propose granular Conventional Commits, and execute atomic commits.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document for another agent to pick up.
- **[teach](skills/productivity/teach/SKILL.md)** — Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[writing-great-skills](skills/productivity/writing-great-skills/SKILL.md)** — Reference for writing and editing skills well — the vocabulary and principles that make a skill predictable.

**Model-invoked**

- **[grilling](skills/productivity/grilling/SKILL.md)** — Interview the user relentlessly about a plan or design. The reusable loop behind `grill-me` and `grill-with-docs`.

## Layout

Skills live under `skills/{engineering,productivity}/<name>/SKILL.md`.

## License

MIT — see [LICENSE](LICENSE).

Original work Copyright (c) Matt Pocock.
Modifications Copyright (c) Rodey Seijkens.
