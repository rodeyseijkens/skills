---
name: git-atomic-commit
description: Analyze uncommitted git changes and split them into atomic Conventional Commits. The shared commit primitive behind `commit`. Use when the user wants to commit, mentions atomic or granular commits, asks for Conventional Commits, or requests a git commit plan.
---

# Git Atomic Commit

Analyse uncommitted changes, propose atomic Conventional Commits, and execute on approval.

## Principles

- **Atomic & granular**: split into the smallest logical units. Separate new types, helpers, refactors, dependency updates, and deletions. Never bundle unrelated changes.
- **Conventional Commits**: `<type>(<scope>): <description>`.
  - **Scope**: only used for multi-package monorepos. Derive from top-level sub-package dirs (e.g. `packages/<scope>`, `apps/<scope>`). Drop scope entirely for single-package and flat-layout repos.
  - **Scope detection**: run this algorithm before grouping:
     1. Check if the repo is a monorepo: `test -f pnpm-workspace.yaml -o -f lerna.json -o -f nx.json` or grep `package.json` for `"workspaces"`; exits 0 if monorepo.
     2. Check for actual sub-packages: `ls -d packages/*/package.json apps/*/package.json libs/*/package.json modules/*/package.json 2>/dev/null | head -2 | wc -l | xargs test 2 -le`; exits 0 if ≥2 sub-packages.
     3. Only use scopes if BOTH a monorepo marker AND ≥2 sub-packages exist. Otherwise omit scopes.
  - **Never invent a scope.** If no real dir matches, drop the scope (e.g. `chore: bump pnpm to 9`).
  - **Description**: imperative, present tense, lowercase, no trailing period.
  - **Breaking**: mark breaking changes per Conventional Commits and add a `BREAKING CHANGE:` footer.

## Analysis

Map the diff before proposing. The output shape is mandatory; fill every section.

1. Run `git status` and the diff. If the working tree is clean, reply exactly: `No uncommitted changes detected.` and stop.
2. **Validate scopes**: run the scope detection algorithm (from Principles) and declare whether scopes are in use. If they are, list the valid scopes and which sub-package dir they map to.
3. **Group** by atomic function, in the Plan's commit-first shape. Mark a file `Partial` when the group carries only some of its hunks.
4. **Overlaps**: files that span groups, staged with `git add -p`; mark each `Partial` in every group it appears in.
5. **Dependencies**: strict ordering between groups (types before importers, deletions last).
6. **Ambiguities**: changes that need user clarification before they can be grouped.

Present all five sections. Never skip a section to save tokens; the user needs every one to approve safely.

## Plan

Commits first, each with the files it carries nested beneath it, in dependency order. Mark a file `Partial` when the commit carries only some of its hunks; a file appears under every commit that takes part of it.

```
**1. `feat(api): add shared auth types`**
- `packages/api/src/types.ts`

**2. `refactor(api): extract token helper`**
- `packages/api/src/auth.ts`
- **Partial** · `packages/api/src/config.ts`

**3. `chore: update lockfile`**
- **Partial** · `pnpm-lock.yaml`
```

Present the full plan, then use the `question` tool to request approval before executing; ambiguity here means rollback risk.

## Approval

Use the `question` tool. Offer backup only when the plan has a `Partial` commit.

- **Partial commits present**: offer **Approve: with backup** and **Approve: no backup**.
- **No partial commits**: offer **Approve** alone; whole-file commits are recoverable from the commits themselves.

**Approve: with backup** stashes the working tree (`git stash push -m "backup-before-atomic-commit"`), then `git stash apply` restores it, leaving the stash as a recovery net.

## Execution

1. **Back up** (only when the plan has a `Partial` commit and "Approve: with backup" was chosen): `git stash push -m "backup-before-atomic-commit"`, then `git stash apply` to restore the working tree.
2. **Unstage all**: `git restore --staged .` (clean staging slate).
3. **Commit in order**: for each group: `git add` (whole files or `-p` for partials), then `git commit -m "<message>"`.
   - On any commit failure: report the error and stop. If a stash was created, it remains for `git stash pop` recovery. Do not continue past a failure.
4. **Summarise**: Markdown table of executed commits:
   ```
   | # | Commit Message | Files |
   |---|----------------|-------|
   | 1 | feat(security): add shared auth types | types.ts |
   ```
5. **Leave the stash** in place after success (if one was created); the user decides when to drop it.

## Constraints

- Allowed commands: `git stash`, `git restore`, `git add`, `git commit`, `git status`, `git diff`, `ls`, `head`, `wc`, `xargs`, `test`, `grep`. Nothing else.
- Lockfile changes (`pnpm-lock.yaml`, etc.) ride with the commit that introduces the dependency, or stand alone as a final `chore: update lockfile` commit when they cross package boundaries.
