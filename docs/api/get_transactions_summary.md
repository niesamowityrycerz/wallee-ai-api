# GET Transactions Summary

Returns spending totals for the authenticated user within a given date range **for a single currency**. Only transactions with `status: ready` and a non-null `amount` are included. The `totals` object is keyed by currency; when filtering by one currency it contains at most that key.

## Endpoint

```
GET /api/v1/users/:user_id/transactions/summary
```

## Authentication

Uses **DeviseTokenAuth** token-based authentication. All four headers are required on every request.

| Header         | Description                    |
|----------------|--------------------------------|
| `access-token` | Token returned after sign-in   |
| `token-type`   | Always `Bearer`                |
| `client`       | Client ID returned after sign-in |
| `uid`          | User's email address           |

## Path Parameters

| Parameter | Type   | Required | Description                  |
|-----------|--------|----------|------------------------------|
| `user_id` | string | Yes      | ID of the authenticated user |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with `403 Forbidden`.

## Query Parameters (required)

All three parameters are **required** on every request.

| Parameter   | Type   | Description |
|-------------|--------|-------------|
| `currency`  | string | Must be **uppercase** and one of: `PLN`, `USD`, `EUR`, `GBP`. |
| `from_date` | string | Inclusive range start, format **DD-MM-YYYY** (e.g. `01-04-2026`). |
| `to_date`   | string | Inclusive range end, format **DD-MM-YYYY**. Must be **greater than or equal to** `from_date`. |

## Example request

```
GET /api/v1/users/123/transactions/summary?currency=PLN&from_date=01-04-2026&to_date=11-04-2026
```

## Response

### 200 OK

```json
{
  "from_date": "2026-04-01",
  "to_date": "2026-04-11",
  "currency": "PLN",
  "transaction_count": 5,
  "total_vat": 42.35,
  "totals": {
    "PLN": 342.50
  }
}
```

When there are no matching transactions, `transaction_count` is `0`, `total_vat` is `0`, and `totals` is `{}`.

#### Field Reference

| Field               | Type             | Description                                                                 |
|---------------------|------------------|-----------------------------------------------------------------------------|
| `from_date`         | ISO 8601 date    | Start of the queried range                                                  |
| `to_date`           | ISO 8601 date    | End of the queried range                                                    |
| `currency`          | string           | The currency filter echoed back (same as the `currency` query parameter)   |
| `transaction_count` | integer          | Number of `ready` transactions with a non-null amount in the range and currency |
| `total_vat`         | float            | Sum of `total_vat` for those same transactions (missing per-transaction VAT counts as `0` in the sum) |
| `totals`            | object           | Sum of `amount` keyed by ISO 4217 currency code (typically one key matching `currency`) |

### 422 Unprocessable Entity

Returned when query parameters are missing, invalid, or fail validation (e.g. wrong date format, `to_date` before `from_date`, invalid currency).

```json
{
  "errors": {
    "currency": ["must be uppercase"],
    "from_date": ["must be in DD-MM-YYYY format"],
    "to_date": ["must be greater than or equal to from_date"]
  }
}
```

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
