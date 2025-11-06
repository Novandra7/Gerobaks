# Backend Integration (Laravel)

The Flutter app can talk to the local Laravel API. Configure the base URL in your `.env` (already whitelisted in `pubspec.yaml` assets):

```
API_BASE_URL=http://127.0.0.1:8000
ORS_API_KEY=your_openrouteservice_key
```

Notes:

- On Android emulator, use `API_BASE_URL=http://10.0.2.2:8000` instead of `127.0.0.1`.
- On iOS simulator, `http://127.0.0.1:8000` works.
- If you run the API on a device in the same LAN, use the machine IP e.g. `http://192.168.1.10:8000`.

Endpoints currently used:

- POST `/api/tracking` → store location updates
- GET `/api/tracking?schedule_id=ID` → fetch location history
- Other endpoints: see `backend/routes/api.php`.
