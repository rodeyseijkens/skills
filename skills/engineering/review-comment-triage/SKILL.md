---
name: review-comment-triage
description: Triage unresolved PR review comments — validate each against the stack tip, post concise replies, resolve addressed threads, and fix approved findings.
disable-model-invocation: true
---

# Review comment triage

Move unresolved review comments on one or more pull requests through triage: validate each finding against the code as it stands, reply, resolve what is addressed, and fix what is approved.

Inputs: one or more PR numbers/URLs, optionally a list of comment authors to skip.

## Flow

### 1. Scope the run

Fetch every unresolved review thread per PR — thread id, first-comment author, body, path, line; recipe in [GH-RECIPES.md](GH-RECIPES.md). Drop threads whose first-comment author is on the skip list. Report the inventory (PR → thread count) before proceeding.

Done when every PR's unresolved threads are listed and filtered.

### 2. Find the validation branch

Every finding is validated against one branch, named explicitly before validating:

- **Stacked PRs** — validate against the **stack tip**. Prefer `gh stack` when installed; if it is missing, prompt the user to install it (running `gh stack` triggers the install prompt), and fall back to walking upward if they decline: `gh pr list --base <head-branch> --state open --json number,headRefName`, repeated until no open PR targets the current head. The topmost PR is the tip.
- **Solo PR** — validate against the PR's own branch.

The working tree must be on the validation branch. Done when the branch is named and the working tree is on it.

### 3. Validate

One research-only subagent per PR. Each agent receives the full text of its PR's comments and returns, per comment:

- **Verdict** —
  - **APPLIES** — the issue exists in the current code.
  - **ALREADY-ADDRESSED** — a later change fixed it; name the commit.
  - **NO-LONGER-APPLIES** — the code it targets is gone or restructured; say how.
- **Evidence** — file:line references, snippets, commit hashes.
- **Drafted reply** — in the reply style below.

Research and drafting belong to the subagent; editing belongs to the coordinator. Done when every comment has a verdict, evidence, and a draft.

### 4. Gate A — post replies

Present the verdict table and the drafts. On approval, post each draft as a thread reply, then resolve the threads whose verdict is ALREADY-ADDRESSED or NO-LONGER-APPLIES. Recipes in [GH-RECIPES.md](GH-RECIPES.md).

### 5. Gate B — approve fixes

With any APPLIES verdicts, present a fix summary — one line per finding: finding → file(s) → planned change. The user approves (all or per finding) or declines. Decline ends the run.

### 6. Fix

Per [FIXING.md](FIXING.md): clean tree, one subagent per approved finding, verify, one atomic commit per finding.

### 7. Gate C — reference commits

Commit references resolve on GitHub only once pushed. Ask the user to push; on confirmation, post a reply on each fixed thread carrying the full commit URL, then resolve the thread.

## Reply style

Concise, plain text, one of three shapes:

- `Already addressed on this branch (<validation-PR URL>) — <evidence>.`
- `No longer applies on this branch (<validation-PR URL>) — <evidence>.`
- `Valid — <details>. Will <fix plan>.`

Post-fix reference: `Fixed in <full commit URL> — <one-line summary>.`

## Staleness

A rebase rewrites every SHA referenced in posted comments. After any rebase of the validation branch, map old SHAs to new via `git log` and rewrite the affected comment bodies — technique in [GH-RECIPES.md](GH-RECIPES.md).
