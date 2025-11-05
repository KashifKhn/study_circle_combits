import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_circle/models/rsvp_model.dart';

class StudySessionModel {
  final String id;
  final String groupId;
  final String title;
  final String topic;
  final DateTime dateTime;
  final int durationMinutes;
  final String agenda;
  final String location;
  final String createdBy;
  final Map<String, RsvpModel> rsvps; // Changed from List to Map for easier lookup
  final DateTime createdAt;
  final DateTime updatedAt;

  StudySessionModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.topic,
    required this.dateTime,
    required this.durationMinutes,
    required this.agenda,
    required this.location,
    required this.createdBy,
    Map<String, RsvpModel>? rsvps,
    required this.createdAt,
    required this.updatedAt,
  }) : rsvps = rsvps ?? {};

  // Factory constructor to create from Firestore document
  factory StudySessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert rsvps map from Firestore
    Map<String, RsvpModel> rsvps = {};
    if (data['rsvps'] != null) {
      final rsvpsData = data['rsvps'] as Map<String, dynamic>;
      rsvps = rsvpsData.map(
        (key, value) => MapEntry(key, RsvpModel.fromMap(value as Map<String, dynamic>)),
      );
    }
    
    return StudySessionModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      title: data['title'] ?? '',
      topic: data['topic'] ?? '',
      dateTime: data['dateTime'] != null 
          ? (data['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      durationMinutes: data['durationMinutes'] ?? 60,
      agenda: data['agenda'] ?? '',
      location: data['location'] ?? '',
      createdBy: data['createdBy'] ?? '',
      rsvps: rsvps,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    // Convert rsvps map to Firestore format
    final rsvpsData = rsvps.map(
      (key, value) => MapEntry(key, value.toMap()),
    );
    
    return {
      'groupId': groupId,
      'title': title,
      'topic': topic,
      'dateTime': Timestamp.fromDate(dateTime),
      'durationMinutes': durationMinutes,
      'agenda': agenda,
      'location': location,
      'createdBy': createdBy,
      'rsvps': rsvpsData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // CopyWith method for immutability
  StudySessionModel copyWith({
    String? id,
    String? groupId,
    String? title,
    String? topic,
    DateTime? dateTime,
    int? durationMinutes,
    String? agenda,
    String? location,
    String? createdBy,
    Map<String, RsvpModel>? rsvps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudySessionModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      agenda: agenda ?? this.agenda,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      rsvps: rsvps ?? this.rsvps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Helper methods for RSVP management
  int get attendingCount => rsvps.values.where((r) => r.status == RsvpStatus.attending).length;
  int get maybeCount => rsvps.values.where((r) => r.status == RsvpStatus.maybe).length;
  int get notAttendingCount => rsvps.values.where((r) => r.status == RsvpStatus.notAttending).length;
  
  bool hasUserRsvp(String userId) => rsvps.containsKey(userId);
  RsvpStatus? getUserRsvpStatus(String userId) => rsvps[userId]?.status;
}
