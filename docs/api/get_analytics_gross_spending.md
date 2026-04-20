# GET Analytics — gross spending (net, VAT, gross per day)

Returns a **time series** of **net spending**, **VAT**, and **gross spending** per **calendar day** for the authenticated user, for a single **currency** and inclusive **date range**. Intended for charts that compare net amounts and tax (for example stacked or grouped bars per day).

This endpoint is only available when the user’s **[GET User setting](get_user_setting.md)** has **`show_vat_details: true`**. Otherwise the server responds with **403 Forbidden**.

Aggregation builds on **[GET Analytics — daily spending](get_analytics_spending.md)**: only transactions with **`status: ready`**, a **non-null `amount`**, **`transaction_date`** on the given day within the range, and the requested **`currency`** are considered. Additionally, **only transactions that have at least one VAT line** (`transaction_vat_components` row) are included.

Per included transaction:

- **`gross_total`** for the day sums **`amount`** (same gross notion as daily spending).
- **`vat_total`** for the day sums **`total_vat`**, treating **null** as **0**.
- **`net_total`** for the day sums **`amount - COALESCE(total_vat, 0)`** per transaction.

Days with **no** qualifying transactions still appear in **`points`** with **zeros** for all three fields.

## Endpoint

```
GET /api/v1/users/:user_id/analytics/gross_spending
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

The API does not accept named ranges (`last 7 days`, etc.). The client should compute `start_date` and `end_date` in **DD-MM-YYYY** the same way as for **[GET Analytics — daily spending](get_analytics_spending.md)**.

## Example request

```
GET /api/v1/users/123/analytics/gross_spending?currency=PLN&start_date=01-04-2026&end_date=07-04-2026
```

## Response

### 200 OK

```json
{
  "currency": "PLN",
  "start_date": "2026-04-01",
  "end_date": "2026-04-07",
  "points": [
    {
      "date": "2026-04-01",
      "net_total": 100.0,
      "vat_total": 23.0,
      "gross_total": 123.0
    },
    {
      "date": "2026-04-02",
      "net_total": 0.0,
      "vat_total": 0.0,
      "gross_total": 0.0
    }
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

| Field         | Type   | Description |
|---------------|--------|-------------|
| `date`        | string | Calendar day **ISO 8601** `YYYY-MM-DD`. |
| `net_total`   | number | Sum of **`amount - COALESCE(total_vat, 0)`** for included transactions that day. **0** when there is nothing to sum. |
| `vat_total`   | number | Sum of **`total_vat`** for included transactions that day (null treated as **0**). **0** when there is nothing to sum. |
| `gross_total` | number | Sum of **`amount`** for included transactions that day. **0** when there is nothing to sum. |

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

Returned in either case:

- `user_id` in the path does not match the authenticated user, or
- the authenticated user’s **`show_vat_details`** is **not** `true` (see **[PATCH User setting](patch_user_setting.md)** / **[GET User setting](get_user_setting.md)**).

```json
{ "error": "Forbidden" }
```
