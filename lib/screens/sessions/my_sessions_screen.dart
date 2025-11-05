import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_circle/models/study_session_model.dart';
import 'package:study_circle/models/study_group_model.dart';
import 'package:study_circle/models/rsvp_model.dart';
import 'package:study_circle/providers/auth_provider.dart' as app_auth;
import 'package:study_circle/services/firestore_service.dart';
import 'package:study_circle/theme/app_colors.dart';
import 'package:study_circle/screens/sessions/create_session_screen.dart';
import 'package:intl/intl.dart';

class MySessionsScreen extends StatefulWidget {
  const MySessionsScreen({super.key});

  @override
  State<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends State<MySessionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final currentUser = authProvider.userModel;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if user is in any groups
    final hasGroups = currentUser.joinedGroupIds.isNotEmpty;

    return Scaffold(
      body: StreamBuilder<List<StudySessionModel>>(
        stream: _firestoreService.getUpcomingSessions(currentUser.joinedGroupIds),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState('Error loading sessions: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          // Separate upcoming and past sessions
          final now = DateTime.now();
          final upcomingSessions = sessions.where((s) => s.dateTime.isAfter(now)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcomingSessions.isNotEmpty) ...[
                _buildSectionHeader('Upcoming Sessions', upcomingSessions.length),
                const SizedBox(height: 12),
                ...upcomingSessions.map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SessionCard(
                        session: session,
                        currentUserId: currentUser.uid,
                      ),
                    )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: hasGroups
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSessionDialog(currentUser.joinedGroupIds),
              icon: const Icon(Icons.add),
              label: const Text('New Session'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Future<void> _showCreateSessionDialog(List<String> groupIds) async {
    if (groupIds.isEmpty) return;

    // If user is in only one group, go directly to create session
    if (groupIds.length == 1) {
      final group = await _firestoreService.getStudyGroupById(groupIds.first);
      if (group != null && mounted) {
        _navigateToCreateSession(group);
      }
      return;
    }

    // If user is in multiple groups, show selection dialog
    showDialog(
      context: context,
      builder: (context) => _GroupSelectionDialog(
        groupIds: groupIds,
        onGroupSelected: (group) {
          Navigator.pop(context);
          _navigateToCreateSession(group);
        },
      ),
    );
  }

  Future<void> _navigateToCreateSession(StudyGroupModel group) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSessionScreen(group: group),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
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
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              'No Upcoming Sessions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join a study group to see scheduled sessions here!',
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
}

// Group Selection Dialog
class _GroupSelectionDialog extends StatelessWidget {
  final List<String> groupIds;
  final Function(StudyGroupModel) onGroupSelected;

  const _GroupSelectionDialog({
    required this.groupIds,
    required this.onGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return AlertDialog(
      title: const Text(
        'Select Group',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: groupIds.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return StreamBuilder<StudyGroupModel?>(
              stream: firestoreService.getStudyGroupStream(groupIds[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Loading...'),
                  );
                }

                final group = snapshot.data;
                if (group == null) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.group, color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    group.courseCode,
                    style: TextStyle(color: AppColors.gray600, fontSize: 12),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
                  onTap: () => onGroupSelected(group),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// Session Card Widget
class _SessionCard extends StatelessWidget {
  final StudySessionModel session;
  final String? currentUserId;

  const _SessionCard({
    required this.session,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final userRsvpStatus = currentUserId != null ? session.getUserRsvpStatus(currentUserId!) : null;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final firestoreService = FirestoreService();

    return StreamBuilder<StudyGroupModel?>(
      stream: firestoreService.getStudyGroupStream(session.groupId),
      builder: (context, groupSnapshot) {
        final group = groupSnapshot.data;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: group != null
                ? () {
                    Navigator.pushNamed(
                      context,
                      '/session-details',
                      arguments: {'session': session, 'group': group},
                    );
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: AppColors.gray800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.topic,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (group != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                group.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (userRsvpStatus != null) _buildRsvpBadge(userRsvpStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    dateFormat.format(session.dateTime),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.access_time,
                    '${timeFormat.format(session.dateTime)} • ${session.durationMinutes} min',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    session.location,
                  ),
                  const SizedBox(height: 12),
                  _buildRsvpSummary(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRsvpBadge(RsvpStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case RsvpStatus.attending:
        color = AppColors.success;
        label = 'Attending';
        icon = Icons.check_circle;
        break;
      case RsvpStatus.maybe:
        color = AppColors.warning;
        label = 'Maybe';
        icon = Icons.help;
        break;
      case RsvpStatus.notAttending:
        color = AppColors.error;
        label = 'Not Attending';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRsvpSummary() {
    return Row(
      children: [
        _buildRsvpCount(Icons.check_circle, session.attendingCount, AppColors.success),
        const SizedBox(width: 12),
        _buildRsvpCount(Icons.help, session.maybeCount, AppColors.warning),
        const SizedBox(width: 12),
        _buildRsvpCount(Icons.cancel, session.notAttendingCount, AppColors.error),
      ],
    );
  }

  Widget _buildRsvpCount(IconData icon, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
