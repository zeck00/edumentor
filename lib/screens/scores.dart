import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/colors.dart'; // Your color definitions
import 'package:edumentor/asset-class/fonts.dart'; // Your font styles
import 'package:edumentor/asset-class/size_config.dart'; // Size configuration

class ScoresScreen extends StatelessWidget {
  final double totalScore;
  final Map<int, double> chapterScores;

  const ScoresScreen({
    required this.totalScore,
    required this.chapterScores,
    super.key,
  });

  double get maxChapterScore {
    if (chapterScores.isEmpty) return 1.0; // Prevent division by zero
    final maxScore =
        chapterScores.values.reduce((max, score) => max > score ? max : score);
    return maxScore > 0.0 ? maxScore : 1.0; // Ensure maxScore is not zero
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Scores',
          style: FontStyles.hometitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(propWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: propHeight(20)),
            Center(
              child: Text(
                'Total Score: ${totalScore.toStringAsFixed(2)}',
                style: FontStyles.hometitle,
              ),
            ),
            SizedBox(height: propHeight(20)),
            Text(
              'Chapter Scores:',
              style: FontStyles.hometitle,
            ),
            SizedBox(height: propHeight(10)),
            Expanded(
              child: _buildChapterScores(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterScores() {
    List<int> chaptersAnswered = chapterScores.keys.toList();
    if (chaptersAnswered.isEmpty) {
      return Center(
        child: Text(
          'No scores to display yet.',
          style: FontStyles.sub,
        ),
      );
    }

    chaptersAnswered.sort(); // Sort the chapters numerically
    final maxScore = maxChapterScore; // Get the highest score

    return ListView.builder(
      itemCount: chaptersAnswered.length,
      itemBuilder: (context, index) {
        int chapter = chaptersAnswered[index];
        double score = chapterScores[chapter] ?? 0.0;

        // Handle division by zero
        double relativeProgress = (maxScore > 0.0) ? (score / maxScore) : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: propHeight(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chapter $chapter',
                    style: FontStyles.sub,
                  ),
                  Text(
                    'Score: ${score.toStringAsFixed(2)}',
                    style: FontStyles.sub,
                  ),
                ],
              ),
              SizedBox(height: propHeight(5)),
              LinearProgressIndicator(
                value: relativeProgress, // Use relative progress
                backgroundColor: AppColors.gray,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                minHeight: propHeight(8), // Make the progress bar more visible
              ),
            ],
          ),
        );
      },
    );
  }
}
