# Boundaries

Mock at the edge of your system. Never inside it. Prefer fakes to mocks when you can.

## What's an edge

**Edges** (you don't control them): external HTTP APIs, payment/email providers, the clock, randomness, the network, the filesystem (sometimes), the database (sometimes — prefer a test DB).

**Not edges**: classes you wrote, repositories deployed alongside the SUT, your own loggers/buses/caches. Mocking those tests wiring, not behavior.

## Three kinds of doubles

**Stub** — canned response, doesn't track anything. Use when you only need a deterministic input.

```
stub_clock = { now: () => fixed_time("2026-01-01") }
```

**Mock** — records calls so you can assert on them. Justified only when you genuinely need to verify a side effect that nothing else can observe (an actual email going out, an event published externally). Asserting on call counts or order beyond that is [mock leakage](smells.md#bad-test-patterns).

```
mock_email = spy()
register(user)
assert mock_email.send.called_with(user.email, "welcome")
```

**Fake** — a working alternative implementation that satisfies the same interface. **Usually what you want.** Doesn't lock in a sequence of internal calls; refactors don't break tests.

```
class InMemoryCalendar implements Calendar:
  bookings = []
  book(b): if no_overlap: bookings.append(b)
  list():  return bookings
```

A test using a fake reads as a real scenario:

```
cal = InMemoryCalendar()
svc = BookingService(cal)
svc.request_booking(start: "10:00", end: "11:00")
assert svc.upcoming().length == 1
```

The same test with mocks would assert on `mock.book.called_with(...)` — that's wiring, not behavior.

## Designing for fakeability

**Pass dependencies in.**

```
# Testable
process_payment(order, gateway)

# Hard to test
process_payment(order):
  gateway = StripeGateway(env.STRIPE_KEY)
```

**Prefer narrow named operations over generic dispatchers.** `api.fetch_user(id)`, `api.update_user(id, data)` — each independently fakeable. A single `api.request(endpoint, opts)` forces every fake to switch on URL.

## Anti-patterns at the edge

- **Mocks of types you own** — you're testing wiring inside your system.
- **Asserting on call sequences** — order is implementation detail.
- **Mocks with logic** (`if input == "x" return y`) — that's a fake pretending to be a mock. Make it a real fake.
- **Partial mocks of real objects** — admits the helper is too important to ignore but inconvenient to test through. Restructure.
