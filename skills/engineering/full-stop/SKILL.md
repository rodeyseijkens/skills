---
name: full-stop
description: Take a change to a PR that is ready for the user to merge, without merging it.
disable-model-invocation: true
metadata:
  credits:
    skill: full-stop
    author: Theo Browne
    organisation: t3dotgg
    url: "https://github.com/t3dotgg/tstack/blob/main/skills/full-stop/SKILL.md"
---

# Full Stop

Trigger this if the user says **full stop**, even as a closing "Full stop." that
reads like emphasis. The trigger means the user is not watching this thread:
your updates go unread until long after you stop. You own the work from its
current state to a PR that is ready to merge.

Finish the change, prove it, review it, file it, and babysit it. Then stop. You
never merge.

## Permission

A "full stop" request is the permission for the work below. It grants:

- Creating a branch when you are on the default branch.
- Rebasing and updating this task's branch, including `--force-with-lease`
  against the head SHA observed before the rebase.
- Using the test methods that Proof needs, without asking first.

### Testing permission

If a project file or other instruction says to ask before a test method, or to
leave testing to the user, this request replaces that rule for this task. That
includes ask-first rules for computer use, browser automation, simulators and
devices, running the app or a dev server, screenshots, and visual checks.

Rules about *how* to test still apply: follow rules that name the correct
command, fixture, or check. This permission only removes the ask-first or
leave-it-to-the-user step. If a preferred method cannot prove the change, use a
gated method under this permission.

It covers only the tests needed for this task. It does not add permission for
production changes, data deletion, or anything outside the repository, and it
does not bypass a harness or system approval prompt.

## No merging

You may commit, push, rebase, fix conflicts, and use `--force-with-lease` on
this task's branch. Never merge, enable auto-merge, enter a merge queue, push to
the default branch, bypass branch protection, or delegate those actions.

Disable existing auto-merge and remove the PR from any merge queue before work
begins; check again before each push. Report these changes. If you cannot
prevent automatic merging, report the blocker before proceeding.

## Steps

1. **Finish the change.** Complete the goal from the user's request with the
   smallest change that works. Fix the case that happened, not every case that
   could. If you are on the default branch, create a branch first.
2. **Prove it.** Get proof for every change you made. See Proof.
3. **Review it.** Run `code-review` on the changes since the branch point. If
   the user's request explicitly names council, run its workflow as a second
   review; you are not calling a user-invoked skill on your own. If the change
   is high-risk and council was not named, recommend `/council` in the handoff
   instead. Fix real findings and re-review the final diff.
4. **File the PR** with the `pr` skill. Rebase onto the latest default branch
   first. The description carries one short line on how the change was proven.
5. **Babysit the PR** with the `babysit-pr` skill. Fix real findings and CI
   failures. Get proof for each fix before you push it.
6. **Stop at the gate.** Report the handoff. Never merge.
7. **Report** in your final message: the PR link, the final head SHA, your
   proof, the review outcome, each decision you made for the user, and the
   remaining risk.

Stay active from step 1 to step 7. If you end your turn while checks or bots are
pending, the work stops, because nobody will prompt you again. Wait with the
watcher from `babysit-pr`, so something wakes you when the PR changes. In T3
Code that is `watch_pull_request`; everywhere else it is `scripts/pr-wait`.

## Proof

Proof is evidence you observed yourself in this session: command output, a
reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the original failure, apply the fix, then watch the same
  reproduction pass.
- Run the checks that the repo's CI runs (typecheck, lint, tests).
- Add one focused test that fails without the fix, when the behavior has none
  and the repo has a test setup.
- For UI and runtime behavior, run the app and look at the change. Green mocked
  tests do not prove that the user experience works. Attach screenshots to the
  PR when they help and you have a way to upload them.

When you cannot find a way to prove a change, you do not have full confidence.
Ask the user.

## Readiness gate

Full confidence means all of these are true on the latest commit:

- Your proof covers every change in the diff.
- Required checks are green.
- Review bots have finished, and each finding is fixed or dismissed with a
  written reason.
- No human review still requests changes.
- The branch is up to date with the default branch, and GitHub reports it as
  mergeable.

Fetch the target branch and check the live PR's head, base, checks, reviews,
and mergeability. Confirm it is open, not a draft, and not set to merge without
the user. If someone else merged it, report that instead.

- **Ready to merge:** the gate passes. Leave the PR open and unmerged.
- **Waiting for required approval:** only human approval remains. Confirm that
  this is the actual blocker.
- **Blocked:** explain what prevents readiness, what you tried, and what is
  needed. Use the harness's question tool.

In T3 Code, call `unwatch_pull_request` before the handoff or a question.

## Asking the user

A question in a normal message goes unseen, and the thread looks done. To ask
the user something, use the harness's question tool so the thread shows that it
is waiting. Put all the context in the question: the PR link, what blocks you,
and the options with your recommendation first.

Ask only when you cannot continue alone:

- You cannot prove the change.
- The readiness gate cannot pass, and you cannot fix that yourself.
- The next step is outside the grant above: deleting data, touching production,
  changing things outside the repo, closing a PR, or force-pushing any other
  branch.
- The goal is ambiguous in a way that changes the result.
- Another PR makes this one obsolete.

Decide everything else yourself with sensible defaults, and list those decisions
in the report.

If no question tool is available, or the tool returns no answer, take the safe
path: leave the PR open and unmerged, and start your final message with the
question.
