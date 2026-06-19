---
name: git-atomic-commit
description: Analyze uncommitted git changes and split them into atomic Conventional Commits. Use when the user wants to commit, mentions atomic or granular commits, asks for Conventional Commits, or requests a git commit plan.
---

# Git Atomic Commit

Analyse uncommitted changes, propose atomic Conventional Commits, and execute on approval.

## Principles

- **Atomic & granular** — split into the smallest logical units. Separate new types, helpers, refactors, dependency updates, and deletions. Never bundle unrelated changes.
- **Conventional Commits** — `<type>(<scope>): <description>`.
  - **Scope** — top-level dir under `packages/<scope>` or `apps/<scope>`. Omit when the project uses only one scope (single-package repo, or a flat layout) or for generic/global changes.
  - **Description** — imperative, present tense, lowercase, no trailing period.
  - **Breaking** — `!` after type plus `BREAKING CHANGE:` footer.

## Analysis

Map the diff before proposing. The output shape is mandatory — fill every section.

1. Run `git status` and the diff. If the working tree is clean, reply exactly: `No uncommitted changes detected.` and stop.
2. **Group** by atomic function. Format:
   - `Group N: <type>(<scope>): <description> → [file1, file2, ...]`
3. **Overlaps** — files that span groups, staged via partial `git add -p` or split paths.
4. **Dependencies** — strict ordering between groups (types before importers, deletions last).
5. **Ambiguities** — changes that need user clarification before they can be grouped.

Present all five sections. Never skip a section to save tokens — the user needs every one to approve safely.

## Plan

Numbered list of proposed commits in dependency order. Use the `question` tool to request approval before executing — ambiguity here means rollback risk.

## Approval

Use the `question` tool with two options:

- **Approve — with backup** — back up the working tree with `git stash push -m "backup-before-atomic-commit"`, then `git stash apply` to restore it. Stash remains as a safety net for recovery. Proceed to execution.
- **Approve — no backup** — skip the stash and proceed straight to execution.

## Execution

1. **Back up** (only if "Approve — with backup" was chosen) — `git stash push -m "backup-before-atomic-commit"`, then `git stash apply` to restore the working tree.
2. **Reset** — `git reset HEAD --quiet` (clean staging slate).
3. **Commit in order** — for each group: `git add` (whole files or `-p` for partials), then `git commit -m "<message>"`.
   - On any commit failure: report the error and stop. If a stash was created, it remains for `git stash pop` recovery. Do not continue past a failure.
4. **Summarise** — Markdown table of executed commits:
   ```
   | # | Commit Message | Files |
   |---|----------------|-------|
   | 1 | feat(security): add shared auth types | types.ts |
   ```
5. **Leave the stash** in place after success (if one was created) — the user decides when to drop it.

## Constraints

- Allowed commands: `git stash`, `git reset`, `git add`, `git commit`, `git status`, `git diff`. Nothing else.
- Lockfile changes (`pnpm-lock.yaml`, etc.) ride with the commit that introduces the dependency, or stand alone as a final `chore` commit.
