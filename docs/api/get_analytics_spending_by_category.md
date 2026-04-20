# GET Analytics — spending by category (pie chart)

Returns **spending totals grouped by receipt line category** for the authenticated user, for one **currency** and inclusive **date range**, using a **saved category pie config** (see **[GET Category pie configs](get_category_pie_configs.md)**). Intended for pie or donut charts.

Totals are the **sum of `transaction_positions.total_price`** on **ready** transactions that fall in the date range and currency. Only positions whose **`category`** is one of the slugs listed in the saved config are included—there is **no** “rest of spending” or uncategorized bucket (unlike **[GET Analytics — spending by tag](get_analytics_spending_by_tag.md)**).

Transaction scope matches **[GET Analytics — daily spending](get_analytics_spending.md)** for inclusion: **`status: ready`**, **non-null `amount`**, **`transaction_date`** in range, requested **`currency`**.

## Endpoint

```
GET /api/v1/users/:user_id/analytics/spending_by_category
```

## Authentication

Uses **DeviseTokenAuth** token-based authentication. All four headers are required on every request.

| Header         | Description                      |
|----------------|----------------------------------|
| `access-token` | Token returned after sign-in     |
| `token-type`   | Always `Bearer`                  |
| `client`       | Client ID returned after sign-in |
| `uid`          | User's email address             |

## Path parameters

| Parameter | Type   | Required | Description                  |
|-----------|--------|----------|------------------------------|
| `user_id` | string | Yes      | ID of the authenticated user |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

## Query parameters (required)

| Parameter                | Type    | Description |
|--------------------------|---------|-------------|
| `currency`               | string  | Must be **uppercase** and one of: `PLN`, `USD`, `EUR`, `GBP`. |
| `start_date`             | string  | Inclusive range start, format **DD-MM-YYYY**. |
| `end_date`               | string  | Inclusive range end, format **DD-MM-YYYY**. Must be **greater than or equal to** `start_date`. |
| `category_pie_config_id` | integer | ID of a **category pie config** that belongs to this user (from **[GET Category pie configs](get_category_pie_configs.md)**). |

## Aggregation semantics

- **`segments[].total`**: sum of **`total_price`** for all positions in that category among included transactions.
- **`segments[].transaction_count`**: number of **distinct transactions** that have at least one included line in that category within the slice.
- Every category listed on the config appears in **`segments`** even when the total is **0** (e.g. no matching lines in the range). The API then **sorts `segments` by `total` descending** (highest first).
- Configs must define **1–7** categories; allowed values are the slugs on **`Transaction::Position`** (same set the client uses elsewhere for receipt lines).

## Example request

```
GET /api/v1/users/123/analytics/spending_by_category?currency=PLN&start_date=01-04-2026&end_date=07-04-2026&category_pie_config_id=2
```

## Response

### 200 OK

```json
{
  "currency": "PLN",
  "start_date": "2026-04-01",
  "end_date": "2026-04-07",
  "category_pie_config_id": 2,
  "segments": [
    { "category": "groceries", "total": 120.5, "transaction_count": 8 },
    { "category": "dairy", "total": 45.0, "transaction_count": 3 }
  ]
}
```

#### Field reference (root)

| Field                   | Type    | Description |
|-------------------------|---------|-------------|
| `currency`              | string  | Echo of the requested currency (uppercase). |
| `start_date`            | string  | Inclusive range start, **ISO 8601** `YYYY-MM-DD`. |
| `end_date`              | string  | Inclusive range end, **ISO 8601** `YYYY-MM-DD`. |
| `category_pie_config_id`| integer | ID of the config used for this response. |
| `segments`              | array   | Category slices; see below. |

#### `segments[]` items

| Field               | Type    | Description |
|---------------------|---------|-------------|
| `category`          | string  | Category slug (e.g. `groceries`, `dairy`). |
| `total`             | number  | Sum of position `total_price` for this category in scope. |
| `transaction_count` | integer | Distinct **ready** transactions in range that contribute to this category’s lines. |

### 404 Not Found

Returned when no category pie config exists for this **`category_pie_config_id`** **and** the authenticated user (including IDs that belong to another user).

```json
{ "error": "Category pie config not found" }
```

### 422 Unprocessable Entity

Returned for invalid or missing query parameters (wrong date format, invalid currency, invalid or missing `category_pie_config_id`, `end_date` before `start_date`, etc.):

```json
{ "errors": { "start_date": ["must be in DD-MM-YYYY format"] } }
```

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
