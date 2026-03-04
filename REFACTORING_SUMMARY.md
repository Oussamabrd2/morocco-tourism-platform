# PFE Refactoring Summary

## Overview

This document summarizes all architectural changes, fixes, and improvements made to the Laravel + Flutter social tourism application (Ziarat).

---

## 1. Laravel Backend

### Models

| Model | Changes |
|-------|---------|
| **User** | Added `role` to fillable; `posts()`, `organizedActivities()` relationships; `isAdmin()`, `isOrganizer()` helpers |
| **Post** | Unchanged (already correct) |
| **Location** | Unchanged (already correct) |
| **Activity** | Unchanged (already correct) |
| **Rating** | Unchanged (already correct) |

### Controllers & API Resources

- **PostController**: Added `show()`, `destroy()`; wrapped responses in `data` + `meta`; uses `PostResource`; multipart image upload; improved validation
- **LocationController**: Uses `LocationResource`; consistent `data`/`meta`; `withCount('ratings')` + `withAvg('ratings', 'score')` for ratings
- **ActivityController**: Uses `ActivityResource`; consistent responses; role-based create (organizer/admin)
- **UserController**: Uses `UserResource`; validation for update; `posts_count` appended
- **AuthController**: Unchanged (returns user + token)

**New Resources:**
- `app/Http/Resources/PostResource.php`
- `app/Http/Resources/LocationResource.php`
- `app/Http/Resources/ActivityResource.php`
- `app/Http/Resources/UserResource.php`

### Policies

- **PostPolicy**: `delete` allows owner OR admin
- **ActivityPolicy**: `create` requires organizer or admin; `delete` allows organizer OR admin
- **UserPolicy**: Unchanged (owner-only update)

### Migrations

- `2026_02_21_005519_add_role_to_users_table.php`: Fixed `down()` to drop `role` column

### Admin Dashboard (Web)

- **Middleware**: `AdminMiddleware` – blocks non-admin users
- **Routes**: `/admin` (dashboard), `/admin/users/{id}/role`, `/admin/posts/delete`, `/admin/activities/delete`
- **Auth**: Web login at `/login` (admin-only for dashboard)
- **Dashboard**: Total users, posts, reviews, activities; user list with role change; delete post/activity forms
- **Views**: `resources/views/auth/login.blade.php`, `resources/views/admin/dashboard.blade.php`

### API Response Structure

All API responses now follow:

```json
{
  "data": { ... },
  "meta": { "current_page": 1, "last_page": 1, "per_page": 20, "total": N }
}
```

Paginated endpoints: `posts`, `locations`, `activities`.

---

## 2. Flutter App

### ApiService

- **Base URL**: `http://192.168.0.164:8000` (change in `api_service.dart` for your environment)
- **Endpoints**: All use `/api/v1/` prefix (posts, locations, activities, user, auth)
- **Token**: Sent in `Authorization: Bearer <token>` header for protected routes
- **Models**: `Post`, `Location`, `Activity` – aligned with backend JSON
- **createPost**: Multipart form-data with image file support
- **createActivity**: For organizer/admin
- **joinActivity** / **cancelActivity**: For activity participation

### Views

| View | Changes |
|------|---------|
| **FeedView** | Fetches from `/api/v1/posts`; parses `data`; displays title, body, user, location, rating, image |
| **CreatePost** | Multipart upload; title, body, score, image file; token in header |
| **GuideView** | Now displays **locations** (was create-post form); ratings + reviews count; search; dark theme |
| **MapView** | **flutter_map** + **latlong2**; OpenStreetMap tiles; markers from locations; bottom sheet on marker tap |
| **ActivitiesView** | Fetches from `/api/v1/activities`; FAB to create activity only for organizer/admin |
| **ActivityDetail** | Join / Cancel participation; full activity info |
| **Profile** | Fetches user from API; edit profile (name, email, bio); displays role; logout |
| **CreateActivity** | New screen for organizer/admin to create activities |

### Theme

- Dark theme with orange accents
- Consistent `Colors.black`, `Color(0xFF1A1A1A)` surfaces

### Dependencies

- `flutter_map: ^6.1.0`
- `latlong2: ^0.9.0`

---

## 3. Database

### Role Column (users table)

- Values: `user`, `organizer`, `admin` (default: `user`)
- Migration: `2026_02_21_005519_add_role_to_users_table.php`
- Run: `php artisan migrate`

---

## 4. Features Implemented / Fixed

### A) Feed View
- ✅ Fetches posts from database
- ✅ Connected to `/api/v1/posts`
- ✅ Displays image, title, content, author, location, rating
- ✅ Dark theme

### B) Create Post
- ✅ Connected to backend
- ✅ Token in header
- ✅ Multipart with image file
- ✅ Saves in database
- ✅ Returns proper JSON

### C) Guide View
- ✅ Fetches ALL locations from database
- ✅ Ordered by name
- ✅ Average rating from reviews
- ✅ Number of reviews
- ✅ Dark theme

### D) Map Page
- ✅ flutter_map + OpenStreetMap
- ✅ Locations from database
- ✅ Dynamic markers
- ✅ Dark style bottom sheet

### E) Activities
- ✅ Fetches from database
- ✅ Create activity only if role = organizer or admin
- ✅ Join / Cancel activity
- ✅ Sanctum-protected routes
- ✅ Activity detail with join/cancel

### F) Profile
- ✅ Fetches authenticated user
- ✅ Displays name, email, role
- ✅ Edit profile (modal)
- ✅ Updates database

### G) Admin Dashboard
- ✅ `/admin` route
- ✅ Total users, posts, reviews, activities
- ✅ User list with role change (user / organizer / admin)
- ✅ Delete post / activity
- ✅ Admin middleware
- ✅ Web login (admin-only)

---

## 5. Suggested Folder Structure

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── Api/           # API controllers
│   │   ├── Admin/         # Admin web controllers
│   │   └── Auth/          # Web auth (login)
│   ├── Middleware/
│   │   └── AdminMiddleware.php
│   └── Resources/         # API Resources
├── Models/
└── Policies/

flutter_app/lib/
├── main.dart
└── src/
    ├── models/            # DTOs (optional, currently in api_service)
    ├── routes/
    ├── services/
    └── views/
```

---

## 6. Environment Setup

### Laravel
1. `php artisan migrate` (including `add_role_to_users_table`)
2. `php artisan storage:link` (for post images)
3. Ensure first admin: update a user's role to `admin` in DB, then log in at `/login`

### Flutter
1. Update `apiBase` in `api_service.dart` to your Laravel API URL
2. `flutter pub get`
3. For Android: add `android:usesCleartextTraffic="true"` in manifest if using HTTP

---

## 7. Security Notes

- Sanctum used for API auth
- Admin dashboard protected by `auth` + `admin` middleware
- Policies enforce ownership/admin for delete
- Activity creation restricted to organizer/admin
- User update restricted to own profile
