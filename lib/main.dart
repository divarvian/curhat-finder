import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/config/router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'core/utils/academic_helper.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Dotenv load note: $e");
  }

  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
      await NotificationService.initialize();
    }
  } catch (e) {
    debugPrint("Firebase/Notification init error: $e");
  }

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint("Supabase init error: $e");
  }

  try {
    await AcademicHelper.initialize();
  } catch (e) {
    debugPrint("AcademicHelper init error: $e");
  }

  runApp(
    const ProviderScope(
      child: MainAppRoot(),
    ),
  );
}

class MainAppRoot extends StatelessWidget {
  const MainAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppContent();
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Curhat Finder',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
