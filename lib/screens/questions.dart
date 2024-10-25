import 'package:flutter/material.dart';
import 'package:edumentor/services/manager.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';

class MCQQuizScreen extends StatefulWidget {
  @override
  _MCQQuizScreenState createState() => _MCQQuizScreenState();
}

class _MCQQuizScreenState extends State<MCQQuizScreen> {
  QuestMgr? _questMgr;
  int _currentQuestionIndex = 0;
  double _totalScore = 0;
  bool _isAnswerSelected = false;
  int? _selectedAnswer;
  bool _isHelpVisible = false;
  String _helpText = '';
  bool _isLoading = true;
  int? _correctAnswerIndex;

  // New variables for proper shuffling
  List<String> _originalChoices = [];
  List<String> _shuffledChoices = [];
  Map<int, int> _shuffleToOriginalMap = {};
  Map<int, int> _originalToShuffleMap = {};

  @override
  void initState() {
    super.initState();
    _initializeQuestMgr();
  }

  Future<void> _initializeQuestMgr() async {
    try {
      final questMgr = await QuestMgr.getInstance();
      if (questMgr.questionCount == 0) {
        await questMgr.appendQuestions(10, 1, 0, 0);
      }
      setState(() {
        _questMgr = questMgr;
        _totalScore = questMgr.totalScore;
        _isLoading = false;
      });
      await _loadShuffledChoices();
    } catch (e) {
      print('Error initializing QuestMgr: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadShuffledChoices() async {
    if (_questMgr == null) return;

    // Get original choices and correct answer
    _originalChoices = await _questMgr!.getChoices(_currentQuestionIndex);
    _correctAnswerIndex =
        await _questMgr!.getCorrectAnswerIndex(_currentQuestionIndex);

    // Create indices for shuffling
    List<int> indices = List.generate(_originalChoices.length, (i) => i);
    indices.shuffle();

    // Create mappings
    _shuffleToOriginalMap.clear();
    _originalToShuffleMap.clear();
    for (int i = 0; i < indices.length; i++) {
      _shuffleToOriginalMap[i] = indices[i];
      _originalToShuffleMap[indices[i]] = i;
    }

    // Create shuffled choices
    setState(() {
      _shuffledChoices = indices.map((i) => _originalChoices[i]).toList();
    });

    // Debug logging
    print('Original choices: $_originalChoices');
    print('Shuffled choices: $_shuffledChoices');
    print('Mapping: $_shuffleToOriginalMap');
    print('Correct answer (original): $_correctAnswerIndex');
    print(
        'Correct answer (shuffled): ${_originalToShuffleMap[_correctAnswerIndex]}');
  }

  void _onAnswerSelected(int shuffledIndex) async {
    if (_isAnswerSelected) return;

    // Get original index from shuffled index
    int originalIndex = _shuffleToOriginalMap[shuffledIndex]!;

    setState(() {
      _selectedAnswer = shuffledIndex;
      _isAnswerSelected = true;
    });

    // Debug logging
    print('Selected Answer (UI Index): $shuffledIndex');
    print('Mapped to Original Index: $originalIndex');
    print('Correct Answer (Original Index): $_correctAnswerIndex');

    bool isCorrect = originalIndex == _correctAnswerIndex;
    print(
        isCorrect ? "Correct answer selected!" : "Incorrect answer selected.");

    await _questMgr!.selectAnswer(_currentQuestionIndex, originalIndex);

    setState(() {
      _totalScore = _questMgr!.totalScore;
    });
  }

  Future<void> _showHelp() async {
    final help = await _questMgr!.getQuestionHelp(_currentQuestionIndex);
    setState(() {
      _helpText = help;
      _isHelpVisible = !_isHelpVisible;
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _questMgr!.questionCount - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSelected = false;
        _selectedAnswer = null;
        _helpText = '';
        _isHelpVisible = false;
        _correctAnswerIndex = null;
      });
      await _loadShuffledChoices();
    } else {
      print("No more questions available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ Quiz', style: FontStyles.hometitleg),
        backgroundColor: AppColors.green,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _questMgr == null
              ? Center(child: Text('Failed to load questions.'))
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: propWidth(16)),
                  child: Column(
                    children: [
                      FutureBuilder<String>(
                        future: _questMgr!.getQuestion(_currentQuestionIndex),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading question');
                          }
                          return Text(
                            snapshot.data!,
                            style: FontStyles.hometitle,
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      SizedBox(height: propHeight(24)),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _shuffledChoices.length,
                        itemBuilder: (context, index) {
                          bool isCorrect = _isAnswerSelected &&
                              _correctAnswerIndex != null &&
                              _shuffleToOriginalMap[index] ==
                                  _correctAnswerIndex;
                          bool isSelected = index == _selectedAnswer;

                          Color containerColor = isCorrect
                              ? AppColors.green
                              : isSelected
                                  ? Colors.red.shade300
                                  : Colors.grey.shade200;

                          return GestureDetector(
                            onTap: _isAnswerSelected
                                ? null
                                : () => _onAnswerSelected(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: containerColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(12),
                              child: Text(
                                _shuffledChoices[index],
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
                              child: Text('Next Question',
                                  style: FontStyles.button),
                            )
                          : Container(),
                      SizedBox(height: propHeight(24)),
                      ElevatedButton(
                        onPressed: _showHelp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                        ),
                        child: Text(
                          _isHelpVisible ? 'Hide Help' : 'Show Help',
                          style: FontStyles.button,
                        ),
                      ),
                      _isHelpVisible && _helpText.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: propHeight(16)),
                              child: Text(
                                _helpText,
                                style: FontStyles.subg,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(),
                      SizedBox(height: propHeight(24)),
                      Text('Total Score: $_totalScore',
                          style: FontStyles.hometitleg),
                    ],
                  ),
                ),
    );
  }
}
