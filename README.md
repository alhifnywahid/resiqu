🌐 **Bahasa:** Indonesia | [English](README.en.md)

# 📦 ResiQu - Package Transit Tracking System

Sistem tracking paket transit antar pulau untuk jasa pengiriman. Terdiri dari aplikasi admin (mobile) dan website tracking publik untuk pembeli.

## Sub-Projects

| Project  | Stack                          | Deskripsi                                     |
| -------- | ------------------------------ | --------------------------------------------- |
| `admin/` | Flutter · GetX · Firebase      | Aplikasi admin untuk kelola paket & kontainer |
| `buyer/` | Next.js · Tailwind CSS · Firebase | Website publik untuk lacak paket              |

## Arsitektur

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│  Admin App   │────▶│  Cloud Firestore │◀────│ Buyer Website│
│  (Flutter)   │     │  (Shared DB)     │     │  (Next.js)   │
└──────────────┘     └──────────────────┘     └──────────────┘
```

Kedua aplikasi berbagi satu database **Cloud Firestore** sebagai single source of truth.

---

## Prasyarat

- **Flutter SDK** ≥ 3.22
- **Node.js** ≥ 20 + **pnpm**
- **Firebase project** yang sudah dikonfigurasi (lihat bagian [Firebase Setup](#-firebase-setup))

---

## Quick Start

### Admin App (Flutter)

```bash
cd admin
flutter pub get
flutter run
```

> ⚠️ Pastikan `android/app/google-services.json` sudah ada dan cocok dengan Firebase project.

### Buyer Website (Next.js)

```bash
cd buyer
pnpm install
cp .env.example .env.local  # isi variabel Firebase
pnpm dev
```

---

## Makefile Commands

| Perintah               | Deskripsi                             |
| ---------------------- | ------------------------------------- |
| `make run-app`         | Jalankan admin app (Flutter debug)    |
| `make run-web`         | Jalankan buyer website (Next.js dev)  |
| `make build-app`       | Build release APK                     |
| `make build-web`       | Build production website              |
| `make clean-app`       | Bersihkan cache Flutter               |
| `make clean-web`       | Bersihkan dependencies Node.js        |
| `make fingerprint-app` | Generate SHA-1/SHA-256 untuk Firebase |

---

## Struktur Proyek

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
│       │   ├── batches/         # Kontainer management
│       │   ├── dashboard/       # Status summary
│       │   ├── packages/        # Paket management
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

## Fitur

### Admin App

- ✅ Login via Google (allowlist Firestore, hanya @gmail.com)
- ✅ Dashboard ringkasan status paket
- ✅ CRUD paket dengan auto-generate kode `RSQ-YYYYMMDD-XXXXXX`
- ✅ Pengelompokan paket per nama penerima
- ✅ Barcode/QR scanner dengan flashlight toggle
- ✅ Manajemen kontainer/box (buat, isi paket, dispatch, arrive, hapus)
- ✅ Hapus kontainer dengan cascade release paket ke status transit
- ✅ Validasi: kontainer kosong tidak bisa dikirim
- ✅ Validasi: tanggal terkunci setelah kontainer dikirim/tiba
- ✅ Update status paket + riwayat lengkap
- ✅ Export ke Excel & PDF
- ✅ Share via WhatsApp
- ✅ Offline-first (Firestore persistence)

### Status Flow

```
Diterima → Dalam Box → Dalam Perjalanan → Tiba di Tujuan → Selesai
                                                        ↘ Kendala
```

### Buyer Website

- ✅ Lacak paket publik via tracking code / resi marketplace
- ✅ Timeline status lengkap dengan waktu
- ✅ Info kontainer terbuka (jadwal transit)
- ✅ Desain Starbucks-inspired (warm cream canvas, green system)
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

### Step 1 - Buat Project

1. Buka https://console.firebase.google.com
2. **Create Project** → nama: `ResiQu` → **Continue**
3. Disable Google Analytics → **Create Project**

### Step 2 - Aktifkan Firestore

1. **Build → Firestore Database → Create Database**
2. **Test mode** → Lokasi: `asia-southeast2` → **Enable**

### Step 3 - Aktifkan Authentication

1. **Build → Authentication → Get Started**
2. **Sign-in method** → Enable **Google** → isi email → **Save**

### Step 4 - Tambah Android App

1. **Project Overview → ➕ Add app → Android**
2. Package name: `id.resiqu.admin` → Register
3. Dapatkan SHA-1:
   ```bash
   cd admin/android && ./gradlew signingReport
   ```
4. **Project Settings → Your apps → Add fingerprint** → paste SHA-1
5. Download `google-services.json` → taruh di `admin/android/app/`

> ⚠️ Pastikan file baru punya `oauth_client` yang **TIDAK kosong** (ada `client_type: 1`)

### Step 5 - Tambah Web App (Buyer)

1. **Project Overview → ➕ Add app → Web**
2. Nickname: `Buyer` → Register
3. Copy config ke `buyer/.env.local`:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=...
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...
```

### Step 6 - Buat Admin Whitelist

Admin whitelist menentukan siapa yang boleh login. Buat di Firestore:

```
Collection: admins
Document ID: emailkamu@gmail.com

Fields:
  email     (string)    → emailkamu@gmail.com
  name      (string)    → Nama Kamu
  createdAt (timestamp) → (tanggal sekarang)
```

> ⚠️ Document ID **HARUS** sama persis dengan email Google. App cek `admins/{email}`.

### Step 7 - Pasang Security Rules

Di **Firestore → Rules**, paste dan publish:

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

**Akses per Collection:**

| Collection                 | Admin          | Buyer (Public) |
| -------------------------- | -------------- | -------------- |
| `admins`                   | ✅ Read/Write  | ❌             |
| `packages`                 | ✅ Read/Write  | ✅ Read only   |
| `packages/*/statusHistory` | ✅ Read/Create | ✅ Read only   |
| `batches`                  | ✅ Read/Write  | ✅ Read only   |

---

## Database Schema

| Koleksi                       | Deskripsi                                                                         |
| ----------------------------- | --------------------------------------------------------------------------------- |
| `admins/{email}`              | Allowlist admin (email, name, createdAt)                                          |
| `packages/{id}`               | Data paket (trackingCode, recipientName, currentStatus, batchId, dimensions, ...) |
| `packages/{id}/statusHistory` | Riwayat status (status, note, updatedBy, timestamp)                               |
| `batches/{id}`                | Kontainer (name, destinationCity, status, packageIds, startDate, expiryDate)      |

---

## Troubleshooting

| Masalah                       | Solusi                                                              |
| ----------------------------- | ------------------------------------------------------------------- |
| Google Sign-In langsung close | Cek SHA-1 sudah ditambahkan. Download ulang `google-services.json`. |
| Login sukses tapi ditolak     | Email belum ada di collection `admins`.                             |
| `oauth_client: []` kosong     | SHA-1 belum ditambahkan ke Firebase project.                        |

---

## Setup Checklist

- [ ] Firebase project dibuat
- [ ] Firestore aktif (asia-southeast2)
- [ ] Auth Google aktif
- [ ] Android app terdaftar + SHA-1 ditambahkan
- [ ] `google-services.json` valid (ada `oauth_client`)
- [ ] Web app terdaftar
- [ ] `buyer/.env.local` diisi
- [ ] Collection `admins` dibuat
- [ ] Security Rules di-publish
- [ ] `flutter run` → login sukses

---

## License

Private - All rights reserved.
