# POST Create tag

Creates a new **tag** on the authenticated user’s **account**. The tag name must be **non-empty** after trimming and must **not** collide with an existing tag on the same account **ignoring case** (e.g. `Food` and `food` cannot both exist). New tags from this endpoint are stored with `created_by`: **`account_member`**.

## Endpoint

```
POST /api/v1/users/:user_id/tags
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

| Field | Type   | Required | Description |
|--------|--------|----------|-------------|
| `name` | string | Yes      | Tag label; leading/trailing whitespace is stripped. Must not be empty after strip. |

### Example request body

```json
{
  "name": "Side projects"
}
```

## Response

### 201 Created

Returns the created tag (same shape as each element in **GET Tags**).

```json
{
  "id": 42,
  "name": "Side projects",
  "created_by": "account_member",
  "created_at": "2026-04-20T09:15:00.000Z",
  "updated_at": "2026-04-20T09:15:00.000Z"
}
```

#### Field reference

| Field        | Type     | Description |
|--------------|----------|-------------|
| `id`         | integer  | New tag ID |
| `name`       | string   | Stored name (trimmed) |
| `created_by` | string   | Always `account_member` for this endpoint |
| `created_at` | string   | ISO 8601 |
| `updated_at` | string   | ISO 8601 |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 422 Unprocessable Entity

Returned when validation fails: missing/blank `name`, duplicate name (case-insensitive) on the account, or the user has **no account**.

```json
{
  "errors": {
    "name": ["can't be blank"]
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

```json
{
  "errors": {
    "account": ["is required"]
  }
}
```

The exact keys and messages depend on what failed validation.
