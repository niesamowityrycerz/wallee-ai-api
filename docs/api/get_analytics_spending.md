# GET Analytics — daily spending

Returns a **time series** of total spending per **calendar day** for the authenticated user, for a single **currency** and inclusive **date range**. Intended for line or bar charts (for example daily spending over a week).

Aggregation matches **[GET Transactions summary](get_transactions_summary.md)**: only transactions with **`status: ready`**, a **non-null `amount`**, **`transaction_date`** on the given day within the range, and the requested **`currency`** are summed. The **[GET Transactions](get_transactions.md)** list may include other statuses; those rows **do not** contribute to `total` here.

## Endpoint

```
GET /api/v1/users/:user_id/analytics/spending
```

## Authentication

Uses **DeviseTokenAuth** token-based authentication. All four headers are required on every request.

| Header         | Description                    |
|----------------|--------------------------------|
| `access-token` | Token returned after sign-in   |
| `token-type`   | Always `Bearer`                |
| `client`       | Client ID returned after sign-in |
| `uid`          | User's email address           |

## Path parameters

| Parameter | Type   | Required | Description                  |
|-----------|--------|----------|------------------------------|
| `user_id` | string | Yes      | ID of the authenticated user |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

## Query parameters (required)

All three parameters are **required** on every request. Omitting any of them fails validation.

| Parameter    | Type   | Description |
|--------------|--------|-------------|
| `currency`   | string | Must be **uppercase** and one of: `PLN`, `USD`, `EUR`, `GBP`. |
| `start_date` | string | Inclusive range start, format **DD-MM-YYYY** (e.g. `05-04-2026`). |
| `end_date`   | string | Inclusive range end, format **DD-MM-YYYY**. Must be **greater than or equal to** `start_date`. |

### Client-side date presets

The API does not accept named ranges (`last 7 days`, etc.). The client should compute `start_date` and `end_date` in **DD-MM-YYYY** the same way as for **[GET Transactions](get_transactions.md)**.

### Aggregation semantics

- **`transaction_date`** must fall **on or between** `start_date` and `end_date` (inclusive), using the same calendar interpretation as the transaction list filters.
- Rows with a **missing** `transaction_date` are not included (they cannot match the date range).
- **`amount`** is summed per day; transactions with **null** `amount` are excluded.

## Example request

```
GET /api/v1/users/123/analytics/spending?currency=PLN&start_date=01-04-2026&end_date=07-04-2026
```

## Response

### 200 OK

```json
{
  "currency": "PLN",
  "start_date": "2026-04-01",
  "end_date": "2026-04-07",
  "points": [
    { "date": "2026-04-01", "total": 0 },
    { "date": "2026-04-02", "total": 45.9 },
    { "date": "2026-04-03", "total": 0 },
    { "date": "2026-04-04", "total": 120.5 },
    { "date": "2026-04-05", "total": 12 },
    { "date": "2026-04-06", "total": 88.25 },
    { "date": "2026-04-07", "total": 0 }
  ]
}
```

#### Field reference (root)

| Field        | Type   | Description |
|--------------|--------|-------------|
| `currency`   | string | Echo of the requested currency (uppercase ISO code). |
| `start_date` | string | Inclusive range start as **ISO 8601** calendar date `YYYY-MM-DD`. |
| `end_date`   | string | Inclusive range end as **ISO 8601** calendar date `YYYY-MM-DD`. |
| `points`     | array  | One object per calendar day from `start_date` through `end_date`, inclusive; see below. |

#### `points[]` items

| Field   | Type   | Description |
|---------|--------|-------------|
| `date`  | string | Calendar day **ISO 8601** `YYYY-MM-DD`. |
| `total` | number | Sum of included **`amount`** for that day in the requested currency. **0** when there is nothing to sum. |

**Ordering:** `points` is sorted by `date` **ascending** with **no gaps**: every consecutive calendar day in the inclusive range appears exactly once. The length of `points` equals the number of days in that range.

### 422 Unprocessable Entity

Returned when query parameters are missing, invalid, or fail validation (e.g. `end_date` before `start_date`). Errors use the same shape as **[GET Transactions](get_transactions.md)**.

```json
{
  "errors": {
    "currency": ["must be uppercase"],
    "start_date": ["must be in DD-MM-YYYY format"],
    "end_date": ["must be greater than or equal to start_date"]
  }
}
```

The exact keys and messages depend on what failed validation. Multiple fields may be present at once.

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
