# Skill alignment workflow

Use this runbook when the user asks to **re-align skills**. The goal is to compare vendored skills with their credited upstream sources, show local and upstream drift, then sync only what the user approves. Candidate review is part of every alignment session, but adding candidates remains an explicit user decision.

## 1. Inspect the workspace

- Confirm the repository root and current branch.
- Check `git status --short --branch`. If the working tree has changes, do not overwrite or mix them with alignment work. Report the state and ask how to proceed.
- Read repository-specific instructions.
- Use the `metadata.credits` entries in each vendored `skills/**/SKILL.md` as the source registry. A credit can name a different upstream skill path or repository from the local directory name; follow the recorded URL.

## 2. Build the comparison before changing files

Run `scripts/align_skills.sh`. Its default report is:

```text
/tmp/opencode/skill-alignment-YYYY-MM-DD.md
```

The report compares each credited file and support directory across:

1. **Recorded baseline** — the source commit stored in that credit's alignment metadata.
2. **Local copy** — the current vendored content, including any local adaptations and extra files.
3. **Current upstream** — the current source branch head fetched for this run.

Read the complete report. Summarize meaningful differences and point out missing or extra support files. Treat local adaptations as intentional until the user decides otherwise. A file being different is not itself permission to replace it.

Present the report and proposed sync scope to the user. Do not edit skill files, metadata, or source-controlled docs until the user approves the sync scope.

## 3. Review external candidates

Always review eligible, stable skills in the credited source repositories that are not represented by an existing credit. Follow the existing candidate-scope decisions: review Matt Pocock, t3dotgg, Humanlayer, and JuliusBrussee candidates; exclude upstream `in-progress` skills and do not expand Cursor's `pstack` collection beyond the already credited `unslop` skill unless the user explicitly reopens that scope. Candidate review is a separate decision phase from syncing existing skills.

For each candidate under consideration:

- Identify the author/organisation and link its exact source path.
- Summarize its purpose, supporting files, maturity, dependencies, and overlap with local skills.
- Ask about candidates **one at a time with the question tool**. Offer add, skip, or defer as appropriate, with a recommendation.
- Never add a candidate based only on its presence upstream. Ask the user to confirm the set of candidates to add before importing them.

Do not repeatedly ask about a candidate the user has already explicitly skipped in this session. A deferred candidate remains open for discussion if relevant.

## 4. Sync approved changes

After approval:

- Create a dated `chore/realign-skills-YYYY-MM-DD` branch from the intended base if the user has not specified another branch.
- Preserve local edits and local-only supporting files by default. Port approved upstream changes around local adaptations; stop and ask when a real conflict changes behavior or content materially.
- Do not remove local files or metadata unless the user explicitly approves that removal.
- Update alignment date/commit metadata for source entries the user approved as reviewed against the fetched source head. Interpret alignment metadata as **last reviewed against this source head**, not as proof that local contents are byte-identical to upstream.
- Add approved external candidates under the placement the user chooses, preserving attribution and required support files. Adapt for local conventions without silently dropping source behavior.
- Update the README and license attribution when newly added skills require it.
- Do not push unless asked.
- Commit changes in reviewable logical commits. Do not commit until changes have been checked and the user has approved the scope.

## 5. Verify and report

- Check `git diff --check`.
- Verify frontmatter names match skill directory names and all relative references resolve.
- Run relevant available validation, especially for imported scripts or executable templates.
- Confirm the report and changes agree, summarize files changed, list verification results, and report branch and commit state.
