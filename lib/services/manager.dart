import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class QuestMgr {
  static QuestMgr? _instance;
  static bool _isCreating = false;
  double _totalScore = 0.0;
  int _questionCount = 0;
  List<Map<String, dynamic>> _questionsData = [];
  Map<String, int> _selectedAnswers = {}; // Changed to Map<String, int>
  Map<int, double> chapterScores = {};

  static Future<QuestMgr> getInstance({
    required List<int> selectedChapters,
    required String difficulty,
  }) async {
    if (_instance != null) return _instance!;
    if (_isCreating) {
      while (_instance == null) {
        await Future.delayed(Duration(milliseconds: 5));
      }
      return _instance!;
    }
    _isCreating = true;
    _instance = QuestMgr();
    await _instance!.initialize(
      selectedChapters: selectedChapters,
      difficulty: difficulty,
    );
    _isCreating = false;
    return _instance!;
  }

  Future<void> initialize({
    required List<int> selectedChapters,
    String difficulty = 'Easy',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');

    if (selectedChapters.isEmpty) {
      throw Exception('Please select chapters for question generation.');
    }

    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      _questionsData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      _questionCount = _questionsData.length;

      // Ensure 'chapter' field is an integer
      for (var question in _questionsData) {
        if (question.containsKey('chapter')) {
          var chapterValue = question['chapter'];
          if (chapterValue is double) {
            question['chapter'] = chapterValue.toInt();
          } else if (chapterValue is String) {
            var intValue = int.tryParse(chapterValue);
            if (intValue != null) {
              question['chapter'] = intValue;
            } else {
              var doubleValue = double.tryParse(chapterValue);
              if (doubleValue != null) {
                question['chapter'] = doubleValue.toInt();
              } else {
                question['chapter'] = -1; // Invalid chapter value
              }
            }
          }
        }
      }

      // Assign IDs to any questions that don't have one
      for (var question in _questionsData) {
        if (!question.containsKey('id')) {
          question['id'] = Uuid().v4();
        }
      }
    } else {
      await generateNewQuestions(5, difficulty, selectedChapters);
    }

    _initializeChapterScores();
    await _loadReadStatus();
  }

  Future<void> generateNewQuestions(
    int numQuestions,
    String difficulty,
    List<int> selectedChapters,
  ) async {
    GPTQuestionGenerator generator = GPTQuestionGenerator();

    // Clear existing unread questions
    _questionsData.removeWhere((q) => !(q['read'] ?? false));

    // Generate new questions for each selected chapter
    for (int chapter in selectedChapters) {
      try {
        final questionData = await generator.generateQuestion(
          difficulty,
          _totalScore.toInt(),
          _selectedAnswers.length,
          _getBestChapter(),
          _getWorstChapter(),
          chapter,
        );

        questionData['id'] = Uuid().v4();
        questionData['correct'] =
            int.tryParse(questionData['correct'].toString()) ?? 0;
        questionData['read'] = false;
        _questionsData.add(questionData);
        _questionCount = _questionsData.length;
      } catch (e) {
        print('Error generating question for chapter $chapter: $e');
      }
    }

    await _saveQuestions();
  }

  String _getBestChapter() {
    return chapterScores.isNotEmpty
        ? chapterScores.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
            .toString()
        : '1';
  }

  String _getWorstChapter() {
    return chapterScores.isNotEmpty
        ? chapterScores.entries
            .reduce((a, b) => a.value < b.value ? a : b)
            .key
            .toString()
        : '1';
  }

  void _initializeChapterScores() {
    chapterScores.clear();
    for (var question in _questionsData) {
      int? chapter = question['chapter'];
      if (chapter != null) {
        chapterScores[chapter] = chapterScores[chapter] ?? 0.0;
      } else {
        print('Warning: Invalid chapter in _questionsData');
      }
    }
  }

  List<Map<String, dynamic>> getUnansweredQuestions() {
    return _questionsData.where((q) => q['read'] != true).toList();
  }

  Future<void> selectAnswerById(
      String questionId, int selectedChoiceIndex) async {
    var questionIndex = _questionsData.indexWhere((q) => q['id'] == questionId);
    if (questionIndex == -1) return;

    await selectAnswer(questionIndex, selectedChoiceIndex);
  }

  Future<void> selectAnswer(int questionIndex, int selectedChoiceIndex) async {
    if (questionIndex >= _questionsData.length) return;

    // Add question to history
    String questionText = _questionsData[questionIndex]['question'];
    await QuestionHistoryManager.addQuestionToHistory(questionText);

    List<dynamic> points = _questionsData[questionIndex]['points'] ?? [0.0];
    int? chapter = _questionsData[questionIndex]['chapter'];

    double earnedPoints =
        (points[selectedChoiceIndex] as num?)?.toDouble() ?? 0.0;

    _totalScore += earnedPoints;

    if (chapter != null) {
      // Update chapter score
      chapterScores[chapter] = (chapterScores[chapter] ?? 0.0) + earnedPoints;
      print(
          'Chapter $chapter, earned points: $earnedPoints, total chapter score: ${chapterScores[chapter]}');
    } else {
      print('Warning: Chapter is null for question at index $questionIndex');
    }

    _questionsData[questionIndex]['read'] = true;
    await _saveQuestions();

    String questionId = _questionsData[questionIndex]['id'];
    _selectedAnswers[questionId] = selectedChoiceIndex;
    await _saveReadStatus();
  }

  int getQuestionChapterById(String questionId) {
    var question =
        _questionsData.firstWhereOrNull((q) => q['id'] == questionId);
    if (question != null) {
      var chapterValue = question['chapter'];
      if (chapterValue is int) {
        return chapterValue;
      } else if (chapterValue is double) {
        return chapterValue.toInt();
      } else if (chapterValue is String) {
        // Try parsing as int directly
        var intValue = int.tryParse(chapterValue);
        if (intValue != null) return intValue;
        // If that fails, try parsing as double and then convert to int
        var doubleValue = double.tryParse(chapterValue);
        if (doubleValue != null) return doubleValue.toInt();
      }
    }
    return -1; // Default if chapter is not found or invalid
  }

  double get totalScore => _totalScore;

  int getUnreadQuestionCount() {
    return _questionsData.where((q) => q['read'] != true).length;
  }

  Future<void> resetQuiz({
    required List<int> selectedChapters,
    required String difficulty,
  }) async {
    _totalScore = 0.0;
    chapterScores.clear();
    _selectedAnswers.clear();
    _questionsData.clear();
    _questionCount = 0;

    // Generate new questions based on selected chapters
    await generateNewQuestions(5, difficulty, selectedChapters);
  }

  bool isQuestionRead(String questionId) {
    var question =
        _questionsData.firstWhereOrNull((q) => q['id'] == questionId);
    if (question != null) {
      return question['read'] ?? false;
    }
    return false;
  }

  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (var question in _questionsData) {
      String id = question['id'];
      bool isRead = prefs.getBool('question_read_$id') ?? false;
      question['read'] = isRead;
    }
  }

  Future<void> _saveReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (var question in _questionsData) {
      String id = question['id'];
      bool isRead = question['read'] ?? false;
      await prefs.setBool('question_read_$id', isRead);
    }
  }

  Future<void> _saveQuestions() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');
    await file.writeAsString(json.encode(_questionsData));
  }
}
