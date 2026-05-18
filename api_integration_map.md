# RKCNL Survey Application - Master API Integration Map

This document serves as the master API integration map defining the data contracts, security guidelines, and architectural alignments between the Flutter Frontend Mobile Application and the Node.js/Prisma/PostgreSQL Backend. 

The application is structured as a **surveyor-focused offline-first client** utilizing dynamic JSONB-based survey schemas. There is no supervisor/admin dashboard interface in the mobile application; however, the backend server implements ready-to-use administrative APIs to support future management integrations.

---

## 1. System Technology Stack

| Tier | Technology | Key Responsibility | Configured File / Entry |
| :--- | :--- | :--- | :--- |
| **Mobile Client** | Flutter / Dart | UI Rendering, Offline Caching, Sync Queue, Geolocation, Base64 Image Processing | [main.dart](file:///e:/rkcnl_survey_app/frontend/lib/main.dart) |
| **Backend Runtime** | Node.js / Express | Route Dispatching, Authorization, Request Parsing, Status Verification | [index.js](file:///e:/rkcnl_survey_app/backend/index.js) |
| **ORM & Schema** | Prisma Client | Type-Safe Database Queries, Data Migrations, PostgreSQL Interaction | [schema.prisma](file:///e:/rkcnl_survey_app/backend/prisma/schema.prisma) |
| **Database** | PostgreSQL | Persistent Storage, JSONB Columns for Dynamic Questions & Responses | [db.js](file:///e:/rkcnl_survey_app/backend/src/config/db.js) |
| **Local Cache** | SharedPreferences | Persistent Key-Value & JSON List Local Storage on the Mobile Device | [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) |

---

## 2. End-to-End API Workflow

All network requests from the mobile application progress through a secure, structured flow from user action to physical persistence:

```text
Flutter Screen (UI User Action)
    ↓
AppState / Provider (App State & Trigger)
    ↓
Service / API Layer (auth_service.dart / http request)
    ↓
JWT Authentication Header (Bearer Token Authorization)
    ↓
Backend Express Route (route dispatching in index.js)
    ↓
protect / authorize Middleware (JWT token validation, expiration checking)
    ↓
Controller Handler (request verification & response marshalling)
    ↓
Prisma Client ORM (type-safe SQL transaction generation)
    ↓
PostgreSQL Database (JSONB & Row writes)
```

### Detailed Execution Tiers:
1. **User Action**: The surveyor triggers an action (e.g., submitting a completed survey).
2. **State Management**: [app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) intercepts the request, formats the data, and prepares local backups.
3. **Network Call**: [auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) executes HTTP calls using the `http` package, appending JWT headers for private endpoints.
4. **Express Routing**: [index.js](file:///e:/rkcnl_survey_app/backend/index.js) handles context parsing and redirects execution to the designated route file.
5. **Security Middleware**: [auth.middleware.js](file:///e:/rkcnl_survey_app/backend/src/middleware/auth.middleware.js) validates the `Bearer <Token>`, queries the database to ensure the user is active, and mounts the active user on `req.user`.
6. **Data Operations**: The controller triggers Prisma transactions to write, read, or sync models with PostgreSQL.

---

## 3. Offline Survey Sync Workflow

Because surveyors operate in remote areas with volatile network connectivity, the system utilizes a robust, offline-first queuing architecture:

```text
Surveyor Completes Survey in UI
      ↓
Respondent Object Saved in SharedPreferences (draft/completed state)
      ↓
Record Appended to Pending Sync Queue (rkcnl_pending key)
      ↓
connectivity_plus Detects Internet Restoration
      ↓
AppState triggers _triggerAutoSync() -> syncAll()
      ↓
Bulk POST /api/responses/sync (Base64 media payload & device timestamps)
      ↓
Prisma Transaction validates Survey IDs & inserts Response records in bulk
      ↓
On Success: Queue Cleared, Synced Key populated, Surveyor Local Status updated
```

### Detailed Sync Steps:
1. **Local Save**: The surveyor records responses. The app writes the [Respondent](file:///e:/rkcnl_survey_app/frontend/lib/models/models.dart) object to local storage with a `completed` state.
2. **Queue Insertion**: [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) saves a summary of the pending sync.
3. **Connectivity Listening**: [app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) listens for cellular/Wi-Fi status via `Connectivity()`.
4. **Base64 Processing**: The sync engine reads image files on disk, converts them to Base64, and forms the payload array.
5. **Database Transaction**: The backend handles the bulk array in a safe loop, persisting responses and GPS data via a Prisma schema write.
6. **State Cleansing**: The local pending sync list is deleted, and the survey state updates to `synced` in the local cache.

---

## 4. JWT Protected Request Flow

Every private endpoint requires authentication via JSON Web Tokens (JWT). The verification process on the server is as follows:

```
Request Header: Authorization: Bearer <jwt_token>
                      ↓
           auth.middleware.js [protect]
                      ↓
       Is Authorization Header present?
             /                 \
          [No]                 [Yes]
           /                     \
Return 401 Unauthorized      Extract Token & jwt.verify()
                             /                 \
                      [Invalid/Expired]       [Valid Payload]
                             /                     \
                   Return 401 Unauthorized     Prisma query: findUnique(User.id)
                                               /                 \
                                           [User Inactive]     [User Active]
                                                 /                     \
                                       Return 401 Unauthorized   Attach req.user & next()
```

* **Token Expiration**: Tokens are issued with a `30d` (30 days) lifespan, allowing surveyors to stay logged in long-term for offline workloads.

---

## 5. Core Surveyor APIs (Consumed by Mobile Application)

These APIs represent the operational pipelines wired directly into the Surveyor Flutter application.

### 5.1 POST `/api/auth/register`
* **Status**: ✅ Implemented
* **Purpose**: Register a new field surveyor account.
* **Access Type**: Public (No JWT required)
* **Request Body**:
  ```json
  {
    "full_name": "Sushil Upadhayay",
    "gender": "Male",
    "date_of_birth": "1998-05-12",
    "location": "Ward 4, Northern Region",
    "email": "sushil@example.com",
    "phone": "+977-9876543210",
    "password": "Password123"
  }
  ```
* **Response Structure (201 Created)**:
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "data": {
      "id": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
      "username": "Sushil Upadhayay",
      "email": "sushil@example.com",
      "gender": "Male",
      "dateOfBirth": "1998-05-12",
      "location": "Ward 4, Northern Region",
      "phone": "+977-9876543210",
      "role": "FieldStaff",
      "createdAt": "2026-05-18T01:30:00.000Z"
    }
  }
  ```

#### Files Responsible for Integration
* **Frontend**:
  * [register_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/register_screen.dart) (View captures surveyor details)
  * [auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) (`register()` network execution)
  * [app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) (Calls authentication service and manages loading state)
* **Backend**:
  * [auth.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/auth.routes.js) (Routes `POST /register` to registration controller)
  * [auth.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/auth.controller.js) (`register()` handles parsing, bcrypt hashing, Prisma user records creation)
  * [schema.prisma](file:///e:/rkcnl_survey_app/backend/prisma/schema.prisma) (`User` model definition)

---

### 5.2 POST `/api/auth/login`
* **Status**: ✅ Implemented
* **Purpose**: Authenticate surveyor credentials and return authorization token.
* **Access Type**: Public (No JWT required)
* **Request Body**:
  ```json
  {
    "email": "sushil@example.com",
    "password": "Password123"
  }
  ```
* **Response Structure (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Login successful",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "data": {
      "id": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
      "username": "Sushil Upadhayay",
      "email": "sushil@example.com",
      "role": "FieldStaff"
    }
  }
  ```

#### Files Responsible for Integration
* **Frontend**:
  * [login_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/login_screen.dart) (Renders credentials form)
  * [auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) (`login()` API hit, persists JWT securely in `SharedPreferences`)
  * [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) (`saveAuth()` keeps high-level state logged in locally)
  * [app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) (`login()` controller coordinator)
* **Backend**:
  * [auth.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/auth.routes.js) (Routes `POST /login`)
  * [auth.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/auth.controller.js) (`login()` checks user, compares hash via `bcrypt.compare`, signs token via `jwt.sign`)

---

### 5.3 GET `/api/auth/profile`
* **Status**: ✅ Implemented
* **Purpose**: Retrieve full identity details of the logged-in surveyor.
* **Access Type**: Private (JWT Required)
* **Headers**: `Authorization: Bearer <token>`
* **Response Structure (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Profile retrieved successfully",
    "data": {
      "id": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
      "username": "Sushil Upadhayay",
      "email": "sushil@example.com",
      "role": "FieldStaff",
      "isActive": true,
      "createdAt": "2026-05-18T01:30:00.000Z"
    }
  }
  ```

#### Files Responsible for Integration
* **Frontend**:
  * [profile_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/profile_screen.dart) (Displays session metadata)
  * [auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart) (`getMe()` execution using authenticated header)
* **Backend**:
  * [auth.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/auth.routes.js) (Routes `GET /profile` protected by `protect`)
  * [auth.middleware.js](file:///e:/rkcnl_survey_app/backend/src/middleware/auth.middleware.js) (Attaches active DB user profile onto `req.user`)
  * [auth.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/auth.controller.js) (`getProfile()` handles JSON mapping)

---

### 5.4 GET `/api/surveys/assigned`
* **Status**: ✅ Implemented
* **Purpose**: Fetch all active survey forms assigned specifically to the logged-in field surveyor.
* **Access Type**: Private (JWT Required)
* **Headers**: `Authorization: Bearer <token>`
* **Response Structure (200 OK)**:
  ```json
  {
    "success": true,
    "count": 1,
    "data": [
      {
        "id": "a9041a7d-b3e3-47a3-b541-e945c71120ab",
        "title": "Crop Health & Soil Survey",
        "description": "Assess regional agricultural crop health metrics in Ward 4.",
        "status": "Active",
        "isDeleted": false,
        "questions": [
          {
            "id": "q1",
            "type": "MultiChoiceSingleSelect",
            "text": "What is the primary crop grown in this plot?",
            "isRequired": true,
            "options": ["Rice", "Maize", "Wheat", "Barley", "Millet"]
          },
          {
            "id": "q2",
            "type": "RatingScale",
            "text": "Rate the observable health of the crop crops.",
            "maxRating": 5,
            "isRequired": false
          }
        ],
        "categoryId": "281c7ba1-1df3-40f4-b203-d6c70014bdf1",
        "category": {
          "id": "281c7ba1-1df3-40f4-b203-d6c70014bdf1",
          "name": "Agriculture"
        },
        "createdById": "3df7ba1c-a111-40e1-bb1c-d788910beaf1",
        "createdAt": "2026-05-18T01:35:00.000Z",
        "updatedAt": "2026-05-18T01:35:00.000Z"
      }
    ]
  }
  ```

#### Files Responsible for Integration
* **Frontend**:
  * [surveys_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/surveys_screen.dart) (Lists downloaded assignments)
  * [app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) (`fetchSurveys()` executes and converts response items)
  * [models.dart](file:///e:/rkcnl_survey_app/frontend/lib/models/models.dart) (`Survey.fromJson` decodes the assigned surveys and parses legacy strings to modern `QuestionType` enums)
* **Backend**:
  * [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js) (Registers `/assigned` route)
  * [survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js) (`getAssignedSurveys()` queries assignments by surveyor userId, filters active projects, returns data payload)
  * [schema.prisma](file:///e:/rkcnl_survey_app/backend/prisma/schema.prisma) (`SurveyAssignment` & `Survey` model relations)

---

### 5.5 POST `/api/responses/sync`
* **Status**: ✅ Implemented
* **Purpose**: Synchronize survey response payloads collected offline to the cloud, including geoposition and base64-encoded photos.
* **Access Type**: Private (JWT Required)
* **Headers**: `Authorization: Bearer <token>`
* **Request Body**:
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
        "personalNotes": "Survey conducted in heavy rain. Crops look healthy overall.",
        "latitude": 27.700769,
        "longitude": 85.30014,
        "photos": ["iVBORw0KGgoAAAANSUhEUgAAADIA...", "iVBORw0KGgoAAAANSUhEUgAAADJA..."]
      }
    ]
  }
  ```
* **Response Structure (200 OK / 207 Partial Success)**:
  ```json
  {
    "success": true,
    "message": "All responses synced successfully",
    "results": [
      {
        "surveyId": "a9041a7d-b3e3-47a3-b541-e945c71120ab",
        "responseId": "8da71a62-a6ee-48c2-a8c4-be1f6004b12a",
        "success": true
      }
    ]
  }
  ```

#### Files Responsible for Integration
* **Frontend**:
  * [sync_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/sync_screen.dart) (Allows user to inspect pending items and trigger manual synchronization)
  * [app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart) (`syncAll()` builds Base64 mappings, prepares payloads, sends POST request, clears offline caches)
  * [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) (`getPending()`, `clearPending()`, `addSynced()` managing offline state arrays)
* **Backend**:
  * [response.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/response.routes.js) (Routes `POST /sync` to synchronization logic)
  * [response.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/response.controller.js) (`syncResponses()` acts in bulk loops, verifies survey existence, writes Prisma `Response` objects containing lat/long floats and photos JSON array)
  * [schema.prisma](file:///e:/rkcnl_survey_app/backend/prisma/schema.prisma) (`Response` model representation)

---

### 5.6 PUT `/api/users/:id`
* **Status**: ✅ Implemented
* **Purpose**: Let field staff update their own account profile configurations (e.g. changing username).
* **Access Type**: Private (JWT Required)
* **Headers**: `Authorization: Bearer <token>`
* **Request Body**:
  ```json
  {
    "username": "Sushil Upadhayay II"
  }
  ```
* **Response Structure (200 OK)**:
  ```json
  {
    "success": true,
    "message": "User updated successfully",
    "data": {
      "id": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
      "username": "Sushil Upadhayay II",
      "email": "sushil@example.com",
      "role": "FieldStaff",
      "isActive": true,
      "updatedAt": "2026-05-18T02:00:00.000Z"
    }
  }
  ```

#### Files Responsible for Integration
* **Frontend**:
  * [profile_screen.dart](file:///e:/rkcnl_survey_app/frontend/lib/screens/profile_screen.dart) (Captured update inputs)
* **Backend**:
  * [user.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/user.routes.js) (Routes `PUT /:id` to user controller)
  * [user.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/user.controller.js) (`updateUser()` parses inputs, authorizes that the active JWT matches user `:id`, updates records via Prisma)

---

## 6. Administrative Backend APIs (Future Dashboards Coordination)

These endpoints are implemented on the Node.js backend. The surveyor application does not consume them, but they are fully ready for integration with supervisor web platforms or admin interfaces.

| Method & Endpoint | Access Type | Status | Purpose | Responsible Files |
| :--- | :--- | :--- | :--- | :--- |
| **`POST /api/surveys`** | Private (JWT Required) | ✅ Implemented | Admin registers new survey templates. | [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js)<br>[survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js#L6) |
| **`POST /api/surveys/assign`** | Private (JWT Required) | ✅ Implemented | Link survey assignments to specific surveyors. | [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js)<br>[survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js#L165) |
| **`GET /api/surveys`** | Public | ✅ Implemented | Lists all active survey projects. | [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js)<br>[survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js#L54) |
| **`GET /api/surveys/:id`** | Public | ✅ Implemented | Fetch survey questions details by survey ID. | [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js)<br>[survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js#L85) |
| **`PUT /api/surveys/:id`** | Private (JWT Required) | ✅ Implemented | Modify titles, options, questions list. | [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js)<br>[survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js#L219) |
| **`DELETE /api/surveys/:id`** | Private (JWT Required) | ✅ Implemented | soft-delete survey templates. | [survey.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/survey.routes.js)<br>[survey.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/survey.controller.js#L267) |
| **`GET /api/categories`** | Public | ✅ Implemented | Lists all categories defined in system. | [category.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/category.routes.js)<br>[category.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/category.controller.js#L6) |
| **`POST /api/categories`** | Private (JWT Required) | ✅ Implemented | Create survey categories. | [category.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/category.routes.js)<br>[category.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/category.controller.js#L21) |
| **`GET /api/reports/stats`** | Private (JWT Required) | ✅ Implemented | Fetch global stats (counts of surveys, responses, fieldstaff accounts). | [report.routes.js](file:///e:/rkcnl_survey_app/backend/src/routes/report.routes.js)<br>[report.controller.js](file:///e:/rkcnl_survey_app/backend/src/controllers/report.controller.js#L6) |

---

## 7. Planned Future APIs

### 7.1 POST `/api/notifications/token`
* **Status**: ❌ Planned (Missing)
* **Purpose**: Register a device FCM Push Notification token on a surveyor profile for assignment notices.
* **Access Type**: Private (JWT Required)
* **Proposed Request Body**:
  ```json
  {
    "userId": "7fa85b61-da2f-48e2-b01c-1bb3705be8b2",
    "token": "fcm-registration-token-string"
  }
  ```

---

## 8. Key Integration Points & Placeholders

Developers extending this codebase should note these critical synchronization entry points:

1. **Host Configuration Location**:
   Inside [auth_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/auth_service.dart), the `baseUrl` is set to `http://10.0.2.2:3000/api/auth` which routes local requests appropriately through Android Emulators. Change this address when shifting to staging/production server environments.
2. **Local Base64 Conversion Block**:
   Inside [app_state.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/app_state.dart#L338-L350), files collected offline are parsed asynchronously from disk, mapped into base64, and packaged into the payload array immediately before transmission.
3. **Database Client Pool**:
   [db.js](file:///e:/rkcnl_survey_app/backend/src/config/db.js) registers and exposes a single shared `PrismaClient` pool instance. Always query through this single instance to prevent server connection leaks.
4. **Offline Database Backups**:
   The class `StorageService` in [storage_service.dart](file:///e:/rkcnl_survey_app/frontend/lib/services/storage_service.dart) provides high-level hooks (`_prefs.setString()`) for saving models in local JSON files. If SQLite or Hive integration is requested in future phases, swap out `StorageService` calls without touching UI screen architectures.
