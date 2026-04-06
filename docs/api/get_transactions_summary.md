# GET Transactions Summary

Returns the total spending for the authenticated user within a given date range. Only transactions with `status: ready` and a non-null `amount` are included. Totals are grouped by currency so mixed-currency results are always accurate.

## Endpoint

```
GET /api/v1/users/:user_id/transactions/summary
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

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with `403 Forbidden`.

## Query Parameters

| Parameter   | Type   | Required | Description                                                                 |
|-------------|--------|----------|-----------------------------------------------------------------------------|
| `from_date` | string | No       | Start of the date range (ISO 8601 date, e.g. `2026-02-01`). Defaults to the first day of the current month. |
| `to_date`   | string | No       | End of the date range (ISO 8601 date, e.g. `2026-02-28`). Defaults to the last day of the current month.  |

## Response

### 200 OK

```json
{
  "from_date": "2026-02-01",
  "to_date": "2026-02-28",
  "transaction_count": 5,
  "totals": {
    "PLN": 342.50,
    "USD": 12.99
  }
}
```

#### Field Reference

| Field               | Type             | Description                                                                 |
|---------------------|------------------|-----------------------------------------------------------------------------|
| `from_date`         | ISO 8601 date    | Start of the queried range                                                  |
| `to_date`           | ISO 8601 date    | End of the queried range                                                    |
| `transaction_count` | integer          | Number of `ready` transactions with a non-null amount in the range          |
| `totals`            | object           | Sum of `amount` keyed by ISO 4217 currency code; empty object if no data    |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
