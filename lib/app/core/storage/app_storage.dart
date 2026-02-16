import 'package:get_storage/get_storage.dart';

import 'app_storage_keys.dart';

/// App-level GetStorage wrapper. Use [AppStorageKeys] for all keys.
class AppStorage {
  AppStorage._();

  static final GetStorage _box = GetStorage();

  static Future<void> init() => GetStorage.init();

  // Auth
  static bool get isLoggedIn => _box.read(AppStorageKeys.isLoggedIn) as bool? ?? false;
  static set isLoggedIn(bool v) => _box.write(AppStorageKeys.isLoggedIn, v);

  static String? get userPhone => _box.read(AppStorageKeys.userPhone) as String?;
  static set userPhone(String? v) => _box.write(AppStorageKeys.userPhone, v);

  static String? get userEmail => _box.read(AppStorageKeys.userEmail) as String?;
  static set userEmail(String? v) => _box.write(AppStorageKeys.userEmail, v);

  static String? get userName => _box.read(AppStorageKeys.userName) as String?;
  static set userName(String? v) => _box.write(AppStorageKeys.userName, v);

  static String? get authToken => _box.read(AppStorageKeys.authToken) as String?;
  static set authToken(String? v) => _box.write(AppStorageKeys.authToken, v);

  static String? get loginToken => _box.read(AppStorageKeys.loginToken) as String?;
  static set loginToken(String? v) => _box.write(AppStorageKeys.loginToken, v);

  static String? get userId => _box.read(AppStorageKeys.userId) as String?;
  static set userId(String? v) => _box.write(AppStorageKeys.userId, v);

  // Onboarding
  static bool get onboardingCompleted => _box.read(AppStorageKeys.onboardingCompleted) as bool? ?? false;
  static set onboardingCompleted(bool v) => _box.write(AppStorageKeys.onboardingCompleted, v);

  // Preferences
  static String? get themeMode => _box.read(AppStorageKeys.themeMode) as String?;
  static set themeMode(String? v) => _box.write(AppStorageKeys.themeMode, v);

  static void clearAuth() {
    _box.remove(AppStorageKeys.isLoggedIn);
    _box.remove(AppStorageKeys.userPhone);
    _box.remove(AppStorageKeys.userEmail);
    _box.remove(AppStorageKeys.userName);
    _box.remove(AppStorageKeys.authToken);
    _box.remove(AppStorageKeys.loginToken);
    _box.remove(AppStorageKeys.userId);
  }

  static Future<void> clearAll() => _box.erase();
}
