# PATCH User setting

Updates the authenticated user’s **currency** and/or **show_vat_details**. Send only the fields you want to change (partial update). At least one field must be present in the JSON body.

## Endpoint

```
PATCH /api/v1/users/:user_id/user_setting
```

`PUT` is also routed to the same action and behaves like **PATCH** (partial update).

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

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

## Request body (JSON)

At least one of the following fields must be included.

| Field                | Type    | Description |
|----------------------|---------|-------------|
| `currency`           | string  | One of: `PLN`, `EUR`, `USD`, `GBP` |
| `show_vat_details` | boolean | `true` to show VAT-related UI/details; `false` to hide |

### Example: change currency only

```json
{
  "currency": "EUR"
}
```

### Example: toggle VAT details only

```json
{
  "show_vat_details": true
}
```

### Example: update both

```json
{
  "currency": "PLN",
  "show_vat_details": false
}
```

## Response

### 200 OK

Returns the same shape as **GET User setting**.

```json
{
  "currency": "EUR",
  "show_vat_details": true,
  "updated_at": "2026-04-12T11:30:00.000Z"
}
```

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```

### 422 Unprocessable Entity

Returned when validation fails (e.g. empty body, invalid currency, or invalid boolean).

The response body includes an `errors` object (shape may nest keys from dry-validation):

```json
{
  "errors": {
    "nil": ["at least one field must be provided"]
  }
}
```

```json
{
  "errors": {
    "currency": ["must be one of: PLN, EUR, USD, GBP"]
  }
}
```
