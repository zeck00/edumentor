import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edumentor/services/manager.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:wave_loading_indicator/wave_progress.dart';
import 'package:quickalert/quickalert.dart';

class MCQQuizScreen extends StatefulWidget {
  final List<int> selectedChapters;
  final int difficultyLevel;

  const MCQQuizScreen({
    required this.selectedChapters,
    required this.difficultyLevel,
    super.key,
  });

  @override
  _MCQQuizScreenState createState() => _MCQQuizScreenState();
}

class _MCQQuizScreenState extends State<MCQQuizScreen> {
  QuestMgr? _questMgr;
  int _currentQuestionIndex = 0;
  double _totalScore = 0;
  bool _isAnswerSelected = false;
  int? _selectedAnswer;
  bool _isLoading = true;
  int? _correctAnswerIndex;
  List<String> _choices = [];
  double _loadingProgress = 0.0;
  bool _isScoresLoaded = false;
  StreamSubscription<Map<String, dynamic>>? _questionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeQuestMgr();
    _simulateProgress();
  }

  @override
  void dispose() {
    _questionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuestMgr() async {
    try {
      final questMgr = await QuestMgr.getInstance(
        selectedChapters: widget.selectedChapters,
      );
      await questMgr.initialize(
        selectedChapters: widget.selectedChapters,
        difficulty: widget.difficultyLevel,
      );

      setState(() {
        _questMgr = questMgr;
        _totalScore = questMgr.totalScore;
        _isLoading = false;
      });

      // Subscribe to the question stream to update the UI as new questions are generated
      _questionSubscription = questMgr.questionStream.listen((question) {
        setState(() {
          _isLoading = false;
          _loadingProgress = 100.0;
        });

        if (_currentQuestionIndex == 0) {
          _loadQuestion();
        }
      });

      await _loadQuestion();
      setState(() {
        _isScoresLoaded = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isScoresLoaded = true;
      });
      print("Error during QuestMgr initialization: $e");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Initialization Error',
        text: 'Could not initialize quiz. Please try again later.',
        confirmBtnColor: AppColors.green,
      );
    }
  }

  Future<void> _loadQuestion() async {
    if (_questMgr == null) return;

    setState(() {
      _choices = [];
      _isLoading = true;
    });

    try {
      _choices = await _questMgr!.getChoices(_currentQuestionIndex);
      _correctAnswerIndex =
          await _questMgr!.getCorrectAnswerIndex(_currentQuestionIndex);
    } catch (e) {
      print("Error loading question: $e");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Load Error',
        text: 'Failed to load the question. Please try again.',
        confirmBtnColor: AppColors.green,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _simulateProgress() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_loadingProgress < 90 && _isLoading) {
        setState(() {
          _loadingProgress += 5;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onAnswerSelected(int index) async {
    if (_isAnswerSelected || _isLoading) return;

    setState(() {
      _selectedAnswer = index;
      _isAnswerSelected = true;
    });

    await _questMgr!.selectAnswer(_currentQuestionIndex, index);

    setState(() {
      _totalScore = _questMgr!.totalScore;
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < (_questMgr?.questionCount ?? 0) - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSelected = false;
        _selectedAnswer = null;
        _isLoading = true;
        _simulateProgress();
      });
      await _loadQuestion();
    } else {
      _showQuizCompletedDialog();
    }
  }

  Future<void> generateNewQuestions() async {
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
    });

    await _questMgr?.generateNewQuestions(
      5,
      widget.difficultyLevel,
      widget.selectedChapters,
    );

    setState(() {
      _isLoading = false;
      _loadingProgress = 100.0;
    });

    await _loadQuestion();
  }

  void _showQuizCompletedDialog() {
    QuickAlert.show(
      context: context,
      animType: QuickAlertAnimType.slideInUp,
      customAsset: 'assets/success.gif',
      type: QuickAlertType.confirm,
      title: 'Quiz Completed!',
      text: 'Would you like to generate new questions or exit?',
      confirmBtnText: 'Do More!',
      cancelBtnText: 'Exit',
      confirmBtnColor: AppColors.green,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        generateNewQuestions();
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ Quiz',
            style: FontStyles.hometitle.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.green,
      ),
      body: _isLoading && !_isScoresLoaded
          ? Center(
              child: WaveProgress(
              borderColor: AppColors.black,
              size: propHeight(200),
              foregroundWaveColor: AppColors.green,
              backgroundWaveColor: AppColors.gray,
              progress: _loadingProgress,
              innerPadding: propHeight(2),
            ))
          : _questMgr == null
              ? Center(child: Text('Failed to load questions.'))
              : _buildQuizContent(),
    );
  }

  Widget _buildQuizContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: propWidth(16)),
      child: Column(
        children: [
          SizedBox(height: propHeight(20)),
          Text(
            'Question ${_currentQuestionIndex + 1}:',
            style: FontStyles.hometitle,
          ),
          SizedBox(height: propHeight(10)),
          FutureBuilder<String>(
            future: _questMgr!.getQuestion(_currentQuestionIndex),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading question');
              } else if (snapshot.hasData) {
                return Text(
                  snapshot.data ?? 'No question available',
                  style: FontStyles.sub,
                  textAlign: TextAlign.center,
                );
              } else {
                return Text('No question available');
              }
            },
          ),
          SizedBox(height: propHeight(24)),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _choices.length,
            itemBuilder: (context, index) {
              bool isCorrect =
                  _isAnswerSelected && index == _correctAnswerIndex;
              bool isSelected = index == _selectedAnswer;

              Color containerColor = isCorrect
                  ? AppColors.green
                  : isSelected
                      ? Colors.red.shade100
                      : Colors.grey.shade200;

              return GestureDetector(
                onTap:
                    _isAnswerSelected ? null : () => _onAnswerSelected(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(12),
                  child: Text(
                    _choices[index],
                    style: FontStyles.sub,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: propHeight(24)),
          _isAnswerSelected
              ? ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                  child: Text('Next Question', style: FontStyles.button),
                )
              : Container(),
          SizedBox(height: propHeight(24)),
          _isScoresLoaded ? _buildChapterScores() : Container(),
          SizedBox(height: propHeight(24)),
          Text('Total Score: $_totalScore', style: FontStyles.hometitleg),
        ],
      ),
    );
  }

  Widget _buildChapterScores() {
    if (_questMgr == null || _questMgr!.chapterScores.isEmpty) {
      return Center(
          child: Text('No chapter scores available.', style: FontStyles.sub));
    }

    var filteredScores = _questMgr!.chapterScores.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (filteredScores.isEmpty) {
      return Center(
          child: Text('No chapter scores to display.', style: FontStyles.sub));
    }

    double maxScore =
        filteredScores.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: filteredScores.map((entry) {
        double score = entry.value;
        double barWidth = (score / maxScore) * propWidth(200);
        barWidth = barWidth.isNaN ? 0 : barWidth;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: propHeight(4)),
          child: Row(
            children: [
              Text(entry.key, style: FontStyles.sub),
              SizedBox(width: propWidth(10)),
              Container(
                height: propHeight(10),
                width: barWidth,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: propWidth(10)),
              Text('${score.toStringAsFixed(2)}', style: FontStyles.sub),
            ],
          ),
        );
      }).toList(),
    );
  }
}
