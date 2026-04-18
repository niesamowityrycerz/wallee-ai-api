# PATCH Update tag

Renames an existing **tag** on the authenticated user’s **account**. Only **`name`** may be changed. The new name must be **non-empty** after trimming and must **not** collide with another tag on the same account **ignoring case** (excluding the tag being updated). This endpoint does **not** change `created_by` (e.g. a tag originally created by the LLM stays `llm` after rename).

## Endpoint

```
PATCH /api/v1/users/:user_id/tags/:id
```

`PUT` is also routed to the same action and behaves like **PATCH** (update `name` only).

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
| `id`      | integer | Yes      | ID of the tag                |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

> The tag must belong to the user’s account. Tags on other accounts are not visible; those requests receive **404 Not Found**.

## Request body (JSON)

| Field  | Type   | Required | Description |
|--------|--------|----------|-------------|
| `name` | string | Yes      | New label; leading/trailing whitespace is stripped. Must not be empty after strip. |

### Example request body

```json
{
  "name": "Dining out (updated)"
}
```

## Response

### 200 OK

Returns the updated tag.

```json
{
  "id": 3,
  "name": "Dining out (updated)",
  "created_by": "account_member",
  "created_at": "2026-04-17T10:00:00.000Z",
  "updated_at": "2026-04-20T11:45:00.000Z"
}
```

#### Field reference

| Field        | Type     | Description |
|--------------|----------|-------------|
| `id`         | integer  | Tag ID |
| `name`       | string   | Updated stored name (trimmed) |
| `created_by` | string   | Unchanged: `account_member` or `llm` |
| `created_at` | string   | ISO 8601 |
| `updated_at` | string   | ISO 8601 |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 404 Not Found

Returned when no tag with the given `id` exists on the user’s account.

```json
{ "error": "Tag not found" }
```

### 422 Unprocessable Entity

Returned when validation fails: missing/blank `name`, duplicate name (case-insensitive) against **another** tag, or the user has **no account**.

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
    "account": ["is required"]
  }
}
```
