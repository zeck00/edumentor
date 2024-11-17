import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edumentor/asset-class/colors.dart';
import 'package:edumentor/asset-class/fonts.dart';
import 'package:edumentor/asset-class/size_config.dart';
import 'package:edumentor/services/generator.dart';
import 'dart:math' show max;
import 'package:edumentor/screens/pdf.dart';

class ScoresScreen extends StatefulWidget {
  final double totalScore;
  final Map<int, double> chapterScores;

  const ScoresScreen({
    required this.totalScore,
    required this.chapterScores,
    super.key,
  });

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  String? feedback;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.totalScore >= 5.0) {
      _getFeedback();
    } else {
      isLoading = false;
    }
  }

  Future<void> _getFeedback() async {
    final generator = GPTQuestionGenerator();
    try {
      final response = await generator.generateFeedback(
        widget.totalScore,
        widget.chapterScores.length,
        widget.chapterScores,
      );
      setState(() {
        feedback = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        feedback = "Unable to generate feedback at this time.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    List<int> chaptersAnswered = widget.chapterScores.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Progress',
          style: FontStyles.hometitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(propWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: propHeight(20)),
            Center(
              child: Text(
                'Total Score: ${widget.totalScore.toStringAsFixed(2)}',
                style: FontStyles.hometitle,
              ),
            ),
            SizedBox(height: propHeight(30)),
            Container(
              height: propHeight(300),
              padding: EdgeInsets.all(propWidth(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: _buildChart(chaptersAnswered),
            ),
            SizedBox(height: propHeight(20)),
            if (isLoading)
              _buildSkeletonFeedback()
            else if (feedback != null)
              _buildFeedbackCard(),
            SizedBox(height: propHeight(20)),
            Text(
              'Chapter Details:',
              style: FontStyles.hometitle,
            ),
            SizedBox(height: propHeight(10)),
            _buildChapterList(chaptersAnswered),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<int> chapters) {
    if (chapters.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: FontStyles.sub,
        ),
      );
    }

    double maxScore = widget.chapterScores.values.reduce(max);

    return Padding(
      padding: EdgeInsets.only(
        left: propWidth(16),
        right: propWidth(16),
        top: propHeight(16),
        bottom: propHeight(24),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxScore + 1,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'Score: ${rod.toY.toStringAsFixed(2)}',
                  FontStyles.sub.copyWith(color: AppColors.green),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      padding: EdgeInsets.only(top: propHeight(8)),
                      child: Text(
                        'Ch${value.toInt()}',
                        style: FontStyles.sub.copyWith(
                          fontSize: propWidth(12),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: FontStyles.sub.copyWith(
                      fontSize: propWidth(12),
                      color: Colors.black87,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.gray.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: chapters.map((chapter) {
            return BarChartGroupData(
              x: chapter,
              barRods: [
                BarChartRodData(
                  toY: widget.chapterScores[chapter] ?? 0,
                  color: AppColors.green,
                  width: propWidth(16),
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxScore + 1,
                    color: AppColors.gray.withOpacity(0.2),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSkeletonFeedback() {
    return Container(
      padding: EdgeInsets.all(propWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(bottom: propHeight(8)),
            height: propHeight(16),
            width: double.infinity * (0.7 + (index * 0.1)),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    List<Widget> feedbackWidgets = [];
    List<String> lines = feedback!.split('\n');

    for (String line in lines) {
      if (line.trim().isEmpty) continue;

      // Handle headers
      if (line.startsWith('###')) {
        feedbackWidgets.add(
          Padding(
            padding:
                EdgeInsets.only(top: propHeight(16), bottom: propHeight(8)),
            child: Text(
              line.replaceAll('#', '').trim(),
              style: FontStyles.hometitle.copyWith(
                fontSize: propWidth(20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      // Process the line for both bold text and chapter references
      List<InlineSpan> spans = [];
      String currentText = line;

      // First, handle bold text
      RegExp boldRegex = RegExp(r'\*\*([^*]+)\*\*');
      List<String> segments = [];
      int lastIndex = 0;

      for (Match match in boldRegex.allMatches(currentText)) {
        // Add text before bold
        if (match.start > lastIndex) {
          segments.add(currentText.substring(lastIndex, match.start));
        }
        // Add bold text without **
        segments.add('BOLD_START${match.group(1)}');
        lastIndex = match.end;
      }

      // Add remaining text
      if (lastIndex < currentText.length) {
        segments.add(currentText.substring(lastIndex));
      }

      // Join segments back together
      currentText = segments.join();

      // Now process chapter references
      RegExp chapterRegex = RegExp(r'Chapter (\d+)');
      lastIndex = 0;

      for (Match match in chapterRegex.allMatches(currentText)) {
        // Add text before chapter reference
        if (match.start > lastIndex) {
          String beforeText = currentText.substring(lastIndex, match.start);
          // Process any bold text in this segment
          if (beforeText.contains('BOLD_START')) {
            beforeText.split(RegExp(r'BOLD_START|BOLD_END')).forEach((part) {
              if (part.isNotEmpty) {
                spans.add(TextSpan(
                  text: part,
                  style: FontStyles.sub.copyWith(
                    fontWeight: beforeText.contains('BOLD_START$part')
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ));
              }
            });
          } else {
            spans.add(TextSpan(text: beforeText, style: FontStyles.sub));
          }
        }

        // Add chapter reference
        String chapterNum = match.group(1)!;
        spans.add(
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(
                      title: 'Chapter $chapterNum',
                      pdfPath: 'assets/PDFs/Lec ($chapterNum).pdf',
                    ),
                  ),
                );
              },
              child: Text(
                'Chapter $chapterNum',
                style: FontStyles.sub.copyWith(
                  color: AppColors.green,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        );

        lastIndex = match.end;
      }

      // Add remaining text
      if (lastIndex < currentText.length) {
        String remainingText = currentText.substring(lastIndex);
        if (remainingText.contains('BOLD_START')) {
          remainingText.split(RegExp(r'BOLD_START|BOLD_END')).forEach((part) {
            if (part.isNotEmpty) {
              spans.add(TextSpan(
                text: part,
                style: FontStyles.sub.copyWith(
                  fontWeight: remainingText.contains('BOLD_START$part')
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ));
            }
          });
        } else {
          spans.add(TextSpan(text: remainingText, style: FontStyles.sub));
        }
      }

      feedbackWidgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: propHeight(4)),
          child: RichText(
            text: TextSpan(children: spans),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(propWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback',
            style: FontStyles.hometitle.copyWith(fontSize: 18),
          ),
          SizedBox(height: propHeight(8)),
          ...feedbackWidgets,
        ],
      ),
    );
  }

  Widget _buildChapterList(List<int> chapters) {
    return Container(
      margin: EdgeInsets.only(bottom: propHeight(80)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          int chapter = chapters[index];
          double score = widget.chapterScores[chapter] ?? 0.0;
          return _buildChapterScoreCard(chapter, score);
        },
      ),
    );
  }

  Widget _buildChapterScoreCard(int chapter, double score) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: propHeight(8),
        horizontal: propWidth(4),
      ),
      padding: EdgeInsets.symmetric(
        vertical: propHeight(16),
        horizontal: propWidth(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.book_outlined,
                color: AppColors.green,
                size: propWidth(24),
              ),
              SizedBox(width: propWidth(12)),
              Text(
                'Chapter $chapter',
                style: FontStyles.sub.copyWith(
                  fontSize: propWidth(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: propWidth(16),
              vertical: propHeight(8),
            ),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              score.toStringAsFixed(2),
              style: FontStyles.sub.copyWith(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
                fontSize: propWidth(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
