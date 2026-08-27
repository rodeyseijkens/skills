# Productivity

General workflow tools, not code-specific.

## User-invoked

Reachable only when you type them (`disable-model-invocation: true`).

- **[grill-me](./grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the design tree is resolved.
- **[handoff](./handoff/SKILL.md)**: Compact the current conversation into a handoff document so another agent can continue the work.
- **[html-report](./html-report/SKILL.md)**: Turn a plan into a visual HTML report.
- **[teach](./teach/SKILL.md)**: Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[todo](./todo/SKILL.md)**: Queue an item into the agent's todo list; it preempts the running task when urgent enough, otherwise slots it in by priority.
- **[to-questionnaire](./to-questionnaire/SKILL.md)**: Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can, filled in async or together over a meeting.
- **[wait-what](./wait-what/SKILL.md)**: Fire this the moment a message doesn't land. The agent re-pitches it with the context you're missing, in plain English, using your `CONTEXT.md` vocabulary.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[create-pr](./create-pr/SKILL.md)**: Short categorized PR title and description from the branch diff. Opens the PR when asked.
- **[grilling](./grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the design tree is resolved.
- **[writing-for-agents](./writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md, and any doc an agent reaches by a pointer.
