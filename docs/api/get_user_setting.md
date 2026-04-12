# GET User setting

Returns the current user’s display preferences: default **currency** and whether to **show VAT details** on the client. If no `user_settings` row exists yet (e.g. legacy user before backfill), the server creates one with defaults (`currency`: **PLN**, `show_vat_details`: **false**) before responding.

## Endpoint

```
GET /api/v1/users/:user_id/user_setting
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

> `user_id` in the path must match the authenticated user's ID, otherwise the request is rejected with **403 Forbidden**.

## Response

### 200 OK

```json
{
  "currency": "PLN",
  "show_vat_details": false,
  "updated_at": "2026-04-12T10:00:00.000Z"
}
```

#### Field reference

| Field               | Type     | Description |
|---------------------|----------|-------------|
| `currency`          | string   | One of: `PLN`, `EUR`, `USD`, `GBP` |
| `show_vat_details`  | boolean  | When `true`, the client may show VAT breakdown (e.g. per rate group); when `false`, hide that UI. |
| `updated_at`        | datetime | ISO 8601 last update time of these settings |

### 403 Forbidden

Returned when `user_id` in the path does not match the authenticated user.

```json
{ "error": "Forbidden" }
```
