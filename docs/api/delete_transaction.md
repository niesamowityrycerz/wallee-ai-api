# DELETE Transaction

Permanently deletes a transaction belonging to the authenticated user. Associated images and positions are removed with the transaction (`dependent: :destroy`).

## Endpoint

```
DELETE /api/v1/users/:user_id/transactions/:id
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

## Request Body

None. Send an empty body or omit the body.

## Response

### 204 No Content

The transaction was deleted successfully. The response has no body.

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
