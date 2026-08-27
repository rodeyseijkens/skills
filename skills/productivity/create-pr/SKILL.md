---
name: create-pr
description: Short categorized PR title and description from the branch diff. Use when the user wants a PR title or description, or to create a pull request.
---

# Create PR

Write PR copy a human reviewer can scan in twenty seconds. Cluster by concern. The diff is the source of truth; commit messages are clustering hints.

## Range

Default base is the repo's default branch (`origin/HEAD`, else `main`). The user can name another. The range is `base...HEAD`. Uncommitted files are not in the PR: mention them, leave them out of the copy.

Done when the base and range are known.

## Map

Read the log and the diff for the range. Lockfiles and generated files are not narrative; if they are the only change they go under Chore.

Cluster by concern. Name each cluster from the work. Use the natural number of clusters. Deps, upgrades, and generated files go under Chore.

Done when every change in the range sits in exactly one named cluster.

## Write

Output only this shape:

**PR Title:**
One line. Concrete. Name the clusters if several, or the one change if one.

**PR Description:**

**Cluster name**
- Concrete change from the diff
- ...

Every bullet names a change in the diff. Bold sentence-case headings. Stop after the last bullet.

Done when the title and every cluster are shown, and every cluster has at least one concrete bullet.

## Unslop

Run unslop on the title and description. Done when the self-audit finds no remaining AI tells.

## Open

When the user asked to create or open the PR, run `gh pr create` with that title and body against the base. Done when the command prints the PR URL. When they only asked for copy, stop after Unslop.
