import 'package:flutter/material.dart';
import 'package:edumentor/services/manager.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:quickalert/quickalert.dart';
import 'questions.dart'; // Import the question screen

class ChapterSelectionScreen extends StatefulWidget {
  const ChapterSelectionScreen({super.key});

  @override
  _ChapterSelectionScreenState createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  List<bool> _selectedChapters = List.generate(15, (_) => false);
  String _difficultyLevel = 'Moderate';
  final List<String> difficultyLevels = [
    'Very Easy',
    'Easy',
    'Moderate',
    'Hard',
    'Very Hard'
  ];

  void _startQuiz() {
    List<int> selectedChapterNumbers = [];
    for (int i = 0; i < _selectedChapters.length; i++) {
      if (_selectedChapters[i]) {
        selectedChapterNumbers.add(i + 1);
      }
    }

    if (selectedChapterNumbers.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Please select at least one chapter to proceed!',
        confirmBtnColor: AppColors.green,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MCQQuizScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Choose Chapters & Difficulty',
          style: FontStyles.button.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: propWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: propHeight(20)),
            Text(
              'Select Chapters',
              style: FontStyles.hometitle.copyWith(
                fontSize: propText(22),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: propHeight(15)),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: propWidth(5),
                  mainAxisSpacing: propHeight(10),
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedChapters[index] = !_selectedChapters[index];
                      });
                    },
                    child: AnimatedContainer(
                      width: propWidth(80), // Fixed width for each container
                      height: propHeight(60), // Fixed height for each container
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _selectedChapters[index]
                            ? AppColors.green
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _selectedChapters[index]
                              ? Colors.transparent
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          if (_selectedChapters[index])
                            BoxShadow(
                              color: AppColors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Ch. ${index + 1}',
                          style: FontStyles.button.copyWith(
                            color: _selectedChapters[index]
                                ? Colors.white
                                : Colors.black87,
                            fontSize: propText(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: propHeight(30)),
            Center(
              child: Column(
                children: [
                  Text(
                    'Select Difficulty',
                    style: FontStyles.hometitle.copyWith(
                      fontSize: propText(22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: propHeight(10)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: propWidth(10)),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: difficultyLevels.map((level) {
                        return ChoiceChip(
                          label: Text(level),
                          selected: _difficultyLevel == level,
                          selectedColor: AppColors.green,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _difficultyLevel == level
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _difficultyLevel = level;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: propHeight(30)),
            Center(
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: EdgeInsets.symmetric(
                    horizontal: propWidth(50),
                    vertical: propHeight(18),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Start Quiz',
                  style: FontStyles.button.copyWith(
                    color: Colors.white,
                    fontSize: propText(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: propHeight(20)),
          ],
        ),
      ),
    );
  }
}
