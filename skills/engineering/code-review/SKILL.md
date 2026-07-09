---
name: code-review
description: Review a diff for correctness, design, and the Fowler "Bad Smells in Code" baseline. Use when a change is ready to merge and needs a second pass, or when a human asks for a code review.
---

# Code Review

Review a diff for **correctness**, **design**, and the **Fowler smell baseline** — a curated set of high-signal code smells held alongside whatever the repo documents. A code review is judgement, not a checklist pass: every smell is reported as a judgement call, never a hard violation.

## When to reach for it

- A change is ready to merge and needs a second pass.
- A human asks for a code review.
- A refactor is in progress and the author wants to confirm the diff doesn't introduce new smells.

## Axes

Three axes, in order:

1. **Correctness** — does it do what it claims? Are the tests covering the right behaviour at the right seam? Are the edge cases handled?
2. **Design** — is the change shaped well? Does it deepen or shallow the modules it touches? Is the interface right?
3. **Fowler smell baseline** — does the diff introduce or fail to retire any of the smells below?

The repo's own standards (style guide, ADRs, `CONTEXT.md`, design docs) override the baseline where they conflict.

## Fowler smell baseline

Curated from Fowler's *Refactoring* — twelve high-signal "Bad Smells in Code" that catch most design regressions. Report each smell present in the diff as a **judgement call**, not a violation: the smell is a flag for "look again", not a "must fix".

### 1. Mysterious Name

A name that doesn't communicate intent — function, variable, class, module. The reader has to read the body to know what it does. Fix: rename to what the thing *is* or *does*, in the project's domain vocabulary.

### 2. Duplicated Code

The same expression in two places. The cure is *one* expression: extract to a function, a constant, a shared helper. Watch for near-duplicates (same shape, slight variation) — they are the same smell wearing a costume.

### 3. Feature Envy

A method that reaches into another module's data more than its own. The behaviour belongs on the other object. Fix: move the method (or its core) to where the data lives.

### 4. Data Clumps

Groups of variables that travel together — passed together, declared together, used together. They're a missed object. Fix: introduce a value object or record, and let the clump be one parameter.

### 5. Primitive Obsession

The use of primitives (strings, numbers, booleans) where a small object would carry the meaning. `string` for an email, `number` for a money amount, `boolean` for a flag with two states — each is a missed type. Fix: introduce a value type with the validation it implies.

### 6. Repeated Switches

The same switch/if-chain on a type or value, scattered across the code. New cases mean editing every site. Fix: replace with polymorphism, or a single dispatch table.

### 7. Shotgun Surgery

A single change requires small edits to many files. The change is the right one, but the code's structure forces you to repeat the touch. Fix: move the behaviour to a single module, or co-locate the data it touches.

### 8. Divergent Change

One module is changed for many unrelated reasons — the shape of "every kind of change" lands here. The module is doing too much. Fix: split along the axes of change.

### 9. Speculative Generality

Code that's "flexible" for a use that hasn't arrived — abstract base classes with one subclass, parameters nobody passes, hooks nothing calls. Fix: delete it. YAGNI is the cure.

### 10. Message Chains

A long chain of method calls (`a.b().c().d().e()`) that walks through the structure. The caller now depends on the *shape* of the structure, not its meaning. Fix: hide the chain behind a method on the *last* object the caller actually needs.

### 11. Middle Man

A class that exists only to delegate to another. Half of its methods are `return this.other.method(...)`. The delegation adds nothing. Fix: remove the middle man and let the caller reach the real one, or move the behaviour up.

### 12. Refused Bequest

A subclass that doesn't want most of what its parent offers — overrides everything, leaves the rest unused. The inheritance was wrong. Fix: replace with composition, or split the parent so the subclass inherits only what it uses.

## How to report

Group findings by axis (Correctness, Design, Smells). For each smell flagged, give:

- **Where** — file and line.
- **What** — the smell, named (use the twelve above).
- **Why now** — what's bad about it in this diff, in the project's context.
- **Fix** — the smallest change that retires the smell, or the next step (often: ask the human which fix they prefer).

If a smell is a judgement call (the cure may be worse than the smell, or the smell is the lesser evil), say so. A smell flagged with "but maybe leave it" is still a smell flagged.

## Triage scope

Review the diff, not the codebase. Smells already in untouched code are *not* findings for this review — note them as adjacent observations only if they will block the change or confuse a future reader.

## Binding rules

1. **Repo standard overrides baseline.** If the project's style guide, an ADR, or `CONTEXT.md` says otherwise, follow the project. The baseline is the floor, not the ceiling.
2. **Every smell is a judgement call.** Never a hard violation. A smell is a "look again", not a "must fix".
3. **Stale baseline rule.** Update this list when the project retires a smell it never hits, or promotes a new one it always does. The baseline is the project's, not Fowler's forever.
