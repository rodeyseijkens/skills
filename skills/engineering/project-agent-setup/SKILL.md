---
name: project-agent-setup
description: Scaffold per-repo agent config (local-markdown issue tracker under `.scratch/`, triage labels, domain-doc layout) that the engineering skills (`to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, `zoom-out`) consume. Writes an `## Agent skills` block to `AGENTS.md` and seeds `docs/agents/`. Run once per repo before first use of those skills, or if they appear to be missing config about the issue tracker, triage labels, or domain docs.
disable-model-invocation: true
---

# Project Agent Setup

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker** — local markdown files under `.scratch/` (no `gh`, no GitLab)
- **Triage labels** — the strings used for the five canonical triage roles
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them

This is a prompt-driven skill, not a deterministic script. Explore, confirm findings with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config` — is there a remote? (not used for issues, but good context)
- `AGENTS.md` at the repo root — does it exist? Is there already an `## Agent skills` section?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does this skill's prior output already exist?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use

### 2. Present findings

Summarise what's present and what's missing. There are no choices to walk through — this skill always uses local-markdown under `.scratch/`, always writes the default triage-label mapping, and auto-detects the domain-doc layout. Tell the user:

- Whether `AGENTS.md` exists or will be created
- Whether a local issue tracker (`.scratch/`) is already in use
- The detected domain-doc layout (single-context vs multi-context based on presence of `CONTEXT-MAP.md`)

### 3. Auto-detect domain-doc layout

Check for `CONTEXT-MAP.md` at the repo root:

- **Present → multi-context.** Write `docs/agents/domain.md` describing a multi-context layout (read `CONTEXT-MAP.md` for the map, then follow pointers to per-context `CONTEXT.md` + `docs/adr/`).
- **Absent → single-context.** Write `docs/agents/domain.md` describing a single-context layout (read `CONTEXT.md` + `docs/adr/` at repo root).

### 4. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to `AGENTS.md`
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`

Let them edit before writing.

### 5. Write

**Edit `AGENTS.md`:**

- If `AGENTS.md` exists, edit it.
- If it doesn't exist, create it.

If an `## Agent skills` block already exists in `AGENTS.md`, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

Local markdown files under `.scratch/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical role-name mapping for triage. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (or multi-context). See `docs/agents/domain.md`.
```

Then write the three docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-local.md](./issue-tracker-local.md) → `docs/agents/issue-tracker.md`
- [triage-labels.md](./triage-labels.md) → `docs/agents/triage-labels.md`
- [domain.md](./domain.md) → `docs/agents/domain.md`

### 6. Done

Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later — re-running this skill is only necessary if they want to restart from scratch.
