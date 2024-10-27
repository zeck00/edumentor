import 'dart:async';
import 'package:flutter/material.dart';
import 'package:edumentor/services/manager.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:wave_loading_indicator/wave_progress.dart';
import 'package:quickalert/quickalert.dart';
import 'questions.dart'; // Import the question screen

class ChapterSelectionScreen extends StatefulWidget {
  const ChapterSelectionScreen({super.key});

  @override
  _ChapterSelectionScreenState createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  List<bool> _selectedChapters = List.generate(15, (_) => false);
  double _difficultyLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Chapters & Difficulty',
          style: FontStyles.button.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.green,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: propWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: propHeight(20)),
            Center(
              child: Text(
                'Select Chapters',
                style: FontStyles.hometitle,
              ),
            ),
            SizedBox(height: propHeight(10)),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(15, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedChapters[index] = !_selectedChapters[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedChapters[index]
                            ? AppColors.green
                            : AppColors.gray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: propWidth(85),
                      height: propHeight(70),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: FontStyles.button.copyWith(
                          color: _selectedChapters[index]
                              ? AppColors.white
                              : AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: propHeight(30)),
            Center(
              child: Text(
                'Select Difficulty',
                style: FontStyles.hometitle,
              ),
            ),
            SizedBox(height: propHeight(10)),
            Slider(
              value: _difficultyLevel,
              min: 1,
              max: 10,
              divisions: 9,
              label: _difficultyLevel.round().toString(),
              activeColor: AppColors.green,
              inactiveColor: AppColors.gray,
              onChanged: (value) {
                setState(() {
                  _difficultyLevel = value;
                });
              },
            ),
            SizedBox(height: propHeight(20)),
            Center(
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                ),
                child: Text(
                  'Start Quiz',
                  style: FontStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz() {
    List<int> selectedChapters = [];
    for (int i = 0; i < _selectedChapters.length; i++) {
      if (_selectedChapters[i]) {
        selectedChapters.add(i + 1);
      }
    }

    print("Selected Chapters: $selectedChapters"); // Debug print

    if (selectedChapters.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Please select at least one chapter to proceed!',
        confirmBtnColor: AppColors.green,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MCQQuizScreen(
            selectedChapters: selectedChapters,
            difficultyLevel: _difficultyLevel.toInt(),
          ),
        ),
      );
    }
  }
}
