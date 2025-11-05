class AppConstants {
  static const String appName = 'StudyCircle';
  static const String appVersion = '1.0.0';

  static const int minGroupMembers = 3;
  static const int maxGroupMembers = 10;

  // Academic departments
  static const List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Biotechnology',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Business Administration',
    'Commerce',
    'Economics',
    'Other',
  ];

  static const int maxFileSizeInMB = 10;
  static const int maxFileSizeInBytes = maxFileSizeInMB * 1024 * 1024;

  static const String rsvpAttending = 'attending';
  static const String rsvpMaybe = 'maybe';
  static const String rsvpCannot = 'cannot';

  static const String requestPending = 'pending';
  static const String requestApproved = 'approved';
  static const String requestRejected = 'rejected';

  static const String resourceTypeImage = 'image';
  static const String resourceTypePDF = 'pdf';
  static const String resourceTypeVideo = 'video';
  static const String resourceTypeOther = 'other';

  static const String usersCollection = 'users';
  static const String groupsCollection = 'study_groups';
  static const String sessionsCollection = 'study_sessions';
  static const String joinRequestsCollection = 'join_requests';
  static const String resourcesCollection = 'resources';

  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';

  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorPermission =
      'You do not have permission to perform this action.';

  static const String successLogin = 'Login successful!';
  static const String successRegister = 'Registration successful!';
  static const String successGroupCreated = 'Study group created successfully!';
  static const String successSessionCreated =
      'Study session scheduled successfully!';
  static const String successJoinGroup = 'You have joined the group!';
  static const String successLeaveGroup = 'You have left the group.';
}
