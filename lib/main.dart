import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'providers/folders_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/note_editor_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force cache refresh for web
  if (kIsWeb) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  // Initialize services
  final databaseService = DatabaseService();
  await databaseService.init();
  
  final themeService = ThemeService();
  await themeService.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FoldersProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: AppConstants.splashRoute,
            routes: {
              AppConstants.splashRoute: (context) => const SplashScreen(),
              AppConstants.pinSetupRoute: (context) => const PinSetupScreen(),
              AppConstants.pinLoginRoute: (context) => const PinLoginScreen(),
              AppConstants.homeRoute: (context) => const HomeScreen(),
              AppConstants.noteEditorRoute: (context) => const NoteEditorScreen(),
            },
          );
        },
      ),
    );
  }
}
