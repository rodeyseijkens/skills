---
name: git-atomic-commit
description: Analyze unpushed git changes, propose granular Conventional Commits, and execute atomic commits. Use when the user wants to commit uncommitted changes, asks for atomic/granular/Conventional Commits, mentions splitting changes by type or scope, or requests a git commit plan.
---

# Git Atomic Commit

Your task is to analyze unpushed changes, propose a highly granular, atomic commit plan using Conventional Commits, and execute it upon approval.

## Core Principles
- **Atomic & Granular**: Split changes into the smallest logical units. Separate new types, new helpers, refactors, dependency updates, and deletions into distinct commits. Never bundle unrelated changes.
- **Conventional Commits**: Use the format `<type>(<scope>): <description>`.
  - **Scopes**: Use the top-level directory names for the scope from `packages/<scope>` or `apps/<scope>`. Omit scope for generic/global changes.
  - **Description**: Imperative, present tense (e.g., "add", "migrate", "rewrite"), lowercase, no period at the end.
  - **Breaking**: Append `!` to type and add `BREAKING CHANGE:` footer.

## Analysis Phase
Before proposing, analyze the git diff and map the changes:
1. **Group by Atomic Function**: Identify the smallest logical units of change (e.g., "add shared types", "migrate specific file to use new types", "delete old file").
2. **Identify Overlaps**: Note if a file has changes that belong to multiple logical groups (prepare for partial staging via `git add -p` or specific file paths).
3. **Trace Dependencies**: Establish strict ordering (e.g., "Types must be committed before files that import them").
4. **Flag Ambiguities**: Note any changes that are unclear or might need user clarification.
Present the analysis strictly as:
- **Group N**: `<type>(<scope>): <description>` → `[file1, file2, ...]`
- **Overlaps**: `[file]` → Group X + Group Y
- **Dependencies**: Group A must precede Group B

## Execution Phase
1. **Output**: Present the full analysis and the proposed granular commit plan (numbered list).
2. **Approval**: Wait for a single "approve", "yes", or "go" from the user.
3. **Backup**: Run `git stash push -m "backup-before-atomic-commit"` to save current changes as a safety net.
4. **Restore**: Run `git stash apply` to restore changes while keeping the stash entry.
5. **Execute**:
   - First, run `git reset HEAD --quiet` to ensure a clean staging slate.
   - Run `git add` (using specific file paths or `-p` for partial staging) and `git commit` for each proposed commit in strict dependency order.
   - If any commit fails, report the error. The stash remains available for recovery with `git stash pop`.
6. **Post-Execution Summary**: Output a clean Markdown table of the executed commits:
   | # | Commit Message | Files Touched |
   |---|----------------|---------------|
   | 1 | `feat(security): add shared auth types` | `types.ts` |
   | 2 | `refactor(trpc): ...` | `init.ts, admin.ts` |
   
   - If all commits succeed, leave the stash in place for potential reuse.
   - The user can clean up later with `git stash drop` or `git stash pop`.
7. **No Changes**: If `git status` shows no unpushed/unstaged changes, reply exactly: "No unpushed changes detected."

## Constraints
- Only use `git stash`, `git reset`, `git add`, and `git commit`.
- Always include lockfile changes (`pnpm-lock.yaml`, etc.) in the commit that introduces the dependency, or as a final isolated `chore` commit.
- The stash backup remains after successful commits; user cleans up manually with `git stash drop` or `git stash pop`.