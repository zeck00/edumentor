import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'generator.dart'; // Custom generator for dynamic questions

class QuestMgr {
  static QuestMgr? _instance;
  static bool _isCreating = false;

  double _totalScore = 0;
  int _questionCount = 0;
  late List<Map<String, dynamic>> _questionsData = [];
  late List<int> _questionOrder;
  Map<int, int> _selectedAnswers = {};
  Map<String, double> _chapterScores = {};

  // Simplified mapping for correct answers
  Map<int, int> _correctAnswerMap = {};

  // Singleton pattern for single instance creation
  static Future<QuestMgr> getInstance() async {
    if (_instance != null) return _instance!;

    if (_isCreating) {
      while (_instance == null) {
        await Future.delayed(Duration(milliseconds: 5));
      }
      return _instance!;
    }

    _isCreating = true;
    var instance = QuestMgr();
    await instance._initialize();
    _instance = instance;
    _isCreating = false;
    return _instance!;
  }

  // Initialization method to load existing questions or generate new ones
  Future<void> _initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');

    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      _questionsData = List<Map<String, dynamic>>.from(json.decode(jsonString));
    } else {
      await _generateNewQuestions(2, 1);
    }

    _questionCount = _questionsData.length;
    _shuffleQuestions();
    _initializeChapterScores();

    _generateNewQuestionsInBackground(3, 3);
  }

  // Generate additional questions in the background
  Future<void> _generateNewQuestionsInBackground(
      int numQuestions, int difficulty) async {
    await _generateNewQuestions(numQuestions, difficulty);
    print("Generated additional questions in the background.");
  }

  // Generates new questions
  Future<void> _generateNewQuestions(int numQuestions, int difficulty) async {
    GPTQuestionGenerator generator = GPTQuestionGenerator();
    List<Map<String, dynamic>> generatedQuestions = [];

    for (int i = 0; i < numQuestions; i++) {
      final questionData = await generator.generateQuestion(
          difficulty + i, _totalScore.toInt(), _selectedAnswers.length);
      generatedQuestions.add(questionData);
    }

    _questionsData.addAll(generatedQuestions);
    _questionCount = _questionsData.length;
    _shuffleQuestions();

    // Save the updated questions to file
    await _saveQuestions();
  }

  // Initialize chapter scores
  void _initializeChapterScores() {
    for (var question in _questionsData) {
      String chapter = question['chapter'] ?? 'Unknown Chapter';
      if (!_chapterScores.containsKey(chapter)) {
        _chapterScores[chapter] = 0.0;
      }
    }
  }

  // Fetch the total score
  double get totalScore => _totalScore;

  // Fetch the number of questions
  int get questionCount => _questionCount;

  // Fetch a question by its index
  Future<String> getQuestion(int index) async {
    return _questionsData[_questionOrder[index]]['question'] ??
        'Unknown Question';
  }

  // Fetch the choices for a given question (in shuffled order)
  Future<List<String>> getChoices(int index) async {
    int mappedIndex = _questionOrder[index];
    return List<String>.from(_questionsData[mappedIndex]['choices']);
  }

  // Select an answer for a question and update scores
  Future<void> selectAnswer(int questionIndex, int choiceIndex) async {
    int mappedIndex = _questionOrder[questionIndex];
    List<dynamic> points = _questionsData[mappedIndex]['points'] ?? [0.0];
    String chapter =
        _questionsData[mappedIndex]['chapter'] ?? 'Unknown Chapter';

    // Adjust score for previously selected answer
    if (_selectedAnswers.containsKey(questionIndex)) {
      int prevChoice = _selectedAnswers[questionIndex]!;
      _totalScore -= (points[prevChoice] as num).toDouble();
      _chapterScores[chapter] = (_chapterScores[chapter] ?? 0) -
          (points[prevChoice] as num).toDouble();
    }

    // Add points for the newly selected answer
    _selectedAnswers[questionIndex] = choiceIndex;
    _totalScore += (points[choiceIndex] as num).toDouble();
    _chapterScores[chapter] = (_chapterScores[chapter] ?? 0) +
        (points[choiceIndex] as num).toDouble();
  }

  // Fetch help text for a question
  Future<String> getQuestionHelp(int index) async {
    return _questionsData[_questionOrder[index]]['help'] ?? '';
  }

  // Add new questions (append) and shuffle them into the existing set
  Future<void> appendQuestions(int numQuestions, int startDifficulty,
      int currentScore, int totalAnswered) async {
    final GPTQuestionGenerator generator = GPTQuestionGenerator();
    final List<Map<String, dynamic>> newQuestions =
        await generator.generateNewQuestions(
            numQuestions, startDifficulty, currentScore, totalAnswered);

    _questionsData.addAll(newQuestions);
    _questionCount = _questionsData.length;
    _shuffleQuestions();

    // Save the updated questions to file
    await _saveQuestions();
  }

  // Save questions data to local storage
  Future<void> _saveQuestions() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/questions.json');
    await file.writeAsString(json.encode(_questionsData));
  }

  // Reset scores if needed
  void resetScores() {
    _totalScore = 0;
    _chapterScores = _chapterScores.map((key, value) => MapEntry(key, 0.0));
  }

  // Reset all state (e.g., when restarting a quiz)
  void resetAllState() {
    _selectedAnswers.clear();
    resetScores();
  }

  // Shuffle questions and their answers, while preserving correct answer mapping
  void _shuffleQuestions() {
    _questionOrder = List.generate(_questionCount, (index) => index)..shuffle();

    // Store correct answers in the mapping
    for (int i = 0; i < _questionsData.length; i++) {
      _correctAnswerMap[i] = _questionsData[i]['correct'];
    }
  }

  // Fetch the correct answer index from the shuffled data
  Future<int> getCorrectAnswerIndex(int index) async {
    int mappedIndex = _questionOrder[index];
    return _correctAnswerMap[mappedIndex] ?? 0;
  }
}
