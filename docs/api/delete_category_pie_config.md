# DELETE Category pie config

Deletes a **category pie config** belonging to the authenticated user. This does **not** delete any transactions or positions—only the saved selection used for **[GET Analytics — spending by category](get_analytics_spending_by_category.md)**.

After deletion, any client still using the old **`category_pie_config_id`** will receive **404** from the spending-by-category endpoint until the user picks another config or creates a new one.

## Endpoint

```
DELETE /api/v1/users/:user_id/analytics/category_pie_configs/:id
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

## Request body

None. Send an empty body or omit the body.

## Response

### 204 No Content

The config was deleted successfully. The response has no body.

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
