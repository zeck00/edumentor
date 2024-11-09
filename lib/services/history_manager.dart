import 'package:shared_preferences/shared_preferences.dart';

class QuestionHistoryManager {
  static const String _historyKey = 'question_history';
  static const int _maxHistorySize = 20;

  static Future<List<String>> getQuestionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    return history;
  }

  static Future<void> addQuestionToHistory(String questionText) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    // Remove the question if it already exists to avoid duplicates
    history.remove(questionText);

    // Add new question at the beginning
    history.insert(0, questionText);

    // Keep only the most recent questions up to _maxHistorySize
    if (history.length > _maxHistorySize) {
      history = history.sublist(0, _maxHistorySize);
    }

    await prefs.setStringList(_historyKey, history);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
