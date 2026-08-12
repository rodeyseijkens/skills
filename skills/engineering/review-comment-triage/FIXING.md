# Fix phase

Turn approved findings into commits, one commit per finding.

## 1. Clean tree

`git status` must be clean before fixing. Unrelated uncommitted changes get their own commits first (or are flagged to the user), so fix commits stay atomic.

## 2. Dispatch

One subagent per approved finding, dispatched **sequentially**. When multiple findings touch the same file, each agent edits the tree exactly as the previous finding left it — never run two agents on the same file at once. (Grouping same-file findings into one agent is the alternative; sequential per-finding dispatch keeps the commits atomic.) Constraints in every prompt:

- edit only the named files
- no git commands that mutate state — the coordinator verifies and commits after the agent returns
- read-only `git diff` is fine; the agent returns the exact diff it applied
- no format/lint/type-check — the coordinator runs those

## 3. Verify + commit, per finding

After each agent returns, before dispatching the next: review the returned diff, run the repo's format and type-check commands (the repo's AGENTS.md names them), fix any failure, then commit that finding. Committing per finding keeps same-file findings separable — staging by file alone cannot split two findings that edited the same file.

Commit: one commit per finding, conventional-commit subject matching the repo's log style, subject-only. Stage only that finding's files.
