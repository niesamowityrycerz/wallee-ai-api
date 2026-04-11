# GET Transactions (list / search)

Returns the authenticated user’s transactions filtered by **currency** and **transaction date range**. Results are sorted from **newest to oldest** (by `transaction_date`, then `created_at`). Pagination is not implemented yet.

## Endpoint

```
GET /api/v1/users/:user_id/transactions
```

## Authentication

Uses **DeviseTokenAuth** token-based authentication. All four headers are required on every request.

| Header         | Description                    |
|----------------|--------------------------------|
| `access-token` | Token returned after sign-in   |
| `token-type`   | Always `Bearer`                |
| `client`       | Client ID returned after sign-in |
| `uid`          | User's email address           |

## Path parameters

| Parameter | Type   | Required | Description                  |
|-----------|--------|----------|------------------------------|
| `user_id` | string | Yes      | ID of the authenticated user |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

## Query parameters (required)

All three parameters are **required** on every request. Omitting any of them fails validation.

| Parameter     | Type   | Description |
|---------------|--------|-------------|
| `currency`    | string | Must be **uppercase** and one of: `PLN`, `USD`, `EUR`, `GBP`. |
| `start_date`  | string | Inclusive range start, format **DD-MM-YYYY** (e.g. `05-04-2026`). |
| `end_date`    | string | Inclusive range end, format **DD-MM-YYYY**. Must be **greater than or equal to** `start_date`. |

### Client-side date presets

The API does not accept named ranges (`today`, `last 7 days`, etc.). The mobile app should compute `start_date` and `end_date` in **DD-MM-YYYY** and send them as query parameters.

### Filtering semantics

- Only transactions whose **`currency`** matches exactly are returned.
- Only transactions whose **`transaction_date`** falls on **or between** `start_date` and `end_date` (inclusive) are returned.

## Example request

```
GET /api/v1/users/123/transactions?currency=USD&start_date=05-04-2026&end_date=11-04-2026
```

## Response

### 200 OK

```json
{
  "transactions": [
    {
      "id": 42,
      "status": "ready",
      "name": "LIDL Receipt",
      "amount": 34.75,
      "currency": "USD",
      "transaction_date": "2026-04-10",
      "store_name": "LIDL",
      "image_urls": [
        "https://example.com/receipts/image1.jpg"
      ],
      "created_at": "2026-04-10T12:00:00.000Z",
      "updated_at": "2026-04-10T12:01:00.000Z"
    }
  ]
}
```

#### Field reference (`transactions[]`)

| Field              | Type             | Description |
|--------------------|------------------|-------------|
| `id`               | integer          | Transaction ID |
| `status`           | string           | `in_progress`, `ready`, or `failed` |
| `name`             | string           | Transaction name |
| `amount`           | float            | Total transaction amount |
| `currency`         | string           | Currency code (matches filter) |
| `transaction_date` | string           | Date of the transaction (JSON date serialization) |
| `store_name`       | string / null    | Store name |
| `image_urls`       | array of strings | Receipt image URLs |
| `created_at`       | string           | Record creation time (ISO 8601) |
| `updated_at`       | string           | Record last update (ISO 8601) |

Ordering: **latest `transaction_date` first**; ties broken by **latest `created_at` first**.

### 422 Unprocessable Entity

Returned when query parameters are missing, invalid, or fail business rules (e.g. `end_date` before `start_date`). Errors use the same shape as other validated endpoints.

```json
{
  "errors": {
    "currency": ["must be uppercase"],
    "start_date": ["must be in DD-MM-YYYY format"],
    "end_date": ["must be greater than or equal to start_date"]
  }
}
```

The exact keys and messages depend on what failed validation. Multiple fields may be present at once.

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
