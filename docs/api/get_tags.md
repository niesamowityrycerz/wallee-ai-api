# GET Tags (list)

Returns all **tags** for the authenticated user’s **account** (shared tags for every user on that account). Tags include the **15 default labels** seeded when the account is created, plus any tags created via the API or by the receipt-tagging flow. Results are sorted **alphabetically by name** (case-insensitive). Pagination is not implemented yet.

**`tagged_transactions_count`** is included **only** when the client sends **`include_tagged_transactions_count`** as a **truthy** query value (see below). If the parameter is omitted or **false**, each tag object has **no** usage field and the API does **not** run the extra counting query.

For a single tag’s details and optional filters on its transactions, use **[GET Tag transactions](get_transactions_by_tag.md)**.

## Endpoint

```
GET /api/v1/users/:user_id/tags
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

## Query parameters (optional)

| Parameter     | Type   | Required | Description |
|---------------|--------|----------|-------------|
| `created_by`  | string | No       | When set, only tags with this origin are returned. Allowed values: `account_member`, `llm`. Omit to return **all** tags regardless of origin. |
| `include_tagged_transactions_count` | boolean / string | No | When **truthy** (`true`, `1`, `yes`, etc.), each tag includes **`tagged_transactions_count`** (account-wide: all users on the account; each transaction at most once per tag; **`user`** and **`llm`** links both count). When **omitted** or **false**, that field is **not** present in the response. |

### Example requests

List all tags (no usage field):

```
GET /api/v1/users/123/tags
```

List tags with transaction usage counts:

```
GET /api/v1/users/123/tags?include_tagged_transactions_count=true
```

Only tags with `created_by` **account_member**, including counts:

```
GET /api/v1/users/123/tags?created_by=account_member&include_tagged_transactions_count=true
```

Only tags first created by the **LLM** tagging agent (`created_by` is `llm`):

```
GET /api/v1/users/123/tags?created_by=llm
```

## Response

### 200 OK

Without **`include_tagged_transactions_count`** (default):

```json
{
  "tags": [
    {
      "id": 1,
      "name": "Coffee & snacks",
      "created_by": "account_member",
      "created_at": "2026-04-17T10:00:00.000Z",
      "updated_at": "2026-04-17T10:00:00.000Z"
    }
  ]
}
```

With **`include_tagged_transactions_count=true`**:

```json
{
  "tags": [
    {
      "id": 1,
      "name": "Coffee & snacks",
      "created_by": "account_member",
      "created_at": "2026-04-17T10:00:00.000Z",
      "updated_at": "2026-04-17T10:00:00.000Z",
      "tagged_transactions_count": 3
    },
    {
      "id": 16,
      "name": "Weekend trip",
      "created_by": "llm",
      "created_at": "2026-04-18T14:22:00.000Z",
      "updated_at": "2026-04-18T14:22:00.000Z",
      "tagged_transactions_count": 0
    }
  ]
}
```

#### Field reference (`tags[]`)

| Field        | Type     | Description |
|--------------|----------|-------------|
| `id`         | integer  | Tag ID |
| `name`       | string   | Display name (unique per account, case-insensitive at persistence layer) |
| `created_by` | string   | `account_member` (defaults + user-created via API) or `llm` (first created by automated tagging) |
| `created_at` | string   | ISO 8601 creation time |
| `updated_at` | string   | ISO 8601 last update time |
| `tagged_transactions_count` | integer | **Only when `include_tagged_transactions_count` is truthy.** Number of **transactions** on the **account** linked to this tag (any member’s transactions; `user` and `llm` assignments both count; each transaction counts once per tag). |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 422 Unprocessable Entity

Returned when the user has **no account** linked yet, or when `created_by` is present but **not** `account_member` or `llm`.

```json
{
  "errors": {
    "created_by": ["is invalid"]
  }
}
```
