import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _lastLoginKey = 'last_login';
  static const String _currentStreakKey = 'current_streak';

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  static Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString(_lastLoginKey);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day).toString();

    if (lastLogin == null) {
      // First time user
      await prefs.setString(_lastLoginKey, todayDate);
      await prefs.setInt(_currentStreakKey, 1);
      return;
    }

    final lastLoginDate = DateTime.parse(lastLogin);
    final difference = today.difference(lastLoginDate).inDays;

    if (todayDate != lastLogin) {
      int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;

      if (difference == 1) {
        // Consecutive day
        currentStreak++;
      } else if (difference > 1) {
        // Streak broken
        currentStreak = 1;
      }

      await prefs.setString(_lastLoginKey, todayDate);
      await prefs.setInt(_currentStreakKey, currentStreak);
    }
  }
}
