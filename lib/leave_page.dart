import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'attendance_page.dart';
import 'models/leave_request.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  int _selectedIndex = 2; // Leave is selected

  // Projects list for dropdown
  final List<String> _projects = [
    'Heritage Site Restoration',
    'Community Center Development',
    'Infrastructure Upgrade Phase 2',
  ];

  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      type: LeaveType.annual,
      status: LeaveStatus.approved,
      days: 5,
      startDate: DateTime(2025, 11, 15),
      endDate: DateTime(2025, 11, 20),
      project: 'Heritage Site Restoration',
      submittedDate: DateTime(2025, 10, 20),
    ),
    LeaveRequest(
      type: LeaveType.sick,
      status: LeaveStatus.approved,
      days: 2,
      startDate: DateTime(2025, 10, 10),
      endDate: DateTime(2025, 10, 11),
      project: 'Community Center Development',
      submittedDate: DateTime(2025, 10, 9),
    ),
    LeaveRequest(
      type: LeaveType.personal,
      status: LeaveStatus.pending,
      days: 3,
      startDate: DateTime(2025, 12, 1),
      endDate: DateTime(2025, 12, 3),
      project: 'Heritage Site Restoration',
      submittedDate: DateTime(2025, 11, 15),
    ),
  ];

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to Projects/Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (index == 1) {
      // Navigate to Attendance
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AttendancePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _handleRequestLeave() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _RequestLeaveDialog(),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (start.month == end.month && start.year == end.year) {
      return '${months[start.month - 1]} ${start.day} - ${end.day}, ${start.year}';
    } else if (start.year == end.year) {
      return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}, ${start.year}';
    } else {
      return '${months[start.month - 1]} ${start.day}, ${start.year} - ${months[end.month - 1]} ${end.day}, ${end.year}';
    }
  }

  String _getLeaveTypeName(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.personal:
        return 'Personal Leave';
    }
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return const Color(0xFF4CAF50); // Green
      case LeaveStatus.pending:
        return const Color(0xFFFFC107); // Yellow
      case LeaveStatus.rejected:
        return const Color(0xFFF44336); // Red
    }
  }

  Color _getStatusTextColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
      case LeaveStatus.rejected:
        return Colors.white;
      case LeaveStatus.pending:
        return const Color(0xFF333333);
    }
  }

  String _formatSubmittedDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]}/${date.day}/${date.year}';
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Management Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Leave Management',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Request and track your leaves',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _handleRequestLeave,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8102E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Leave Requests Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leave Requests',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Leave Request Cards
                  ..._leaveRequests.map((request) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title, Status, and Duration
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getLeaveTypeName(request.type),
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 18,
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
                                      color: _getStatusColor(request.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      request.status == LeaveStatus.approved
                                          ? 'Approved'
                                          : request.status == LeaveStatus.pending
                                              ? 'Pending'
                                              : 'Rejected',
                                      style: TextStyle(
                                        color: _getStatusTextColor(request.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${request.days} days',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Calendar date
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDateRange(
                                      request.startDate,
                                      request.endDate,
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Project
                              Text(
                                'Project: ${request.project}',
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 13,
                                ),
                              ),
                              // Submitted date (if not pending or if it exists)
                              if (request.status != LeaveStatus.pending)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Submitted: ${_formatSubmittedDate(request.submittedDate)}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
              icon: const Icon(Icons.folder_copy),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_circle_outline),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 2
                    ? BoxDecoration(
                        color: const Color(0xFFC8102E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: const Icon(Icons.description),
              ),
              label: 'Leave',
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestLeaveDialog extends StatefulWidget {
  const _RequestLeaveDialog();

  @override
  State<_RequestLeaveDialog> createState() => _RequestLeaveDialogState();
}

class _RequestLeaveDialogState extends State<_RequestLeaveDialog> {
  final _formKey = GlobalKey<FormState>();
  LeaveType? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProject;
  final _daysController = TextEditingController();

  final List<String> _projects = [
    'Heritage Site Restoration',
    'Community Center Development',
    'Infrastructure Upgrade Phase 2',
  ];

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
        // Auto-calculate days if both dates are set
        if (_startDate != null && _endDate != null) {
          final days = _endDate!.difference(_startDate!).inDays + 1;
          _daysController.text = days.toString();
        }
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLeaveType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a leave type')),
        );
        return;
      }
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }
      if (_selectedProject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a project')),
        );
        return;
      }
      if (_daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter number of days')),
        );
        return;
      }

      // TODO: Submit leave request to backend
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Request Leave',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: const Color(0xFF333333),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Leave Type Dropdown
                const Text(
                  'Leave Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<LeaveType>(
                    value: _selectedLeaveType,
                    decoration: InputDecoration(
                      hintText: 'Select leave type',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[600],
                      ),
                    ),
                    items: LeaveType.values.map((type) {
                      String name;
                      switch (type) {
                        case LeaveType.annual:
                          name = 'Annual Leave';
                        case LeaveType.sick:
                          name = 'Sick Leave';
                        case LeaveType.personal:
                          name = 'Personal Leave';
                      }
                      return DropdownMenuItem(
                        value: type,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaveType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Start Date
                const Text(
                  'Start Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _startDate == null
                                ? 'mm/dd/yyyy'
                                : _formatDate(_startDate!),
                            style: TextStyle(
                              color: _startDate == null
                                  ? Colors.grey[400]
                                  : const Color(0xFF333333),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // End Date
                const Text(
                  'End Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _endDate == null
                                ? 'mm/dd/yyyy'
                                : _formatDate(_endDate!),
                            style: TextStyle(
                              color: _endDate == null
                                  ? Colors.grey[400]
                                  : const Color(0xFF333333),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Project Dropdown
                const Text(
                  'Project',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedProject,
                    decoration: InputDecoration(
                      hintText: 'Select project',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[600],
                      ),
                    ),
                    items: _projects.map((project) {
                      return DropdownMenuItem(
                        value: project,
                        child: Text(project),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProject = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Number of Days
                const Text(
                  'Number of Days',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter number of days',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of days';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA00000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

