# Orventus Admin — Starter (Flutter)

This is a minimal starter Flutter admin dashboard for *Orventus* (mock data). It includes screens:
- Dashboard (overview + recent rides)
- Manage Users
- Manage Drivers
- Rides list + ride details
- Manual Booking (mock)
- Settings

## How to run

1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Extract this project.
3. From the project root, run:
   ```
   flutter pub get
   flutter run
   ```
   (or open in Android Studio / VS Code and run).

## Notes about maps & notifications

- The project uses mock UI only. For live "God's View" map, add `google_maps_flutter` and a Google Maps API key, then implement a map screen that fetches driver lat/lng from backend.

## Integrating with your backend (overview)

This starter uses `assets/mock_data.json`. To integrate with a backend:
1. Decide on base URL, auth (JWT / API key).
2. Replace calls to `AdminModel.loadMockData()` with `AdminModel.fetchFromApi(baseUrl, apiKey)`.
3. Example expected dashboard response JSON (single object):
```json
{
  "users": [ /* array of users */ ],
  "drivers": [ /* array of drivers */ ],
  "rides": [ /* array of rides */ ],
  "totalRevenue": 12345.67
}
```
4. Endpoints you might implement on the server:
- `GET /admin/dashboard` — returns dashboard JSON (users, drivers, rides, revenue)
- `GET /users` — paginated list of users
- `POST /users/:id/block` — block/unblock user
- `GET /drivers` — list of drivers
- `POST /drivers/:id/approve` — approve driver
- `GET /rides` — list rides (filter by status/date)
- `POST /rides/manual` — create manual booking (admin)
- `GET /reports` — reports and earnings
- `POST /promo` — create promo
- `POST /notifications/send` — send push notification

5. In Flutter, use `package:http` to call endpoints. See `AdminModel.fetchFromApi()` for an example stub.

## Next steps (suggested)
- Add role-based auth (sub-admins).
- Add Google Maps integration for live driver tracking.
- Implement secure auth and CSRF protections on server.
- Add server-side pagination & date filters for large data.
- Add document verification flows and file uploads.

