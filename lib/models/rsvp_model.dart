import 'package:cloud_firestore/cloud_firestore.dart';

enum RsvpStatus { attending, maybe, notAttending }

class RsvpModel {
  final String userId;
  final String userName;
  final RsvpStatus status;
  final DateTime respondedAt;

  RsvpModel({
    required this.userId,
    required this.userName,
    required this.status,
    required this.respondedAt,
  });

  // Factory constructor to create from Firestore map
  factory RsvpModel.fromMap(Map<String, dynamic> data) {
    return RsvpModel(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      status: RsvpStatus.values.firstWhere(
        (e) => e.toString() == 'RsvpStatus.${data['status']}',
        orElse: () => RsvpStatus.attending,
      ),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'status': status.toString().split('.').last,
      'respondedAt': Timestamp.fromDate(respondedAt),
    };
  }

  // CopyWith method
  RsvpModel copyWith({
    String? userId,
    String? userName,
    RsvpStatus? status,
    DateTime? respondedAt,
  }) {
    return RsvpModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
