# CommunityHub

A comprehensive residential community management platform built with **Flutter** (mobile app) and **Next.js** (admin panel), powered by **Supabase** as the backend.

## Overview

CommunityHub enables residents to manage visitor access, book facilities, raise complaints, track maintenance bills, and stay informed about community announcements. The admin panel provides management tools for society administrators.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CommunityHub                              │
├──────────────────────────────┬──────────────────────────────────┤
│     Mobile App (Flutter)     │    Admin Panel (Next.js)         │
│  ┌────────────────────────┐  │  ┌────────────────────────────┐  │
│  │ Resident Features      │  │  │ Admin Features             │  │
│  ├────────────────────────┤  │  ├────────────────────────────┤  │
│  │ • Visitor Passes (QR)  │  │  │ • Dashboard Analytics      │  │
│  │ • Facility Booking     │  │  │ • Resident Management      │  │
│  │ • Complaint System     │  │  │ • Facility Management      │  │
│  │ • Maintenance Bills    │  │  │ • Announcement Management  │  │
│  │ • Profile & Family     │  │  │ • Billing & Payments       │  │
│  │ • Vehicles             │  │  │ • Staff Assignment         │  │
│  │ • Notifications        │  │  │ • Reports & Exports        │  │
│  └────────────────────────┘  │  └────────────────────────────┘  │
└──────────────────────────────┴──────────────────────────────────┘
                              │
                              ▼
                    ┌───────────────────────┐
                    │    Supabase Backend   │
                    │  ┌─────────────────┐  │
                    │  │ PostgreSQL DB   │  │
                    │  │ Auth (Email/OTP)│  │
                    │  │ Realtime        │  │
                    │  │ Storage         │  │
                    │  │ Edge Functions  │  │
                    │  └─────────────────┘  │
                    └───────────────────────┘
```

---

## Features

### Resident Mobile App

| Feature | Description |
|---------|-------------|
| **Visitor Management** | Generate QR code passes with OTP, share via WhatsApp/Share sheet, revoke passes, view history |
| **Facility Booking** | Browse facilities (clubhouse, gym, pool, etc.), select date/time slots with conflict prevention, view booking history |
| **Complaint System** | Raise complaints with photos, categories (Plumbing, Electrical, Security, etc.), emergency flag, track status |
| **Maintenance & Billing** | View outstanding dues, payment history, expense breakdown, multiple payment methods (UPI, Card, Net Banking) |
| **Profile Management** | Edit profile, manage family members, register vehicles, notification preferences, privacy settings |
| **Announcements** | View society announcements with pinned/highlighted posts |
| **AI Chat Assistant** | Floating action button for quick help |

### Admin Panel (Next.js)

- Dashboard with analytics
- Resident management
- Facility & schedule management
- Announcement publishing
- Billing cycle management
- Staff assignment for complaints
- Reports & data exports

---

## Tech Stack

### Mobile App (Flutter)
| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x (Dart 3.12+) |
| State Management | `setState` / `FutureBuilder` (lightweight) |
| Backend | Supabase Flutter SDK (`supabase_flutter`) |
| UI | Material 3, Custom Theme (`AppTheme`), Google Fonts |
| Icons | `lucide_icons_flutter` |
| QR/Scanning | `qr_flutter`, `mobile_scanner` |
| Image Picker | `image_picker` |
| Sharing | `share_plus`, `url_launcher` |
| Auth | `local_auth` (biometric) |
| Env Config | `flutter_dotenv` |
| UUID | `uuid` |

### Admin Panel (Next.js)
| Category | Technology |
|----------|------------|
| Framework | Next.js 16 (App Router) |
| Language | TypeScript |
| UI | React 19, Tailwind CSS (implied), `lucide-react` |
| Charts | `recharts` |
| QR Scanning | `html5-qrcode`, `@yudiel/react-qr-scanner` |
| Backend | Supabase JS SDK (`@supabase/supabase-js`) |
| Linting | ESLint 9, `eslint-config-next` |

### Backend (Supabase)
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Auth**: Email/OTP, JWT tokens
- **Realtime**: Live updates for bookings, complaints, announcements
- **Storage**: Complaint images, avatars
- **Edge Functions**: Serverless logic (if used)

---

## Database Schema (Key Tables)

```sql
-- Core tables
societies                 -- Society/Community info
apartments               -- Units within society
residents                -- User profiles (linked to auth.users)
family_members           -- Resident's family
vehicles                 -- Resident vehicles

-- Features
visitors                 -- Guest invites (QR codes, OTP, status)
facilities               -- Bookable amenities (clubhouse, gym, pool)
facility_schedules       -- Operating hours by day type (weekday/weekend/holiday)
bookings                 -- Facility reservations with conflict prevention
holidays                 -- Society holidays affecting schedules
facility_slot_blocks     -- Admin-blocked time slots

complaints               -- Resident complaints with images, priority, status
billing_cycles           -- Maintenance bills (pending/paid/overdue)
payments                 -- Payment transactions
announcements            -- Society notices (pinned, tags, icons)

-- Security
-- Row Level Security policies on all tables
-- Triggers for booking conflict prevention (prevent_overlapping_bookings.sql)
-- Auto-cleanup for cancelled bookings (auto_delete_cancelled.sql)
```

---

## Project Structure

### Flutter App (`lib/`)
```
lib/
├── main.dart                          # App entry, Supabase init, theme
├── core/
│   ├── config/
│   │   └── env.dart                   # Supabase URL & Anon Key
│   ├── constants/
│   │   └── app_spacing.dart           # Consistent spacing tokens
│   ├── models/                        # Data models (User, Booking, Complaint, etc.)
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_typography.dart        # Text styles
│   │   └── app_theme.dart             # ThemeData (light/dark)
│   └── widgets/
│       ├── custom_icon.dart           # Lucide icon wrapper
│       └── user_avatar.dart           # Generated avatar widget
└── features/
    ├── auth/
    │   └── presentation/pages/login_page.dart
    ├── layout/
    │   └── presentation/
    │       ├── widgets/bottom_tab_bar.dart
    │       ├── widgets/ai_chat_fab.dart
    │       └── pages/main_layout_page.dart
    ├── home/
    │   └── presentation/
    │       ├── widgets/ (header, banners, quick actions, cards)
    │       └── pages/home_dashboard_page.dart
    ├── visitors/
    │   └── presentation/
    │       ├── widgets/guest_invite_card.dart, qr_code_display.dart
    │       └── pages/visitor_invite_page.dart, qr_scanner_page.dart
    ├── bookings/
    │   └── presentation/
    │       ├── widgets/ (facility_card, time_slot_grid, booking_confirmation)
    │       └── pages/facility_booking_page.dart
    ├── complaints/
    │   ├── data/supabase_complaint_repository.dart
    │   ├── domain/complaint_repository.dart
    │   └── presentation/pages/raise_complaint_page.dart, my_complaints_page.dart
    ├── maintenance/
    │   └── presentation/
    │       ├── widgets/ (outstanding_dues, payment_summary, billing_history)
    │       └── pages/maintenance_and_billing_page.dart, payment_page.dart
    └── profile/
        └── presentation/
            ├── widgets/ (add_vehicle_modal, add_family_member_modal)
            └── pages/profile_page.dart, edit_profile_page.dart, family_members_page.dart,
                vehicles_page.dart, notifications_settings_page.dart, privacy_security_page.dart
```

### Admin Panel (`admin-panel/`)
```
admin-panel/
├── src/
│   ├── app/
│   │   ├── layout.tsx                 # Root layout with providers
│   │   ├── page.tsx                   # Redirects to /dashboard
│   │   ├── login/page.tsx             # Admin login
│   │   ├── globals.css                # Global styles
│   │   └── dashboard/...              # Dashboard pages (to be built)
│   ├── components/
│   │   ├── SidebarNav.tsx             # Navigation sidebar
│   │   ├── MobileNav.tsx              # Mobile navigation
│   │   └── AuthGuard.tsx              # Route protection
│   └── lib/
│       └── supabase.ts                # Supabase client
├── package.json
├── tsconfig.json
├── next.config.ts
└── eslint.config.mjs
```

---

## Getting Started

### Prerequisites
- **Flutter SDK** 3.12+
- **Dart** 3.12+
- **Node.js** 20+ (for admin panel)
- **Supabase Account** (project created)

### 1. Supabase Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Run the SQL migration files in order (see `/*.sql` files in root):
   ```bash
   # Example order (adjust based on dependencies):
   create_resident_profiles.sql
   create_family_members.sql
   create_vehicles.sql
   facility_redesign.sql
   create_notification_settings.sql
   prevent_overlapping_bookings.sql
   prevent_double_bookings.sql
   auto_delete_cancelled.sql
   seed_native_data.sql
   ```
3. Enable **Row Level Security** on all tables
4. Configure **Auth** providers (Email/OTP)
5. Note your **Project URL** and **Anon Key**

### 2. Mobile App Setup

```bash
# Clone and navigate
cd community_hub

# Configure environment
# Edit lib/core/config/env.dart with your Supabase credentials:
# static const String supabaseUrl = 'YOUR_PROJECT_URL';
# static const String supabaseAnonKey = 'YOUR_ANON_KEY';

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

**Note**: The app currently uses a hardcoded test user (`testUser` in `user_model.dart:95`). Replace with actual Supabase Auth flow in `login_page.dart` and `main.dart:33`.

### 3. Admin Panel Setup

```bash
cd admin-panel

# Install dependencies
npm install

# Create .env.local with Supabase credentials:
# NEXT_PUBLIC_SUPABASE_URL=YOUR_PROJECT_URL
# NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY

# Run development server
npm run dev
# Opens http://localhost:3000
```

---

## Key Implementation Details

### Visitor Pass Flow
1. Resident enters guest name/purpose → Generates QR code + 6-digit OTP
2. QR contains invite code (`VIS-{timestamp}`)
3. Pass valid for 6 hours (configurable)
4. Share via WhatsApp, system share, or copy code
5. Guard scans QR → Validates code + OTP at gate
6. Resident can revoke active passes anytime

### Facility Booking Conflict Prevention
- **Database-level**: Unique constraint + trigger (`prevent_overlapping_bookings.sql`)
- **Application-level**: Real-time slot availability check before submit
- **Day-type aware**: Weekday/Weekend/Holiday schedules
- **Admin overrides**: Slot blocking for maintenance/events

### Complaint System
- Categories: Plumbing, Electrical, Cleaning, Security, Lift, Parking, Other
- Priority: Normal / Emergency (high priority)
- Image uploads (max 5) → Supabase Storage
- Status tracking: Open → In Progress → Resolved/Closed
- Ticket ID auto-generated for reference

### Maintenance Billing
- Billing cycles per apartment
- Statuses: Pending, Overdue, Paid
- Payment methods: UPI, Card, Net Banking, Wallet
- Expense breakdown (static demo data, ready for dynamic)

---

## Configuration Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Flutter dependencies & assets |
| `analysis_options.yaml` | Dart lint rules |
| `lib/core/config/env.dart` | Supabase credentials (mobile) |
| `admin-panel/.env.local` | Supabase credentials (admin) |
| `admin-panel/tsconfig.json` | TypeScript config |
| `admin-panel/next.config.ts` | Next.js config |
| `admin-panel/eslint.config.mjs` | ESLint flat config |

---

## Scripts & Commands

### Flutter
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device
flutter build apk            # Build Android APK
flutter build ios            # Build iOS (requires Xcode)
flutter test                 # Run tests
flutter analyze              # Static analysis
```

### Admin Panel
```bash
npm run dev                  # Development server
npm run build                # Production build
npm run start                # Start production server
npm run lint                 # Run ESLint
```

---

## Environment Variables

### Mobile App (`lib/core/config/env.dart`)
```dart
class Env {
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

### Admin Panel (`.env.local`)
```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

---

## Deployment

### Mobile App
- **Android**: `flutter build appbundle` → Upload to Play Console
- **iOS**: `flutter build ios` → Archive in Xcode → TestFlight/App Store
- **Web**: `flutter build web` → Deploy to Firebase Hosting/Vercel/Netlify

### Admin Panel
- **Vercel** (recommended): Connect repo, add env vars, deploy
- **Docker**: Build image → Deploy to Cloud Run, ECS, etc.
- **Static Export**: `next build && next export` → Any static host

---

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style
- **Flutter**: Follow `analysis_options.yaml` (flutter_lints)
- **Admin**: ESLint + Prettier (run `npm run lint`)
- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)

---

## License

This project is private and not licensed for public distribution.

---

## Support

For issues or questions, please check the existing GitHub issues or create a new one.

---

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Supabase](https://supabase.com) - Backend-as-a-Service
- [Next.js](https://nextjs.org) - React framework
- [Lucide Icons](https://lucide.dev) - Icon set
- [Google Fonts](https://fonts.google.com) - Typography

