# GET Category pie configs (list)

Returns all **category pie configs** for the authenticated user. Each config is a **named set of 1–7 category slugs** used with **[GET Analytics — spending by category](get_analytics_spending_by_category.md)**. A user may have **at most 3** configs.

Configs are sorted **alphabetically by `name`**.

## Endpoint

```
GET /api/v1/users/:user_id/analytics/category_pie_configs
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

## Query parameters

None.

## Example request

```
GET /api/v1/users/123/analytics/category_pie_configs
```

## Response

### 200 OK

```json
{
  "category_pie_configs": [
    {
      "id": 1,
      "name": "Weekly essentials",
      "categories": ["groceries", "dairy", "bakery"],
      "created_at": "2026-04-20T10:00:00.000Z",
      "updated_at": "2026-04-20T10:00:00.000Z"
    }
  ]
}
```

#### `category_pie_configs[]` items

| Field        | Type     | Description |
|--------------|----------|-------------|
| `id`         | integer  | Config id (use as **`category_pie_config_id`** on **[GET Analytics — spending by category](get_analytics_spending_by_category.md)**). |
| `name`       | string   | User-visible label; unique per user **ignoring case**. |
| `categories` | string[] | 1–7 distinct category slugs from **`Transaction::Position`** allowed list. |
| `created_at` | string   | ISO 8601 |
| `updated_at` | string   | ISO 8601 |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
