import 'package:flutter/material.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/absentease_theme.dart';
import 'features/auth/screens/absentease_login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/leave_screen.dart';
import 'screens/overtime_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/news_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const AbsenEaseApp());
}

class AbsenEaseApp extends StatelessWidget {
  const AbsenEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbsenEase',
      debugShowCheckedModeBanner: false,
      theme: AbsenEaseTheme.lightTheme,
      routes: {
        '/': (context) => const AbsenEaseLoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/employees': (context) => const EmployeesScreen(),
        '/leave': (context) => const LeaveScreen(),
        '/overtime': (context) => const OvertimeScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/news': (context) => const NewsScreen(),
      },
      initialRoute: '/',
    );
  }
}
