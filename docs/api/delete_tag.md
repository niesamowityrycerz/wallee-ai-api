# DELETE Tag

Permanently deletes a **tag** belonging to the authenticated user’s **account**. All **transaction–tag** links for that tag are removed as well (hard delete on the join rows). Transactions themselves are **not** deleted.

## Endpoint

```
DELETE /api/v1/users/:user_id/tags/:id
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
| `id`      | integer | Yes      | ID of the tag                |

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

> The tag must belong to the user’s account. Tags on other accounts are not visible; those requests receive **404 Not Found**.

## Request body

None. Send an empty body or omit the body.

## Response

### 204 No Content

The tag was deleted successfully. The response has no body.

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 404 Not Found

Returned when no tag with the given `id` exists on the user’s account.

```json
{ "error": "Tag not found" }
```

### 422 Unprocessable Entity

Returned when the user has **no account** linked yet.

```json
{
  "errors": {
    "account": ["is required"]
  }
}
```
