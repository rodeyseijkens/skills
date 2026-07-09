---
name: grilling
description: Grill the user relentlessly about a plan or design. The shared interview primitive behind `grill-me` and `grill-with-docs`. Use when the user wants to stress-test a plan before building, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

## Facts vs. decisions

- **Facts** — look them up. If a question can be answered by exploring the codebase, exploring the docs, or reading the code, do that. Do not put a fact to the human; resolve it yourself.
- **Decisions** — put each one to the human and wait for their answer. A decision is a choice between alternatives the human must make (or explicitly delegate). Decisions include taste, scope, priority, and any judgment call.

If you cannot tell which it is, default to the human — but state the fact you would otherwise have looked up so they can correct it cheaply.

Ask the questions one at a time (using the `question` tool), waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

## Confirmation gate

Do not enact the plan until the user confirms the shared understanding has been reached. The completion criterion is explicit: the plan is enacted only after the user types confirmation (or equivalent). If the conversation feels done but you have not received confirmation, ask for it — do not infer it from silence.

The grill is done when the human confirms. Until then, every "we're aligned" or "the plan is clear" you might want to say is premature.
