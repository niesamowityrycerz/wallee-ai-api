# PATCH Update category pie config

Updates an existing **category pie config** for the authenticated user. You must send **at least one** of **`name`** or **`categories`**.

**Same rules as create** for fields that are present: **`name`** must remain **unique per user** ignoring case (excluding the config being updated); **`categories`**, when sent, must be **1–7** distinct valid **`Transaction::Position`** category slugs.

`PUT` is also routed to this action and behaves like **PATCH**.

## Endpoint

```
PATCH /api/v1/users/:user_id/analytics/category_pie_configs/:id
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
| `id`      | integer | Yes      | ID of the category pie config |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

> The config must belong to the user; unknown or other users’ ids receive **404 Not Found**.

## Request body (JSON)

At least one field required:

| Field        | Type     | Required | Description |
|--------------|----------|----------|-------------|
| `name`       | string   | No*      | New label; stripped; must not be blank if provided. |
| `categories` | string[] | No*      | Replace the full category list: **1–7** distinct valid slugs. Must not be JSON **`null`** if the key is present. |

\*Send **at least one** of `name` or `categories`.

### Example: rename only

```json
{
  "name": "Weekly essentials (updated)"
}
```

### Example: change categories only

```json
{
  "categories": ["groceries", "snacks_and_sweets", "beverages"]
}
```

## Response

### 200 OK

Returns the updated config (same shape as **[GET Category pie configs](get_category_pie_configs.md)** items).

```json
{
  "id": 2,
  "name": "Weekly essentials (updated)",
  "categories": ["groceries", "snacks_and_sweets", "beverages"],
  "created_at": "2026-04-20T10:15:00.000Z",
  "updated_at": "2026-04-20T10:20:00.000Z"
}
```

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 404 Not Found

Returned when no config exists for this **`id`** and user.

```json
{ "error": "Config not found" }
```

### 422 Unprocessable Entity

Returned when validation fails: empty body without `name` or `categories`, blank `name`, duplicate `name` (case-insensitive), invalid `categories` count or values, or `categories` explicitly **`null`**.

```json
{
  "errors": {
    "base": ["at least one of name, categories must be present"]
  }
}
```

```json
{
  "errors": {
    "name": ["has already been taken"]
  }
}
```

The exact keys and messages depend on what failed validation.
