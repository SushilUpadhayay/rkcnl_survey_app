# RKCNL Survey Application - API Integration Map

This document serves as the master API integration map between the Flutter Frontend and the Node.js/PostgreSQL Backend.

---

## 1. Authentication & Profile APIs

### API: `POST /api/auth/register`
* **Status**: ⚠️ Placeholder implemented, needs real production logic in frontend
* **Purpose**: Register a new user (Admin or FieldStaff).
* **Access Type**: Public
* **Request Body**: `{ "username": "string", "email": "string", "password": "string", "role": "string" }`
* **Response Structure**: `{ "success": true, "token": "string", "user": { ... } }`

**Frontend Files:**
- `lib/services/auth_service.dart` (To be implemented)
- `lib/services/app_state.dart` (Needs `register()` method)
- `lib/screens/login_screen.dart` (Needs UI for registration)

**Backend Files:**
- `backend/src/routes/auth.routes.js`
- `backend/src/controllers/auth.controller.js`
- `backend/prisma/schema.prisma` (User model)

### API: `POST /api/auth/login`
* **Status**: ✅ Implemented
* **Purpose**: Authenticate user and issue a JWT.
* **Access Type**: Public
* **Request Body**: `{ "email": "string", "password": "string" }`
* **Response Structure**: `{ "success": true, "token": "string", "user": { ... } }`

**Frontend Files:**
- `lib/services/auth_service.dart`
- `lib/services/app_state.dart` (Handles `login()`)
- `lib/screens/login_screen.dart`
- `lib/services/storage_service.dart` (Saves auth token)

**Backend Files:**
- `backend/src/routes/auth.routes.js`
- `backend/src/controllers/auth.controller.js`

### API: `GET /api/auth/profile`
* **Status**: ✅ Implemented
* **Purpose**: Fetch details of the currently logged-in user.
* **Access Type**: Private
* **Request Body**: None (Uses Bearer Token)
* **Response Structure**: `{ "success": true, "data": { "id": "...", "username": "...", "email": "...", "role": "..." } }`

**Frontend Files:**
- `lib/services/auth_service.dart`
- `lib/services/app_state.dart`
- `lib/screens/profile_screen.dart` (Needs to consume this instead of local mock)

**Backend Files:**
- `backend/src/routes/auth.routes.js`
- `backend/src/controllers/auth.controller.js`
- `backend/src/middleware/auth.middleware.js`

---

## 2. Survey APIs

### API: `GET /api/surveys/assigned`
* **Status**: ✅ Implemented
* **Purpose**: Fetch all active surveys explicitly assigned to the logged-in field surveyor.
* **Access Type**: Private (FieldStaff)
* **Request Body**: None
* **Response Structure**: `{ "success": true, "count": 1, "data": [ { "id": "...", "title": "...", "questions": [ ... ] } ] }`

**Frontend Files:**
- `lib/services/app_state.dart` (In `fetchSurveys()`)
- `lib/models/models.dart` (`Survey.fromJson`)
- `lib/screens/home_screen.dart`
- `lib/screens/surveys_screen.dart`

**Backend Files:**
- `backend/src/routes/survey.routes.js`
- `backend/src/controllers/survey.controller.js`
- `backend/prisma/schema.prisma` (`Survey` and `SurveyAssignment` models)

### API: `POST /api/surveys`
* **Status**: ✅ Implemented
* **Purpose**: Create a new survey with dynamic JSONB questions.
* **Access Type**: Private (Admin)
* **Request Body**: `{ "title": "string", "description": "string", "questions": [ ... ], "categoryId": "string" }`
* **Response Structure**: `{ "success": true, "data": { ... } }`

**Frontend Files:**
- N/A (Consumed by Admin Web Panel)

**Backend Files:**
- `backend/src/routes/survey.routes.js`
- `backend/src/controllers/survey.controller.js`

### API: `POST /api/surveys/assign`
* **Status**: ✅ Implemented
* **Purpose**: Assign a survey to a specific FieldStaff user.
* **Access Type**: Private (Admin)
* **Request Body**: `{ "surveyId": "string", "userId": "string" }`
* **Response Structure**: `{ "success": true, "data": { ... } }`

**Frontend Files:**
- N/A (Consumed by Admin Web Panel)

**Backend Files:**
- `backend/src/routes/survey.routes.js`
- `backend/src/controllers/survey.controller.js`

### API: `GET /api/surveys` & `GET /api/surveys/:id` & `PUT` & `DELETE`
* **Status**: ✅ Implemented
* **Purpose**: CRUD operations for surveys.
* **Access Type**: Public/Private (Admin)

**Backend Files:**
- `backend/src/routes/survey.routes.js`
- `backend/src/controllers/survey.controller.js`

---

## 3. Response / Sync APIs

### API: `POST /api/responses/sync`
* **Status**: ✅ Implemented
* **Purpose**: Bulk upload offline responses. Includes GPS data and Base64-encoded photos.
* **Access Type**: Private (FieldStaff)
* **Request Body**: 
```json
{
  "responses": [
    {
      "surveyId": "string",
      "deviceTimestamp": "ISO-8601 string",
      "answers": [ { "questionId": "string", "answer": "any" } ],
      "latitude": 27.7,
      "longitude": 85.3,
      "photos": [ "base64String1", "base64String2" ]
    }
  ]
}
```
* **Response Structure**: `{ "success": true, "message": "Synced X responses", "results": [ ... ] }` (Returns 200 or 207)

**Frontend Files:**
- `lib/services/app_state.dart` (In `syncAll()`)
- `lib/models/models.dart` (`Respondent`)
- `lib/screens/sync_screen.dart`

**Backend Files:**
- `backend/src/routes/response.routes.js`
- `backend/src/controllers/response.controller.js`
- `backend/prisma/schema.prisma` (`Response` model with `latitude`, `longitude`, `photos` JSONB)

### API: `GET /api/responses`
* **Status**: ✅ Implemented
* **Purpose**: Retrieve all survey responses for analytics and review.
* **Access Type**: Private (Admin)

**Backend Files:**
- `backend/src/routes/response.routes.js`
- `backend/src/controllers/response.controller.js`

---

## 4. Category APIs

### API: `GET /api/categories` & `POST /api/categories`
* **Status**: ✅ Implemented
* **Purpose**: Read/Create survey categories (e.g., 'Agriculture', 'Water').
* **Access Type**: Public / Private (Admin)

**Backend Files:**
- `backend/src/routes/category.routes.js`
- `backend/src/controllers/category.controller.js`

---

## 5. User Management APIs

### API: `GET /api/users` & `PUT /api/users/:id`
* **Status**: ✅ Implemented
* **Purpose**: View all users and update roles (Admin functionality).
* **Access Type**: Private (Admin)

**Backend Files:**
- `backend/src/routes/user.routes.js`
- `backend/src/controllers/user.controller.js`

---

## 6. Reporting & Analytics APIs

### API: `GET /api/reports/stats`
* **Status**: ✅ Implemented
* **Purpose**: Fetch top-level KPIs (Total Responses, Active Surveys, Active Users) for Admin dashboards.
* **Access Type**: Private (Admin)
* **Response Structure**: `{ "success": true, "data": { "totalResponses": 150, "activeSurveys": 5, "activeUsers": 12 } }`

**Frontend Files:**
- `lib/services/app_state.dart` (Inside `fetchGlobalStats()` - currently ⚠️ Placeholder logic needs replacing with real HTTP GET request)
- `lib/screens/analytics_screen.dart`

**Backend Files:**
- `backend/src/routes/report.routes.js`
- `backend/src/controllers/report.controller.js`

### API: `GET /api/reports/export/:surveyId`
* **Status**: ❌ Missing (Needs Implementation)
* **Purpose**: Generate and download a CSV/PDF of all responses for a given survey.
* **Access Type**: Private (Admin)

**Frontend Files:**
- `lib/services/app_state.dart` (Inside `exportSurveyData()` - currently ⚠️ Placeholder mock delay)
- `lib/screens/analytics_screen.dart`

**Backend Files:**
- Needs new route in `report.routes.js` or `response.routes.js`

---

## 7. Push Notifications (Future Implementation)

### API: `POST /api/notifications/token`
* **Status**: ❌ Missing (Requires Supervisor Integration/Approval for FCM architecture)
* **Purpose**: Register the mobile device's Firebase Cloud Messaging token to the user's profile for push notifications on new survey assignments.
* **Access Type**: Private

**Frontend Files:**
- Needs Firebase setup in `pubspec.yaml`
- `lib/services/notification_service.dart` (To be created)
- `lib/services/app_state.dart`

**Backend Files:**
- Needs new model field for FCM tokens in `schema.prisma`
- Needs new route and controller for handling notifications.
