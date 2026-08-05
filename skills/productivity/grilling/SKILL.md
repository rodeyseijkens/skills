---
name: grilling
description: Grill the user relentlessly about a plan or design. The shared interview primitive behind `grill-me` and `grill-with-docs`. Use when the user wants to stress-test a plan before building, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

## Rounds, not one question at a time

Ask in **numbered rounds**. Each round lists every open question on the current frontier (all the unresolved decisions that are ready to be answered). The user answers all they can in that round, and you proceed to the next round only when the current one is complete.

This is more efficient than one-question-at-a-time because:
- Parallel answers: the user can resolve multiple dependencies in one response
- Context carry: answers in the same round inform later questions in that same round
- Frontier visibility: the user sees the full scope of what's being decided

Within a round, group questions by theme or dependency layer so the user can answer coherently. Still ask one thing per question, but present them as a set.

## Facts vs. decisions

- **Facts** — look them up. If a question can be answered by exploring the codebase, exploring the docs, or reading the code, do that. Do not put a fact to the human; resolve it yourself. Use subagents for heavy research and report findings as facts.
- **Decisions** — put each one to the human and wait for their answer. A decision is a choice between alternatives the human must make (or explicitly delegate). Decisions include taste, scope, priority, and any judgment call.

If you cannot tell which it is, default to the human — but state the fact you would otherwise have looked up so they can correct it cheaply.

## The frontier

Maintain a **frontier** — the set of unresolved decisions that are currently actionable (their dependencies are satisfied). Each round addresses the current frontier; new decisions uncovered by answers are added to the next round's frontier.

## Confirmation gate

Do not enact the plan until the user confirms the shared understanding has been reached. The completion criterion is explicit: the plan is enacted only after the user types confirmation (or equivalent). If the conversation feels done but you have not received confirmation, ask for it — do not infer it from silence.

The grill is done when the human confirms. Until then, every "we're aligned" or "the plan is clear" you might want to say is premature.

## Subagents for facts

When a question requires reading code, docs, or external sources, delegate to a subagent, get the result, and present it as a resolved fact in the next round. Never ask the user to do legwork that an agent can do.
