# POST Create Transaction by Hand

Creates a transaction manually for the authenticated user, without a receipt image.

## Endpoint

```
POST /api/v1/users/:user_id/transactions/create_by_hand
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

| Parameter | Type    | Required | Description                    |
|-----------|---------|----------|--------------------------------|
| `user_id` | integer | Yes      | ID of the authenticated user   |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with `403 Forbidden`.

## Request Body (JSON)

| Field              | Type    | Required | Description                                         |
|--------------------|---------|----------|-----------------------------------------------------|
| `title`            | string  | Yes      | Name/title of the transaction                       |
| `store_name`       | string  | No       | Name of the store                                   |
| `total_price`      | float   | Yes      | Total transaction amount                            |
| `currency`         | string  | Yes      | One of: `pln`, `usd`, `eur`, `gbp`                 |
| `transaction_date` | date    | Yes      | Format: `YYYY-MM-DD`                                |
| `positions`        | array   | Yes      | List of line items; can be an empty array `[]`      |

### Position Object

| Field             | Type   | Required | Description                              |
|-------------------|--------|----------|------------------------------------------|
| `name`            | string | Yes      | Name of the line item                    |
| `quantity`        | float  | Yes      | Quantity purchased                       |
| `price`           | float  | Yes      | Unit price                               |
| `category`        | string | Yes      | One of the predefined categories (below) |
| `total_discount`  | float  | Yes      | Discount for this line (use `0` when none). Must be ≥ 0 |

Per-line **`total_price`** is not sent in the request. The API stores it on each position as `quantity × price − total_discount`. When there is at least one position, the transaction’s **`total_discount`** is set to the **sum** of all line `total_discount` values.

**Available categories:** `groceries`, `beverages`, `dairy`, `bakery`, `meat_and_seafood`, `fruits_and_vegetables`, `snacks_and_sweets`, `frozen_foods`, `household_and_cleaning`, `personal_care`, `health_and_pharmacy`, `electronics`, `clothing_and_apparel`, `alcohol_and_tobacco`, `pet_supplies`, `office_supplies`, `home_and_garden`, `toys_and_games`, `books_and_magazines`, `restaurant_and_dining`, `transportation`, `entertainment`, `other`

### Example Request Body

```json
{
  "title": "Grocery run",
  "store_name": "Lidl",
  "total_price": 42.50,
  "currency": "pln",
  "transaction_date": "2026-03-31",
  "positions": [
    {
      "name": "Whole Milk",
      "quantity": 2,
      "price": 1.49,
      "category": "dairy",
      "total_discount": 0.50
    },
    {
      "name": "Sourdough Bread",
      "quantity": 1,
      "price": 3.29,
      "category": "bakery",
      "total_discount": 0
    }
  ]
}
```

## Response

### 201 Created

```json
{
  "id": 42,
  "title": "Grocery run",
  "store_name": "Lidl",
  "transaction_date": "2026-03-31",
  "status": "ready",
  "price": 42.50,
  "currency": "pln"
}
```

#### Field Reference

| Field              | Type    | Description                                    |
|--------------------|---------|------------------------------------------------|
| `id`               | integer | Transaction ID                                 |
| `title`            | string  | Transaction name                               |
| `store_name`       | string / null | Name of the store                        |
| `transaction_date` | date    | Date of the transaction (`YYYY-MM-DD`)         |
| `status`           | string  | Always `ready` for manually created records    |
| `price`            | float   | Total transaction amount                       |
| `currency`         | string  | Currency code (`pln`, `usd`, `eur`, or `gbp`)  |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 422 Unprocessable Entity

Returned when input validation fails. The `errors` object uses field names as keys.

```json
{
  "errors": {
    "currency": ["must be one of: pln, usd, eur, gbp"],
    "positions": {
      "0": {
        "category": ["must be one of: groceries, beverages, ..."]
      }
    }
  }
}
```
