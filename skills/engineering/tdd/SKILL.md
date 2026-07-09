---
name: tdd
description: Test-driven development — write a failing test, make it pass, repeat at a pre-agreed seam. Test only at seams you and the user agreed on, with expected values from an independent source of truth. Use when the user wants to build features or fix bugs test-first, mentions "red-green", or wants integration tests.
---

# Test-Driven Development

The red → green loop is the part of TDD that earns its place in `SKILL.md`; the rest is reference, held alongside it so the agent can reach for the rules on demand.

## The loop

```
RED   → write a test that fails
GREEN → write the smallest code that makes it pass
REPEAT
```

Test only at pre-agreed **seams** — places in the code where a test can pin behaviour without reaching past a public interface into internal structure. Confirm the seams with the user before any test is written; a test that lands somewhere new is a test that breaks the wrong thing on the next refactor.

## Rules of the loop

- **One test, one cycle.** Never write a batch of tests before any implementation lands; the tests would describe imagined behaviour, not actual.
- **Vertical slices.** One test → one piece of implementation → next test. The slice is end-to-end through every layer, not a horizontal band of one layer.
- **Smallest code to pass.** No speculative features, no scaffolding for tests not yet written.
- **Behaviour, not implementation.** Tests exercise public interfaces. If renaming an internal function breaks a test, the test was wrong.
- **Independent source of truth for expected values.** An expected value that is recomputed the way the code computes it passes by construction and gives zero confidence — see [tests.md](tests.md).
- **Refactor at green, never at red.** Refactoring belongs to the review stage (see `code-review`), not the TDD loop.

## Anti-patterns

### Horizontal slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" — treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behaviour, not _actual_ behaviour.
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behaviour.
- Tests become insensitive to real changes — they pass when behaviour breaks, fail when behaviour is fine.
- You outrun your headlights, committing to test structure before understanding the implementation.

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behaviour matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

### Tautological tests

A tautological test is one whose assertion is recomputed the way the code computes it — so it passes by construction and tells you nothing. It looks like a test, reads like a test, and the only thing it proves is that the code does what the code does.

```typescript
// BAD: tautological — the "expected" value is the same expression the code uses
test("total is sum of line items", () => {
  const items = [{ price: 10 }, { price: 20 }, { price: 30 }];
  const total = items.reduce((s, i) => s + i.price, 0);
  expect(total).toBe(items.reduce((s, i) => s + i.price, 0)); // tautology
});

// GOOD: expected value comes from an independent source of truth
test("total is sum of line items", () => {
  const items = [{ price: 10 }, { price: 20 }, { price: 30 }];
  expect(totalOf(items)).toBe(60);
});
```

Distinct from the implementation-coupling anti-pattern covered in [tests.md](tests.md): there the test is *bound to* the implementation; here the test is *vacuous*. Different diagnostic, different cure — the cure for a tautological test is to source the expected value from somewhere the code did not.

### Test without a seam

A test that reaches past a public interface (queries the DB to verify a function, mocks an internal collaborator, asserts on call counts) is not testing behaviour — it is testing structure. The test will break on the next refactor that the user did not ask you to avoid.

**Defence**: confirm seams with the user before writing the first test. If a behaviour you want to test has no seam, stop and ask: should one be added, or is the test the wrong shape?

## Files

- [tests.md](tests.md) — good and bad tests, with implementation-coupling examples.
- [interface-design.md](interface-design.md) — designing the interfaces tests will pin.
- [mocking.md](mocking.md) — when and how to mock.
- [deep-modules.md](deep-modules.md) — designing testable modules: small interface, deep implementation.
