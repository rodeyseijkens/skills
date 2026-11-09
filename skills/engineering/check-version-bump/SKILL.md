---
name: check-version-bump
description: Audit dependency version bumps before committing: delegate each bump to a fresh research subagent, then aggregate blockers, behavior changes, and safe updates into one report.
disable-model-invocation: true
---

# Check Version Bump

Audit a **bump set** before it is committed. The report answers one question: can these version bumps be committed, and if not, what must change first?

These leading words run through the audit:

- **Bump set**: every version, rev, or digest the author intended to move, not everything that moved in the resolved graph.
- **Entry**: one dependency or pin in the bump set.
- **Resolved graph**: the lockfile, lock, or pin file that records the exact versions, revs, or digests behind the manifests.
- **Churn**: movement the author did not target: transitive dependencies, nested pins, and anything the intended bump dragged with it. Note it and leave it out of the bump set.
- **Blocker**: a bump that breaks install, evaluation, type-check, build, or runtime.
- **Behavior change**: a bump that still builds but changes a default or a semantic.
- **Safe**: no breaking change reaches this repo's usage.

## Process

### 1. Extract the bump set (orchestrator)

```sh
git status --short
git diff --stat
```

Open every changed manifest and pin file, plus the resolved graph that records them. Record each entry as **name**, **from → to**, class, and **direct or transitive**.

The bump set is what the author targeted. Movement beneath a targeted entry is churn; note it and leave it out. When the resolved graph is the only record of the change, the entries the manifest names are the target, and everything beneath them is churn.

Classify each entry by its ecosystem's version scheme:

- **Release version**: **major**, **minor**, **patch**, or the scheme's equivalent. Treat any pre-1.0 change as major for risk.
- **Pin bump**: a rev, digest, or tag that moved. The range between the two pins is the changelog; a bump that crosses a release boundary inherits every breaking change in between.

Mark **runtime** versus **dev-only**: whether the dependency reaches the built outputs or only development tooling.

**Done when** every intentional version change is in the bump set with a class, and churn is explicitly excluded. This inventory is the dispatch list for step 2.

### 2. Delegate research per entry (subagents)

Delegate each bump-set entry to one research-only subagent, each started with a fresh context window. Dispatch all of them together in the foreground, wait for every report, and aggregate.

Give each agent:

- the entry: name, old → new, class, direct or transitive, runtime or dev-only;
- the repo root and the file that records the bump;
- the release-note depth for its class.

Each agent returns:

- **Breaking changes** — every breaking change, removed or renamed API, changed default, new peer, engine, or runtime requirement, and new required upstream service version, with a cited URL. For a major, pre-1.0 minor, or pin bump, read the upstream releases, changelog, migration guide, and the change range between the pins; confirm any tag still points where the resolved graph says. For a minor or patch, scan for deprecations, security fixes, and default changes. A clean entry is a cited "none found".
- **Distribution notes** — when the entry is a distribution or platform (package set, base image, runtime, framework), the options and defaults this repo uses that its release notes changed.
- **Repo reach** — for each breaking change, the `file:line` call sites and configs that reach it. Follow configs, CLIs, plugins, re-exports, generated code, build definitions, and downstream packages. If the entry is unused, say so with the search evidence.
- **Requirements** — new peer ranges, engine constraints, language editions, or minimum runtimes, with the source that declares them.
- **Verdict** — **Blocker** (name the replacement API or exact option change), **Behavior change** (name the test and scenario), or **Safe** (the changed API is not reached).
- **Overlap signals** — shared call sites, root causes, or runtimes another entry might also touch.

Constraints in every prompt:

- research only: read the tree, run read-only searches and fetches, inspect published types or source;
- no edits, installs, builds, or changes to the resolved graph;
- cite every claim; an uncited break is a guess;
- return only the structured report.

**Done when** every entry has a report with cited breaking changes, repo reach or unused evidence, requirements, a verdict, and overlap signals.

### 3. Aggregate the delegated reports (orchestrator)

Collect every report. Group entries that share a call site, root cause, or runtime; they are reported as one item. Resolve contradictions and uncited claims against the cited source. Re-dispatch or research directly any entry whose report is missing or unusable. The orchestrator owns the final classification; a subagent's verdict is a proposal.

**Done when** every entry in the bump set has one final verdict, overlaps are grouped, and every report is accounted for.

### 4. Check toolchain consistency (orchestrator)

A dependency bump is also a toolchain bump. The reports supply each entry's new peer, engine, and runtime requirements; compare them against every place the toolchain is pinned: version files, the resolved graph, CI, container images, and contributor docs.

- Every new peer, plugin, engine, or runtime requirement against the installed version.
- Every compatibility marker that records the version a system was provisioned at (a state or schema version): it does not track the bump, so leave it unless the user is deliberately migrating.

A pre-release or alpha runtime or pin is a blocker until the user confirms it is intentional.

**Done when** runtime, declared type versions, and toolchain agree, or every mismatch is listed with the file that disagrees.

### 5. Verify only when safe (orchestrator)

Research agents never install or build; verification stays here. With no blockers, run the repo's own commands. Read the config rather than assuming names. Run the cheapest first: consistency, then static checks, then build, then tests.

For each build target the bump reaches (host, image, platform, package), verify that target, not only the default one. Record every command and its outcome.

With blockers, stop before installing or evaluating. Installing a known-broken combination spends time and rewrites the resolved graph further. State which blocker prevented verification.

**Done when** the verification commands ran and their outcomes are recorded, or the report names the blocker that made verification unsafe.

### 6. Report (orchestrator)

Lead with the verdict. Then use three tables so every entry lands in exactly one:

```md
## Verdict
Commit / hold / fix first, in one or two sentences.

## Blockers
| Dependency / pin | Bump | Evidence | Fix |

## Behavior changes
| Dependency / pin | Bump | Test |

## Safe
| Dependency / pin | Bump |

## Recommended commit path
1. Hold or revert …
2. Fix …
3. Run …
```

Every blocker row cites a `file:line` or a command output, and names the replacement. Behavior-change rows name the test that would catch the regression. The safe table accounts for the remainder of the bump set.

**Done when** the user can decide from the report alone, every blocker has a concrete remediation, and no entry is missing from all three tables.

## Reference

- **Major releases**: the project's migration guide beats the changelog.
- **Tooling majors**: init behavior and rule renames matter even when the runtime API does not. Expect formatting churn from formatter and linter majors.
- **Drivers and clients**: read the upgrade section of the README, not only the releases. Typing, date handling, and transaction semantics are the usual breaks.
- **Types-only packages**: match the runtime they describe; newer types can describe APIs the runtime does not have.
- **Unused pins**: declared but never consumed is safe. Confirm by searching for every reach before calling it.
- **Distribution bumps**: the package set or platform's own release notes list the option and default changes that no package changelog carries.

Cite the release note, migration guide, or commit range for every breaking claim. Inferring a break from a version number is a guess, and the report is supposed to remove guesses.
