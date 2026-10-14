# T-Sport MVP

T-Sport is a mobile sports-facility booking marketplace designed for Tripoli, Libya. 
It features a strict "Anti-AI" dark industrial design, robust Firestore-based slot locking to prevent race conditions, and an authoritative backend.

## Architecture

* **Frontend**: Flutter + Riverpod + GoRouter
* **Backend**: Firebase Cloud Functions + Firestore
* **Auth**: Firebase Authentication (Phone/OTP)
* **Payments**: Stripe (Server-side webhooks) + Cash on Arrival

## Folder Structure

```
lib/
  core/
    theme/       # Design System (Colors, Typography)
    routing/     # GoRouter setup
    widgets/     # Reusable components (Buttons, Slots)
  features/      # Feature slices (Home, Bookings, Checkout, Manager)
  services/      # Firebase, Stripe abstractions
  models/        # Data models (Venue, Booking, User)
functions/
  src/
    slots/       # Atomic lock transaction functions
```

## Local Setup

### 1. Flutter Setup
Since Flutter was not found on your machine during the initial run, you must [install Flutter](https://docs.flutter.dev/get-started/install/windows) first.
After installing, run:
```bash
flutter pub get
```

### 2. Firebase Setup
1. Create a project in the Firebase Console.
2. Enable **Firestore**, **Authentication (Phone)**, and **Cloud Functions**.
3. Install the Firebase CLI and run `firebase init` in this directory to link the `functions/` folder.
4. Run `flutterfire configure` to generate your `firebase_options.dart`.

### 3. Stripe Setup
Add your Stripe test keys to the Cloud Functions environment:
```bash
firebase functions:config:set stripe.secret="sk_test_..."
```

## Running the App

```bash
flutter run
```

## Running Tests
*(Tests will be added as we complete the features)*
```bash
flutter test
```
