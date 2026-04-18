# GET Tag transactions

Returns the **tag** (`id`, `name`, **`created_at`**) and the authenticated user’s **transactions** linked to that tag. Each transaction row uses the **same shape** as **[GET Transactions (list)](get_transactions.md)** (no `tags` on each row).

**Query filters are optional.** If you omit them, every transaction that has this tag is returned (still scoped to the authenticated user). If you pass **`currency`** and/or a **date range** (`start_date` + `end_date`), only matching transactions are included—same semantics as **[GET Transactions (list)](get_transactions.md)** for those fields.

The tag **`id`** must belong to the user’s **account** (same scope as **[GET Tags](get_tags.md)**). If the tag does not exist on that account, the API returns **404 Not Found**.

Results are sorted from **newest to oldest** (`transaction_date`, then `created_at`), matching the main transactions list.

## Endpoint

```
GET /api/v1/users/:user_id/tags/:id/transactions
```

Implemented as the **`transactions`** member action on **[GET Tags](get_tags.md)**.

## Authentication

Uses **DeviseTokenAuth** token-based authentication. All four headers are required on every request.

| Header         | Description                    |
|----------------|--------------------------------|
| `access-token` | Token returned after sign-in   |
| `token-type`   | Always `Bearer`                |
| `client`       | Client ID returned after sign-in |
| `uid`          | User's email address           |

## Path parameters

| Parameter | Type    | Required | Description                  |
|-----------|---------|----------|------------------------------|
| `user_id` | integer | Yes      | ID of the authenticated user |
| `id`      | integer | Yes      | ID of the tag (must exist on the user’s **account**) |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

## Query parameters (all optional)

Omit all query parameters to return **all** of the user’s transactions that carry this tag.

| Parameter    | Type   | Required | Description |
|--------------|--------|----------|-------------|
| `currency`   | string | No       | If set: **uppercase**; one of `PLN`, `USD`, `EUR`, `GBP`. Filters to that currency. |
| `start_date` | string | No       | If you filter by date, **both** `start_date` and `end_date` are required. **DD-MM-YYYY**, inclusive. |
| `end_date`   | string | No       | Inclusive end; must be ≥ `start_date`. |

Rules:

- **`start_date` / `end_date`**: either **omit both** or **send both**. Sending only one returns **422**.
- Date and currency filters can be combined (e.g. USD transactions in a given range).

### Example requests

No filters (all transactions with this tag):

```
GET /api/v1/users/123/tags/5/transactions
```

With filters:

```
GET /api/v1/users/123/tags/5/transactions?currency=USD&start_date=05-04-2026&end_date=11-04-2026
```

## Response

### 200 OK

```json
{
  "id": 5,
  "name": "Groceries",
  "created_at": "2026-04-01T10:00:00.000Z",
  "transactions": [
    {
      "id": 42,
      "status": "ready",
      "name": "LIDL Receipt",
      "amount": 34.75,
      "currency": "USD",
      "transaction_date": "2026-04-10",
      "store_name": "LIDL",
      "total_vat": 23.70,
      "image_urls": [
        "https://example.com/receipts/image1.jpg"
      ],
      "created_at": "2026-04-10T12:00:00.000Z",
      "updated_at": "2026-04-10T12:01:00.000Z"
    }
  ]
}
```

| Field        | Type   | Description |
|--------------|--------|-------------|
| `id`         | integer | Tag ID |
| `name`       | string | Tag name |
| `created_at` | string  | ISO 8601 — when the **tag record** was created (same as **[GET Tags](get_tags.md)**) |
| `transactions` | array | Transaction rows (see below) |

Each element of **`transactions`** matches the list payload in **[GET Transactions (list)](get_transactions.md)**. **`tags` are not included** on each transaction.

### 403 Forbidden

```json
{ "error": "Forbidden" }
```

### 404 Not Found

Returned when the tag is missing or not on the user’s account (including when the user has no account and the tag cannot be resolved).

```json
{ "error": "Tag not found" }
```

### 422 Unprocessable Entity

Returned when an optional filter is present but invalid (bad currency, bad date format, only one of `start_date`/`end_date`, or `end_date` before `start_date`).

```json
{
  "errors": {
    "currency": ["must be one of: PLN, USD, EUR, GBP"]
  }
}
```

```json
{
  "errors": {
    "": ["start_date and end_date must both be provided when filtering by date"]
  }
}
```
