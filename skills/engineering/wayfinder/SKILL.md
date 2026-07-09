---
name: wayfinder
description: Wayfind a huge chunk of work — chart a route through a foggy problem when the build is too big for one session. Produces a map of decisions, not deliverables, on the repo's issue tracker.
disable-model-invocation: true
---

# Wayfinder

A fog-of-war map for a chunk of work too big for one agent session to hold. Wayfinding charts a *route* to a destination — it doesn't charge at building it. The map is **decisions, not deliverables**; it's done when nothing is left to decide before someone builds the thing.

The map lives on the repo's issue tracker as a single `wayfinder:map` issue whose tickets are its child issues. Sessions load the map at low resolution and zoom into tickets on demand.

The issue tracker and triage label vocabulary should have been provided to you — run `/project-agent-setup` if not.

## Leading words

- **Fog of war** — what we don't yet know about the destination; in-scope work that hasn't been decided.
- **Frontier** — the tickets whose blockers are done; the takeable work.
- **The map** — the wayfinder:map issue and its child tickets.
- **Destination** — the target the work is heading toward; the first thing every session orients to.

## Destination

The first act of wayfinding is naming the **destination** — the thing we're heading toward, in one or two sentences. The destination fixes the scope and shapes every ticket; without it the map is a wish list.

Every session orients to the destination before reading the map. If a ticket doesn't serve the destination, it's out of scope (or a missed destination — flag it).

## Map structure

The `wayfinder:map` issue carries the destination at the top and the four sections below. Tickets are child issues of the map; the map itself only *gists* them and links, never restates.

```
## Destination

<the destination, one or two sentences>

## Frontmatter

<the constraints, vocabulary, and known facts the rest of the map builds on —
 domain glossary terms, ADRs in the area, relevant modules, prior art>

## Not yet specified

<in-scope fog that graduates as the frontier advances. Each entry is a future
 ticket, named in one line. The frontier walks this list downward.>

## Out of scope

<work ruled beyond the destination, closed here, never graduating.>
```

`## Not yet specified` and `## Out of scope` are split because beyond-destination work must not read as takeable frontier. If it's in the first section it's a future ticket; if it's in the second, it's ruled out.

## Tickets

Each child ticket is one of four **types**, tagged `wayfinder:<type>`:

- **`decision`** — a choice to make. "Should auth be session- or token-based?" Has an answer and a few alternatives; resolving it removes fog.
- **`research`** — a question to investigate. Often a `/research` ticket. Resolving it removes fog by bringing back cited findings.
- **`grilling`** — a HITL interview to run. The output is an agreement, not a code change.
- **`task`** — manual work that blocks a decision (provisioning access, moving data, signing up for a service). The one ticket type that *does* rather than decides; earns its place by unblocking a decision.

### HITL and AFK

Every ticket is **HITL** (human in the loop) or **AFK** (agent alone):

- `decision` — HITL. Only a human can decide.
- `research` — AFK (with cited findings handed back for grilling).
- `grilling` — HITL. The whole point is the live exchange.
- `task` — Either. If the human is the one provisioning access, HITL; if a script is the one doing it, AFK.

A HITL ticket only resolves through the live exchange. A grilling agent that answers its own questions has, by definition, broken HITL.

### Blocking edges

Prefer the tracker's **native blocking** relationship. On GitHub, use task lists / `Blocked by #N` links; on GitLab, use the dependency field. Native blocking renders the frontier visually in the tracker's own UI so the human sees what's takeable without opening the map.

The map body uses `## Blocked by` conventions as a fallback when the tracker doesn't support native edges.

### Claim by assignment

A session claims a ticket by **assigning it to the driving dev** — the assignee *is* the claim. The label vocabulary stays clean for `wayfinder:<type>` alone. If you find yourself adding a "claimed" or "in-progress" label, use assignment instead.

## Process

1. **Confirm the destination.** If the human hasn't named one, grill it out — the destination is the first decision and the map cannot start without it.
2. **Open the map issue.** If one doesn't exist, create it as `wayfinder:map` on the tracker, with the four-section structure above.
3. **Breadth-first grill.** Open every section of the problem at once. Surface unknowns; the map is built *down* from fog, not up from tasks. If the breadth-first pass surfaces no fog, the journey is small enough for one session — stop and ask how the human wants to proceed (don't build a map nobody needs).
4. **Seed tickets.** For each fog entry, open a child ticket. Use the type system above. Set blocking edges between tickets where one needs another's answer.
5. **Maintain the map.** When a ticket resolves, update the map: graduated fog is *cleared* from `## Not yet specified` (the decision lives in the ticket, not the map). New fog discovered mid-build gets added to `## Not yet specified` and tracked as a child ticket.

## Plan, don't do

Wayfinder produces **decisions, not deliverables**. The map is done when nothing is left to decide before someone builds the thing. An effort can override this in its Notes (e.g. "wayfinder:map for the auth migration also produces the spec") — but absent an override, the map is the contract, and the build is someone else's job.

## Resolution

Wayfinder is "done" when the map has no more fog and every ticket is resolved. The map issue can then be closed — its child tickets stand on their own as the work that shipped.
