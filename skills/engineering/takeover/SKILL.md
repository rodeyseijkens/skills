---
name: takeover
description: Take over existing work in a PR, branch, or agent thread and finish it while preserving the original contributors' credit.
disable-model-invocation: true
metadata:
  credits:
    skill: takeover
    author: Theo Browne
    organisation: t3dotgg
    url: "https://github.com/t3dotgg/tstack/blob/main/skills/takeover/SKILL.md"
---

# Takeover

Trigger this if the user says **take over**. Take responsibility for finishing
the original goal while preserving the original contributors' credit. Do not
defend an implementation just because another agent already built it.

Read the source PR, branch, or thread, including review findings and the user's
later corrections. Resolve the handoff to the actual code and current head, and
account for uncommitted work. Treat the handoff as context, not proof.

## Credit

For a replacement PR, import the original commits onto a new branch and add
your fixes separately. Honor an explicitly requested in-place or stacked
continuation instead. Do not overwrite unrelated work or change the original PR
without authorization.

Preserve Git authorship and existing co-author trailers. Credit the original
contributors in the PR description and link the original PR when there is one.
If the work will be squashed, preserve human author/co-author credit in the
merge commit too, using verified identities rather than guessed emails. Model
attribution is not a substitute for contributor credit.

## Finish the goal

Use `modernize` to update the continuation against its intended base and current
architecture. Rework what is necessary to finish the same goal, not unrelated
features. Simplify the implementation without dropping intended behavior or
surfaces. Recheck the source PR too: it may have improved while you were working.

Independently verify the original failure and realistic workflows, following
repository guidance and permissions. Green mocked tests do not prove the user
experience works. State what remains unverified.

When the requested finish includes a PR, use `pr` to file or update it, then
`babysit-pr` rather than stopping at creation. Use `leaving-pr-comments` for
replies. Merge or close the original PR only when the user explicitly authorized
it; otherwise stop at a PR that is ready to merge.

## Report

Lead with what you inherited. Then report what you changed, how you verified it,
how credit was preserved, and any remaining decision. Include the PR link when
there is one.
