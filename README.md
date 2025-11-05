# StudyCircle - Study Group Finder App

A comprehensive Flutter application for finding and managing study groups, scheduling study sessions, and collaborating with peers. Built with Firebase, Cloudinary, and modern Flutter best practices.

## Features

### Core Functionality
- **User Authentication**: Email/password registration and login with Firebase Auth
- **Profile Management**: Create and edit user profiles with profile pictures, bio, courses, and skill levels
- **Study Groups**: 
  - Create public/private study groups with course codes, descriptions, and member limits
  - Browse and search groups by course code, name, or category
  - Join public groups instantly or send join requests for private groups
  - Group creators can approve/reject join requests
  - Leave groups (with confirmation)
  - Real-time member management
- **Study Sessions**:
  - Schedule study sessions for groups with date, time, location, and duration
  - Edit and delete sessions (creator-only)
  - RSVP system with three states: Attending, Maybe, Cannot Attend
  - View attendee lists organized by RSVP status
  - Separate upcoming and past sessions views
- **Dashboard**: 
  - Quick stats (groups joined, upcoming sessions)
  - Recent groups display
  - Quick access to create groups and find sessions
- **My Groups**: View all groups you've joined or created

### Technical Highlights
- Clean architecture with separation of concerns (models, services, screens, providers)
- Real-time data synchronization using Firestore streams
- State management with Provider
- Custom app theme with consistent color scheme and typography
- Image uploads via Cloudinary integration
- Form validation and error handling
- Responsive UI with Material Design 3 principles
- Logging system for debugging

## Tech Stack

- **Framework**: Flutter 3.8.1+
- **Backend**: Firebase (Auth + Firestore)
- **Storage**: Cloudinary (images and files)
- **State Management**: Provider
- **UI**: Material Design 3, Custom theme
- **Additional Packages**:
  - `image_picker`: Profile picture uploads
  - `file_picker`: Document/resource uploads
  - `cached_network_image`: Efficient image loading
  - `intl`: Date/time formatting
  - `table_calendar`: Calendar views
  - `flutter_local_notifications`: Push notifications

## Project Structure

```
lib/
├── config/           # App configuration (Cloudinary, etc.)
├── models/           # Data models (User, Group, Session, RSVP, etc.)
├── providers/        # State management (Auth, Theme)
├── screens/          # UI screens organized by feature
│   ├── auth/        # Login, Register, Profile Setup
│   ├── groups/      # Groups List, Details, Create, Join Requests
│   ├── home/        # Dashboard
│   ├── profile/     # Profile View/Edit, Change Password
│   └── sessions/    # Sessions List, Details, Create, My Sessions
├── services/         # Business logic (Auth, Firestore)
├── theme/           # App theme and colors
├── utils/           # Helpers, validators, constants, logger
└── main.dart        # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase account
- Cloudinary account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd study_circle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at https://console.firebase.google.com
   - Enable Email/Password authentication
   - Create a Firestore database
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Run FlutterFire CLI (optional):
     ```bash
     flutterfire configure
     ```

4. **Cloudinary Setup**
   - Create account at https://cloudinary.com
   - Create `.env` file in project root:
     ```env
     CLOUDINARY_CLOUD_NAME=your_cloud_name
     CLOUDINARY_API_KEY=your_api_key
     CLOUDINARY_API_SECRET=your_api_secret
     CLOUDINARY_UPLOAD_PRESET=your_upload_preset
     ```
   - Update `lib/config/cloudinary_config.dart` with your credentials

5. **Firestore Security Rules** (Recommended)
   Update your Firestore rules to:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
       match /study_groups/{groupId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null && 
           resource.data.createdBy == request.auth.uid;
       }
       match /study_sessions/{sessionId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null && 
           resource.data.createdBy == request.auth.uid;
       }
       match /join_requests/{requestId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null;
       }
     }
   }
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Output location: build/app/outputs/flutter-apk/app-release.apk
```

## Usage Guide

### First Time Setup
1. Launch the app
2. Register with email and password
3. Complete profile setup (name, bio, profile picture, courses)
4. Explore groups or create your first study group

### Creating a Study Group
1. Tap "Create Group" on the home screen
2. Fill in details: name, course code, description, category
3. Set privacy (public/private) and member limit
4. Upload optional group image
5. Submit to create

### Scheduling a Study Session
1. Navigate to a group you're a member of
2. Tap "Sessions" tab
3. Tap "New Session" button
4. Enter session details: title, topic, date, time, location, duration
5. Optionally add description
6. Save to schedule

### Managing Join Requests (Group Creators)
1. Open your group
2. Tap "Pending Requests" badge (appears when requests exist)
3. Review user profiles
4. Approve or Reject requests

## Code Quality

- **Linting**: Configured with `flutter_lints` package
- **Formatting**: Use `dart format .` before commits
- **Analysis**: Run `flutter analyze` to check for issues
- **Logging**: All errors logged via `AppLogger` utility

### Running Code Checks
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Run tests (if available)
flutter test
```

## Database Schema

### Users Collection (`users`)
- `uid`: String (document ID)
- `email`: String
- `name`: String
- `bio`: String (optional)
- `profilePicUrl`: String (optional)
- `courses`: List<String>
- `skillLevel`: String (Beginner/Intermediate/Advanced)
- `createdAt`: Timestamp
- `updatedAt`: Timestamp

### Study Groups Collection (`study_groups`)
- `id`: String (auto-generated)
- `name`: String
- `courseCode`: String
- `description`: String
- `category`: String
- `isPublic`: bool
- `memberLimit`: int
- `createdBy`: String (user ID)
- `memberIds`: List<String>
- `imageUrl`: String (optional)
- `createdAt`: Timestamp
- `updatedAt`: Timestamp

### Study Sessions Collection (`study_sessions`)
- `id`: String (auto-generated)
- `groupId`: String
- `title`: String
- `topic`: String
- `description`: String (optional)
- `dateTime`: Timestamp
- `durationMinutes`: int
- `location`: String
- `createdBy`: String (user ID)
- `rsvps`: Map<String, String> (userId -> status)
- `createdAt`: Timestamp

### Join Requests Collection (`join_requests`)
- `id`: String (auto-generated)
- `groupId`: String
- `userId`: String
- `status`: String (pending/approved/rejected)
- `createdAt`: Timestamp

## Known Limitations

- Resource sharing feature not yet implemented (planned)
- Push notifications configured but not fully integrated
- Calendar view available but not used in UI

## Contributing

When contributing:
1. Follow the code style guidelines in `AGENTS.md`
2. Run `flutter analyze` before committing
3. Format code with `dart format .`
4. Use meaningful commit messages
5. Test on both Android and iOS if possible

## License

This project is part of a university competition submission.

## Support

For issues or questions, please contact the development team or create an issue in the repository.

---

**Built with Flutter | Powered by Firebase & Cloudinary**
