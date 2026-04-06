# PATCH Update Transaction

Updates an existing transaction for the authenticated user. Only transactions with status `ready` can be edited. Send only the fields you want to change — all fields are optional.

## Endpoint

```
PATCH /api/v1/users/:user_id/transactions/:id
```

## Authentication

Uses **DeviseTokenAuth** token-based authentication. All four headers are required on every request.

| Header         | Description                      |
|----------------|----------------------------------|
| `access-token` | Token returned after sign-in     |
| `token-type`   | Always `Bearer`                  |
| `client`       | Client ID returned after sign-in |
| `uid`          | User's email address             |

## Path Parameters

| Parameter | Type    | Required | Description                  |
|-----------|---------|----------|------------------------------|
| `user_id` | integer | Yes      | ID of the authenticated user |
| `id`      | integer | Yes      | ID of the transaction        |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with `403 Forbidden`.

## Request Body (JSON)

All fields are optional, but at least one must be provided.

| Field              | Type          | Description                                        |
|--------------------|---------------|----------------------------------------------------|
| `name`             | string        | Name/title of the transaction                      |
| `amount`           | float         | Total transaction amount                           |
| `currency`         | string        | One of: `pln`, `usd`, `eur`, `gbp`                |
| `transaction_date` | date          | Format: `YYYY-MM-DD`                               |
| `store_name`       | string / null | Name of the store; send `null` to clear            |
| `store_address`    | string / null | Address of the store; send `null` to clear         |
| `total_discount`   | float / null  | Total discount applied; send `null` to clear       |

### Example Request Body

```json
{
  "name": "Weekly groceries",
  "amount": 55.00,
  "store_address": "ul. Kwiatowa 1, Warsaw"
}
```

## Response

### 200 OK

```json
{
  "id": 42,
  "name": "Weekly groceries",
  "amount": 55.00,
  "currency": "pln",
  "transaction_date": "2026-04-01",
  "store_name": "Biedronka",
  "store_address": "ul. Kwiatowa 1, Warsaw",
  "total_discount": 0.0,
  "status": "ready",
  "created_at": "2026-04-01T10:00:00.000Z",
  "updated_at": "2026-04-04T12:30:00.000Z"
}
```

#### Field Reference

| Field              | Type          | Description                                   |
|--------------------|---------------|-----------------------------------------------|
| `id`               | integer       | Transaction ID                                |
| `name`             | string / null | Transaction name                              |
| `amount`           | float / null  | Total transaction amount                      |
| `currency`         | string / null | Currency code                                 |
| `transaction_date` | date / null   | Date of the transaction (`YYYY-MM-DD`)        |
| `store_name`       | string / null | Name of the store                             |
| `store_address`    | string / null | Address of the store                          |
| `total_discount`   | float / null  | Total discount applied                        |
| `status`           | string        | Always `ready` for editable transactions      |
| `created_at`       | datetime      | ISO 8601 creation timestamp                   |
| `updated_at`       | datetime      | ISO 8601 last-updated timestamp               |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 404 Not Found

Returned when no transaction with the given `id` exists for the user.

```json
{ "error": "Transaction not found" }
```

### 422 Unprocessable Entity

Returned when input validation fails or the transaction status is not `ready`.

```json
{
  "errors": {
    "currency": ["must be one of: pln, usd, eur, gbp"]
  }
}
```

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
    "": ["at least one field must be provided"]
  }
}
```

---

## PATCH Position (line item)

Updates a single position (line item) on a `ready` transaction. Send only the fields you want to change — all are optional, but at least one must be provided. Uses the same [Authentication](#authentication) headers as the transaction update above.

### Endpoint

```
PATCH /api/v1/users/:user_id/transactions/:transaction_id/positions/:id
PUT   /api/v1/users/:user_id/transactions/:transaction_id/positions/:id
```

`PATCH` and `PUT` behave the same for this resource.

### Path Parameters

| Parameter          | Type    | Required | Description                    |
|--------------------|---------|----------|--------------------------------|
| `user_id`          | integer | Yes      | ID of the authenticated user   |
| `transaction_id`   | integer | Yes      | ID of the transaction          |
| `id`               | integer | Yes      | ID of the position             |

> The position must belong to the given transaction, and the transaction must belong to the authenticated user.

### Request Body (JSON)

| Field              | Type          | Description                                                |
|--------------------|---------------|------------------------------------------------------------|
| `name`             | string        | Position name                                              |
| `quantity`         | float         | Quantity; must be greater than 0 if provided               |
| `unit_price`       | float         | Price per unit                                             |
| `total_discount`   | float / null  | Discount for this position; `null` clears the discount   |
| `category`         | string        | One of the predefined categories (same as GET transaction) |

`total_price` is **not** accepted in the body. It is computed and stored as `quantity × unit_price − total_discount` whenever the position is saved.

### Transaction totals (side effects)

After a successful update, the API may refresh header-level totals on the parent transaction:

- **`transaction.total_price` in the response** (see below) is the same value as the transaction’s stored **`amount`**. It is recalculated as the **sum of every position’s `total_price`** when you change **`quantity`**, **`unit_price`**, or **`total_discount`** on this position (because those inputs affect the line total).
- **`transaction.total_discount` in the response** matches the transaction’s stored **`total_discount`**. It is recalculated as the **sum of every position’s `total_discount`** when you change **`total_discount`** on this position.

If you only change fields that do not affect those rules (e.g. `name` or `category` alone), the parent transaction’s `amount` and `total_discount` are left unchanged.

### 200 OK

The body includes the updated position fields at the root, plus a **`transaction`** object with the current header totals after the update.

```json
{
  "id": 1,
  "name": "Whole Milk",
  "quantity": 2.0,
  "unit_price": 1.49,
  "total_price": 2.48,
  "total_discount": 0.5,
  "category": "dairy",
  "created_at": "2026-04-01T10:00:00.000Z",
  "updated_at": "2026-04-04T12:45:00.000Z",
  "transaction": {
    "total_price": 45.9,
    "total_discount": 2.5
  }
}
```

#### Field Reference (position response — root)

| Field             | Type            | Description                                                |
|-------------------|-----------------|------------------------------------------------------------|
| `id`              | integer         | Position ID                                                |
| `name`            | string          | Position name                                              |
| `quantity`        | float           | Quantity                                                   |
| `unit_price`      | float           | Price per unit                                             |
| `total_price`     | float           | Line total: `quantity × unit_price − total_discount`       |
| `total_discount`  | float / null    | Discount applied to this position                          |
| `category`        | string          | Category code                                              |
| `created_at`      | ISO 8601 string | Creation timestamp                                         |
| `updated_at`      | ISO 8601 string | Last update timestamp                                      |
| `transaction`     | object          | Snapshot of parent transaction totals (see below)          |

#### Field Reference (`transaction` object)

| Field             | Type            | Description                                                |
|-------------------|-----------------|------------------------------------------------------------|
| `total_price`     | float / null    | Same as the transaction **`amount`**: overall total after line items |
| `total_discount`  | float / null    | Same as the transaction **`total_discount`**: sum of line discounts when synced |

### 403 Forbidden

Same as transaction update: `user_id` must match the authenticated user.

### 404 Not Found

Returned when the transaction or position does not exist for the user.

```json
{ "error": "Transaction not found" }
```

```json
{ "error": "Position not found" }
```

### 422 Unprocessable Entity

Returned when validation fails (e.g. empty body, invalid category) or the transaction status is not `ready`.

```json
{
  "errors": {
    "": ["at least one field must be provided"]
  }
}
```

```json
{
  "errors": {
    "status": ["transaction must have status 'ready' to be edited"]
  }
}
```
