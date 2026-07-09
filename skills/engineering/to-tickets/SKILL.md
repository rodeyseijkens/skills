---
name: to-tickets
description: Break a plan, spec, or PRD into independently-grabbable tickets on the project issue tracker using tracer-bullet vertical slices. Handles ordinary work and wide refactors.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring its **blocking edges** — and publish them to the project issue tracker.

A ticket is "grabbable" the moment its blockers are done; the tracker's native blocking edges show the frontier visually. That one artifact reads two ways depending on the tracker `/setup-matt-pocock-skills` configured: a **local file** (`tickets.md`) writes the edges as text and you work it top-to-bottom by hand; a **real tracker** writes them as native blocking links, so any ticket whose blockers are done is on the frontier and several agents can run at once.

The issue tracker and triage label vocabulary should have been provided to you — run `/project-agent-setup` if not.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes an issue reference (issue number, URL, or path) as an argument, fetch it from the issue tracker and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Pick the slicing strategy

Most plans slice into **vertical slices** (ordinary tracer bullets). A few don't — they are a **wide refactor**: a single mechanical change whose blast radius fans across the whole codebase, breaking thousands of call sites at once so no vertical slice can land green. If you recognise that shape, switch to the wide-refactor strategy in [Wide refactors](#wide-refactors) below.

<vertical-slice-rules>

### Vertical slice rules (ordinary work)

- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Any prefactoring should be done first

</vertical-slice-rules>

<wide-refactor-rules>

### Wide refactors (mechanical, cross-cutting change)

A wide refactor — e.g. rename a column, swap a function signature, change a type's shape — cannot be sliced by tracer bullet because every slice would break the world at once. Slice it by **expand–contract** instead:

1. **Expand.** Introduce the new form *beside* the old. Both work; the world is consistent.
2. **Migrate.** Update call sites in batches sized by **blast radius** — a batch is small enough to land green and large enough to be worth a ticket. The batch is the **tracer bullet** here: it must compile, pass tests, and keep the system green.
3. **Contract.** Remove the old form once every call site is on the new one. CI stays green batch to batch — or, when it can't, only at a final **integrate-and-verify** ticket that does the contract step.

If the refactor is so large that even the expand phase can't stay green, plan for a single integrate-and-verify ticket that holds the whole migration behind a feature flag.

</wide-refactor-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish the tickets to the issue tracker

For each approved slice, publish a new ticket to the issue tracker. Use the ticket body template below. These tickets are considered ready for AFK agents, so publish them with the correct triage label unless instructed otherwise.

Publish tickets in dependency order (blockers first) so you can reference real ticket identifiers in the "Blocked by" field.

Prefer the tracker's **native sub-issues** for parent → slice and **native blocking edges** for `Blocked by` where the tracker supports them. Keep the body sections below as the fallback when it doesn't.

<ticket-template>
## Parent

A reference to the parent issue on the issue tracker (if the source was an existing issue, otherwise omit this section).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</ticket-template>

Do NOT close or modify any parent issue.
