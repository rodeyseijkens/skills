---
name: research
description: Prototype a question against primary sources — spin up a background agent to investigate official docs, source code, specs, and first-party APIs, then leave a single cited Markdown note wherever the repo keeps such notes.
---

# Research

When a question needs more legwork than fits in the current session — reading the docs, tracing the code, comparing APIs — spin up a **background agent** to do it. You keep working in the current thread; the agent reads, you get back a document to grill, plan, or design against.

## When to reach for it

Reach for `research` when:

- The question is open-ended and reading-heavy (a whole library, a spec, a migration guide).
- The answer needs to come from **primary sources** — official docs, source code, specs, first-party APIs — not from your priors.
- You want a cited artefact at the end, not a verbal summary you'll have to verify later.

Do not use it for questions you can answer by reading the repo or a few short files in the current session. `research` is delegable reading legwork; trivial reading is the agent's job, not a background task's.

## Process

1. **Frame the question.** Write it as a single, specific prompt: the question, the sources to prefer (official docs first, then source, then anything else), the output format. The clearer the prompt, the less the background agent has to guess.

2. **Delegate.** Spin up a background agent with the framed question. Pass it the repo path so it can read source if it needs to. Tell it where to leave the note (the repo's notes location — see step 4).

3. **Keep working.** Continue the current session. The background agent reads while you plan.

4. **Receive the note.** When the agent returns, it leaves a single Markdown file at the repo's notes location. The file is cited — every claim has a link or path to its source.

## Output format

The note is a single Markdown file. Minimum structure:

```markdown
# <Question, as a sentence>

## Summary

<3–5 sentence answer>

## Findings

### <Sub-question 1>

<Answer, with citations inline as links>

### <Sub-question 2>

<Answer, with citations inline as links>

## Open questions

<Anything the sources didn't resolve — for the human to follow up>
```

Citations are links to the source the agent actually read (a doc URL, a file path, a line number). No claims without a citation; the artefact is only as useful as it is verifiable.

## Notes location

Leave the note wherever the repo already keeps such notes. If the repo has a `docs/`, `notes/`, or `.scratch/` directory used for research artefacts, use it. If the repo has a `## Agent skills` block in `AGENTS.md` (set up by `project-agent-setup`), it may point at a notes path — follow that pointer rather than inventing one.
