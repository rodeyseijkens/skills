# Example Control Loop: React Doctor

One fully worked loop, to make the taxonomy concrete. **This is an illustration, not a template.** A real loop from a production monorepo, it drives React code quality in a single app. Your loop's set point, sensor, controller, and actuator will look different — copy the *shape*, not the specifics.

It is a useful example because the sensor and controller come almost entirely from an existing, configurable tool, so the whole loop is small.

## Set point

`apps/riptide-ui` stays free of high-impact React issues (lint, accessibility, correctness, architecture). A direction more than a fixed threshold: each run leaves the app a little healthier.

## Sensor — `react-doctor` + `doctor.config.ts`

The [`react-doctor`](https://github.com/millionco/react-doctor) CLI scans the app and reports prioritized issues; `doctor.config.ts` configures which rules run and which paths/rules are ignored. It runs locally exactly as it does in CI:

```bash
bunx react-doctor --project '@codelayer/riptide-ui' --diff false --yes
```

Chosen because it is repeatable, configurable, and lives outside the editor/lint config so a stray inline comment can't quietly switch it off — a trade-off that mattered *for this team*, not a requirement of all sensors.

## Controller — fused with the sensor

There is no separate controller: `react-doctor` returns "the top 3 rules by impact," and the loop's policy is "fix up to 5 issues from those top 3 rules this run." That selection logic lives in the actuator's prompt. This is the **sensor + controller blur** — one tool plus a small policy does both jobs.

## Actuator — CodeLayer + a repo-local skill

A CodeLayer agent runs with the repo's `react-doctor` skill. Its per-issue loop gives the agent three honest options — **fix**, **ignore** (add to `doctor.config.ts` with a reason), or **skip** (leave for a human) — and validates each change before committing it separately:

```bash
bun run typecheck
bun run quality
bunx react-doctor --project '@codelayer/riptide-ui' --staged
```

## Disturbances + dampener

**Disturbance:** teammates ship React code continuously while the loop runs.

**Dampener:** a second workflow (`react-doctor.yml`) runs on pull requests and pushes to `main`. It diffs against the merge base and comments on only newly introduced issues. It is advisory by default; it does not fail teammate PRs. The team can later make it blocking if the signal proves reliable.

## The loop — `agent-react-doctor.yml`

A scheduled workflow (daily, plus manual dispatch and `/iterate`) runs the loop and opens a PR whose body is the agent's final message. Because the sensor, controller, and actuator are fused into one agent step here, the workflow does not have three separate steps. A loop with a deterministic, standalone sensor and controller would instead have discrete steps.

## Human on the loop

- `.github/agent-memory/react-doctor.md` is loaded into the agent every run. It carries standing feedback, not one-off logs.
- Maintainers comment `/iterate` on the PR; a hidden marker in the PR body routes the comment to the workflow that created it. The workflow loads the PR context and feedback and updates the memory file and PR.

## Flow control

Every PR is labeled `agent-react-doctor`. Scheduled runs no-op when an open PR with that label already exists, so there is at most one open PR per loop; manual dispatch bypasses the gate.

## What to take from this

- **Reusable shape:** set point → sensor → controller → actuator under disturbances, plus a dampener, memory, `/iterate` steering, and one-PR flow control.
- **Not reusable:** `react-doctor`, the bun/CodeLayer commands, the "top 3 rules / 5 fixes" policy, and the `riptide-ui` scope. Those are tailored to the example repo; design your loop from the target codebase.
