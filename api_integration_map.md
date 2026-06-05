# RKCNL Survey Application — Master API Integration Map

This document is the master API reference for the RKCNL Survey Application, defining all data contracts, security specifications, and architectural alignments between the Flutter FieldStaff mobile client and the Node.js/Prisma/PostgreSQL backend.

The application is a **FieldStaff-only offline-first survey platform**. Survey templates are created externally via a web portal. The mobile app exclusively handles field data collection by authenticated surveyors.

---

## 1. System Technology Stack

| Tier | Technology | Key Responsibility | Entry Point |
| :--- | :--- | :--- | :--- |
| **Mobile Client** | Flutter / Dart | UI, Offline Caching, Sync Queue, GPS, Base64 Photo Processing | [main.dart](file:///e:/rkcnl_survey_app/frontend/lib/main.dart) |
| **Backend Runtime** | Node.js / Express | Route Dispatching, JWT Authorization, Request Parsing | [index.js](file:///e:/rkcnl_survey_app/backend/index.js) |
| **ORM & Schema** | Prisma Client | Type-Safe DB Queries, PostgreSQL Interaction | [schema.prisma](file:///e:/rkcnl_survey_app/backend/prisma/schema.prisma) |
| **Database** | PostgreSQL | Persistent Storage, JSONB for Questions & Responses | [db.js](file:///e:/rkcnl_survey_app/backend/src/config/db.js) |
| **Local Cache** | SharedPreferences | Device-side Persistent Key-Value & JSON Storage | [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) |

---

## 2. Active API Endpoints

All endpoints below are implemented and consumed by the FieldStaff mobile application.

| # | Endpoint | Method | Access | Purpose | Frontend | Backend |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | `/api/auth/register` | `POST` | Public | Register a new FieldStaff account | [register_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/register_screen.dart)<br>[auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) | [auth.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/auth.routes.js)<br>[auth.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/auth.controller.js) |
| 2 | `/api/auth/login` | `POST` | Public | Authenticate and receive JWT | [login_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/login_screen.dart)<br>[auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) | [auth.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/auth.routes.js)<br>[auth.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/auth.controller.js) |
| 3 | `/api/auth/profile` | `GET` | Private | Fetch authenticated user profile | [profile_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/profile_screen.dart)<br>[auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) | [auth.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/auth.routes.js)<br>[auth.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/auth.controller.js) |
| 4 | `/api/users/:id` | `PUT` | Private | Update own profile (self only) | [profile_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/profile_screen.dart) | [user.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/user.routes.js)<br>[user.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/user.controller.js) |
| 5 | `/api/surveys/assigned` | `GET` | Private | Fetch active surveys assigned to this surveyor | [surveys_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/surveys_screen.dart)<br>[app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) | [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js)<br>[survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js) |
| 6 | `/api/responses/sync` | `POST` | Private | Bulk upload offline responses with GPS & photos | [sync_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/sync_screen.dart)<br>[app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) | [response.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/response.routes.js)<br>[response.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/response.controller.js) |
| 7 | `/api/health` | `GET` | Public | Backend health check | — | [index.js](file:///e:/rkcnl_survey_app/backend/index.js) |

---

## 3. End-to-End Request Flow

```text
Flutter Screen (User Action)
    ↓
AppState / Provider (State & Trigger)
    ↓
AuthService (HTTP Request + JWT Header)
    ↓
Express Router (index.js)
    ↓
protect Middleware (JWT verification, user active check)
    ↓
Controller (request handling + Prisma query)
    ↓
PostgreSQL (JSONB & relational row writes)
```

---

## 4. Offline Survey Sync Workflow

```text
Surveyor Completes Survey Form
    ↓
Respondent saved to SharedPreferences (completed state)
    ↓
ID added to rkcnl_pending queue
    ↓
connectivity_plus detects internet restore
    ↓
AppState._triggerAutoSync() → syncAll()
    ↓
Photo files → Base64 encoded strings
    ↓
POST /api/responses/sync (bulk payload)
    ↓
Prisma writes Response records (answers, GPS, photos JSONB)
    ↓
Success: rkcnl_pending cleared → rkcnl_synced updated
```

---

## 5. JWT Authentication Flow

```text
Request: Authorization: Bearer <jwt_token>
    ↓
auth.middleware.js [protect]
    ↓
Token present?
    ├── No  → 401 Unauthorized
    └── Yes → jwt.verify()
                ├── Invalid/Expired → 401 Unauthorized
                └── Valid → prisma.user.findUnique(id)
                                ├── Not found   → 401 Unauthorized
                                ├── isActive=false → 401 Unauthorized
                                └── Active → attach req.user → next()
```

- **Token Expiry:** 30 days — supports long offline periods in remote areas.
- **JWT Payload:** `{ id, email }` — role is always `"FieldStaff"` and is read directly from the database when needed.

---

## 6. Detailed API Contracts

### 6.1 POST `/api/auth/register`
**Request Body:**
```json
{
<<<<<<< HEAD
  "full_name": "Rubi Adhikari",
  "gender": "Female",
  "date_of_birth": "1998-05-12",
  "location": "Ward 4, Northern Region",
  "email": "rubi.adhikari@example.com",
=======
  "full_name": "Sushil Upadhayay",
  "gender": "Male",
  "date_of_birth": "1998-05-12",
  "location": "Ward 4, Northern Region",
  "email": "sushil@example.com",
>>>>>>> register
  "phone": "+977-9876543210",
  "password": "Password123"
}
```
<<<<<<< HEAD
**RRubi Adhikari
=======
**Response (201):**
>>>>>>> register
```json
{
  "success": true,
  "message": "Account registered successfully",
  "data": {
    "id": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
<<<<<<< HEAD
    "username": "Rubi Adhikari",
    "email": "rubi.adhikari@example.com",
=======
    "username": "Sushil Upadhayay",
    "email": "sushil@example.com",
>>>>>>> register
    "role": "FieldStaff",
    "createdAt": "2026-05-18T01:30:00.000Z"
  }
}
```

---

### 6.2 POST `/api/auth/login`
**Request Body:**
```json
<<<<<<< HEAD
{ "email": "rubi.adhikari@example.com", "password": "Password123" }
=======
{ "email": "sushil@example.com", "password": "Password123" }
>>>>>>> register
```
**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "id": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
<<<<<<< HEAD
    "username": "Rubi Adhikari",
    "email": "rubi.adhikari@example.com"
=======
    "username": "Sushil Upadhayay",
    "email": "sushil@example.com"
>>>>>>> register
  }
}
```

---

### 6.3 GET `/api/auth/profile`
**Headers:** `Authorization: Bearer <token>`
**Response (200):**
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
<<<<<<< HEAD
    "username": "Rubi Adhikari",
    "email": "rubi.adhikari@example.com",
    "gender": "Female",
=======
    "username": "Sushil Upadhayay",
    "email": "sushil@example.com",
    "gender": "Male",
>>>>>>> register
    "phone": "+977-9876543210",
    "location": "Ward 4, Northern Region",
    "isActive": true,
    "createdAt": "2026-05-18T01:30:00.000Z"
  }
}
```

---

### 6.4 GET `/api/surveys/assigned`
**Headers:** `Authorization: Bearer <token>`
**Response (200):**
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": "a9041a7d-b3e3-47a3-b541-e945c71120ab",
      "title": "Crop Health & Soil Survey",
      "description": "Assess regional agricultural metrics in Ward 4.",
      "status": "Active",
      "questions": [
        {
          "id": "q1",
          "type": "MultiChoiceSingleSelect",
          "text": "What is the primary crop grown?",
          "isRequired": true,
          "options": ["Rice", "Maize", "Wheat", "Barley", "Millet"]
        },
        {
          "id": "q2",
          "type": "RatingScale",
          "text": "Rate the observable crop health.",
          "maxRating": 5,
          "isRequired": false
        }
      ],
      "category": { "id": "...", "name": "Agriculture" },
      "createdAt": "2026-05-18T01:35:00.000Z"
    }
  ]
}
```

---

### 6.5 POST `/api/responses/sync`
**Headers:** `Authorization: Bearer <token>`
**Request Body:**
```json
{
  "responses": [
    {
      "surveyId": "a9041a7d-b3e3-47a3-b541-e945c71120ab",
      "deviceTimestamp": "2026-05-18T07:15:30.000Z",
      "answers": [
        { "questionId": "q1", "answer": "Rice" },
        { "questionId": "q2", "answer": 4 }
      ],
      "customQuestions": [],
      "personalNotes": "Crops look healthy. Survey in light rain.",
      "latitude": 27.700769,
      "longitude": 85.30014,
      "photos": ["iVBORw0KGgoAAAANSUhEUgAAADIA..."]
    }
  ]
}
```
**Response (200 / 207 Partial):**
```json
{
  "success": true,
  "message": "All responses synced successfully",
  "results": [
    { "surveyId": "a9041a7d...", "responseId": "8da71a62...", "success": true }
  ]
}
```

---

## 7. Client-Side Analytics

Surveyor stats are computed entirely from local `SharedPreferences` — no backend reporting endpoint is required:

| Stat | AppState Property | Source |
| :--- | :--- | :--- |
| Surveys completed | `completedResponses` | Local respondent status count |
| Pending sync count | `pendingCount` | `rkcnl_pending` queue length |
| Today's submissions | `todayCompleted` | Completed respondents with today's date |
| Total synced | `syncedCount` | `rkcnl_synced` list length |

---

<<<<<<< HEAD
## 8. Data Export (Client-Side CSV)

Surveyors can export their locally collected respondent data as a CSV file directly from the Sync screen. This is a **fully client-side operation** — no backend endpoint is required.

| Step | Detail |
| :--- | :--- |
| **Trigger** | "Export Data" button on Sync screen |
| **Source** | All respondents across all surveys from `SharedPreferences` |
| **Format** | CSV (comma-separated values) via `csv` package |
| **Delivery** | System share dialog via `share_plus` package |
| **Columns** | Survey, Respondent Name, Phone, Gender, Age, Status, GPS, Completed At, Answers |

---

## 9. Key Integration Notes

1. **Base URL:** `AuthService.baseUrl` in [auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) is set to `http://10.0.2.2:3000/api/auth` for Android emulator. Update for production server.
2. **Base64 Photos:** Photo file paths are converted to Base64 inside `AppState.syncAll()` immediately before upload.
3. **DB Client:** A single shared `PrismaClient` instance is used across all controllers — see [db.js](file:///e:/rkcnl_survey_app/backend/src/config/db.js).
4. **Local Storage Extensibility:** `StorageService` in [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) can be swapped for SQLite/Hive without touching UI screens.

---

## 10. Planned Future APIs

=======
## 8. Key Integration Notes

1. **Base URL:** `AuthService.baseUrl` in [auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) is set to `http://10.0.2.2:3000/api/auth` for Android emulator. Update for production server.
2. **Base64 Photos:** Photo file paths are converted to Base64 inside `AppState.syncAll()` immediately before upload.
3. **DB Client:** A single shared `PrismaClient` instance is used across all controllers — see [db.js](file:///e:/rkcnl_survey_app/backend/src/config/db.js).
4. **Local Storage Extensibility:** `StorageService` in [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) can be swapped for SQLite/Hive without touching UI screens.

---

## 9. Planned Future APIs

>>>>>>> register
### POST `/api/notifications/token`
- **Status:** ❌ Planned
- **Purpose:** Register device FCM Push Notification token for real-time survey assignment alerts.
- **Access:** Private (JWT Required)
