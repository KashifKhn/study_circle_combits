import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a student in the StudyCircle app
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String department;
  final int semester;
  final int year;
  final String profileImageUrl;
  final List<String> joinedGroupIds;
  final List<String> createdGroupIds;
  final List<String> upcomingSessionIds;
  final int sessionsAttended;
  final String themePreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.department,
    required this.semester,
    required this.year,
    this.profileImageUrl = '',
    List<String>? joinedGroupIds,
    List<String>? createdGroupIds,
    List<String>? upcomingSessionIds,
    this.sessionsAttended = 0,
    this.themePreference = 'light',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : joinedGroupIds = joinedGroupIds ?? [],
        createdGroupIds = createdGroupIds ?? [],
        upcomingSessionIds = upcomingSessionIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? 1,
      year: data['year'] ?? 2024,
      profileImageUrl: data['profileImageUrl'] ?? '',
      joinedGroupIds: List<String>.from(data['joinedGroupIds'] ?? []),
      createdGroupIds: List<String>.from(data['createdGroupIds'] ?? []),
      upcomingSessionIds: List<String>.from(data['upcomingSessionIds'] ?? []),
      sessionsAttended: data['sessionsAttended'] ?? 0,
      themePreference: data['themePreference'] ?? 'light',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? 1,
      year: data['year'] ?? 2024,
      profileImageUrl: data['profileImageUrl'] ?? '',
      joinedGroupIds: List<String>.from(data['joinedGroupIds'] ?? []),
      createdGroupIds: List<String>.from(data['createdGroupIds'] ?? []),
      upcomingSessionIds: List<String>.from(data['upcomingSessionIds'] ?? []),
      sessionsAttended: data['sessionsAttended'] ?? 0,
      themePreference: data['themePreference'] ?? 'light',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'department': department,
      'semester': semester,
      'year': year,
      'profileImageUrl': profileImageUrl,
      'joinedGroupIds': joinedGroupIds,
      'createdGroupIds': createdGroupIds,
      'upcomingSessionIds': upcomingSessionIds,
      'sessionsAttended': sessionsAttended,
      'themePreference': themePreference,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'department': department,
      'semester': semester,
      'year': year,
      'profileImageUrl': profileImageUrl,
      'joinedGroupIds': joinedGroupIds,
      'createdGroupIds': createdGroupIds,
      'upcomingSessionIds': upcomingSessionIds,
      'sessionsAttended': sessionsAttended,
      'themePreference': themePreference,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? department,
    int? semester,
    int? year,
    String? profileImageUrl,
    List<String>? joinedGroupIds,
    List<String>? createdGroupIds,
    List<String>? upcomingSessionIds,
    int? sessionsAttended,
    String? themePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      joinedGroupIds: joinedGroupIds ?? this.joinedGroupIds,
      createdGroupIds: createdGroupIds ?? this.createdGroupIds,
      upcomingSessionIds: upcomingSessionIds ?? this.upcomingSessionIds,
      sessionsAttended: sessionsAttended ?? this.sessionsAttended,
      themePreference: themePreference ?? this.themePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, department: $department)';
  }
}
