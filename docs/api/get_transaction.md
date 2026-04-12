# GET Transaction

Retrieves the details of a single transaction belonging to the authenticated user, including all associated products, image URLs, and—when extracted from the receipt—**VAT** (`total_vat` and per–tax-group `vat_components`).

## Endpoint

```
GET /api/v1/users/:user_id/transactions/:id
```

## Authentication

Uses **DeviseTokenAuth** token-based authentication. All four headers are required on every request.

| Header        | Description                          |
|---------------|--------------------------------------|
| `access-token`| Token returned after sign-in         |
| `token-type`  | Always `Bearer`                      |
| `client`      | Client ID returned after sign-in     |
| `uid`         | User's email address                 |

## Path Parameters

| Parameter | Type   | Required | Description                        |
|-----------|--------|----------|------------------------------------|
| `user_id` | string | Yes      | ID of the authenticated user       |
| `id`      | string | Yes      | ID of the transaction to retrieve  |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with `403 Forbidden`.

## Response

### 200 OK

```json
{
  "id": 42,
  "status": "ready",
  "name": "LIDL Receipt",
  "amount": 34.75,
  "currency": "USD",
  "transaction_date": "2026-03-29T10:00:00.000Z",
  "store_name": "LIDL",
  "store_address": "123 Main St, Berlin",
  "image_urls": [
    "https://example.com/receipts/image1.jpg"
  ],
  "total_discount": 2.50,
  "total_vat": 2.09,
  "vat_components": [
    {
      "vat_group": "A",
      "rate_percent": 23.0,
      "vat_amount": 1.95
    },
    {
      "vat_group": "C",
      "rate_percent": 5.0,
      "vat_amount": 0.14
    }
  ],
  "products": [
    {
      "id": 1,
      "name": "Whole Milk",
      "quantity": 2,
      "unit_price": 1.49,
      "total_price": 2.48,
      "category": "dairy",
      "total_discount": 0.50
    },
    {
      "id": 2,
      "name": "Sourdough Bread",
      "quantity": 1,
      "unit_price": 3.29,
      "total_price": 3.29,
      "category": "bakery",
      "total_discount": 0.00
    }
  ],
  "created_at": "2026-03-29T09:55:00.000Z",
  "updated_at": "2026-03-29T10:01:00.000Z"
}
```

#### Field Reference

| Field              | Type             | Description                                                       |
|--------------------|------------------|-------------------------------------------------------------------|
| `id`               | integer          | Transaction ID                                                    |
| `status`           | string           | `in_progress`, `ready`, or `failed`                              |
| `name`             | string           | Transaction name                                                  |
| `amount`           | float            | Total transaction amount                                          |
| `currency`         | string           | ISO 4217 currency code (e.g. `USD`)                              |
| `transaction_date` | ISO 8601 string  | Date and time of the transaction                                  |
| `store_name`       | string           | Name of the store                                                 |
| `store_address`    | string / null    | Address of the store                                              |
| `image_urls`       | array of strings | URLs of receipt images; empty array if none                       |
| `total_discount`   | float / null     | Total discount applied to the transaction                         |
| `total_vat`        | float / null     | Total VAT for the transaction (e.g. **SUMA PTU** on Polish fiscal receipts). `null` if not extracted or not present on the receipt. |
| `vat_components`   | array of objects | Per–VAT-group breakdown when available (see **VAT component** below). Always a JSON array—never `null`. Use an **empty array** `[]` when there is no data or the association is absent. |
| `products`         | array of objects | Line items parsed from the receipt (see below)                    |
| `created_at`       | ISO 8601 string  | Record creation timestamp                                         |
| `updated_at`       | ISO 8601 string  | Record last-updated timestamp                                     |

#### Product Object

| Field              | Type         | Description                                                                 |
|--------------------|--------------|-----------------------------------------------------------------------------|
| `id`               | integer      | Product (position) ID                                                       |
| `name`             | string       | Product name                                                                |
| `quantity`         | float        | Quantity purchased                                                          |
| `unit_price`       | float        | Price per unit                                                              |
| `total_price`      | float        | Line total after discount: `quantity × unit_price − total_discount`          |
| `total_discount`   | float / null | Discount applied to this line item                                          |
| `category`         | string       | One of: `groceries`, `beverages`, `dairy`, `bakery`, `meat_and_seafood`, `fruits_and_vegetables`, `snacks_and_sweets`, `frozen_foods`, `household_and_cleaning`, `personal_care`, `health_and_pharmacy`, `electronics`, `clothing_and_apparel`, `alcohol_and_tobacco`, `pet_supplies`, `office_supplies`, `home_and_garden`, `toys_and_games`, `books_and_magazines`, `restaurant_and_dining`, `transportation`, `entertainment`, `other` |

#### VAT component object

Each element of `vat_components` describes one fiscal VAT group (e.g. Polish stawki **A**–**E**) as printed on the receipt summary.

| Field           | Type   | Description |
|-----------------|--------|-------------|
| `vat_group`     | string | Letter **A**, **B**, **C**, **D**, or **E** |
| `rate_percent`  | float  | VAT rate for that group as on the receipt (percent) |
| `vat_amount`    | float  | VAT amount (e.g. **PTU**) for that group |

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
