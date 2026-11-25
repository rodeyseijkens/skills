---
name: full-send
description: Take work through proof, review, pull request, CI/review follow-up, and merge when the user explicitly grants full-send authority.
disable-model-invocation: true
metadata:
  credits:
    - skill: full-send
      author: Theo Browne
      organisation: t3dotgg
      url: "https://github.com/t3dotgg/tstack/blob/main/skills/full-send/SKILL.md"
      alignment:
        date: "2026-11-25"
        commit: "11e37a74d0a6868c121cd0910ab2b3bd9873b92a"
---

# Full Send

Use this only when the user clearly asks for **full send**. It is the merge-authorized counterpart to the local [`full-stop`](../full-stop/SKILL.md) workflow: follow full-stop's finish, proof, review, PR, and babysitting discipline, then merge only when its readiness gate passes.

Updates and the final report may go unread until the work is complete. Stay active from the start through the merge gate; if CI or review is pending, use the repository's supported watcher instead of polling or sleeping.

## Permission boundary

An explicit **full send** request grants permission to:

- Create a branch when starting on the default branch.
- Rebase and update this task's own branch, using `--force-with-lease` against the observed head.
- Use necessary test methods without separate confirmation.
- Merge this task's PR only after the merge gate below passes.

It does not grant permission to delete data, change production, modify unrelated branches, bypass harness approvals, bypass branch protection, or merge another PR. Never use admin/bypass permissions or enable auto-merge/merge-queue participation unless the user separately authorized that behavior. If the repo's merge mechanism would auto-merge before the gate or bypass protections, stop and ask.

## Workflow

1. **Finish.** Continue the user's stated goal with the smallest complete change. If on the default branch, create a task branch.
2. **Prove.** Reproduce the original failure or run the most direct validation available. Run required CI-equivalent checks; for UI/runtime changes, inspect the actual experience when possible. Report anything not verified.
3. **Review.** Run the local `code-review` workflow on changes since the branch point. If the user explicitly names `council`, run it too. Fix real findings and re-review the final diff.
4. **File or update the PR.** Use the local `pr` skill. Rebase onto the latest default branch first. Include a short line explaining proof. Do not create a second PR if one already exists for the branch.
5. **Babysit.** Use `babysit-pr` to handle CI and review findings. Prove each fix before pushing it.
6. **Check the merge gate.** On the latest head, confirm:
   - Proof covers every change.
   - Required checks are green.
   - Review bots have finished and every finding is fixed or dismissed with a written reason.
   - No human review requests changes and required approvals are present.
   - The branch is current with its base and GitHub reports it mergeable.
   - The PR is open, non-draft, and not configured to merge without the user.
   - The merge method follows branch protection and repository policy.
7. **Merge.** Only after all gate conditions pass, use the repository-approved merge method. Do not force-merge, bypass protections, or merge with unresolved blockers. Confirm GitHub reports the PR merged.
8. **Report.** Include the PR URL, merge commit, proof, review/check outcome, decisions made, and remaining risk.

## If blocked

Ask the user through the harness question tool if proof is unavailable, the gate cannot pass, the next action falls outside the permission above, or the goal is ambiguous. Otherwise resolve ordinary findings yourself. If approval is required, the PR is obsolete, or another PR changes the goal, do not merge; explain the exact blocker and stop safely.
