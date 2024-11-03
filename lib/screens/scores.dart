import 'package:flutter/material.dart';
import 'package:edumentor/asset-class/colors.dart'; // Your color definitions
import 'package:edumentor/asset-class/fonts.dart'; // Your font styles
import 'package:edumentor/asset-class/size_config.dart'; // Size configuration

class ScoresScreen extends StatelessWidget {
  final double totalScore;
  final Map<String, double> chapterScores;

  const ScoresScreen({
    required this.totalScore,
    required this.chapterScores,
    super.key,
  });

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
    List<String> chaptersAnswered = chapterScores.keys.toList();
    if (chaptersAnswered.isEmpty) {
      return Center(
        child: Text(
          'No scores to display yet.',
          style: FontStyles.sub,
        ),
      );
    }

    return ListView.builder(
      itemCount: chaptersAnswered.length,
      itemBuilder: (context, index) {
        String chapter = chaptersAnswered[index];
        double score = chapterScores[chapter] ?? 0.0;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: propHeight(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chapter $chapter',
                style: FontStyles.sub,
              ),
              SizedBox(height: propHeight(5)),
              LinearProgressIndicator(
                value: score % 1.0, // Adjust max score as per your logic
                backgroundColor: AppColors.gray,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
              SizedBox(height: propHeight(5)),
              Text(
                'Score: ${score.toStringAsFixed(2)}',
                style: FontStyles.sub,
              ),
            ],
          ),
        );
      },
    );
  }
}
