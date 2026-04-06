# DELETE Transaction position (line item)

Removes a single position (line item) from a `ready` transaction. The parent transaction’s **`amount`** (exposed in the API as **`total_price`**) and **`total_discount`** are recalculated from the **remaining** line items: `total_price` is the sum of each position’s `total_price`, and `total_discount` is the sum of each position’s `total_discount`. If no positions remain, both totals are **0**.

Uses the same **Authentication** pattern as [PATCH Update Transaction — Position](update_transaction.md#patch-position-line-item) (DeviseTokenAuth headers: `access-token`, `token-type`, `client`, `uid`).

## Endpoint

```
DELETE /api/v1/users/:user_id/transactions/:transaction_id/positions/:id
```

## Path Parameters

| Parameter        | Type    | Required | Description                  |
|------------------|---------|----------|------------------------------|
| `user_id`        | integer | Yes      | ID of the authenticated user |
| `transaction_id` | integer | Yes      | ID of the transaction        |
| `id`             | integer | Yes      | ID of the position to delete |

The position must belong to the given transaction, and the transaction must belong to the authenticated user.

## Request Body

None.

## Response

### 200 OK

Returns the recalculated header-level totals on the parent transaction.

```json
{
  "transaction": {
    "total_price": 43.42,
    "total_discount": 2.0
  }
}
```

| Field                       | Type         | Description                                                                 |
|-----------------------------|--------------|-----------------------------------------------------------------------------|
| `transaction`               | object       | Snapshot of parent transaction totals after deletion                        |
| `transaction.total_price`   | float        | Same as the stored **`amount`**: sum of remaining positions’ `total_price`  |
| `transaction.total_discount`| float / null | Sum of remaining positions’ `total_discount`                              |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 404 Not Found

Returned when the transaction or position does not exist for the user.

```json
{ "error": "Transaction not found" }
```

```json
{ "error": "Position not found" }
```

### 422 Unprocessable Entity

Returned when the transaction status is not `ready` (positions on non-ready transactions cannot be edited).

```json
{
  "errors": {
    "status": ["transaction must have status 'ready' to be edited"]
  }
}
```
