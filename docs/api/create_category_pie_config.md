# POST Create category pie config

Creates a **category pie config**: a **name** plus **1–7 distinct category slugs** used with **[GET Analytics — spending by category](get_analytics_spending_by_category.md)**.

**Limits**

- At most **3** configs per user—creating a fourth returns **422**.
- **`name`** must be **unique per user** **ignoring case** (e.g. `Food` and `food` cannot both exist).
- **`categories`** must each be a valid **`Transaction::Position`** category slug (same vocabulary as receipt line items elsewhere in the API).

## Endpoint

```
POST /api/v1/users/:user_id/analytics/category_pie_configs
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

| Parameter | Type    | Required | Description                  |
|-----------|---------|----------|------------------------------|
| `user_id` | integer | Yes      | ID of the authenticated user |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

## Request body (JSON)

| Field        | Type     | Required | Description |
|--------------|----------|----------|-------------|
| `name`       | string   | Yes      | Config label; leading/trailing whitespace is stripped. Must not be empty after strip. |
| `categories` | string[] | Yes      | **1–7** distinct category slugs. |

### Example request body

```json
{
  "name": "Weekly essentials",
  "categories": ["groceries", "dairy", "bakery"]
}
```

## Response

### 201 Created

Returns the created config (same shape as each element in **[GET Category pie configs](get_category_pie_configs.md)**).

```json
{
  "id": 2,
  "name": "Weekly essentials",
  "categories": ["groceries", "dairy", "bakery"],
  "created_at": "2026-04-20T10:15:00.000Z",
  "updated_at": "2026-04-20T10:15:00.000Z"
}
```

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 422 Unprocessable Entity

Returned when validation fails, including:

- Empty or missing `name`
- Wrong number of categories (not **1–7**), duplicates, or unknown slugs
- Duplicate **`name`** (case-insensitive) for this user
- User already has **3** configs (`errors.base`)

Examples:

```json
{
  "errors": {
    "name": ["has already been taken"]
  }
}
```

```json
{
  "errors": {
    "base": ["maximum of 3 category pie configs reached"]
  }
}
```

```json
{
  "errors": {
    "categories": ["must have between 1 and 7 items"]
  }
}
```

The exact keys and messages depend on what failed validation.
