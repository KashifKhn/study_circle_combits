import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_circle/models/study_session_model.dart';
import 'package:study_circle/models/study_group_model.dart';
import 'package:study_circle/models/rsvp_model.dart';
import 'package:study_circle/providers/auth_provider.dart' as app_auth;
import 'package:study_circle/services/firestore_service.dart';
import 'package:study_circle/screens/sessions/create_session_screen.dart';
import 'package:study_circle/theme/app_colors.dart';
import 'package:study_circle/utils/logger.dart';
import 'package:intl/intl.dart';

class SessionDetailsScreen extends StatefulWidget {
  final StudySessionModel session;
  final StudyGroupModel group;

  const SessionDetailsScreen({
    super.key,
    required this.session,
    required this.group,
  });

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isUpdatingRsvp = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final currentUser = authProvider.userModel;
    final isGroupMember = currentUser != null && widget.group.memberIds.contains(currentUser.uid);
    final isCreator = currentUser != null && widget.session.createdBy == currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Session Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          if (isCreator) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditSession(),
              tooltip: 'Edit Session',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDeleteSession(),
              tooltip: 'Delete Session',
            ),
          ],
        ],
      ),
      body: StreamBuilder<StudySessionModel>(
        stream: _firestoreService.getSession(widget.session.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState('Error loading session: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = snapshot.data;

          if (session == null) {
            return _buildErrorState('Session not found');
          }

          final userRsvpStatus = currentUser != null ? session.getUserRsvpStatus(currentUser.uid) : null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(session),
                const SizedBox(height: 16),
                _buildInfoSection(session),
                const SizedBox(height: 16),
                if (session.agenda.isNotEmpty) ...[
                  _buildAgendaSection(session),
                  const SizedBox(height: 16),
                ],
                if (isGroupMember) ...[
                  _buildRsvpSection(session, currentUser.uid, currentUser.name, userRsvpStatus),
                  const SizedBox(height: 16),
                ],
                _buildAttendeesSection(session),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(StudySessionModel session) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            session.topic,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(session.dateTime),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                '${timeFormat.format(session.dateTime)} • ${session.durationMinutes} minutes',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(StudySessionModel session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.group, 'Group', widget.group.name),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.book, 'Course', widget.group.courseCode),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Location', session.location),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgendaSection(StudySessionModel session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              session.agenda,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpSection(StudySessionModel session, String userId, String userName, RsvpStatus? currentStatus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Response',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRsvpButton(
                  icon: Icons.check_circle,
                  label: 'Attending',
                  color: AppColors.success,
                  status: RsvpStatus.attending,
                  currentStatus: currentStatus,
                  onPressed: () => _updateRsvp(session, userId, userName, RsvpStatus.attending),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRsvpButton(
                  icon: Icons.help,
                  label: 'Maybe',
                  color: AppColors.warning,
                  status: RsvpStatus.maybe,
                  currentStatus: currentStatus,
                  onPressed: () => _updateRsvp(session, userId, userName, RsvpStatus.maybe),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRsvpButton(
                  icon: Icons.cancel,
                  label: 'Cannot',
                  color: AppColors.error,
                  status: RsvpStatus.notAttending,
                  currentStatus: currentStatus,
                  onPressed: () => _updateRsvp(session, userId, userName, RsvpStatus.notAttending),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpButton({
    required IconData icon,
    required String label,
    required Color color,
    required RsvpStatus status,
    required RsvpStatus? currentStatus,
    required VoidCallback onPressed,
  }) {
    final isSelected = currentStatus == status;

    return OutlinedButton(
      onPressed: _isUpdatingRsvp ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
        side: BorderSide(
          color: isSelected ? color : AppColors.gray300,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? color : AppColors.gray500,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? color : AppColors.gray700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesSection(StudySessionModel session) {
    final attendingList = session.rsvps.values.where((r) => r.status == RsvpStatus.attending).toList();
    final maybeList = session.rsvps.values.where((r) => r.status == RsvpStatus.maybe).toList();
    final notAttendingList = session.rsvps.values.where((r) => r.status == RsvpStatus.notAttending).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Attendees',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  session.rsvps.length.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (attendingList.isNotEmpty) ...[
            _buildAttendeeGroup('Attending', attendingList, AppColors.success),
            const SizedBox(height: 12),
          ],
          if (maybeList.isNotEmpty) ...[
            _buildAttendeeGroup('Maybe', maybeList, AppColors.warning),
            const SizedBox(height: 12),
          ],
          if (notAttendingList.isNotEmpty) ...[
            _buildAttendeeGroup('Cannot Attend', notAttendingList, AppColors.error),
          ],
          if (session.rsvps.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No responses yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendeeGroup(String title, List<RsvpModel> attendees, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                attendees.length.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...attendees.map((rsvp) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      rsvp.userName.isNotEmpty ? rsvp.userName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rsvp.userName,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimestamp(rsvp.respondedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRsvp(StudySessionModel session, String userId, String userName, RsvpStatus status) async {
    setState(() => _isUpdatingRsvp = true);

    try {
      await _firestoreService.updateSessionRsvp(
        sessionId: session.id,
        userId: userId,
        userName: userName,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('RSVP updated to ${status.toString().split('.').last}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to update RSVP', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update RSVP: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingRsvp = false);
      }
    }
  }

  Future<void> _navigateToEditSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSessionScreen(
          group: widget.group,
          session: widget.session,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmDeleteSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteSession();
    }
  }

  Future<void> _deleteSession() async {
    try {
      await _firestoreService.deleteSession(widget.session.id);

      if (mounted) {
        Navigator.pop(context); // Go back to sessions list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to delete session', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete session: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
