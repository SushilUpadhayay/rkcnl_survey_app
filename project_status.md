# RKCNL Survey Application — Project Status

**Last Updated:** 2026-05-14  
**Version:** 1.0.0-dev  
**Stack:** Flutter (Mobile) · Node.js + Express · Prisma ORM · PostgreSQL

---

## Project Overview

The RKCNL (Rastriye Krishi Company Nepal Limited) Survey Application is a field data collection platform for agricultural surveyors. The system enables field staff to conduct surveys offline, sync data to the backend when online, and allows administrators to manage survey assignments, view reports, and export data.

---

## Current Architecture Summary

### Backend — `backend/`
```
backend/
├── index.js                  → Express entry point
├── .env                      → Environment config (Prisma URL, JWT secret)
├── prisma/schema.prisma      → Prisma schema (PostgreSQL)
└── src/
    ├── config/db.js          → PrismaClient singleton + connectDB()
    ├── controllers/
    │   ├── auth.controller.js    → Register, Login, GetProfile
    │   └── survey.controller.js  → Create, GetAll, GetById
    ├── middleware/
    │   └── auth.middleware.js    → JWT protect + authorize()
    └── routes/
        ├── auth.routes.js        → /api/auth/*
        └── survey.routes.js      → /api/surveys/*
```

### Frontend — `frontend/lib/`
```
frontend/lib/
├── main.dart                 → App entry, GoRouter setup, Provider init
├── theme/                    → AppTheme (light/dark)
├── models/models.dart        → Question, Survey, Respondent, Notification, SyncHistoryItem
├── services/
│   ├── app_state.dart        → Central ChangeNotifier (auth, sync, surveys)
│   ├── auth_service.dart     → HTTP calls to /api/auth/*
│   └── storage_service.dart  → SharedPreferences offline persistence
└── screens/ (12 screens)     → Splash, Login, OTP, Dashboard, Surveys,
                                 Respondents, SurveyForm, Sync, Analytics,
                                 Notifications, Profile, Settings
```

---

## ✅ Completed Modules

### Backend
| Feature | Status | Notes |
|---|---|---|
| Express server setup | ✅ Complete | Runs on port 3000 |
| PostgreSQL connection (Prisma) | ✅ Complete | `prisma db push` applied |
| Prisma schema | ✅ Complete | User, Survey, Category, Response models |
| User registration (`POST /api/auth/register`) | ✅ Complete | bcryptjs hashing, Prisma `user.create` |
| User login (`POST /api/auth/login`) | ✅ Complete | bcrypt compare, 30-day JWT |
| JWT middleware (`protect`) | ✅ Complete | DB lookup, isActive check |
| Role authorization (`authorize`) | ✅ Complete | Middleware built, not yet applied to routes |
| Get profile (`GET /api/auth/profile`) | ✅ Complete | Full user from DB |
| Survey CRUD — Full | ✅ Complete | Create, List, GetById, Update, Delete |
| Response Sync (`POST /api/responses/sync`) | ✅ Complete | Bulk offline sync for Flutter |
| Reports/Stats API | ✅ Complete | Admin dashboard aggregation |
| Category Management | ✅ Complete | List and Create categories |
| User Management | ✅ Complete | List and Update users (Admin) |
| Health check (`GET /api/health`) | ✅ Complete | |
| `.env` configuration | ✅ Complete | Single DATABASE_URL, JWT_SECRET |

### Frontend
| Feature | Status | Notes |
|---|---|---|
| Flutter project structure | ✅ Complete | Provider, GoRouter, modular screens |
| Auth routing guard | ✅ Complete | GoRouter redirect on `isLoggedIn` |
| Login screen | ✅ Complete | Calls `AuthService.login()` |
| Splash screen | ✅ Complete | Checks stored auth on startup |
| App state (ChangeNotifier) | ✅ Complete | Central truth for auth, surveys, sync |
| JWT storage | ✅ Complete | SharedPreferences (`jwt_token`) |
| AuthService HTTP client | ✅ Complete | `/login`, `/register`, `/me` |
| Offline storage (SharedPreferences) | ✅ Complete | Respondents, pending, sync history |
| Local respondent management | ✅ Complete | Add, draft, submit, track status |
| Pending sync queue | ✅ Complete | Queue built, cleared on success |
| Sync screen + sync logic | ✅ Complete | `syncAll()` posts to `/api/responses/sync` |
| Auto-sync on connectivity restore | ✅ Complete | `connectivity_plus` listener |
| All 10 question types (model) | ✅ Complete | `QuestionType` enum + `Question` model |
| Survey form screen | ✅ Complete | Renders questions by type |
| Surveys list screen | ✅ Complete | Filter by status (pending/in_progress/synced) |
| Respondents screen | ✅ Complete | Per-survey respondent list |
| Dashboard screen | ✅ Complete | Stats, quick actions, recent activity |
| Analytics screen | ✅ Complete | Local stats (total, completed, synced) |
| Notifications screen | ✅ Complete | Static notifications (not yet API-driven) |
| Profile screen | ✅ Complete | Displays stored user data |
| Settings screen | ✅ Complete | Dark mode, auto-sync, language placeholder |
| Dark / Light theme | ✅ Complete | Material 3 theming |
| OTP screen | ✅ Structural | UI complete, OTP logic not wired to backend |

---

## ⚠️ Partially Implemented

| Feature | Status | Notes |
|---|---|---|
| Survey fetching from backend | ✅ Complete | `getAssignedSurveys` implemented |
| Sync endpoint | ✅ Complete | `POST /api/responses/sync` implemented |
| Analytics | ✅ Complete | Backend aggregation stats implemented |
| `getMe` / `/api/auth/profile` | ✅ Complete | Redirected or mapped to `/profile` |
| Notification system | ⚠️ Partial | Backend foundation ready, but not yet API-driven |
| Survey assignment | ⚠️ Partial | Filtered by active status; specific assignment model planned |
| OTP login | ⚠️ Partial | UI exists, backend routes pending |
| User region/role display | ✅ Complete | Returned from profile API |

---

## ❌ Missing / Not Yet Implemented

### Backend APIs Required
| Endpoint | Status | Description |
|---|---|---|
| `POST /api/responses/sync` | ✅ Done | Accept and store bulk survey responses from Flutter |
| `GET /api/surveys/assigned` | ✅ Done | Return surveys for field staff |
| `GET /api/responses` | ✅ Done | Admin: list all responses |
| `GET /api/reports/stats` | ✅ Done | Admin: dashboard aggregate stats |
| `PUT /api/surveys/:id` | ✅ Done | Admin: update survey |
| `DELETE /api/surveys/:id` | ✅ Done | Admin: soft delete |
| `GET /api/categories` | ✅ Done | Category listing |
| `POST /api/categories` | ✅ Done | Admin: create category |
| `GET /api/users` | ✅ Done | Admin: list all users |
| `PUT /api/users/:id` | ✅ Done | Admin/Self: update user |
| `POST /api/auth/otp/send` | 🔴 Planned | OTP-based login |
| `POST /api/auth/otp/verify` | 🔴 Planned | OTP verification |

### Frontend Features Not Yet Implemented
| Feature | Priority | Notes |
|---|---|---|
| Wire `fetchSurveys()` to real backend | 🔴 Critical | Replace demo data with `GET /api/surveys` |
| Admin panel / web dashboard | 🟡 High | Not started. Requirements specify admin role. | Don't needed
| Survey creation UI (admin) | 🟡 High | No create-survey screen exists | Don't needed
| CSV / PDF export | 🟢 Medium | `exportSurveyData()` is a stub |
| Push notifications | 🟢 Medium | Requires FCM integration |
| GPS/location capture per response | 🟢 Medium | Referenced in requirements |
| Photo attachment per response | 🟢 Medium | Requirements mention photo capture |
| Role-based UI (Admin vs FieldStaff) | 🟡 High | `userRole` tracked but no UI branching | Don't neede admin functionality
| OTP backend integration | 🟢 Medium | Screen built, no backend |

---

## Database Integration Status

| Model | Schema | Migrated | API Exposed |
|---|---|---|---|
| User | ✅ Prisma | ✅ `db push` applied | ✅ List/Update/Profile |
| Survey | ✅ Prisma | ✅ `db push` applied | ✅ Create/List/Update/Delete |
| Category | ✅ Prisma | ✅ `db push` applied | ✅ List/Create |
| Response | ✅ Prisma | ✅ `db push` applied | ✅ Sync/List |

---

## Authentication Status

| Layer | Status |
|---|---|
| Backend: Password hashing (bcryptjs) | ✅ Complete |
| Backend: JWT generation (30-day) | ✅ Complete |
| Backend: JWT verification middleware | ✅ Complete |
| Backend: DB-backed user lookup in middleware | ✅ Complete |
| Backend: `isActive` account check | ✅ Complete |
| Backend: Role-based `authorize()` | ✅ Built, not yet applied to routes |
| Frontend: JWT stored in SharedPreferences | ✅ Complete |
| Frontend: Token sent in Authorization header | ✅ Complete |
| Frontend: Session persists across restarts | ✅ Complete |
| Frontend: Logout clears token and state | ✅ Complete |
| OTP Login | ❌ Not implemented |

---

## Offline Sync Status

| Feature | Status |
|---|---|
| Local respondent storage (SharedPreferences) | ✅ Complete |
| Pending queue (add/clear) | ✅ Complete |
| Sync history tracking | ✅ Complete |
| Last sync timestamp | ✅ Complete |
| Auto-sync on connectivity restore | ✅ Complete |
| `syncAll()` HTTP call to backend | ✅ Built |
| Backend sync endpoint (`/api/responses/sync`) | ✅ Complete |

---

## Overall Completion Estimate

| Area | Completion |
|---|---|
| Backend infrastructure & auth | 95% |
| Backend survey APIs | 90% |
| Backend response/sync APIs | 100% |
| Backend admin/reporting APIs | 100% |
| Flutter authentication flow | 90% |
| Flutter survey collection flow | 75% |
| Flutter offline storage | 95% |
| Flutter sync mechanism | 90% |
| Flutter admin features | 0% |
| End-to-end integration | 80% |
| **Overall Project** | **~85%** |

---

## Remaining Development Roadmap

### Phase 1 — Frontend Integration (High Priority)
1. **Wire `fetchSurveys()`** — Replace demo data in `app_state.dart` with real `GET /api/surveys/assigned` call.
2. **Fix `AuthService.getMe()`** — Update frontend to call `/api/auth/profile` (backend expects `/profile`, frontend calls `/me`).
3. **Fix Registration Field** — Update `AuthService.register()` to send `full_name` instead of `username`.
4. **Role-based UI** — Implement logic to show/hide admin features based on `user.role`.

### Phase 2 — Advanced Backend Features
5. **OTP Authentication** — Implement `POST /api/auth/otp/send` and `verify`.
6. **Specific Assignment Model** — Move from "all active" to a specific `SurveyAssignment` model for better control.

### Phase 3 — Field Data Enhancements
7. **GPS Capture** — Capture coordinates on survey submission.
8. **Photo Attachments** — Support for image uploads in responses.
9. **Push Notifications** — Real-time alerts for new assignments.

---

## Technical Debt & Notes

- `AuthService.getMe()` calls `/api/auth/me` — backend only exposes `/api/auth/profile`. **Fix the URL.**
- `app_state.dart` `register()` sends `username` but `auth.controller.js` expects `full_name` in `req.body` — **field name mismatch**.
- `fetchSurveys()` contains commented-out real API code and falls back to hardcoded surveys. Must be replaced before real field use.
- Survey `questions` field in Prisma schema is `Json` (JSONB). Ensure backend serializes the `Question` model correctly when returning surveys to Flutter.
- `sqflite` is declared as a dependency in `pubspec.yaml` but is unused — `StorageService` uses `SharedPreferences` only. Consider removing or migrating to SQLite for larger datasets.
- Notification list is hardcoded in `AppState` — must be API-driven before production.
