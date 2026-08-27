# Good and Bad Tests

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

## Tautological tests

A test whose **expected value is recomputed the way the code computes it** passes by construction and gives zero confidence. It looks like a test, reads like a test, and the only thing it proves is that the code does what the code does.

Distinct from the implementation-coupling pattern above: there the test is *bound to* the implementation (it will fail when internal structure changes); here the test is *vacuous* (it cannot fail because the assertion mirrors the code).

```typescript
// BAD: tautological; the assertion is the same expression the code uses
test("total is sum of line items", () => {
  const items = [{ price: 10 }, { price: 20 }, { price: 30 }];
  const total = items.reduce((s, i) => s + i.price, 0);
  expect(total).toBe(items.reduce((s, i) => s + i.price, 0));
});

// GOOD: expected value from an independent source of truth
test("total is sum of line items", () => {
  const items = [{ price: 10 }, { price: 20 }, { price: 30 }];
  expect(totalOf(items)).toBe(60);
});
```

The cure is to source the expected value from somewhere the code did not: a hand-computed constant, a property of the input the code cannot see, a value fetched from an independent system. If the assertion could be mechanically rewritten to match the production expression, the test is tautological.
```
