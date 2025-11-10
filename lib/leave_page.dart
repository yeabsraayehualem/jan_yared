// leave_page.dart
import 'package:flutter/material.dart';
import 'package:jan_yared/providors/leave_providor.dart';
import 'package:provider/provider.dart';
import 'package:jan_yared/models/leaveModels.dart';
import 'package:jan_yared/core/constants.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'attendance_page.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  int _selectedIndex = 2; // Leave is selected

  // UI state
  bool _isLoading = true;
  String? _error;
  List<LeaveType> _leaveTypes = [];
  List<LeaveRequest> _leaveRequests = [];

  // Employee data – in a real app you get this from login / shared prefs
  late final int _employeeId;
  late final String _sessionId;

  @override
  void initState() {
    super.initState();
    // -----------------------------------------------------------------
    // 1. Get employee_id & session_id from wherever you store them
    // -----------------------------------------------------------------
    // Example (replace with your own logic):
    _employeeId = 123;               // <-- from login response / secure storage
    _sessionId = "your_session_id"; // <-- from login response / secure storage

    _loadData();
  }

  Future<void> _loadData() async {
    final prov = Provider.of<LeaveProvidor>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. fetch leave types
      final types = await prov.fetchLeaveTypes(
        employee_id: _employeeId,
        session_id: _sessionId,
      );

      // 2. fetch employee leaves (raw map → LeaveRequest)
      final rawLeaves = await prov.fetchEmployeeLeaves(
        employeeId: _employeeId,
        sessionId: _sessionId,
      );

      final requests = rawLeaves.map((m) => _mapToLeaveRequest(m, types)).toList();

      setState(() {
        _leaveTypes = types;
        _leaveRequests = requests;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------
  // Convert Odoo raw map → LeaveRequest
  // ---------------------------------------------------------------
  LeaveRequest _mapToLeaveRequest(Map<String, dynamic> m, List<LeaveType> types) {
    final statusStr = (m['state'] as String?) ?? 'to_confirm';
    switch (statusStr) {
      case 'confirm':
      case 'validate':
      case 'validate1':
        break;
      case 'refuse':
        break;
      default:
    }

    // holiday_status_id is [id, name] in Odoo
    final holiday = (m['holiday_status_id'] as List<dynamic>?)?[0] as int?;
    final type = types.firstWhere(
      (t) => t.id == holiday,
      orElse: () => LeaveType(id: -1, name: 'Unknown'),
    );

    // dates are strings like "2025-11-15 00:00:00"
    final start = _parseDate(m['date_from'] ?? m['request_date_from']);
    final end = _parseDate(m['date_to'] ?? m['request_date_to']);

    return LeaveRequest(
      type: type.id, // <-- we store the id, UI will resolve the name later
      days: (m['number_of_days'] as num?)?.toInt() ?? 0,
      startDate: start,
      endDate: end,
      project: (m['name'] as String?) ?? '–',
      submittedDate: _parseDate(m['create_date'] ?? DateTime.now().toString()),
     
    );
  }

  DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    final s = raw.toString();
    try {
      return DateTime.parse(s.split(' ').first);
    } catch (_) {
      return DateTime.now();
    }
  }

  // -----------------------------------------------------------------
  // Navigation
  // -----------------------------------------------------------------
  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AttendancePage()));
    } else if (index == 2) {
      // already here
    } else {
       Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardPage()));

    }
  }

  void _handleRequestLeave() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _RequestLeaveDialog(
        leaveTypes: _leaveTypes,
        employeeId: _employeeId,
        sessionId: _sessionId,
        onSubmitted: () {
          // refresh list after submit
          _loadData();
        },
      ),
    );
  }

  // -----------------------------------------------------------------
  // UI helpers
  // -----------------------------------------------------------------
  String _formatDate(DateTime d) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatDateRange(DateTime s, DateTime e) {
    if (s.month == e.month && s.year == e.year) {
      return '${_formatDate(s).split(' ').first} ${s.day} - ${e.day}, ${s.year}';
    }
    return '${_formatDate(s)} - ${_formatDate(e)}';
  }

  String _getLeaveTypeName(int id) {
    final t = _leaveTypes.firstWhere((t) => t.id == id,
        orElse: () => LeaveType(id: -1, name: 'Unknown'));
    return t.name;
  }



  // -----------------------------------------------------------------
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
              decoration: const BoxDecoration(
                color: Color(0xFFC8102E),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset('assets/logo.jpg', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jan Yared',
                      style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('Employee Portal',
                      style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Color(0xFF333333))),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ----- Header -----
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Leave Management',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333))),
                                  SizedBox(height: 4),
                                  Text('Request and track your leaves',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey)),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _handleRequestLeave,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text('Request',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC8102E),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ----- List of Requests -----
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Leave Requests',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333))),
                            const SizedBox(height: 16),
                            if (_leaveRequests.isEmpty)
                              const Center(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text('No leave requests yet.',
                                    style: TextStyle(color: Colors.grey)),
                              ))
                            else
                              ..._leaveRequests.map((req) => _buildCard(req)),
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
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2))
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
            const BottomNavigationBarItem(
                icon: Icon(Icons.folder_copy), label: 'Projects'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline), label: 'Attendance'),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 2
                    ? BoxDecoration(
                        color: const Color(0xFFC8102E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8))
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

  Widget _buildCard(LeaveRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status + days
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(_getLeaveTypeName(req.type),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333))),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                   "Approved",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${req.days} days',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Calendar
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(_formatDateRange(req.startDate, req.endDate),
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            // Project
            Text('Project: ${req.project}',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF333333))),
            // Submitted (only for non-pending)
           
          ],
        ),
      ),
    );
  }
}

// ====================================================================
//                     REQUEST LEAVE DIALOG
// ====================================================================
class _RequestLeaveDialog extends StatefulWidget {
  final List<LeaveType> leaveTypes;
  final int employeeId;
  final String sessionId;
  final VoidCallback onSubmitted;

  const _RequestLeaveDialog({
    required this.leaveTypes,
    required this.employeeId,
    required this.sessionId,
    required this.onSubmitted,
  });

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

  String _fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate(bool start) async {
    final init = start
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (start) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
      }

      if (_startDate != null && _endDate != null) {
        final days = _endDate!.difference(_startDate!).inDays + 1;
        _daysController.text = days.toString();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLeaveType == null ||
        _startDate == null ||
        _endDate == null ||
        _selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final prov = Provider.of<LeaveProvidor>(context, listen: false);
    final req = LeaveRequest(
      type: _selectedLeaveType!.id,
      days: int.parse(_daysController.text),
      startDate: _startDate!,
      endDate: _endDate!,
      project: _selectedProject!,
      submittedDate: DateTime.now(),
    );

    final ok = await prov.submitLeaveRequest(
      employeeId: widget.employeeId,
      sessionId: widget.sessionId,
      request: req,
    );

    Navigator.of(context).pop(); // close dialog

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Leave request submitted!'
          : 'Failed to submit request'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));

    if (ok) widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Request Leave',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333))),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: const Color(0xFF333333)),
                  ],
                ),
                const SizedBox(height: 24),

                // ---------- Leave Type ----------
                const Text('Leave Type',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333))),
                const SizedBox(height: 8),
                DropdownButtonFormField<LeaveType>(
                  value: _selectedLeaveType,
                  hint: Text('Select leave type',
                      style: TextStyle(color: Colors.grey[400])),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  items: widget.leaveTypes
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLeaveType = v),
                  validator: (v) =>
                      v == null ? 'Select a leave type' : null,
                ),
                const SizedBox(height: 20),

                // ---------- Start Date ----------
                const Text('Start Date',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333))),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDate(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                                _startDate == null
                                    ? 'mm/dd/yyyy'
                                    : _fmt(_startDate!),
                                style: TextStyle(
                                    color: _startDate == null
                                        ? Colors.grey[400]
                                        : const Color(0xFF333333)))),
                        Icon(Icons.calendar_today,
                            size: 20, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- End Date ----------
                const Text('End Date',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333))),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDate(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                                _endDate == null
                                    ? 'mm/dd/yyyy'
                                    : _fmt(_endDate!),
                                style: TextStyle(
                                    color: _endDate == null
                                        ? Colors.grey[400]
                                        : const Color(0xFF333333)))),
                        Icon(Icons.calendar_today,
                            size: 20, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Project ----------
                const Text('Project',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedProject,
                  hint: Text('Select project',
                      style: TextStyle(color: Colors.grey[400])),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  items: _projects
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedProject = v),
                  validator: (v) => v == null ? 'Select a project' : null,
                ),
                const SizedBox(height: 20),

                // ---------- Days ----------
                const Text('Number of Days',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  readOnly: true, // auto-filled
                  decoration: InputDecoration(
                    hintText: 'Auto-calculated',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Days required' : null,
                ),
                const SizedBox(height: 32),

                // ---------- Buttons ----------
                Row(
                  children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                side:
                                    BorderSide(color: Colors.grey[300]!)),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA00000),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: const Text('Submit Request',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)))),
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