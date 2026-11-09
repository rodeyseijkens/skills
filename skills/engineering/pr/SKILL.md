---
name: pr
description: "Write a problem-first pull request title and body with diagrams, evidence, and merge danger, then open the pull request when asked."
metadata:
  credits:
    skill: show-me
    author: Dex Horthy
    organisation: Humanlayer
    url: "https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md"
---

# PR

Write PR copy a human reviewer can scan in twenty seconds. Lead with the problem.
Then cluster the change by concern. The diff is the source of truth; commit
messages are clustering hints.

The problem-first opening and model attribution are adapted from
[t3dotgg/tstack](https://github.com/t3dotgg/tstack)'s `file-pr` (MIT).

Before writing, check whether a PR for this branch already exists. Review the
diff locally against the base branch to make sure its contents match the goal.

## Range

Default base is the repo's default branch (`origin/HEAD`, else `main`). The user
can name another. The range is `base...HEAD`. Uncommitted files are not in the
PR: mention them, leave them out of the copy.

Done when the base and range are known.

## Map

Read the log and the diff for the range. Lockfiles and generated files are not
narrative; if they are the only change they go under Chore.

Cluster by concern. Name each cluster from the work. Use the natural number of
clusters. Deps, upgrades, and generated files go under Chore.

Done when every change in the range sits in exactly one named cluster.

## Write

Open with the problem, not an inventory of implementation. Titles usually become
commit messages, so follow the repository's title conventions and look at
recently merged PRs and Git history for examples.

BAD

> ❌ perf(server): negotiate permessage-deflate on the websocket

GOOD

> ✅ perf(server): cut websocket frame size by 70%+ with gzipping

BAD

> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD

> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

Output the title and body in this shape:

```markdown
## Summary

<1–3 sentences: the problem in the user's terms, then the outcome.>

<diagram, diff-sketch, or tree>

## Evidence

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <one-word description>

<optional: potential ramifications of merge>

Created with <model> in <harness>.
```

**PR Title:** one line, concrete. Name the clusters if several, or the one change
if one. Title the PR after the clusters, not the template sections.

Skip all preambles and keep prose brief. Use the user's domain language from
`GLOSSARY.md`.

### Summary

The first paragraph is the problem the user had, in their words, and what is now
true. It must stand alone: a reader who stops there knows why the PR exists. Then
pick the smallest view that makes the key point clear. Use the cluster map from
above as the outline; each visual should name a real change in the diff.

- Show logic or an algorithm as pseudocode:

```text
on(save)
  if content is unchanged
    return cached result
  write new content
  return fresh result
```

- Show runtime control flow as a call tree:

```text
submitForm
  createSession
    persistPrompt
    launchAgent
  navigateToSession
```

- Show UI structure as a component tree, including state and module boundaries
  that matter:

```text
<SessionPage> (apps/example/src/routes/session.tsx)
  useSessionEvents()
  <SessionToolbar>
    <RunSkillButton> (packages/ui)
```

- Show file responsibility or a broad refactor as a shallow file tree:

```text
src/
├── commands/       # parses user actions
├── sessions/       # owns session state
└── transport/      # sends API requests
```

- Show component interaction, control flow, or data flow with Mermaid:

```mermaid
sequenceDiagram
    participant User
    participant UI
    participant Daemon
    User->>UI: choose command
    UI->>Daemon: send expanded prompt
    Daemon-->>UI: stream result
```

- Use `diff` when the point is what changes and the surrounding shape already
  exists. Match the diff shape to the topic.

For a component change:

```diff
 <SessionPage>
   useSessionEvents()
   <SessionToolbar>
+    <RunSkillButton />
   <SessionTimeline>
+    <SkillResultCard />
```

For a file-layout change:

```diff
 src/
 ├── commands/
+│   └── show-me.ts       # expands the slash command
 ├── sessions/
-└── transport.ts
+└── transport/
+    ├── client.ts
+    └── stream.ts
```

For a call-tree or call-stack change:

```diff
 submitForm
   createSession
     persistPrompt
+    expandSkillMention
     launchAgent
-  navigateToSession
+  navigateToSession
+    subscribeToEvents
```

For a state or control-flow change:

```diff
 on(save)
-  write content
+  if content is unchanged
+    return cached result
+  write new content
+  invalidate cache
```

- Show the whole block when most of it is new, when omitted context would hide
  ownership or order, or when the user needs a copyable target shape:

```ts
function expandSkill(command: string): string {
  const skillName = command.slice(1);
  return `use the ${skillName} skill`;
}
```

Place each visual next to the short text it supports. Keep only the calls, files,
props, states, and boundaries needed to answer the user's current question. Use
one or several; it is unlikely you need all of them.

### Evidence

Concrete evidence that the change works. Show a before and after.

Screenshots are S-tier when the environment is set up for it and the change is
visual.

Execution-based evidence is A-tier: test results, console output. Show the exact
test that now fails and passes, using pseudocode.

### Merge Danger

Describe whether it is a one-way or two-way door. You can walk back through
two-way doors, but not one-way doors. A PR that is cheap to roll back is lower
risk. Changes that involve destructive actions or hard-to-reverse decisions are
one-way doors.

The blast radius is the potential impact or scope of the changes introduced by
this PR. Consider all possibilities, such as layout shift, breakage for
consumers, or mobile responsiveness.

### Attribution

End the description with the public model name and harness that made the changes,
for example `Created with <model> in <harness>.` Include subagent models that
wrote part of the change. Use the model name the harness reports. If model
identity is unavailable, name the harness without guessing a model.

## Secrets

Before submission, check the title, description, quotes, and attachments for
secrets and private details.

## Unslop

Call the Skill tool with "unslop" on the title and body. Done when the self-audit
finds no remaining AI tells.

## Open

When the user asked to create or open the PR, run `gh pr create` with that title
and body against the base. Open a real PR rather than a draft so review bots run.
If `gh pr create` fails because the GraphQL rate limit is used up, open it
through REST with `gh api repos/<owner>/<repo>/pulls -f title=... -f head=...
-f base=... -F body=@<file>`.

Done when the command prints the PR URL. When they only asked for copy, stop after
Unslop. If the user also asked to babysit it, continue with the `babysit-pr`
skill. Do not post a follow-up PR comment unless it serves the user's request;
when a comment is needed, use `leaving-pr-comments`.
