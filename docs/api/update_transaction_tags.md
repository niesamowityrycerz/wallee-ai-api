# PATCH Update transaction tags

Applies **tag deltas** to a single **ready** transaction for the authenticated user. Tags are scoped to the user’s **account** (same IDs as **[GET Tags](get_tags.md)**). Use **[GET Transaction](get_transaction.md)** for full transaction detail; this endpoint returns only the updated **`tags`** list (same shape as the `tags` array on GET transaction).

To **create a tag by name** and link it in one step (empty **201** body), use **[POST Create transaction tag (name)](create_transaction_tag.md)**.

Tag assignment rules match the previous transaction PATCH behavior:

- **`add_tag_ids`** — attach tags by ID. Creates a **`user`** link, or if the tag is already on the transaction with **`source`: `llm`**, updates that row to **`user`**.
- **`remove_tag_ids`** — removes the transaction–tag link for each ID, whether the assignment **`source`** is **`user`** or **`llm`**.

## Endpoint

```
PATCH /api/v1/users/:user_id/transactions/:transaction_id/tags
```

The same handler is registered for **PUT** on that path as well (identical request and response).

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
|--------------------|---------|----------|------------------------------|
| `user_id`          | integer | Yes      | ID of the authenticated user |
| `transaction_id`   | integer | Yes      | ID of the transaction |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

> The transaction must belong to the authenticated user; otherwise the response is **404 Not Found** with `{ "error": "Transaction not found" }`.

## Request body (JSON)

| Field            | Type              | Required | Description |
|------------------|-------------------|----------|-------------|
| `add_tag_ids`    | array of integers | No       | Tag IDs to attach (see introduction). Omit or send `[]` when not adding. |
| `remove_tag_ids` | array of integers | No       | Tag IDs to detach from this transaction (**`user`** or **`llm`** assignment). Omit or send `[]` when not removing. |

Rules:

- Every element must be a **positive integer**; use JSON arrays of numbers (e.g. `[1, 2]`).
- `add_tag_ids` and `remove_tag_ids` must **not** contain the same ID in one request (overlap → **422**).
- Sending **both** arrays empty (or omitting both) applies **no changes** and still returns **200 OK** with the current tags.

### Example

```json
{
  "add_tag_ids": [1, 16],
  "remove_tag_ids": [3]
}
```

## Response

### 200 OK

Returns the transaction’s tags after applying the deltas, sorted alphabetically by `name` (case-insensitive). Each element matches the **Tag object** described in **[GET Transaction](get_transaction.md)** (`id`, `name`, `created_by`, `created_at`, `updated_at`, **`source`** on the assignment).

```json
{
  "tags": [
    {
      "id": 1,
      "name": "Groceries",
      "created_by": "account_member",
      "created_at": "2026-04-01T10:00:00.000Z",
      "updated_at": "2026-04-01T10:00:00.000Z",
      "source": "user"
    }
  ]
}
```

### 403 Forbidden

```json
{ "error": "Forbidden" }
```

### 404 Not Found

```json
{ "error": "Transaction not found" }
```

### 422 Unprocessable Entity

Returned when validation fails or the transaction status is not **`ready`**.

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
    "": ["add_tag_ids and remove_tag_ids must not overlap"]
  }
}
```

```json
{
  "errors": {
    "tag_ids": ["unknown or not allowed: 999"]
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

Invalid array contents (e.g. non-integers, zero, or not an array):

```json
{
  "errors": {
    "add_tag_ids": ["must contain only positive integers"]
  }
}
```
