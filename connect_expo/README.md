# Connect Giant — Expo (React Native)

Frontend-only rebuild of the Flutter app. Uses the **same backend**:

- REST: `https://api.connectgiant.com/api`
- Auth storage key: `userJson` (same shape as Flutter)
- Bearer token on authenticated calls

## Run (Expo Go)

```bash
cd connect_expo
npm install
npm start
```

Then press `i` / `a`, or scan the QR code with **Expo Go**. No Xcode or custom native build is required for chat media editing.

## What's included

- API client mirroring Flutter `HttpsServices` / `AppApis`
- Auth: login, register, session hydrate/logout
- Feed, chat, camera capture
- Chat media preview editor (Expo Go): text overlay + colors, music picker (`expo-audio`), color filters (`expo-video` playback)
- Brand colors from Flutter `AppColors`

## Next

- Google / Apple → `/auth/social-login`
- Stories, maps, create post multipart
