/// All GetStorage keys in one place. Use these constants only.
class AppStorageKeys {
  AppStorageKeys._();

  // Auth
  static const String isLoggedIn = 'is_logged_in';
  static const String userPhone = 'user_phone';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String authToken = 'auth_token';

  // Onboarding
  static const String onboardingCompleted = 'onboarding_completed';

  // App preferences (add more as needed)
  static const String themeMode = 'theme_mode';
  static const String selectedState = 'selected_state';
  static const String fcmToken = 'fcm_token';
}
