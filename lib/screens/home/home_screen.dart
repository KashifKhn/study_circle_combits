import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_circle/models/user_model.dart';
import 'package:study_circle/models/study_session_model.dart';
import 'package:study_circle/models/study_group_model.dart';
import 'package:study_circle/providers/auth_provider.dart' as app_auth;
import 'package:study_circle/providers/theme_provider.dart';
import 'package:study_circle/services/firestore_service.dart';
import 'package:study_circle/theme/app_colors.dart';
import 'package:study_circle/screens/groups/groups_list_screen.dart';
import 'package:study_circle/screens/sessions/my_sessions_screen.dart';
import 'package:study_circle/screens/profile/profile_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _buildAppBar(context, user),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardTab(user: user, onChangeTab: _changeTab),
          GroupsListScreen(),
          MySessionsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to create group screen
                Navigator.pushNamed(context, '/create-group');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Group'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UserModel user) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
          ),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hello, ${user.name.split(' ').first}! 👋',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Ready to learn today?',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined, color: Colors.white),
          tooltip: 'Achievements',
          onPressed: () {
            Navigator.pushNamed(context, '/achievements');
          },
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month_outlined, color: Colors.white),
          tooltip: 'Calendar',
          onPressed: () {
            Navigator.pushNamed(context, '/calendar');
          },
        ),
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            context.read<ThemeProvider>().toggleTheme();
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Groups',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event),
          label: 'Sessions',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Dashboard Tab
class _DashboardTab extends StatelessWidget {
  final UserModel user;
  final Function(int) onChangeTab;

  const _DashboardTab({required this.user, required this.onChangeTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh user data
        await context.read<app_auth.AuthProvider>().reloadUserData();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, AppColors.surfaceDark]
                : [AppColors.gray50, AppColors.backgroundLight],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildUpcomingSessions(),
              const SizedBox(height: 24),
              _buildRecentGroups(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final firestoreService = FirestoreService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.groups_rounded,
                title: 'Groups Joined',
                value: user.joinedGroupIds.length.toString(),
                color: AppColors.primary,
                gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<List<StudySessionModel>>(
                stream: firestoreService.getUpcomingSessions(user.joinedGroupIds),
                builder: (context, snapshot) {
                  final sessionCount = snapshot.data?.length ?? 0;
                  return _StatCard(
                    icon: Icons.event_available_rounded,
                    title: 'Upcoming',
                    value: sessionCount.toString(),
                    color: AppColors.success,
                    gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.group_add_rounded,
                title: 'Groups Created',
                value: user.createdGroupIds.length.toString(),
                color: AppColors.accent,
                gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder(
                stream: firestoreService.getUserStatsStream(user.uid),
                builder: (context, snapshot) {
                  final stats = snapshot.data;
                  final points = stats?.totalPoints ?? 0;
                  return _StatCard(
                    icon: Icons.stars_rounded,
                    title: 'Total Points',
                    value: points.toString(),
                    color: AppColors.warning,
                    gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'Create Group',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/create-group'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.search_rounded,
                label: 'Find Groups',
                color: AppColors.info,
                onTap: () {
                  // Switch to groups tab
                  onChangeTab(1);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.event_note_rounded,
                label: 'My Sessions',
                color: AppColors.success,
                onTap: () => onChangeTab(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.question_answer_rounded,
                label: 'Q&A Forum',
                color: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, '/qna-list'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSessions() {
    final firestoreService = FirestoreService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_today_rounded, 
                    color: AppColors.info, 
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Upcoming Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => onChangeTab(2),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<StudySessionModel>>(
          stream: firestoreService.getUpcomingSessions(user.joinedGroupIds),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildEmptyState(
                icon: Icons.error_outline_rounded,
                message: 'Error loading sessions',
                color: AppColors.error,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final sessions = snapshot.data ?? [];

            if (sessions.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_busy_rounded,
                message: 'No upcoming sessions yet',
                subtitle: 'Join a group to see sessions',
                color: AppColors.gray400,
              );
            }

            // Show first 3 sessions
            final displaySessions = sessions.take(3).toList();

            return Column(
              children: displaySessions.map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SessionPreviewCard(session: session),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentGroups() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.groups_rounded, 
                    color: AppColors.primary, 
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'My Groups',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => onChangeTab(1),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        user.joinedGroupIds.isEmpty
            ? _buildEmptyState(
                icon: Icons.group_add_rounded,
                message: 'No groups yet',
                subtitle: 'Join or create your first study group!',
                color: AppColors.gray400,
              )
            : Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.groups_rounded, 
                        color: AppColors.primary, 
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.joinedGroupIds.length == 1 
                              ? '1 Study Group' 
                              : '${user.joinedGroupIds.length} Study Groups',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep learning together!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, 
                      color: AppColors.primary, 
                      size: 28,
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon, 
    required String message, 
    String? subtitle,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: (color ?? AppColors.gray400).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? AppColors.gray400).withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 56, color: color ?? AppColors.gray400),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: AppColors.gray700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient.map((c) => c.withValues(alpha: isDark ? 0.2 : 0.15)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: isDark ? 0.15 : 0.1),
                color.withValues(alpha: isDark ? 0.1 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Session Preview Card Widget
class _SessionPreviewCard extends StatelessWidget {
  final StudySessionModel session;

  const _SessionPreviewCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final timeFormat = DateFormat('h:mm a');
    final firestoreService = FirestoreService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<StudyGroupModel?>(
      stream: firestoreService.getStudyGroupStream(session.groupId),
      builder: (context, groupSnapshot) {
        final group = groupSnapshot.data;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: group != null
                ? () {
                    Navigator.pushNamed(
                      context,
                      '/session-details',
                      arguments: {'session': session, 'group': group},
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                  ? AppColors.surfaceDark 
                  : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.info.withValues(alpha: 0.2),
                          AppColors.info.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.event_rounded, 
                      color: AppColors.info, 
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, 
                              size: 14, 
                              color: AppColors.gray500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dateFormat.format(session.dateTime)} • ${timeFormat.format(session.dateTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                        if (group != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.groups_rounded, 
                                size: 14, 
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, 
                      color: AppColors.info, 
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
