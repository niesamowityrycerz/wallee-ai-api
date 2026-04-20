# GET Analytics — spending by tag (pie chart)

Returns **spending totals grouped by tag** for the authenticated user, for one **currency** and inclusive **date range**, plus an **untagged** bucket. Intended for pie or donut charts.

Transaction inclusion rules match **[GET Analytics — daily spending](get_analytics_spending.md)** / **[GET Transactions summary](get_transactions_summary.md)**: **`status: ready`**, **non-null `amount`**, **`transaction_date`** in range, requested **`currency`**. Tag **`id`** and **`name`** match tags on the user’s **account** (same as **[GET Tags](get_tags.md)**).

## Endpoint

```
GET /api/v1/users/:user_id/analytics/spending_by_tag
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

Same as **[GET Analytics — daily spending](get_analytics_spending.md)**.

| Parameter    | Type   | Description |
|--------------|--------|-------------|
| `currency`   | string | Must be **uppercase** and one of: `PLN`, `USD`, `EUR`, `GBP`. |
| `start_date` | string | Inclusive range start, format **DD-MM-YYYY**. |
| `end_date`   | string | Inclusive range end, format **DD-MM-YYYY**. Must be **greater than or equal to** `start_date`. |

## Aggregation semantics

### Multi-tag transactions (equal split)

If a transaction has **multiple tags** on the account, its **`amount` is split evenly** across those tags (only account tags count toward the split). Example: **100** with tags *Groceries* and *Transport* contributes **50** to each tag’s `total`.

Therefore **the sum of `segments[].total` plus `untagged_total`** equals the sum of **`amount`** over all included transactions in the range (same scope as daily spending). The pie can treat **untagged** as an extra slice using `untagged_total` / `untagged_transaction_count` if the client wants a full partition.

### `segments`

- One entry per tag with **`total` &gt; 0** after aggregation (tags with zero are omitted).
- Sorted by **`total` descending** (highest first).
- **`transaction_count`**: number of **distinct transactions** that include that tag and contribute to the slice (each such transaction counts **once** toward that tag, regardless of how many other tags it has).

### `untagged`

Transactions that have **no** `transaction_tags` rows are counted only here: **`untagged_total`** (sum of `amount`) and **`untagged_transaction_count`** (row count).

### Account requirement

The user must belong to an **account** (normal for registered users). If `account` is missing, the API responds with **422** and `errors.account`.

## Example request

```
GET /api/v1/users/123/analytics/spending_by_tag?currency=PLN&start_date=01-04-2026&end_date=07-04-2026
```

## Response

### 200 OK

```json
{
  "currency": "PLN",
  "start_date": "2026-04-01",
  "end_date": "2026-04-07",
  "segments": [
    { "tag_id": 5, "tag_name": "Groceries", "total": 320.5, "transaction_count": 12 },
    { "tag_id": 8, "tag_name": "Transport", "total": 89.0, "transaction_count": 4 }
  ],
  "untagged_total": 40.0,
  "untagged_transaction_count": 2
}
```

#### Field reference (root)

| Field                        | Type    | Description |
|------------------------------|---------|-------------|
| `currency`                   | string  | Echo of the requested currency (uppercase). |
| `start_date`                 | string  | Inclusive range start, **ISO 8601** `YYYY-MM-DD`. |
| `end_date`                   | string  | Inclusive range end, **ISO 8601** `YYYY-MM-DD`. |
| `segments`                   | array   | Tag slices; see below. |
| `untagged_total`             | number  | Sum of `amount` for included transactions with no tags. |
| `untagged_transaction_count` | integer | Count of those transactions. |

#### `segments[]` items

| Field               | Type    | Description |
|---------------------|---------|-------------|
| `tag_id`            | integer | Tag primary key (stable id for colors / cache keys). |
| `tag_name`          | string  | Tag display name (same account as **[GET Tags](get_tags.md)**). |
| `total`             | number  | Allocated spending for this tag in the request currency (see equal split above). |
| `transaction_count` | integer | Distinct included transactions that have this tag. |

### 422 Unprocessable Entity

Returned for invalid or missing query parameters (same shape as **[GET Transactions](get_transactions.md)**), or when **`account`** is required but missing:

```json
{ "errors": { "account": ["is required"] } }
```

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
