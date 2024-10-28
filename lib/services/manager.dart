import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'generator.dart';

class QuestMgr {
  static QuestMgr? _instance;
  static bool _isCreating = false;

  double _totalScore = 0.0;
  int _questionCount = 0;
  List<Map<String, dynamic>> _questionsData = [];
  Map<int, int> _selectedAnswers = {};
  Map<String, double> chapterScores = {};

  final StreamController<Map<String, dynamic>> _questionStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get questionStream =>
      _questionStreamController.stream;

  static Future<QuestMgr> getInstance(
      {required List<int> selectedChapters}) async {
    if (_instance != null) return _instance!;
    if (_isCreating) {
      while (_instance == null) {
        await Future.delayed(Duration(milliseconds: 5));
      }
      return _instance!;
    }
    _isCreating = true;
    _instance = QuestMgr();
    await _instance!.initialize(selectedChapters: selectedChapters);
    _isCreating = false;
    return _instance!;
  }

  Future<void> initialize(
      {required List<int> selectedChapters, int difficulty = 1}) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');

    if (selectedChapters.isEmpty) {
      throw Exception('Please select chapters for question generation.');
    }

    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      _questionsData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      _questionCount = _questionsData.length;
      _questionsData.forEach(_questionStreamController.add);
    } else {
      await generateNewQuestions(5, difficulty, selectedChapters);
    }

    _initializeChapterScores();
  }

  Future<void> generateNewQuestions(
      int numQuestions, int difficulty, List<int> selectedChapters) async {
    GPTQuestionGenerator generator = GPTQuestionGenerator();

    for (int i = 0; i < numQuestions; i++) {
      final int chapterNo = selectedChapters[i % selectedChapters.length];

      try {
        final questionData = await generator.generateQuestion(
          difficulty + i,
          _totalScore.toInt(),
          _selectedAnswers.length,
          _getBestChapter(),
          _getWorstChapter(),
          chapterNo,
        );

        // Ensure chapter and correct are consistent
        questionData['chapter'] =
            questionData['chapter'].toString(); // Chapter as String
        questionData['correct'] =
            int.tryParse(questionData['correct'].toString()) ??
                0; // Correct as int, default to 0

        if (!_questionsData
            .any((q) => q['question'] == questionData['question'])) {
          _questionsData.add(questionData);
          _questionCount = _questionsData.length;
          _questionStreamController.add(questionData);
        }
      } catch (e) {
        print('Error generating question for chapter $chapterNo: $e');
      }
    }

    await _saveQuestions();
  }

  String _getBestChapter() {
    return chapterScores.isNotEmpty
        ? chapterScores.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : '1';
  }

  String _getWorstChapter() {
    return chapterScores.isNotEmpty
        ? chapterScores.entries.reduce((a, b) => a.value < b.value ? a : b).key
        : '1';
  }

  void _initializeChapterScores() {
    chapterScores.clear();
    for (var question in _questionsData) {
      String chapter =
          question['chapter'].toString(); // Ensure chapter is String
      chapterScores[chapter] = chapterScores[chapter] ?? 0.0;
    }
  }

  Future<String> getQuestion(int index) async {
    if (index >= _questionCount) return 'No more questions available.';
    return _questionsData[index]['question'] ?? 'Unknown Question';
  }

  Future<List<String>> getChoices(int index) async {
    if (index >= _questionCount) return [];
    return List<String>.from(_questionsData[index]['choices']);
  }

  Future<int> getCorrectAnswerIndex(int questionIndex) async {
    if (questionIndex >= _questionCount) return 0;
    List<dynamic> points = _questionsData[questionIndex]['points'] ?? [0.0];
    return points.indexWhere((p) => (p as num).toDouble() == 1.0);
  }

// Select an answer and update the score
  Future<void> selectAnswer(int questionIndex, int selectedChoiceIndex) async {
    if (questionIndex >= _questionCount) return;

    // Fetch the points and chapter values, ensuring proper types
    List<dynamic> points = _questionsData[questionIndex]['points'] ?? [0.0];
    String chapter =
        _questionsData[questionIndex]['chapter']?.toString() ?? 'Unknown';

    // Ensure points[selectedChoiceIndex] is treated as a double for _totalScore
    double earnedPoints =
        (points[selectedChoiceIndex] as num?)?.toDouble() ?? 0.0;

    // Update the total score and chapter score, enforcing String for chapter keys
    _totalScore += earnedPoints;
    chapterScores[chapter] = (chapterScores[chapter] ?? 0.0) + earnedPoints;

    // Store the selected answer
    _selectedAnswers[questionIndex] = selectedChoiceIndex;
  }

  Future<String> getQuestionHelp(int index) async {
    if (index >= _questionCount) return '';
    return _questionsData[index]['help'] ?? '';
  }

  Future<void> _saveQuestions() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');
    await file.writeAsString(json.encode(_questionsData));
  }

  double get totalScore => _totalScore;
  int get questionCount => _questionCount;

  void dispose() {
    _questionStreamController.close();
  }
}
