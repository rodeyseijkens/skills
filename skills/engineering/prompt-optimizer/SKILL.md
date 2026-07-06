---
name: prompt-optimizer
description: Distill a prompt or instruction file into a predictable instruction hierarchy.
disable-model-invocation: true
---

# Prompt Optimizer

Distill a prompt into a predictable instruction hierarchy: essential root, disclosed reference, and deletion candidates.

## Workflow

### 1. Scope

Identify the prompt source: supplied text, a named file, or an instruction corpus such as `AGENTS.md`. Determine whether the user wants an edited file, a proposed rewrite, or a new skill.

Completion criterion: every source to optimize is known, the output mode is clear, and missing sources have been requested only if they cannot be found.

### 2. Audit

Assign every instruction to exactly one bucket:

- **Root** — needed on every run before the agent can act safely.
- **Disclosed** — relevant only for a branch, domain, tool, language, workflow, or convention.
- **Clarify** — conflicts with another instruction or depends on a user preference.
- **Delete** — duplicate, stale, vague, obvious, or no-op.

For contradictions that change behaviour, ask the user which version to keep before rewriting.

Completion criterion: every instruction has one bucket, every contradiction has an explicit resolution or pending user choice, and no instruction is represented in two buckets.

### 3. Design the hierarchy

Keep the root skeletal. It may contain:

- one-sentence project or prompt purpose
- package manager only when it is not the ecosystem default
- non-standard build, test, lint, or typecheck commands
- universal safety or repository constraints
- context pointers to disclosed files

Move branch-specific material behind strongly worded context pointers. Name disclosed files for the decision that should trigger reading them, not for a vague category.

Completion criterion: every kept non-root instruction has a target file and a context pointer whose wording says when to read it.

### 4. Rewrite

Produce the minimal root and each disclosed file. Preserve behaviour while improving predictability:

- one meaning has one source of truth
- root pointers cover every disclosed file
- branch instructions are co-located with their caveats
- weak phrases collapse into stronger leading words where they improve execution
- deletion candidates do not silently disappear unless the user requested direct editing

Completion criterion: every kept instruction appears exactly once, every disclosed file is reachable from the root, and every requested output artifact is present.

### 5. Report

Summarize the final structure and list deletion candidates with reasons: duplicate, stale, vague, obvious, or no-op. If unresolved contradictions remain, stop before applying edits and present only the choices needed to proceed.

Completion criterion: the user can see what changed, what moved, what was flagged for deletion, and what still requires a decision.

## AGENTS.md branch

When optimizing `AGENTS.md`, treat it as the always-loaded root for coding agents. Keep it shorter than the files it points to whenever possible. Suggested disclosed targets:

- `docs/agents/typescript.md`
- `docs/agents/testing.md`
- `docs/agents/api-design.md`
- `docs/agents/git-workflow.md`
- `docs/agents/build-and-checks.md`
- `docs/agents/domain.md`

Use only the files whose instructions exist in the source material.
