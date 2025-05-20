class AppConstants {
  // App name
  static const String appName = 'DomiNotes';
  
  // Routes
  static const String splashRoute = '/';
  static const String pinSetupRoute = '/pin-setup';
  static const String pinLoginRoute = '/pin-login';
  static const String homeRoute = '/home';
  static const String noteEditorRoute = '/note-editor';
  static const String folderSelectionRoute = '/folder-selection';
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // PIN Constants
  static const int pinLength = 4;
}
