# Agent Skills

Agent skills for planning, development, and tooling: small, composable, and model-agnostic.

Forked from [mattpocock/skills](https://github.com/mattpocock/skills).

## Quickstart

```sh
npx skills@latest add rodeyseijkens/skills
```

Pick the skills you want and the coding agents you want them installed on.

## Reference

Skills split on one axis: **who can invoke them**.

- **User-invoked** skills are reachable only when you type them (e.g. `/grill-me`); they orchestrate.
- **Model-invoked** skills can be invoked by you *or* reached for automatically by the agent when the task fits; they hold the reusable discipline.

A user-invoked skill may call the Skill tool for model-invoked skills, but never another user-invoked one.

### Engineering

Skills for code work: development, debugging, triage, and architecture.

**User-invoked**

- **[skill-router](skills/engineering/skill-router/SKILL.md)**: Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[prompt-optimizer](skills/engineering/prompt-optimizer/SKILL.md)**: Distill a prompt or instruction file into a predictable instruction hierarchy.
- **[grill-with-docs](skills/engineering/grill-with-docs/SKILL.md)**: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `GLOSSARY.md` and ADRs inline.
- **[triage](skills/engineering/triage/SKILL.md)**: Move issues and external PRs through a state machine of triage roles, categorise, verify, grill if needed, and write agent-ready briefs.
- **[improve-codebase-architecture](skills/engineering/improve-codebase-architecture/SKILL.md)**: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
- **[project-agent-setup](skills/engineering/project-agent-setup/SKILL.md)**: Scaffold per-repo agent config: issue tracker, triage labels, and domain-doc layout. Run once per repo before using the other engineering skills.
- **[to-spec](skills/engineering/to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis.
- **[to-tickets](skills/engineering/to-tickets/SKILL.md)**: Break a plan or spec into independently-grabbable tickets using tracer-bullet vertical slices. Handles ordinary work and wide refactors.
- **[wayfinder](skills/engineering/wayfinder/SKILL.md)**: Plan a huge chunk of work as a shared map of decision tickets on your issue tracker, and resolve them one at a time until the way is clear.
- **[implement](skills/engineering/implement/SKILL.md)**: Implement a piece of work based on a spec or set of tickets, driving `tdd` and closing out with `code-review`.
- **[implement-spec](skills/engineering/implement-spec/SKILL.md)**: Implement a whole spec in one run: read the tickets as a task graph, run implementers across the ready frontier, and land everything on one integration branch.
- **[commit](skills/engineering/commit/SKILL.md)**: Split uncommitted git changes into atomic Conventional Commits and execute them.
- **[review-comment-triage](skills/engineering/review-comment-triage/SKILL.md)**: Triage unresolved PR review comments: validate each against the stack tip, post concise replies, resolve addressed threads, and fix approved findings.
- **[retro](skills/engineering/retro/SKILL.md)**: Conduct a retrospective on a coding session and suggest improvements to the agent's environment, not the code.

**Model-invoked**

- **[diagnosing-bugs](skills/engineering/diagnosing-bugs/SKILL.md)**: Disciplined diagnosis loop for hard bugs and performance regressions: reproduce, minimise, hypothesise, instrument, fix, regression-test.
- **[tdd](skills/engineering/tdd/SKILL.md)**: Test-driven development: write a failing test, make it pass, repeat at a pre-agreed seam.
- **[prototype](skills/engineering/prototype/SKILL.md)**: Build a throwaway prototype to answer a design question: runnable logic, or several radically different UI variations.
- **[domain-modeling](skills/engineering/domain-modeling/SKILL.md)**: Build and sharpen a project's domain model: challenge terms against the glossary, stress-test with edge-case scenarios, update `GLOSSARY.md` and ADRs inline.
- **[codebase-design](skills/engineering/codebase-design/SKILL.md)**: Shared vocabulary for designing deep modules: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface.
- **[code-review](skills/engineering/code-review/SKILL.md)**: Two-axis review of the changes since a fixed point: Standards and Spec, run in parallel sub-agents.
- **[research](skills/engineering/research/SKILL.md)**: Spin up a background agent to investigate a question against primary sources, leaving a single cited Markdown note.
- **[git-atomic-commit](skills/engineering/git-atomic-commit/SKILL.md)**: Analyze uncommitted git changes and split them into atomic Conventional Commits. The shared commit primitive behind `commit`.
- **[pr](skills/engineering/pr/SKILL.md)**: Write a categorized pull request title and body from the branch diff, then open the pull request when asked.
- **[wizard](skills/engineering/wizard/SKILL.md)**: Generate an interactive bash wizard that walks a human through steps only they can perform.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](skills/productivity/grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[html-report](skills/productivity/html-report/SKILL.md)**: Render a plan as a single self-contained HTML report (Tailwind + Mermaid from CDNs, no build step).
- **[handoff](skills/productivity/handoff/SKILL.md)**: Compact the current conversation into a handoff document for another agent to pick up.
- **[teach](skills/productivity/teach/SKILL.md)**: Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[todo](skills/productivity/todo/SKILL.md)**: Queue an item into the agent's todo list: preempts the running task when urgent enough, otherwise slots it in by priority.
- **[to-questionnaire](skills/productivity/to-questionnaire/SKILL.md)**: Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can.
- **[wait-what](skills/productivity/wait-what/SKILL.md)**: Fire this the moment a message doesn't land. The agent re-pitches it with the context you're missing, using your `GLOSSARY.md` vocabulary.

**Model-invoked**

- **[grilling](skills/productivity/grilling/SKILL.md)**: Grill the user relentlessly about a plan, decision, or idea. The shared interview primitive behind `grill-me` and `grill-with-docs`.
- **[writing-for-agents](skills/productivity/writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md, and any doc an agent reaches by a pointer.

### Misc

Communication and style skills.

**Model-invoked**

- **[unslop](skills/misc/unslop/SKILL.md)**: Cut AI tells from any writing. Must always apply.
- **[caveman](skills/misc/caveman/SKILL.md)**: Ultra-compressed communication mode. Speaks like a smart caveman while keeping full technical accuracy.

## Layout

Skills live under `skills/{engineering,productivity,misc}/<name>/SKILL.md`.

## License

MIT: see [LICENSE](LICENSE).

Original work Copyright (c) Matt Pocock.
Original work Copyright (c) Lauren Tan.
Original work Copyright (c) Julius Brussee.
Modifications Copyright (c) Rodey Seijkens.
