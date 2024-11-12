import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edumentor/screens/scores.dart'; // Scores Class
import 'package:edumentor/services/manager.dart'; // QuestMgr class
import 'package:edumentor/asset-class/colors.dart'; // Color definitions
import 'package:edumentor/asset-class/fonts.dart'; // Font styles
import 'package:edumentor/asset-class/size_config.dart'; // Size configuration
import 'package:quickalert/quickalert.dart'; // Alert dialogs
import 'package:skeletonizer/skeletonizer.dart'; // Loading skeletons

class MCQQuizScreen extends StatefulWidget {
  const MCQQuizScreen({super.key});

  @override
  _MCQQuizScreenState createState() => _MCQQuizScreenState();
}

class _MCQQuizScreenState extends State<MCQQuizScreen> {
  QuestMgr? _questMgr;
  int _currentQuestionIndex = 0;
  bool _isLoadingQuestion = true;
  bool _isHelpVisible = false;
  final PageController _pageController = PageController();
  List<int> _coveredChapters = [];
  List<String> _questions = [];
  List<List<String>> _choicesList = [];
  List<int?> _correctAnswers = [];
  List<int?> _selectedAnswers = [];
  List<bool> _answeredQuestions = [];
  List<String> _helpTexts = [];
  String _difficultyLevel = 'Moderate';
  List<int> _selectedChapters = List.generate(15, (index) => index + 1);
  double _totalScore = 0.0;
  Map<int, double> _chapterScores = {};
  bool _isCountdownVisible = false;
  int _countdown = 10;
  List<String> _questionIds = [];

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    await _initializeQuestMgr();
    await _loadUnansweredQuestions();
  }

  Future<void> _initializeQuestMgr() async {
    _questMgr = await QuestMgr.getInstance(
      selectedChapters: _selectedChapters,
      difficulty: _difficultyLevel,
    );
  }

  Future<void> _loadUnansweredQuestions() async {
    setState(() {
      _isLoadingQuestion = true;
    });
    try {
      List<Map<String, dynamic>> unansweredQuestions =
          _questMgr!.getUnansweredQuestions();

      if (unansweredQuestions.isEmpty) {
        await _generateAdditionalQuestions();
        unansweredQuestions = _questMgr!.getUnansweredQuestions();
      }

      for (var questionData in unansweredQuestions) {
        _questions.add(questionData['question']);
        _choicesList.add(List<String>.from(questionData['choices']));
        _correctAnswers.add(questionData['correct']);
        _helpTexts.add(questionData['help']);
        _answeredQuestions.add(false);
        _selectedAnswers.add(null);
        // Store question IDs for reference
        _questionIds.add(questionData['id']);
      }
    } catch (e) {
      print("Error loading unanswered questions: $e");
    } finally {
      setState(() {
        _isLoadingQuestion = false;
      });
    }
  }

  Future<void> _generateAdditionalQuestions() async {
    try {
      List<int> uncoveredChapters = _selectedChapters
          .where((chapter) => !_coveredChapters.contains(chapter))
          .toList();
      if (uncoveredChapters.isEmpty) {
        setState(() {
          _coveredChapters.clear();
          uncoveredChapters = List.from(_selectedChapters);
        });
      }
      await _questMgr!.generateNewQuestions(
        _selectedChapters.length - 9,
        _difficultyLevel,
        _selectedChapters,
      );
    } catch (e) {
      print("Error generating additional questions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MCQ Quiz',
          style: FontStyles.hometitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_suggest_rounded, color: AppColors.white),
            onPressed: _openChapterAndDifficultySelection,
          ),
          IconButton(
            icon: Icon(Icons.stacked_bar_chart_rounded, color: AppColors.white),
            onPressed: _navigateToScoresScreen,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0 && _currentQuestionIndex > 0) {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _questions.length + 1,
              onPageChanged: (index) {
                if (index == _questions.length) {
                  _loadMoreQuestions();
                } else {
                  setState(() {
                    _currentQuestionIndex = index;
                    _isHelpVisible = false;
                  });
                }
              },
              itemBuilder: (context, index) {
                if (index == _questions.length) return _buildSkeletonLoader();
                return _buildQuizContent(index);
              },
            ),
          ),
          if (_isCountdownVisible) _buildCountdownOverlay(),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'All Questions Completed!',
      text: 'Would you like to attempt more questions?',
      confirmBtnText: 'Do More!',
      onConfirmBtnTap: () async {
        Navigator.of(context).pop();
        _loadMoreQuestions(); // Load new questions immediately
        _startCountdown(); // Start eye protection countdown
      },
      confirmBtnColor: AppColors.green,
    );
  }

  void _startCountdown() {
    setState(() {
      _isCountdownVisible = true;
      _countdown = 15;
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown == 0) {
          _isCountdownVisible = false;
          timer.cancel();
          // No need to call _loadMoreQuestions() here
        } else {
          _countdown--;
        }
      });
    });
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_red_eye_rounded,
              color: Colors.white,
              size: propWidth(90),
            ),
            Text(
              '$_countdown',
              style: FontStyles.hometitle.copyWith(
                fontSize: propWidth(70),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: propHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Look away from the screen to relieve eye stress',
                    style: FontStyles.sub.copyWith(
                      fontSize: propWidth(20),
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScoresScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoresScreen(
          totalScore: _totalScore,
          chapterScores: _chapterScores,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.all(propWidth(16)),
        child: Column(
          children: [
            SizedBox(height: propHeight(20)),
            Text('Loading Question...', style: FontStyles.hometitle),
            SizedBox(height: propHeight(10)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300],
              ),
              height: propHeight(200),
              width: double.infinity,
            ),
            SizedBox(height: propHeight(24)),
            for (var i = 0; i < 4; i++)
              Container(
                height: propHeight(50),
                margin: EdgeInsets.symmetric(vertical: propHeight(8)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: propWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: propHeight(20)),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: propHeight(60),
                      width: propWidth(120),
                      padding: EdgeInsets.all(propWidth(12)),
                      decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(propWidth(15)),
                      ),
                      child: Center(
                        child: Text(
                          'Chapter ${_questMgr!.getQuestionChapterById(_questionIds[index])}',
                          style: FontStyles.sub,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: propHeight(60),
                  width: propWidth(250),
                  padding: EdgeInsets.all(propWidth(12)),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(propWidth(15)),
                  ),
                  child: Center(
                    child: Text(
                      'Question ${index + 1}',
                      style:
                          FontStyles.hometitle.copyWith(color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: propHeight(10)),
          Container(
            padding: EdgeInsets.all(propWidth(20)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(propWidth(15)),
            ),
            child: Text(
              _questions[index],
              style: FontStyles.sub,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: propHeight(24)),
          Expanded(
            child: ListView.builder(
              itemCount: _choicesList[index].length,
              itemBuilder: (context, choiceIndex) {
                return GestureDetector(
                  onTap: () => _onAnswerSelected(index, choiceIndex),
                  child: Container(
                    width: propWidth(250),
                    margin: EdgeInsets.symmetric(vertical: propHeight(8)),
                    padding: EdgeInsets.symmetric(
                      vertical: propHeight(12),
                      horizontal: propWidth(16),
                    ),
                    decoration: BoxDecoration(
                      color: _getChoiceColor(index, choiceIndex),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _choicesList[index][choiceIndex],
                            style: FontStyles.sub,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: propHeight(20)),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isHelpVisible = !_isHelpVisible;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.black),
            child: Text(
              _isHelpVisible ? 'Hide Help' : 'Show Help',
              style: FontStyles.button,
            ),
          ),
          if (_isHelpVisible)
            Padding(
              padding: EdgeInsets.all(propHeight(16)),
              child: Container(
                padding: EdgeInsets.all(propHeight(16)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.gray,
                ),
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded, color: AppColors.black),
                    SizedBox(width: propWidth(10)),
                    Expanded(
                      child: Text(
                        _helpTexts[index],
                        style: FontStyles.sub,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: propHeight(25)),
          SizedBox(
            width: propWidth(300),
            child: ElevatedButton(
              onPressed: () {
                if (_currentQuestionIndex >= _questions.length - 1) {
                  _showCompletionDialog();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: propHeight(12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(propWidth(15)),
                ),
              ),
              child: Text('Next Question', style: FontStyles.button),
            ),
          ),
          SizedBox(height: propHeight(20)),
          Text(
            'Total Score: ${_totalScore.toStringAsFixed(2)}',
            style: FontStyles.hometitle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: propHeight(10)),
        ],
      ),
    );
  }

  Color _getChoiceColor(int questionIndex, int choiceIndex) {
    if (_answeredQuestions[questionIndex] &&
        choiceIndex == _correctAnswers[questionIndex]) {
      return AppColors.green;
    } else if (_answeredQuestions[questionIndex] &&
        choiceIndex == _selectedAnswers[questionIndex]) {
      return Colors.red.shade100;
    }
    return Colors.grey.shade200;
  }

  void _onAnswerSelected(int questionIndex, int answerIndex) async {
    if (_answeredQuestions[questionIndex]) return;
    setState(() {
      _selectedAnswers[questionIndex] = answerIndex;
      _answeredQuestions[questionIndex] = true;
      String questionId = _questionIds[questionIndex];
      _questMgr?.selectAnswerById(questionId, answerIndex);
      _totalScore = _questMgr?.totalScore ?? 0.0;
      _chapterScores = Map<int, double>.from(_questMgr?.chapterScores ?? {});
    });
    int chapter =
        _questMgr!.getQuestionChapterById(_questionIds[questionIndex]);
    if (chapter != -1 && !_coveredChapters.contains(chapter)) {
      setState(() {
        _coveredChapters.add(chapter);
      });
    }
    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  Future<void> _loadMoreQuestions() async {
    setState(() {
      _isLoadingQuestion = true;
      // Reset quiz state
      _currentQuestionIndex = 0;
      _questions.clear();
      _choicesList.clear();
      _correctAnswers.clear();
      _selectedAnswers.clear();
      _answeredQuestions.clear();
      _helpTexts.clear();
      _coveredChapters.clear();
      _pageController.jumpToPage(0);
    });
    await _generateAdditionalQuestions();
    await _loadUnansweredQuestions();
    setState(() {
      _isLoadingQuestion = false;
    });
  }

  void _openChapterAndDifficultySelection() {
    List<int> tempSelectedChapters = List.from(_selectedChapters);
    String tempDifficultyLevel = _difficultyLevel;
    final List<String> difficultyLevels = [
      'Very Easy',
      'Easy',
      'Moderate',
      'Hard',
      'Very Hard'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Configure Quiz',
                style: FontStyles.hometitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Chapters',
                      style:
                          FontStyles.sub.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: propHeight(15)),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: propWidth(8),
                        runSpacing: propHeight(8),
                        children: List.generate(15, (index) {
                          return SizedBox(
                            width: propWidth(110),
                            height: propHeight(40),
                            child: ChoiceChip(
                              label: Text('Ch# ${index + 1}'),
                              selected:
                                  tempSelectedChapters.contains(index + 1),
                              selectedColor: AppColors.green,
                              labelStyle: TextStyle(
                                color: tempSelectedChapters.contains(index + 1)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    tempSelectedChapters.add(index + 1);
                                  } else {
                                    tempSelectedChapters.remove(index + 1);
                                  }
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Select Difficulty Level',
                      style: FontStyles.sub.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: difficultyLevels.map((level) {
                        return ChoiceChip(
                          label: Text(level),
                          selected: tempDifficultyLevel == level,
                          selectedColor: AppColors.green,
                          labelStyle: TextStyle(
                            color: tempDifficultyLevel == level
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                tempDifficultyLevel = level;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (tempSelectedChapters.isEmpty) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        text: 'Please select at least one chapter.',
                        confirmBtnColor: AppColors.green,
                      );
                      return;
                    }
                    setState(() {
                      _selectedChapters = tempSelectedChapters;
                      _difficultyLevel = tempDifficultyLevel;
                      _currentQuestionIndex = 0;
                      _pageController.jumpToPage(0);
                      _questions.clear();
                      _choicesList.clear();
                      _correctAnswers.clear();
                      _selectedAnswers.clear();
                      _answeredQuestions.clear();
                      _helpTexts.clear();
                      _totalScore = 0.0;
                      _chapterScores.clear();
                    });
                    await _questMgr!.generateNewQuestions(
                      5,
                      _difficultyLevel,
                      _selectedChapters,
                    );
                    await _loadUnansweredQuestions();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
