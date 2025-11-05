import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_circle/models/study_group_model.dart';
import 'package:study_circle/providers/auth_provider.dart' as app_auth;
import 'package:study_circle/services/firestore_service.dart';
import 'package:study_circle/theme/app_colors.dart';
import 'package:study_circle/utils/constants.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedDepartment;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Study Groups',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'All Groups'),
            Tab(text: 'My Groups'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllGroupsTab(),
                _buildMyGroupsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.gray50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gray200.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search groups, courses, locations...',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.gray500),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: AppColors.gray500),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All Departments',
                  isSelected: _selectedDepartment == null,
                  onTap: () {
                    setState(() {
                      _selectedDepartment = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...AppConstants.departments.take(5).map((dept) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: dept,
                      isSelected: _selectedDepartment == dept,
                      onTap: () {
                        setState(() {
                          _selectedDepartment = dept;
                        });
                      },
                    ),
                  );
                }),
                // More button
                InkWell(
                  onTap: () => _showDepartmentFilter(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray200.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list_rounded, 
                          size: 18, 
                          color: AppColors.gray700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'More',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                )
              : null,
          color: isSelected ? null : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }

  Widget _buildAllGroupsTab() {
    return StreamBuilder<List<StudyGroupModel>>(
      stream: _firestoreService.getAllGroups(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error loading groups: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = snapshot.data ?? [];
        
        // Apply filters
        final filteredGroups = _filterGroups(groups);

        if (filteredGroups.isEmpty) {
          return _buildEmptyState(
            icon: Icons.group_off,
            title: 'No groups found',
            message: _searchQuery.isNotEmpty || _selectedDepartment != null
                ? 'Try adjusting your filters'
                : 'Be the first to create a study group!',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredGroups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _GroupCard(group: filteredGroups[index]);
          },
        );
      },
    );
  }

  Widget _buildMyGroupsTab() {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final currentUser = authProvider.userModel;

    if (currentUser == null) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Not Logged In',
        message: 'Please log in to view your groups',
      );
    }

    return StreamBuilder<List<StudyGroupModel>>(
      stream: _firestoreService.getUserGroups(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error loading your groups: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = snapshot.data ?? [];

        if (groups.isEmpty) {
          return _buildEmptyState(
            icon: Icons.groups,
            title: 'No Groups Yet',
            message: 'Groups you join or create will appear here',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _GroupCard(group: groups[index]);
          },
        );
      },
    );
  }

  List<StudyGroupModel> _filterGroups(List<StudyGroupModel> groups) {
    var filtered = groups;

    // Apply search filter - now smarter with multiple word support
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      final searchTerms = query.split(' ').where((term) => term.isNotEmpty).toList();
      
      filtered = filtered.where((group) {
        final name = group.name.toLowerCase();
        final courseCode = group.courseCode.toLowerCase();
        final courseName = group.courseName.toLowerCase();
        final description = group.description.toLowerCase();
        final location = group.location.toLowerCase();
        
        // If multiple words, all terms must match somewhere
        if (searchTerms.length > 1) {
          return searchTerms.every((term) =>
            name.contains(term) ||
            courseCode.contains(term) ||
            courseName.contains(term) ||
            description.contains(term) ||
            location.contains(term)
          );
        }
        
        // Single word search - match anywhere
        return name.contains(query) ||
            courseCode.contains(query) ||
            courseName.contains(query) ||
            description.contains(query) ||
            location.contains(query);
      }).toList();
    }

    // Apply department filter
    if (_selectedDepartment != null) {
      filtered = filtered.where((group) {
        return group.courseName.contains(_selectedDepartment!);
      }).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              title,
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

  void _showDepartmentFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Department',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDepartment = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        RadioListTile<String?>(
                          title: const Text('All Departments'),
                          value: null,
                          groupValue: _selectedDepartment,
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ...AppConstants.departments.map((dept) {
                          return RadioListTile<String>(
                            title: Text(dept),
                            value: dept,
                            groupValue: _selectedDepartment,
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartment = value;
                              });
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Group Card Widget
class _GroupCard extends StatelessWidget {
  final StudyGroupModel group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark 
              ? AppColors.gray700.withValues(alpha: 0.5)
              : AppColors.gray200.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/group-details',
              arguments: group.id,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container with gradient
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and course code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.1),
                                  AppColors.primaryLight.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              group.courseCode,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge with gradient
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(),
                            _getStatusColor().withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Description
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    group.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      height: 1.4,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (isDark ? AppColors.gray700 : AppColors.gray300)
                            .withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.people_rounded,
                      label: '${group.memberIds.length}/${group.maxMembers} members',
                      color: AppColors.info,
                    ),
                    _InfoChip(
                      icon: Icons.school_rounded,
                      label: group.courseName,
                      color: AppColors.accent,
                    ),
                    if (group.location.isNotEmpty)
                      _InfoChip(
                        icon: Icons.location_on_rounded,
                        label: group.location,
                        color: AppColors.warning,
                      ),
                    _InfoChip(
                      icon: group.isPublic ? Icons.public_rounded : Icons.lock_rounded,
                      label: group.isPublic ? 'Public' : 'Private',
                      color: group.isPublic ? AppColors.success : AppColors.warning,
                    ),
                  ],
                ),
                
                // Navigation arrow
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (group.memberIds.length >= group.maxMembers) {
      return AppColors.error;
    } else if (group.memberIds.length >= (group.maxMembers * 0.8)) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (group.memberIds.length >= group.maxMembers) {
      return Icons.block_rounded;
    } else if (group.memberIds.length >= (group.maxMembers * 0.8)) {
      return Icons.warning_rounded;
    }
    return Icons.check_circle_rounded;
  }

  String _getStatusText() {
    if (group.memberIds.length >= group.maxMembers) {
      return 'Full';
    } else if (group.memberIds.length >= (group.maxMembers * 0.8)) {
      return 'Almost Full';
    }
    return 'Open';
  }
}

// Info Chip Widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.gray600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            chipColor.withValues(alpha: isDark ? 0.2 : 0.12),
            chipColor.withValues(alpha: isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
