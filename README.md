# StudyCircle - Study Group Finder Mobile App

A comprehensive Flutter-based mobile platform that helps students create, discover, and join study groups for their courses. Built for the COMBITS Mobile Application Development Competition with a focus on connecting students, scheduling study sessions, and fostering collaborative academic success.

**Competition:** COMBITS Mobile App Development  
**Duration:** 6 Hours  
**Tech Stack:** Flutter + Firebase + Cloudinary  
**Team GitHub:** https://github.com/zarqan-khn  
**Download APK:** [Release APK Download Link](https://github.com/zarqan-khn/study_circle/releases)

---

## Table of Contents
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [Usage Guide](#usage-guide)
- [Database Schema](#database-schema)
- [Code Quality](#code-quality)
- [Competition Compliance](#competition-compliance)
- [Bonus Features Implemented](#bonus-features-implemented)

---

## Features

### Core Features (All Implemented)

#### 1. User Authentication & Profile Management
- Email/password registration and login with Firebase Authentication
- Comprehensive user profiles with:
  - Name, email, department, semester/year
  - Profile image upload (Cloudinary-powered)
  - Bio and skill level (Beginner/Intermediate/Advanced)
  - Course interests
- Edit profile functionality after registration
- Secure password change with validation
- Light/Dark theme preference

#### 2. Study Group Management
- Create study groups with complete details:
  - Group name, course name, course code
  - Description and study topics
  - Maximum members (3-10 with validation)
  - Meeting schedule and location
  - Public (open join) or Private (approval required)
- Edit and delete groups (creator-only)
- View detailed group information with 3-tab layout:
  - Overview: Group details and quick actions
  - Members: Member list with role identification
  - Sessions: All scheduled study sessions
- Real-time member count and capacity tracking
- Beautiful card-based UI with status badges (Open/Almost Full/Full)

#### 3. Group Discovery & Joining System
- Browse all public study groups
- Advanced search and filtering:
  - Search by group name or course code
  - Filter by department/category
  - Real-time search results
- Detailed group listings showing:
  - Group name, course, creator
  - Member count and capacity
  - Meeting schedule
  - Privacy status
- Join/Leave functionality:
  - Public groups: Instant join
  - Private groups: Request-to-join with approval system
  - Duplicate membership prevention
  - Member limit enforcement
  - Confirmation dialogs for leaving groups
- Join request management for group creators:
  - Review pending requests
  - Approve or reject with user profile preview
  - Real-time notifications badge

#### 4. Study Session Scheduling & RSVP
- Comprehensive session creation:
  - Title and topic
  - Date and time pickers
  - Duration (in minutes)
  - Location
  - Detailed agenda/description
- Session management:
  - Edit sessions (creator-only)
  - Delete/cancel sessions
  - View session details
- Advanced RSVP system:
  - Three status options: Attending / Maybe / Cannot Attend
  - Real-time attendee counts
  - Attendee lists organized by RSVP status
  - One-click RSVP updates
- Session organization:
  - Separate upcoming and past sessions
  - Session cards with complete information
  - Visual status indicators

#### 5. Personalized Dashboard
- Real-time statistics:
  - Total groups joined
  - Upcoming sessions count
  - Sessions attended
- Quick action buttons:
  - Create new group
  - Find groups
  - View all sessions
- Upcoming sessions preview with:
  - Session title, date, time
  - Group information
  - RSVP status
  - Quick navigation to details
- My groups overview with cards
- Pull-to-refresh functionality
- Beautiful, intuitive UI with custom colors

### Bonus Features Implemented

#### 1. Resource Sharing
- Upload study materials (PDFs, images, links)
- Resource management in groups
- Cloudinary-powered file storage
- Resource details with:
  - File name, type, size
  - Uploader information
  - Upload date
  - File preview/download
- Delete resources (uploader-only)

#### 2. Group Q&A System
- Ask questions within study groups
- Voting system (upvote/downvote)
- Answer questions with detailed responses
- Mark answers as accepted (question asker)
- Mark questions as resolved
- Filter questions:
  - All questions
  - Resolved
  - Unresolved
- Vote score calculation
- Answer count tracking

#### 3. Gamification System
- User achievements and badges
- Streak tracking:
  - Current streak counter
  - Longest streak record
  - Daily activity tracking
- Points system for:
  - Joining groups
  - Attending sessions
  - Uploading resources
  - Answering questions
  - Creating groups
- Achievement types:
  - First Session
  - Group Creator
  - Active Learner
  - Resource Contributor
  - Streak Master
- Progress tracking with visual indicators
- Unlock dates for earned achievements

#### 4. Calendar View
- Visual calendar with session markers
- Month/Week/Day view modes
- Session indicators on dates
- Tap date to view sessions
- Session cards with status (Scheduled/Ongoing/Completed)
- Quick navigation to session details
- Beautiful UI with color-coded events

#### 5. Group Analytics (for Creators)
- Comprehensive analytics dashboard:
  - Total sessions count
  - Total members
  - Resources shared
  - Average attendance rate
- Attendance trends visualization:
  - Session-by-session attendance
  - Visual progress bars
  - Historical data
- Top contributors leaderboard:
  - Activity scores
  - Medal system (Gold/Silver/Bronze)
  - Member rankings
- Member activity breakdown:
  - Individual member scores
  - Activity progress bars
  - Sortable by contribution

#### 6. Smart Recommendations (Future)
- Suggest groups based on:
  - User's courses
  - Semester/year
  - Previous searches
  - Interest matching

---

## Screenshots

> Add screenshots of key features here:
> - Login/Register
> - Dashboard
> - Groups List
> - Group Details
> - Session Scheduling
> - Calendar View
> - Achievements
> - Q&A

---

## Tech Stack

### Framework & Language
- **Flutter** 3.8.1+ (Cross-platform mobile framework)
- **Dart** (Programming language)

### Backend & Database
- **Firebase Authentication** - User authentication and session management
- **Cloud Firestore** - Real-time NoSQL database
- **Cloudinary** - Cloud-based image and file storage

### State Management
- **Provider** - Reactive state management

### Key Packages
```yaml
# Core
firebase_core: ^4.2.1
firebase_auth: ^6.1.2
cloud_firestore: ^6.1.0

# Storage
cloudinary_sdk: ^5.0.0+1

# State Management
provider: ^6.1.2

# UI & Media
image_picker: ^1.1.2
file_picker: ^8.1.6
cached_network_image: ^3.4.1
table_calendar: ^3.1.2

# Utilities
intl: ^0.19.0
uuid: ^4.5.1
shared_preferences: ^2.3.3
logger: ^2.6.2
```

---

## Architecture

### Clean Architecture Pattern
```
lib/
├── config/              # Configuration files
│   └── cloudinary_config.dart
├── models/              # Data models
│   ├── user_model.dart
│   ├── study_group_model.dart
│   ├── study_session_model.dart
│   ├── rsvp_model.dart
│   ├── join_request_model.dart
│   ├── question_model.dart
│   ├── answer_model.dart
│   ├── achievement_model.dart
│   ├── user_stats_model.dart
│   └── group_analytics_model.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   └── theme_provider.dart
├── screens/             # UI screens (feature-based)
│   ├── auth/           # Authentication flows
│   ├── home/           # Dashboard
│   ├── groups/         # Group management
│   ├── sessions/       # Session scheduling
│   ├── profile/        # User profile
│   ├── qna/            # Q&A system
│   ├── achievements/   # Gamification
│   ├── calendar/       # Calendar view
│   └── analytics/      # Group analytics
├── services/            # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── gamification_service.dart
├── theme/              # App theming
│   ├── app_colors.dart
│   └── app_theme.dart
├── utils/              # Utilities
│   ├── constants.dart
│   ├── helpers.dart
│   ├── validators.dart
│   └── logger.dart
├── firebase_options.dart
└── main.dart           # App entry point
```

### Design Patterns Used
- **Provider Pattern** for state management
- **Repository Pattern** for data access (FirestoreService)
- **Singleton Pattern** for service instances
- **Factory Pattern** for model creation
- **Stream Builder Pattern** for real-time updates

---

## Setup Instructions

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase account
- Cloudinary account (for image/file uploads)

### Installation Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/zarqan-khn/study_circle.git
cd study_circle
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Email/Password Authentication**:
   - Go to Authentication > Sign-in method
   - Enable Email/Password
3. Create **Firestore Database**:
   - Go to Firestore Database
   - Create database in production mode
   - Start in test mode (update rules later)
4. Download configuration files:
   - **Android**: Download `google-services.json` and place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` and place in `ios/Runner/`
5. (Optional) Use FlutterFire CLI:
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```

#### 4. Cloudinary Setup
1. Create account at [Cloudinary](https://cloudinary.com)
2. Get your credentials from Dashboard
3. Create an upload preset (Settings > Upload > Add upload preset)
4. Create `.env` file in project root:
   ```env
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   CLOUDINARY_UPLOAD_PRESET=your_upload_preset
   ```
5. Update `lib/config/cloudinary_config.dart` with your credentials

#### 5. Firestore Security Rules
Update your Firestore rules for production:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Study groups
    match /study_groups/{groupId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.createdBy == request.auth.uid;
    }
    
    // Study sessions
    match /study_sessions/{sessionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.createdBy == request.auth.uid || 
         get(/databases/$(database)/documents/study_groups/$(resource.data.groupId)).data.createdBy == request.auth.uid);
    }
    
    // Join requests
    match /join_requests/{requestId} {
      allow read, create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/study_groups/$(resource.data.groupId)).data.createdBy == request.auth.uid);
    }
    
    // Questions, answers, achievements, stats
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

#### 6. Run the App
```bash
# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release
```

### Building APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# Split APK by ABI (smaller file sizes)
flutter build apk --split-per-abi --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Usage Guide

### For Students

#### First Time Setup
1. **Launch the app**
2. **Register** with email and password
3. **Complete profile setup**:
   - Enter name, department, semester/year
   - Upload profile picture
   - Add bio and courses
   - Select skill level
4. **Explore** the dashboard and available groups

#### Finding & Joining Groups
1. Tap **"Find Groups"** from dashboard
2. **Browse** available groups or use search
3. **Filter** by department or course
4. Tap a group to view details
5. **Join**:
   - Public groups: Instant join
   - Private groups: Send request and wait for approval

#### Creating a Study Group
1. Tap **"Create Group"** from dashboard
2. Fill in details:
   - Group name and course code
   - Description
   - Category/Department
   - Set public/private
   - Member limit (3-10)
   - Meeting schedule
3. (Optional) Upload group image
4. Tap **"Create Group"**

#### Scheduling Study Sessions
1. Navigate to your group
2. Go to **"Sessions"** tab
3. Tap **"New Session"** (+) button
4. Enter session details:
   - Title and topic
   - Date and time
   - Location
   - Duration
   - Description
5. Tap **"Create Session"**

#### RSVP to Sessions
1. View session details
2. Select RSVP status:
   - **Attending** (green)
   - **Maybe** (yellow)
   - **Cannot Attend** (red)
3. Your status updates instantly

#### Asking Questions (Q&A)
1. Open a group
2. Tap **Q&A** section
3. Tap **"Ask Question"**
4. Enter title and description
5. Submit question
6. Vote on other questions
7. Answer questions
8. Mark helpful answers as accepted

#### Uploading Resources
1. Navigate to group
2. Go to **Resources** section
3. Tap **"Upload"**
4. Select file (PDF, image, etc.)
5. Add title and description
6. Upload to group

### For Group Creators

#### Managing Join Requests
1. Open your group
2. Look for **"Pending Requests"** badge
3. Tap to view all requests
4. Review user profiles
5. **Approve** or **Reject** each request

#### Viewing Analytics
1. Open your group (as creator)
2. Tap **"Analytics"** button
3. View insights:
   - Total sessions, members, resources
   - Average attendance
   - Attendance trends
   - Top contributors
   - Member activity scores

---

## Database Schema

### Collections & Documents

#### `users` Collection
```javascript
{
  uid: "string (document ID)",
  email: "user@example.com",
  name: "John Doe",
  bio: "Computer Science student",
  profileImageUrl: "https://cloudinary.com/...",
  department: "Computer Science",
  semester: "5th",
  year: "3rd Year",
  courses: ["CS101", "CS202"],
  skillLevel: "Intermediate",
  joinedGroupIds: ["group1", "group2"],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### `study_groups` Collection
```javascript
{
  id: "string (auto-generated)",
  name: "Data Structures Study Group",
  courseCode: "CS202",
  courseName: "Data Structures & Algorithms",
  description: "Weekly sessions on DSA topics",
  category: "Computer Science",
  isPublic: true,
  memberLimit: 10,
  memberIds: ["user1", "user2", "user3"],
  memberCount: 3,
  createdBy: "user1",
  schedule: "Mondays 6 PM",
  location: "Library Room 201",
  imageUrl: "https://cloudinary.com/...",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### `study_sessions` Collection
```javascript
{
  id: "string (auto-generated)",
  groupId: "group1",
  title: "Binary Trees Practice",
  topic: "Trees and Traversal",
  description: "Hands-on practice session",
  dateTime: Timestamp,
  durationMinutes: 90,
  location: "Library Room 201",
  createdBy: "user1",
  rsvps: {
    "user1": "attending",
    "user2": "maybe",
    "user3": "notAttending"
  },
  attendingCount: 5,
  maybeCount: 2,
  notAttendingCount: 1,
  createdAt: Timestamp
}
```

#### `join_requests` Collection
```javascript
{
  id: "string (auto-generated)",
  groupId: "group1",
  userId: "user4",
  userName: "Jane Smith",
  userEmail: "jane@example.com",
  status: "pending", // pending, approved, rejected
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### `questions` Collection
```javascript
{
  id: "string (auto-generated)",
  groupId: "group1",
  askedBy: "user1",
  askedByName: "John Doe",
  title: "How do you implement BFS?",
  description: "I'm confused about the algorithm",
  isResolved: false,
  upvotes: ["user2", "user3"],
  downvotes: [],
  voteScore: 2,
  answerCount: 3,
  createdAt: Timestamp
}
```

#### `user_stats` Collection
```javascript
{
  userId: "user1",
  totalPoints: 150,
  currentStreak: 7,
  longestStreak: 15,
  totalSessionsAttended: 12,
  totalGroupsJoined: 5,
  totalGroupsCreated: 2,
  totalResourcesUploaded: 8,
  lastActivityDate: Timestamp
}
```

#### `achievements` Collection
```javascript
{
  id: "string (auto-generated)",
  userId: "user1",
  type: "first_session",
  title: "First Steps",
  description: "Attended your first study session",
  iconName: "school",
  isUnlocked: true,
  unlockedAt: Timestamp,
  currentValue: 1,
  targetValue: 1,
  progress: 1.0
}
```

---

## Code Quality

### Linting & Formatting
- **Linting**: Using `flutter_lints` package (official Flutter lints)
- **Code Style**: Follow Dart style guide
- **Formatting**: Consistent code formatting with `dart format`

### Running Quality Checks
```bash
# Analyze code for issues
flutter analyze

# Format all Dart files
dart format .

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated
```

### Best Practices Implemented
- **Type Safety**: Explicit type annotations everywhere
- **Null Safety**: Sound null safety enabled
- **Error Handling**: Try-catch blocks with proper logging
- **Logging**: Custom `AppLogger` for debugging
- **Validation**: Input validation on all forms
- **Const Constructors**: Used wherever possible for performance
- **Separation of Concerns**: Clean architecture with distinct layers
- **Code Reusability**: Extracted common widgets and functions

---

## Competition Compliance

### COMBITS Competition Requirements

#### Core Features (All Completed)
- [x] User Authentication & Profile (name, email, department, semester, year, profile image)
- [x] Profile editing after registration
- [x] Study Group Creation (all required fields)
- [x] Public/Private group types
- [x] Group edit/delete functionality
- [x] Group discovery with search and filters
- [x] Public group instant join
- [x] Private group approval system
- [x] Duplicate membership prevention
- [x] Member limit enforcement (3-10)
- [x] Study session scheduling (all required fields)
- [x] RSVP system (Attending/Maybe/Cannot Attend)
- [x] Session cancellation
- [x] Dashboard with active groups and upcoming sessions
- [x] Quick statistics display

#### Bonus Features Implemented
- [x] **Resource Sharing** - Upload PDFs, images, links
- [x] **Group Q&A** - Questions, answers, voting
- [x] **Gamification** - Achievements, badges, streaks, points
- [x] **Calendar View** - Visual session calendar
- [x] **Analytics** - Attendance trends, top contributors

#### Submission Requirements
- [x] **GitHub Repository** - Complete source code with documentation
- [x] **Build APK File** - Android release APK ready for testing
- [ ] **Video Demo** - 2-5 minute demonstration (to be recorded)

### Evaluation Criteria Alignment

| Criteria | Points | Implementation |
|----------|--------|----------------|
| **Core Functionality** | 35 | All required features working correctly with real-time updates |
| **Code Quality** | 18 | Clean architecture, proper documentation, linting, type safety |
| **Database Design** | 12 | Well-structured Firestore schema with proper relationships |
| **UI/UX Design** | 12 | Material Design 3, consistent theming, intuitive navigation |
| **Security/Validation** | 10 | Firebase auth, input validation, security rules |
| **Business Logic** | 8 | Member limits, join approvals, RSVP logic, duplicate prevention |
| **Bonus Features** | 10 | 5 bonus features fully implemented (Resources, Q&A, Gamification, Calendar, Analytics) |
| **Documentation** | 3 | Comprehensive README, code comments, setup instructions |
| **Git Usage** | 2 | Consistent commits, version tracking, meaningful messages |
| **TOTAL** | **100** | **Target: 95-100 points** |

---

## Bonus Features Implemented

### 1. Resource Sharing
Upload and share study materials within groups
- PDF documents
- Images
- External links
- File preview and download
- Delete functionality for uploaders

### 2. Group Q&A System
Enable in-group discussions and knowledge sharing
- Ask questions
- Answer questions
- Upvote/downvote system
- Mark questions as resolved
- Accept helpful answers
- Vote score calculation

### 3. Gamification
Achievements, badges, and streaks for active users
- Point system for activities
- Achievement unlocking
- Streak tracking (current and longest)
- Progress visualization
- Leaderboards
- Activity rewards

### 4. Calendar View
Visual calendar of upcoming study sessions
- Month/week/day views
- Session markers on dates
- Color-coded events
- Tap to view session details
- Status indicators (scheduled/ongoing/completed)

### 5. Analytics
Insights for group creators
- Attendance trends over time
- Top contributors leaderboard
- Member activity scores
- Visual progress bars
- Total stats (sessions, members, resources)

---

## Future Enhancements

- [ ] Push notifications for session reminders
- [ ] In-app messaging/chat
- [ ] Smart group recommendations based on AI
- [ ] Video session integration
- [ ] Study timer and Pomodoro technique
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Export study materials in bulk

---

## Credits

**Developer:** Zarqan Khan  
**GitHub:** https://github.com/zarqan-khn  
**Competition:** COMBITS Mobile Application Development  
**Framework:** Flutter 3.8.1  
**Backend:** Firebase + Cloudinary  

---

## License

This project was developed for the COMBITS Mobile Application Development Competition. All rights reserved.

---

## Support & Contact

For issues, questions, or feedback:
- Create an issue in the [GitHub repository](https://github.com/zarqan-khn/study_circle/issues)
- Contact: zarqan.khn@example.com

---

**Built with Flutter | Powered by Firebase & Cloudinary | Made with dedication for academic collaboration**
