# Fix phase

Turn approved findings into commits, one commit per finding.

## 1. Clean tree

`git status` must be clean before fixing. Unrelated uncommitted changes get their own commits first (or are flagged to the user), so fix commits stay atomic.

## 2. Dispatch

One subagent per approved finding. Constraints in every prompt:

- edit only the named files
- no git commands, no format/lint/type-check — the coordinator runs those after all agents finish
- return the exact diff applied

Findings that touch the same files go to one agent, never two.

## 3. Verify

Review every returned diff, then run the repo's format and type-check commands (the repo's AGENTS.md names them). Fix any failure before committing.

## 4. Commit

One commit per finding: conventional-commit subject matching the repo's log style, subject-only. Stage only that finding's files.
