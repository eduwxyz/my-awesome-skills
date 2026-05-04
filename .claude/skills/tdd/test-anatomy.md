# Test Anatomy

## Body shape

Three sections in order — set up, do the thing, check what's observed.

```
test "scheduling a meeting that overlaps an existing one is rejected":
  calendar = open_calendar(owner: alice)
  calendar.book(start: "10:00", end: "11:00")

  result = calendar.book(start: "10:30", end: "11:30")

  assert result.status == "conflict"
```

If setup is more than ~3× the size of action+check, the system depends on too much state, or the test is over-specifying. Build a factory; if the system genuinely needs all that, split it.

## Assertions per test

Real rule: **one behavior per test**. Multiple assertions on the same outcome are fine:

```
test "registering returns a user with id, email, and timestamp":
  u = register(email: "a@b.com")
  assert u.id exists
  assert u.email == "a@b.com"
  assert u.created_at is recent
```

Multiple assertions on **separate** outcomes is the smell — split each into its own test:

```
# Three outcomes hidden in one test → split
test "checkout flow":
  r = checkout(cart)
  assert r.status == "confirmed"           # outcome A
  assert stock_of(product) == initial - 1  # outcome B
  assert email_queue.peek().to == user.email  # outcome C
```

## Verifying through the public surface

Don't reach past the system to peek at storage or internals.

```
# Wrong — bypasses the API
register(email: "a@b.com")
row = db.query("SELECT * FROM users WHERE email = ?", ["a@b.com"])
assert row exists

# Right — uses the API
register(email: "a@b.com")
found = find_user_by_email("a@b.com")
assert found exists
```

If `find_user_by_email` doesn't exist yet, the test is telling you it should.

## Naming

```
✅ deleting_account_revokes_active_sessions
✅ blank_search_returns_recent_first

❌ test_delete
❌ test_calls_payment_service
```

Read the name to a non-engineer. If they can't tell what the system does, rename.
