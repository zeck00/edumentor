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
  double _difficultyLevel = 1.0;
  List<int> _selectedChapters = List.generate(15, (index) => index + 1);
  double _totalScore = 0.0;
  Map<String, double> _chapterScores = {};

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    await _initializeQuestMgr();
    await _loadUnansweredQuestions();
  }

  Future<void> _loadUnansweredQuestions() async {
    setState(() {
      _isLoadingQuestion = true;
    });

    try {
      int totalQuestions = _questMgr!.totalQuestions; // Use the getter
      for (int i = 0; i < totalQuestions; i++) {
        bool isRead = _questMgr!.isQuestionRead(i); // Use the public method
        if (!isRead) {
          final question = await _questMgr!.getQuestion(i);
          final choices = await _questMgr!.getChoices(i);
          final correctAnswer = await _questMgr!.getCorrectAnswerIndex(i);
          final helpText = await _questMgr!.getQuestionHelp(i);

          setState(() {
            _questions.add(question);
            _choicesList.add(choices);
            _correctAnswers.add(correctAnswer);
            _helpTexts.add(helpText);
            _answeredQuestions.add(false);
            _selectedAnswers.add(null);
          });
        }
      }

      // If no unanswered questions, generate new ones
      if (_questions.isEmpty) {
        await _generateAdditionalQuestions();
        await _loadUnansweredQuestions(); // Reload after generating
      }
    } catch (e) {
      print("Error loading unanswered questions: $e");
    } finally {
      setState(() {
        _isLoadingQuestion = false;
      });
    }
  }

  Future<void> _initializeQuestMgr() async {
    _questMgr = await QuestMgr.getInstance(
      selectedChapters: _selectedChapters,
      difficulty: _difficultyLevel.toInt(),
    );
  }

  Future<void> _loadQuestionsFromIndex(int startIndex) async {
    int totalQuestions = _questMgr!.questionCount;
    for (int i = startIndex; i < totalQuestions; i++) {
      try {
        final question = await _questMgr!.getQuestion(i);
        final choices = await _questMgr!.getChoices(i);
        final correctAnswer = await _questMgr!.getCorrectAnswerIndex(i);
        final helpText = await _questMgr!.getQuestionHelp(i);

        setState(() {
          _questions.add(question);
          _choicesList.add(choices);
          _correctAnswers.add(correctAnswer);
          _helpTexts.add(helpText);
          _answeredQuestions.add(false);
          _selectedAnswers.add(null);
        });
      } catch (e) {
        print("Error adding question to UI: $e");
      }
    }
  }

  // Future<void> _generateFirstQuestion() async {
  //   setState(() {
  //     _isLoadingQuestion = true;
  //   });

  //   try {
  //     final question = await _questMgr!.getQuestion(_currentQuestionIndex);
  //     final choices = await _questMgr!.getChoices(_currentQuestionIndex);
  //     final correctAnswer =
  //         await _questMgr!.getCorrectAnswerIndex(_currentQuestionIndex);
  //     final helpText = await _questMgr!.getQuestionHelp(_currentQuestionIndex);

  //     setState(() {
  //       _questions.add(question);
  //       _choicesList.add(choices);
  //       _correctAnswers.add(correctAnswer);
  //       _helpTexts.add(helpText);
  //       _answeredQuestions.add(false);
  //       _selectedAnswers.add(null);
  //     });
  //   } catch (e) {
  //     print("Error generating first question: $e");
  //   } finally {
  //     setState(() {
  //       _isLoadingQuestion = false;
  //     });

  //     // Start generating additional questions in the background
  //     _generateAdditionalQuestions();
  //   }
  // }

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
          // Stats Button to Navigate to Scores Screen
          IconButton(
            icon: Icon(
              Icons.settings_suggest_rounded,
              color: AppColors.white,
            ),
            onPressed: _openChapterAndDifficultySelection,
          ),
          IconButton(
            icon: Icon(
              Icons.stacked_bar_chart_rounded,
              color: AppColors.white,
            ),
            onPressed: _navigateToScoresScreen,
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            // Swiping right (backward), move to previous page
            if (_currentQuestionIndex > 0) {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
          // Swiping left (forward), do nothing
        },
        child: PageView.builder(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // Disable default scrolling
          itemCount:
              _questions.length + 1, // Add extra page for skeleton loader
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
            if (index == _questions.length) {
              return _buildSkeletonLoader();
            }
            return _buildQuizContent(index);
          },
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: propHeight(20)),
          Center(
            child: Text(
              'Question ${index + 1}',
              style: FontStyles.hometitle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: propHeight(10)),
          Container(
            padding: EdgeInsets.all(propWidth(20)),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: propHeight(5),
                  offset: Offset(0, 2),
                ),
              ],
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
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
                      boxShadow: [],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
            ),
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
          ElevatedButton(
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
              padding: EdgeInsets.symmetric(vertical: propHeight(12)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Next Question', style: FontStyles.button),
          ),
          SizedBox(height: propHeight(20)),
          // Display Total Score
          Text(
            'Total Score: ${_totalScore.toStringAsFixed(2)}',
            style: FontStyles.hometitle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: propHeight(10)),
          // Display Chapter Scores as Progress Bars
          // _buildChapterScores(),
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

  // Ensure to update _onAnswerSelected to keep scores updated
  void _onAnswerSelected(int questionIndex, int answerIndex) async {
    if (_answeredQuestions[questionIndex]) return;

    setState(() {
      _selectedAnswers[questionIndex] = answerIndex;
      _answeredQuestions[questionIndex] = true;
      _questMgr?.selectAnswer(questionIndex, answerIndex);

      // Update total score and chapter scores
      _totalScore = _questMgr?.totalScore ?? 0.0;
      _chapterScores = Map<String, double>.from(_questMgr?.chapterScores ?? {});
    });

    // Get the chapter of the answered question using the public method
    int chapter = _questMgr!.getQuestionChapter(questionIndex);
    if (chapter != -1 && !_coveredChapters.contains(chapter)) {
      setState(() {
        _coveredChapters.add(chapter);
      });
    }

    // Optionally, navigate to the next question automatically
    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  Future<void> _generateAdditionalQuestions() async {
    try {
      // Determine the list of uncovered chapters
      List<int> uncoveredChapters = _selectedChapters
          .where((chapter) => !_coveredChapters.contains(chapter))
          .toList();

      // If all chapters have been covered, reset the covered chapters to start over
      if (uncoveredChapters.isEmpty) {
        setState(() {
          _coveredChapters.clear();
          uncoveredChapters = List.from(_selectedChapters);
        });
      }

      await _questMgr!.generateNewQuestions(
        uncoveredChapters.length,
        _difficultyLevel.toInt(),
        uncoveredChapters,
      );
    } catch (e) {
      print("Error generating additional questions: $e");
    }
  }

  Future<void> _loadMoreQuestions() async {
    setState(() {
      _isLoadingQuestion = true;
    });

    // Generate new questions for uncovered chapters
    await _generateAdditionalQuestions();

    // Load the new questions into the UI lists
    await _loadUnansweredQuestions();

    setState(() {
      _isLoadingQuestion = false;
    });
  }

  void _showCompletionDialog() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'All Questions Completed!',
      text: 'Would you like to attempt more questions?',
      confirmBtnText: 'Do More!',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        _loadMoreQuestions();
      },
      confirmBtnColor: AppColors.green,
    );
  }

  void _openChapterAndDifficultySelection() {
    // Temporary variables to hold selections
    List<int> tempSelectedChapters = List.from(_selectedChapters);
    double tempDifficultyLevel = _difficultyLevel;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Chapters & Difficulty'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(15, (index) {
                        return ChoiceChip(
                          label: Text('Chapter ${index + 1}'),
                          selected: tempSelectedChapters.contains(index + 1),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                tempSelectedChapters.add(index + 1);
                              } else {
                                tempSelectedChapters.remove(index + 1);
                              }
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    Text('Difficulty Level: ${tempDifficultyLevel.toInt()}'),
                    Slider(
                      value: tempDifficultyLevel,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: tempDifficultyLevel.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          tempDifficultyLevel = value;
                        });
                      },
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

                    // Update local selections
                    setState(() {
                      _selectedChapters = tempSelectedChapters;
                      _difficultyLevel = tempDifficultyLevel;
                      _currentQuestionIndex = 0; // Reset to first question
                      _pageController
                          .jumpToPage(0); // Navigate to first question
                      _questions.clear();
                      _choicesList.clear();
                      _correctAnswers.clear();
                      _selectedAnswers.clear();
                      _answeredQuestions.clear();
                      _helpTexts.clear();
                      _totalScore = 0.0;
                      _chapterScores.clear();
                    });

                    // Generate new questions based on selected chapters and difficulty
                    await _questMgr!.generateNewQuestions(
                      5, // Number of new questions to generate
                      _difficultyLevel.toInt(),
                      _selectedChapters,
                    );

                    // Load the newly generated unanswered questions
                    await _loadUnansweredQuestions();

                    Navigator.of(context).pop();
                  },
                  child: Text('Save', style: TextStyle(color: AppColors.green)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class OnlyAllowBackwardScrollPhysics extends ScrollPhysics {
  const OnlyAllowBackwardScrollPhysics({super.parent});

  @override
  OnlyAllowBackwardScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OnlyAllowBackwardScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // If trying to scroll forward (value > position.pixels), prevent it.
    if (value > position.pixels) {
      return value - position.pixels; // Disallow forward scroll
    }
    // Allow backward scroll
    return 0.0;
  }
}
