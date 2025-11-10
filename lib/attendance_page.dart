import 'package:flutter/material.dart';
import 'package:jan_yared/leave_page.dart';
import 'package:jan_yared/models/attendanceModel.dart';
import 'package:jan_yared/providors/attendance_providor.dart';
import 'package:jan_yared/providors/auth_providor.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'qr_scanner_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _selectedIndex = 1;
  double absent_days = 0.0,
      present_days = 0.0,
      onleave_days = 0.0,
      total_hours = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      // Get providers
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (auth.user == null || auth.sessionId == null) return;

      // Call the async method
      final data = await attendanceProvider.getAttendances(
        employee_id:
            auth.user!.employeeId, // make sure to use auth.user!.employeeId
        session_id: auth.sessionId!,
      );

      if (data.isEmpty) return;

      // Convert the first item into a summary model
      final attendanceSummary = data[0];

      // Now you can use attendanceSummary to update state
      setState(() {
        // For example:
        absent_days = attendanceSummary.totalAbsent.toDouble();
        present_days = attendanceSummary.totalPresent.toDouble();
        onleave_days = attendanceSummary.totalOnLeave.toDouble();
        total_hours = attendanceSummary.totalWorkedHours.toDouble();
      });
    } catch (e) {
      debugPrint("Error loading attendance: $e");
    }
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AttendancePage()),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LeavePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _handleScanQRCode() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const QRScannerPage()));
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
                child: Image.asset('assets/logo.jpg', fit: BoxFit.contain),
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
              icon: const Icon(Icons.logout, color: Color(0xFF333333)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendance Section Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your attendance and hours',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

            // Scan Attendance Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFC8102E),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Scan Attendance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use QR code to mark attendance',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleScanQRCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFC8102E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Monthly Report Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Report',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 2x2 Grid of Stat Cards
                  Row(
                    children: [
                      // Total Hours Card
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.access_time,
                          iconColor: const Color(0xFF2196F3),
                          value: '$total_hours',
                          label: 'Total Hours',
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Present Days Card
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          iconColor: const Color(0xFF4CAF50),
                          value: '$present_days',
                          label: 'Present Days',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Absent Days Card
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.cancel,
                          iconColor: const Color(0xFFF44336),
                          value: '$absent_days',
                          label: 'Absent Days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      // On Leave Card
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.work_outline,
                          iconColor: const Color(0xFFFFC107),
                          value: '$onleave_days',
                          label: 'On Leave',
                        ),
                      ),
                    ],
                  ),
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
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: _selectedIndex == 1
                    ? BoxDecoration(
                        color: const Color(0xFFC8102E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: const Icon(Icons.check_circle_outline),
              ),
              label: 'Attendance',
            ),
            // BottomNavigationBarItem(
            //   icon: const Icon(Icons.description),
            //   label: 'Leave',
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
