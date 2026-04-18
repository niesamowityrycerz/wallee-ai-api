# POST Create transaction tag (name)

Creates or reuses an account **tag** by **`name`** and ensures it is **linked** to a **ready** transaction for the authenticated user. All writes run in a **single database transaction**.

Behavior:

- **`name`** is trimmed; it must be **non-empty** after trimming (same rules as **[POST Create tag](create_tag.md)** for format).
- If a tag with the same name already exists on the account (**case-insensitive** match), that tag is **reused** (no duplicate tag row).
- If the tag is **already linked** to this transaction, the request succeeds with **201 Created**, **no response body**, and **no database changes**.
- Otherwise a **`user`** assignment is created for this transaction. New tag rows use **`created_by`**: **`account_member`**.

Use **[GET Transaction](get_transaction.md)** to read the updated `tags` list.

## Endpoint

```
POST /api/v1/users/:user_id/transactions/:transaction_id/tags
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

| Parameter        | Type    | Required | Description                  |
|------------------|---------|----------|------------------------------|
| `user_id`        | integer | Yes      | ID of the authenticated user |
| `transaction_id` | integer | Yes      | ID of the transaction        |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

> The transaction must belong to the authenticated user; otherwise the response is **404 Not Found** with `{ "error": "Transaction not found" }`.

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

Empty body (no JSON).

### 403 Forbidden

```json
{ "error": "Forbidden" }
```

### 404 Not Found

```json
{ "error": "Transaction not found" }
```

### 422 Unprocessable Entity

Returned when validation fails, the transaction is not **`ready`**, or the user has **no account**.

```json
{
  "errors": {
    "status": ["transaction must have status 'ready' to be edited"]
  }
}
```

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
    "account": ["is required"]
  }
}
```
