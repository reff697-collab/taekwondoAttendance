import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/attendance_provider.dart';
import 'features/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initialize Firebase safely (supports offline / demo mode if keys are not configured yet)
  await FirebaseService.initialize();

  // Initialize local persistent storage & seed mock data
  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storageService)),
        ChangeNotifierProvider(create: (_) => StudentProvider(storageService)),
        ChangeNotifierProvider(create: (_) => ScheduleProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AttendanceProvider(storageService)),
      ],
      child: const GtaAttendanceApp(),
    ),
  );
}

class GtaAttendanceApp extends StatelessWidget {
  const GtaAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTA Attendance - Taekwondo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

