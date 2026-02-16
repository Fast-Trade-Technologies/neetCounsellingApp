/// All GetStorage keys in one place. Use these constants only.
class AppStorageKeys {
  AppStorageKeys._();

  // Auth
  static const String isLoggedIn = 'is_logged_in';
  static const String userPhone = 'user_phone';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String authToken = 'auth_token';
  /// Token from login API (used for verify-otp / resend-otp).
  static const String loginToken = 'login_token';
  /// User ID from verify-otp (nLoginUserIdNo for authenticated APIs).
  static const String userId = 'user_id';
  /// From verify-otp data.user
  static const String userFirstName = 'user_first_name';
  static const String userLastName = 'user_last_name';
  static const String userStream = 'user_stream';
  static const String userPaidStatus = 'user_paid_status';
  static const String userImage = 'user_image';

  // Onboarding
  static const String onboardingCompleted = 'onboarding_completed';

  // App preferences (add more as needed)
  static const String themeMode = 'theme_mode';
  static const String selectedState = 'selected_state';
  static const String fcmToken = 'fcm_token';
}
