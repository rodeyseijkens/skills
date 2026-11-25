# Agent Task: <Task Title>

You are working in `<owner/repo>`. Your task is to make one small, reviewable improvement toward this set point:

> <set point>

## Selected Work

<controller output: the target(s) selected for this run, or the rules for selecting them if the agent is also the controller>

## Scope

- May change: <paths/packages>
- Read-only: <paths/packages>
- Never change: <generated, vendored, or otherwise excluded paths>
- Maximum batch size: <count or scope limit>

## Instructions

1. Read the task-specific actuator skill at `<path-to-skill>/SKILL.md` and follow it. The skill owns the task judgment and validation rules.
2. Read the current memory file below. Apply standing feedback that is relevant to this run.
3. Inspect the selected target and surrounding code. Follow established patterns; do not invent a new architecture.
4. Make only the smallest change that moves the measured state toward the set point.
5. Run the agreed validation. Do not claim unrun checks passed.
6. Stop and report a blocker if the target is unsafe, ambiguous, out of scope, or cannot be validated. Do not substitute a different target unless the controller policy allows it.
7. Commit the change only if this workflow explicitly grants commit permission. Never push, open or edit a PR, modify secrets, or change workflow permissions unless this task explicitly grants that permission.
8. Format the final response using `<response-template-path>`; the workflow may use it as the PR body.

## Disturbances and Feedback

Tolerate these expected changes outside the loop: <disturbances>.

Do not act on: <known noise, false positives, or exclusions>.

## Memory / Standing Feedback

<memory contents>

## Validation

Run:

```sh
<commands>
```

Report each command and its actual result. If validation cannot run, state why and what remains unverified.
