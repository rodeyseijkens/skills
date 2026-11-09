---
name: council
description: Get review or feedback from three models on different providers, looping until they agree or the round cap is reached.
disable-model-invocation: true
metadata:
  credits:
    skill: council
    author: Theo Browne
    organisation: t3dotgg
    url: "https://github.com/t3dotgg/tstack/blob/main/skills/council/SKILL.md"
---

# Council

Trigger this if the user says **council**.

Before an audit, address outstanding PR comments, fix known issues, and run
relevant checks. Give council the updated implementation; do not defer known
fixes until reviews return. If the user wants to discard the implementation and
explore new ideas, skip fixes to code being replaced.

Bring in three delegates to help with the user's request, usually for review or
feedback. Use one strong model from each of three different providers, at high
reasoning effort.

## Members

If the user's instructions name council members, use those. Otherwise pick the
latest flagship model from each provider.

In T3 Code, call `orchestrator_capabilities` to resolve the models, then
`delegate_task` to start one delegate per model in parallel. Elsewhere, use the
harness's subagent tools. Do not hardcode model IDs: they rot. If you cannot
reach three providers, or a named member is unavailable, report it instead of
substituting.

Give each delegate the request and relevant context. For review or feedback,
keep their work read-only. Collect their responses and summarize the useful
findings, disagreements, and recommended next steps.

## Rounds and the cap

For a code review, ask each delegate for a score out of 10. Count each full
review pass as one round. A fresh review after fixes starts a new round.

If you agree with their recommendations, make the changes and request a fresh
review after. Keep fighting to keep scope limited: repeated reviews must not
turn into scope creep.

**Cap: three rounds.** If the delegates have not all agreed after round three,
stop. Report the remaining disagreements, each delegate's score, and your
recommendation, then hand the decision back to the user. Do not start round four
without an explicit instruction.

## Where results go

If the work ends in a pull request, put the results in the PR description. Put
this section before the model and harness line at the end:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| GPT Sol | 8/10 | 10/10 |
| Gemini Pro | 7/10 | 9/10 |
```

If a delegate gives no score, write `no score`. Do not invent one. If the PR is
open, edit the description. Do not post a comment for this. If there is no PR,
put the same results in the final reply only.
