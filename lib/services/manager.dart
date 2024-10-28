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

  // Stream for listening to newly generated questions
  Stream<Map<String, dynamic>> get questionStream =>
      _questionStreamController.stream;

  // Singleton pattern for single instance creation
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

  // Initialize by loading questions or generating new ones
  Future<void> initialize({
    required List<int> selectedChapters,
    int difficulty = 1,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');

    if (selectedChapters.isEmpty) {
      print('Error: No chapters selected for question generation.');
      throw Exception('Please select chapters for question generation.');
    }

    print("Selected Chapters: $selectedChapters");

    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      _questionsData = List<Map<String, dynamic>>.from(json.decode(jsonString));
      _questionCount = _questionsData.length;
      print('Loaded $_questionCount questions from saved data.');
      _questionsData.forEach(_questionStreamController.add);
    } else {
      print(
          'No saved questions found. Generating new questions for selected chapters: $selectedChapters.');
      await generateNewQuestions(5, difficulty, selectedChapters);
    }

    _initializeChapterScores();
  }

  // Generates new questions based on the selected chapters and difficulty
  Future<void> generateNewQuestions(
    int numQuestions,
    int difficulty,
    List<int> selectedChapters,
  ) async {
    GPTQuestionGenerator generator = GPTQuestionGenerator();
    print('Using the following chapters for generation: $selectedChapters');

    for (int i = 0; i < numQuestions; i++) {
      final int chapterNo = selectedChapters[i % selectedChapters.length];
      print('Generating question for chapter number: $chapterNo');

      try {
        final questionData = await generator.generateQuestion(
          difficulty + i,
          _totalScore.toInt(),
          _selectedAnswers.length,
          _getBestChapter(),
          _getWorstChapter(),
          chapterNo,
        );

        // Ensure chapter and correct answer are consistently String or int as needed
        questionData['chapter'] =
            questionData['chapter'].toString(); // Ensure chapter is String
        questionData['correct'] = int.tryParse(questionData['correct']
            .toString()); // Parse correct as int if needed

        if (!_questionsData
            .any((q) => q['question'] == questionData['question'])) {
          _questionsData.add(questionData);
          _questionCount = _questionsData.length;

          // Emit each question as it’s generated
          _questionStreamController.add(questionData);
        }
      } catch (e) {
        print('Error generating question for chapter $chapterNo: $e');
      }
    }
    await _saveQuestions();
  }

  // Get the best performing chapter based on scores
  String _getBestChapter() {
    return chapterScores.isNotEmpty
        ? chapterScores.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : '1';
  }

  // Get the worst performing chapter based on scores
  String _getWorstChapter() {
    return chapterScores.isNotEmpty
        ? chapterScores.entries.reduce((a, b) => a.value < b.value ? a : b).key
        : '1';
  }

  // Initialize chapter scores to track user performance
  void _initializeChapterScores() {
    chapterScores.clear();
    for (var question in _questionsData) {
      String chapter =
          question['chapter'].toString(); // Ensure chapter is String
      chapterScores[chapter] = chapterScores[chapter] ?? 0.0;
    }
  }

  // Fetch a question by its index
  Future<String> getQuestion(int index) async {
    if (index >= _questionCount) return 'No more questions available.';
    return _questionsData[index]['question'] ?? 'Unknown Question';
  }

  // Fetch the choices for a question (no shuffling)
  Future<List<String>> getChoices(int index) async {
    if (index >= _questionCount) return [];
    return List<String>.from(_questionsData[index]['choices']);
  }

  // Fetch the correct answer index by checking which choice has a score of 1
  Future<int> getCorrectAnswerIndex(int questionIndex) async {
    if (questionIndex >= _questionCount) return 0;
    List<dynamic> points = _questionsData[questionIndex]['points'] ?? [0.0];
    return points.indexWhere((p) => (p as num).toDouble() == 1.0);
  }

  // Select an answer and update the score
  Future<void> selectAnswer(int questionIndex, int selectedChoiceIndex) async {
    if (questionIndex >= _questionCount) return;
    List<dynamic> points = _questionsData[questionIndex]['points'] ?? [0.0];
    String chapter = _questionsData[questionIndex]['chapter'] ?? 'Unknown';

    double earnedPoints =
        (points[selectedChoiceIndex] as num?)?.toDouble() ?? 0.0;
    _totalScore += earnedPoints;
    chapterScores[chapter] = (chapterScores[chapter] ?? 0.0) + earnedPoints;

    _selectedAnswers[questionIndex] = selectedChoiceIndex;
  }

  // Fetch help text for a question
  Future<String> getQuestionHelp(int index) async {
    if (index >= _questionCount) return '';
    return _questionsData[index]['help'] ?? '';
  }

  // Save the questions to local storage
  Future<void> _saveQuestions() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');
    await file.writeAsString(json.encode(_questionsData));
  }

  // Fetch total score
  double get totalScore => _totalScore;

  // Fetch question count
  int get questionCount => _questionCount;

  // Dispose resources
  void dispose() {
    _questionStreamController.close();
  }
}
