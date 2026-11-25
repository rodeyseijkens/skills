---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
metadata:
  credits:
    - skill: implement
      author: Matt Pocock
      organisation: mattpocock
      url: "https://github.com/mattpocock/skills/blob/main/skills/engineering/implement/SKILL.md"
      alignment:
        date: "2026-11-25"
        commit: "6f7f7831a625f040a8e06a0e7954826b87ce775a"
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "code-review" to review the work.

Commit your work to the current branch.
