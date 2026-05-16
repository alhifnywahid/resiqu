🌐 **Language:** [Indonesia](README.md) | English

# 📦 ResiQu - Package Transit Tracking System

Inter-island package transit tracking system for shipping services. Consists of an admin app (mobile) and a public tracking website for buyers.

## Sub-Projects

| Project  | Stack                          | Description                              |
| -------- | ------------------------------ | ---------------------------------------- |
| `admin/` | Flutter · GetX · Firebase      | Admin app for managing packages & batches |
| `buyer/` | Next.js · Tailwind CSS · Firebase | Public website for package tracking       |

## Architecture

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│  Admin App   │────▶│  Cloud Firestore │◀────│ Buyer Website│
│  (Flutter)   │     │  (Shared DB)     │     │  (Next.js)   │
└──────────────┘     └──────────────────┘     └──────────────┘
```

Both apps share a single **Cloud Firestore** database as the single source of truth.

---

## Prerequisites

- **Flutter SDK** ≥ 3.22
- **Node.js** ≥ 20 + **pnpm**
- **Firebase project** already configured (see [Firebase Setup](#-firebase-setup))

---

## Quick Start

### Admin App (Flutter)

```bash
cd admin
flutter pub get
flutter run
```

> ⚠️ Make sure `android/app/google-services.json` exists and matches your Firebase project.

### Buyer Website (Next.js)

```bash
cd buyer
pnpm install
cp .env.example .env.local  # fill in Firebase variables
pnpm dev
```

---

## Makefile Commands

| Command                | Description                           |
| ---------------------- | ------------------------------------- |
| `make run-app`         | Run admin app (Flutter debug)         |
| `make run-web`         | Run buyer website (Next.js dev)       |
| `make build-app`       | Build release APK                     |
| `make build-web`       | Build production website              |
| `make clean-app`       | Clean Flutter cache                   |
| `make clean-web`       | Clean Node.js dependencies            |
| `make fingerprint-app` | Generate SHA-1/SHA-256 for Firebase   |

---

## Project Structure

```
resiqu/
├── admin/                       # Flutter admin mobile app
│   └── lib/
│       ├── core/
│       │   ├── constants/       # PackageStatus, BatchStatus, AppStrings
│       │   ├── routes/          # App routes & pages
│       │   ├── services/        # ConnectivityService, ExportService
│       │   ├── theme/           # AppTheme (Material 3)
│       │   └── utils/           # DateFormatter, StringUtils
│       ├── features/
│       │   ├── auth/            # Google Sign-In + allowlist
│       │   ├── batches/         # Container management
│       │   ├── dashboard/       # Status summary
│       │   ├── packages/        # Package management
│       │   ├── settings/        # App settings
│       │   └── splash/          # Splash + auth check
│       │   └── {feature}/
│       │       ├── data/        # Repository (Firestore)
│       │       ├── domain/      # Models
│       │       └── presentation/
│       │           ├── bindings/
│       │           ├── controllers/
│       │           └── pages/
│       └── shared/widgets/      # Reusable components
├── buyer/                       # Next.js buyer website
│   ├── app/                     # App Router pages
│   ├── components/              # UI components
│   ├── hooks/                   # Custom React hooks
│   ├── lib/                     # Firebase config, utilities
│   ├── services/                # Data fetching
│   └── types/                   # TypeScript interfaces
└── Makefile                     # Development shortcuts
```

---

## Features

### Admin App

- ✅ Google login (Firestore allowlist, @gmail.com only)
- ✅ Package status dashboard summary
- ✅ CRUD packages with auto-generated code `RSQ-YYYYMMDD-XXXXXX`
- ✅ Group packages by recipient name
- ✅ Barcode/QR scanner with flashlight toggle
- ✅ Batch/container management (create, fill, dispatch, arrive, delete)
- ✅ Delete container with cascade release of packages to transit status
- ✅ Validation: empty containers cannot be dispatched
- ✅ Validation: date fields locked after container is dispatched/arrived
- ✅ Update package status + full history
- ✅ Export to Excel & PDF
- ✅ Share via WhatsApp
- ✅ Offline-first (Firestore persistence)

### Status Flow

```
Received → In Container → In Transit → Arrived at Destination → Completed
                                                              ↘ Issue
```

### Buyer Website

- ✅ Track packages via tracking code / marketplace receipt
- ✅ Full status timeline with timestamps
- ✅ Open container info (transit schedule)
- ✅ Starbucks-inspired design (warm cream canvas, green system)
- ✅ Responsive design
- ✅ SEO-optimized

---

## Tech Stack

**Admin (Flutter):**

```
get, firebase_core, firebase_auth, cloud_firestore
google_sign_in, mobile_scanner, excel, pdf, printing
share_plus, connectivity_plus, intl, uuid
```

**Buyer (Next.js):**

```
next, react, firebase, date-fns
tailwindcss v4
```

---

## 🔥 Firebase Setup

### Step 1 - Create Project

1. Go to https://console.firebase.google.com
2. **Create Project** → name: `ResiQu` → **Continue**
3. Disable Google Analytics → **Create Project**

### Step 2 - Enable Firestore

1. **Build → Firestore Database → Create Database**
2. **Test mode** → Location: `asia-southeast2` → **Enable**

### Step 3 - Enable Authentication

1. **Build → Authentication → Get Started**
2. **Sign-in method** → Enable **Google** → fill email → **Save**

### Step 4 - Add Android App

1. **Project Overview → ➕ Add app → Android**
2. Package name: `id.resiqu.admin` → Register
3. Get SHA-1:
   ```bash
   cd admin/android && ./gradlew signingReport
   ```
4. **Project Settings → Your apps → Add fingerprint** → paste SHA-1
5. Download `google-services.json` → place in `admin/android/app/`

> ⚠️ Make sure the new file has a non-empty `oauth_client` (contains `client_type: 1`)

### Step 5 - Add Web App (Buyer)

1. **Project Overview → ➕ Add app → Web**
2. Nickname: `Buyer` → Register
3. Copy config to `buyer/.env.local`:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=...
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...
```

### Step 6 - Create Admin Whitelist

The admin whitelist determines who can log in. Create in Firestore:

```
Collection: admins
Document ID: youremail@gmail.com

Fields:
  email     (string)    → youremail@gmail.com
  name      (string)    → Your Name
  createdAt (timestamp) → (current date)
```

> ⚠️ Document ID **MUST** exactly match the Google email. The app checks `admins/{email}`.

### Step 7 - Set Security Rules

In **Firestore → Rules**, paste and publish:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    function isAdmin() {
      return request.auth != null
        && exists(/databases/$(database)/documents/admins/$(request.auth.token.email));
    }

    match /admins/{email} {
      allow read, write: if isAdmin();
    }

    match /packages/{packageId} {
      allow read: if true;
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();

      match /statusHistory/{historyId} {
        allow read: if true;
        allow create: if isAdmin();
        allow update: if false;
        allow delete: if isAdmin();
      }
    }

    match /batches/{batchId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Access per Collection:**

| Collection                 | Admin          | Buyer (Public) |
| -------------------------- | -------------- | -------------- |
| `admins`                   | ✅ Read/Write  | ❌             |
| `packages`                 | ✅ Read/Write  | ✅ Read only   |
| `packages/*/statusHistory` | ✅ Read/Create | ✅ Read only   |
| `batches`                  | ✅ Read/Write  | ✅ Read only   |

---

## Database Schema

| Collection                    | Description                                                                        |
| ----------------------------- | ---------------------------------------------------------------------------------- |
| `admins/{email}`              | Admin allowlist (email, name, createdAt)                                           |
| `packages/{id}`               | Package data (trackingCode, recipientName, currentStatus, batchId, dimensions, ...) |
| `packages/{id}/statusHistory` | Status history (status, note, updatedBy, timestamp)                                |
| `batches/{id}`                | Container (name, destinationCity, status, packageIds, startDate, expiryDate)       |

---

## Troubleshooting

| Problem                       | Solution                                                             |
| ----------------------------- | -------------------------------------------------------------------- |
| Google Sign-In closes immediately | Check SHA-1 is added. Re-download `google-services.json`.        |
| Login succeeds but rejected   | Email not in `admins` collection.                                    |
| `oauth_client: []` is empty   | SHA-1 not added to Firebase project.                                 |

---

## Setup Checklist

- [ ] Firebase project created
- [ ] Firestore enabled (asia-southeast2)
- [ ] Google Auth enabled
- [ ] Android app registered + SHA-1 added
- [ ] `google-services.json` valid (has `oauth_client`)
- [ ] Web app registered
- [ ] `buyer/.env.local` filled
- [ ] `admins` collection created
- [ ] Security Rules published
- [ ] `flutter run` → login succeeds

---

## License

Private - All rights reserved.
