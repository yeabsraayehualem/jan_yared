import 'package:flutter/material.dart';
import 'models/project.dart';
import 'login_page.dart';
import 'attendance_page.dart';
import 'leave_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Project> _projects = [
    Project(
      title: 'Heritage Site Restoration',
      status: ProjectStatus.active,
      category: ProjectCategory.construction,
      startDate: DateTime(2025, 1, 15),
      endDate: DateTime(2025, 12, 31),
      progress: 65,
    ),
    Project(
      title: 'Community Center Development',
      status: ProjectStatus.active,
      category: ProjectCategory.architecture,
      startDate: DateTime(2025, 3, 1),
      endDate: DateTime(2025, 9, 30),
      progress: 40,
    ),
    Project(
      title: 'Infrastructure Upgrade Phase 2',
      status: ProjectStatus.completed,
      category: ProjectCategory.engineering,
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 12, 31),
      progress: 100,
    ),
  ];

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to Attendance page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AttendancePage()),
      );
    } else if (index == 2) {
      // Navigate to Leave page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LeavePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  IconData _getCategoryIcon(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.construction:
        return Icons.build;
      case ProjectCategory.architecture:
        return Icons.architecture;
      case ProjectCategory.engineering:
        return Icons.engineering;
    }
  }

  String _getCategoryName(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.construction:
        return 'Construction';
      case ProjectCategory.architecture:
        return 'Architecture';
      case ProjectCategory.engineering:
        return 'Engineering';
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return const Color(0xFF4CAF50); // Green
      case ProjectStatus.completed:
        return const Color(0xFF2196F3); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFC8102E),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title and Subtitle
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jan Yared',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Employee Portal',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            // Logout Button
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(
                Icons.logout,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Projects Section Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Projects',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View all your assigned projects',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Project Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to project details
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  project.title,
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  project.status == ProjectStatus.active
                                      ? 'Active'
                                      : 'Completed',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Category and Date
                          Row(
                            children: [
                              Icon(
                                _getCategoryIcon(project.category),
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getCategoryName(project.category),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatDate(project.startDate)} - ${_formatDate(project.endDate)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Progress
                          Row(
                            children: [
                              const Text(
                                'Progress',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: project.progress / 100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFA00000),
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${project.progress}%',
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF333333),
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFC8102E),
          unselectedItemColor: const Color(0xFF666666),
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 0
                    ? BoxDecoration(
                        color: const Color(0xFFC8102E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: const Icon(Icons.folder_copy),
              ),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_circle_outline),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.description),
              label: 'Leave',
            ),
          ],
        ),
      ),
    );
  }
}

