import 'package:flutter/material.dart';
import 'package:jan_yared/dashboard_page.dart';
import 'package:jan_yared/login_page.dart';
import 'package:jan_yared/providors/attendance_providor.dart';
import 'package:jan_yared/providors/auth_providor.dart';
import 'package:provider/provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
   runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? const DashboardPage() : const LoginPage();
        },
      ),
    );
  }
}