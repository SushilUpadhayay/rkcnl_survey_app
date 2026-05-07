import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/surveys_screen.dart';
import 'screens/respondents_screen.dart';
import 'screens/survey_form_screen.dart';
import 'screens/sync_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final storage = await StorageService.create();
  final appState = AppState(storage);
  runApp(
    ChangeNotifierProvider.value(value: appState, child: const RKNCLSurveyApp()),
  );
}

class RKNCLSurveyApp extends StatelessWidget {
  const RKNCLSurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final router = _buildRouter(appState);
    return MaterialApp.router(
      title: 'RKNCL Survey App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(dark: false),
      darkTheme: buildAppTheme(dark: true),
      themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}

GoRouter _buildRouter(AppState appState) => GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    if (state.matchedLocation == '/splash') return null;
    if (!appState.isLoggedIn && state.matchedLocation != '/login' && state.matchedLocation != '/otp') {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/surveys', builder: (_, __) => const SurveysScreen()),
    GoRoute(
      path: '/respondents/:surveyId',
      builder: (_, state) => RespondentsScreen(surveyId: state.pathParameters['surveyId']!),
    ),
    GoRoute(
      path: '/form/:surveyId/:respondentId',
      builder: (_, state) => SurveyFormScreen(
        surveyId: state.pathParameters['surveyId']!,
        respondentId: state.pathParameters['respondentId']!,
      ),
    ),
    GoRoute(path: '/sync', builder: (_, __) => const SyncScreen()),
    GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
