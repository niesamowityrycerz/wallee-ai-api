# GET Analytics — top categories (candidates for pie chart)

Returns the **top 7 position categories** by usage over a **fixed rolling window of the last 90 calendar days** (ending **today** in the server’s timezone). “Usage” means the **number of receipt lines** (`transaction_positions` rows), not sum of money.

Only **ready** transactions with a **non-null `amount`** and **`transaction_date`** inside the window are considered—aligned with other analytics that exclude in-progress rows.

Use this list to suggest categories before the user saves a **[category pie config](get_category_pie_configs.md)** (the client may let the user add or remove categories; configs are still limited to **1–7** categories when saved).

## Endpoint

```
GET /api/v1/users/:user_id/analytics/top_categories
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

## Query parameters

None.

## Window definition

- **`period_days`**: always **90**.
- **`as_of`**: **today’s date** (`YYYY-MM-DD`) in the server’s current timezone when the request runs.
- **Inclusive date range**: from **`as_of` minus 89 days** through **`as_of`** (90 distinct calendar days).

Categories are ranked by **`position_count` descending**. Ties are broken alphabetically by **`category`** slug.

## Example request

```
GET /api/v1/users/123/analytics/top_categories
```

## Response

### 200 OK

```json
{
  "as_of": "2026-04-20",
  "period_days": 90,
  "categories": [
    { "category": "groceries", "position_count": 42 },
    { "category": "dairy", "position_count": 28 }
  ]
}
```

#### Field reference (root)

| Field         | Type    | Description |
|---------------|---------|-------------|
| `as_of`       | string  | End date of the window, **ISO 8601** `YYYY-MM-DD`. |
| `period_days` | integer | Always **90**. |
| `categories`  | array   | Up to **7** entries; see below. |

#### `categories[]` items

| Field             | Type    | Description |
|-------------------|---------|-------------|
| `category`        | string  | Category slug (values allowed on **`Transaction::Position`**). |
| `position_count`  | integer | Number of position rows in the window for that category. |

If the user has no qualifying positions in the window, **`categories`** is an **empty array**.

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
