---
name: leaving-pr-comments
description: Use whenever leaving a comment on GitHub on the user's behalf.
metadata:
  credits:
    - skill: leaving-pr-comments
      author: Theo Browne
      organisation: t3dotgg
      url: "https://github.com/t3dotgg/tstack/blob/main/skills/leaving-pr-comments/SKILL.md"
      alignment:
        date: "2026-10-24"
        commit: "6efae364201abc9d9f07443e9caa461f42e51090"
---

# Leaving PR Comments

Prefix every agent-authored comment left on the user's behalf with this GitHub
note callout:

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <user>**

Actual comment starts here.
```

## Attribution values

- `<model>`: the verified public name of the model that wrote the comment. If the
  harness does not expose a model name, use the harness name. Do not guess.
- `<user>`: resolve with `gh api user --jq .name`. If that returns nothing, fall
  back to `git config user.name`. Ask only when both fail.

## Format rules

Keep the attribution inside the note and the actual reply outside it. The context
line must start with the robot emoji. Do not add a horizontal rule, Setext
underline, heading, signature footer, or a second attribution.

Apply this format to top-level PR comments, inline review comments, replies to
bots or reviewers, and written explanations used before resolving or dismissing
feedback. Do not add it to PR descriptions, commit messages, or text the user
explicitly asked to post verbatim without attribution.

## Secrets

Before posting, check the entire comment, including quoted text and attachments,
for secrets and private details.

## Write the comment

Write in a direct style:

- Lead with the conclusion.
- Cite the relevant code, behavior, check, or reproduction.
- Keep it concise and avoid filler, canned thanks, or status narration.
- Distinguish verified facts from judgment.

Preview the final Markdown before posting so quoting and blank lines render as
shown. After posting, verify that GitHub returned the comment or review URL.
Resolve a review thread only after its response was posted successfully.

## Posting with `gh`

`gh api -f` (raw field) sends its value literally: it does **not** expand an
`@file` argument. `-f body=@comment.md` posts the path itself, not the file
contents. Use `-F` (typed field) for file expansion, or pass the body as JSON
via `--input`:

```bash
# Reply to an inline review comment, body read from a file
gh api -X POST repos/<owner>/<repo>/pulls/<n>/comments/<comment-id>/replies \
  -F body=@comment.md

# Top-level PR comment
gh pr comment <n> --body-file comment.md

# Arbitrary endpoint, body from a file
jq -Rs '{body: .}' comment.md > payload.json
gh api -X PATCH repos/<owner>/<repo>/pulls/comments/<id> --input payload.json
```

After posting, read the comment back and check what actually landed:

```bash
gh api repos/<owner>/<repo>/pulls/comments/<id> --jq .body | head -3
```

A body that is just a path or starts with `@` means the file was not expanded;
fix that comment with `PATCH ... -F body=@comment.md` before resolving the
thread.
