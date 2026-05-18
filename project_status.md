# RKCNL Survey Application — Project Status

**Last Updated:** 2026-05-18
**Version:** 1.0.0
**Stack:** Flutter (Mobile) · Node.js + Express · Prisma ORM · PostgreSQL

---

## Project Overview

The RKCNL (Rastriye Krishi Company Nepal Limited) Survey Application is a **FieldStaff-only** offline-first mobile platform for agricultural field data collection. Field surveyors use the app to receive assigned surveys, collect responses with GPS and photo capture, and sync all data back to the backend when connectivity is available.

Survey creation, user management, and administrative operations are handled by a **separate web portal system** and are not part of this mobile application.

---

## ✅ Completed

### Backend Infrastructure & API
- Express server with Prisma ORM and PostgreSQL connection.
- FieldStaff JWT authentication: registration, login, profile fetch, and token verification middleware.
- Survey assignment fetch endpoint (`GET /api/surveys/assigned`).
- Bulk offline response sync endpoint (`POST /api/responses/sync`) with GPS and Base64 photo support.
- Self-service profile update (`PUT /api/users/:id`).
- Health check endpoint (`GET /api/health`).
- Environment configuration via `.env`.

### Flutter Mobile Application
- GoRouter navigation, Provider state management, Material 3 theming (Dark/Light).
- Full JWT authentication flow: Login, Registration, secure token storage via `SharedPreferences`.
- Offline-first architecture: local respondent storage, pending sync queue, sync history.
- Dynamic survey form engine supporting all 10 question types.
- GPS location capture and photo attachment per respondent.
- Auto-sync on connectivity restore and manual sync all.
- Client-side analytics: surveys completed, pending count, today's submissions, total synced.
- Screens: Dashboard, Surveys List, Respondents, Survey Form, Sync, Notifications, Profile, Settings.

---

## ⏳ Planned Features

- **Push Notifications:** Firebase Cloud Messaging (FCM) for real-time survey assignment alerts.
- **Data Export:** CSV/PDF export of synced respondent data.

---

## Overall Completion

| Area | Completion | Status |
|---|---|---|
| Backend Infrastructure & Auth | 100% | ✅ Complete |
| Backend Survey/Response APIs | 100% | ✅ Complete |
| Flutter Authentication Flow | 100% | ✅ Complete |
| Flutter Offline Storage & Sync | 100% | ✅ Complete |
| Flutter Survey Collection Flow | 100% | ✅ Complete |
| Survey Assignments & Media | 100% | ✅ Complete |
| FieldStaff-Only Architecture Refactor | 100% | ✅ Complete |
| End-to-End Integration | 100% | ✅ Complete |
| **Overall Project** | **~95%** | 🟢 On Track |

---

## 🚀 Next Steps

1. Integrate Firebase Cloud Messaging (FCM) for push notifications.
2. Implement CSV/PDF export functionality for synced survey data.
