import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edumentor/const.dart';
import 'package:edumentor/services/history_manager.dart';

class GPTQuestionGenerator {
  // Generates a question based on user score, progress, and chapter context.
  Future<Map<String, dynamic>> generateQuestion(
    String difficulty,
    int score,
    int numAnswered,
    String bestChapter,
    String worstChapter,
    int chapterNo,
  ) async {
    // Get question history
    final List<String> questionHistory =
        await QuestionHistoryManager.getQuestionHistory();

    final String prompt = createDynamicPrompt(
      difficulty,
      score,
      numAnswered,
      bestChapter,
      worstChapter,
      chapterNo,
      questionHistory,
    );

    // API request body
    final Map<String, dynamic> body = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content":
              "You are an instructor used to generate MCQs (Multiple Choice Questions) in specific format for a student assessment system. Each question should be based on the student's performance, with a focus on the selected chapter and the weakest-performing chapter."
        },
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 300,
      "n": 1,
      "temperature": 0.5,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.LapiKey}',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Print the full raw GPT response for debugging
        print("GPT response content:\n$content");

        // Parse the content and extract the question, choices, points, correct answer, and chapter
        return _parseGeneratedQuestion(content);
      } else {
        throw Exception('Failed to generate question: ${response.body}');
      }
    } catch (e) {
      print('Error generating question: $e');
      rethrow;
    }
  }

  // Create a dynamic prompt for the OpenAI API
  String createDynamicPrompt(
    String difficulty,
    int score,
    int numAnswered,
    String bestChapter,
    String worstChapter,
    int chapterNo,
    List<String> questionHistory,
  ) {
    String historyContext = '';
    if (questionHistory.isNotEmpty) {
      historyContext =
          '\nRecently asked questions (DO NOT REPEAT THESE):\n${questionHistory.map((q) => '- $q').join('\n')}';
    }

    return '''
Generate a multiple-choice question for a student in health sciences and nutrition focusing on the chapter: $chapterNo.

STUDENT CONTEXT:
- Current Chapter Focus: $chapterNo
- Performance Level: ${(score / (numAnswered == 0 ? 1 : numAnswered)).toStringAsFixed(2)} avg score
- Questions Completed: $numAnswered
- Strongest Chapter: $bestChapter
- Weakest Chapter: $worstChapter
- Required Difficulty: $difficulty --make sure to take that into account,

Chapters:
1. Basic Nutritional Concepts (macronutrients, micronutrients, and energy balance)
2. Digestion and Absorption (nutrient absorption processes, GI tract roles)
3. Carbohydrates (types of carbohydrates, fiber, digestion)
4. Lipids (fatty acids, cholesterol, health implications)
5. Proteins (essential and non-essential amino acids, protein digestion)
6. Vitamins and Minerals (water- and fat-soluble vitamins, deficiency diseases)
7. Energy Metabolism (energy requirements, metabolism regulation)
8. Weight Management (obesity, energy expenditure, diet strategies)
9. Physical Fitness (exercise benefits, guidelines, physical activity)
10. Diabetes Mellitus (types, symptoms, treatment, glycemic control)
11. Cardiovascular Diseases (hypertension, heart disease risk factors, DASH diet)
12. Overweight and Obesity (BMI, types of obesity, treatment strategies)
13. Eating Disorders (anorexia, bulimia, pica, binge eating)
14. Water and Fluid Balance (hydration, electrolyte balance)
15. Nutrition in Special Populations (pregnancy, elderly, athletes).

$historyContext

Please provide:
- A question related to one of the chapters above (focus on $chapterNo and $worstChapter).
- Four multiple-choice answers, **without labels or points embedded**, separated by commas.
- A separate list of points corresponding to each choice, in the same order, separated by commas.
  - Use the following point values: 1 (correct), 0.75 (closely related), 0.5 (somewhat related), 0.25 (incorrect).
- The index of the correct answer (0-based).
- The chapter of the question.
- A brief help explanation of how to get to the correct answer, without giving the answer directly.

Example:
Question: Which vitamin is essential for calcium absorption in the body?
Choices: Vitamin A, Vitamin D, Vitamin C, Vitamin B12
Points: 0.25, 1, 0.5, 0.25
Correct: 1
Chapter: 6
Help: Think of a vitamin that helps the body absorb calcium, which is crucial for bone health too!

Please provide a NEW question that has not been asked before. Ensure that the question is not similar to any of the recently asked questions provided above.
''';
  }

  Map<String, dynamic> _parseGeneratedQuestion(String content) {
    try {
      // Clean up content and normalize line endings
      content = content
          .replaceAll(RegExp(r'\*\*'), '')
          .replaceAll('\r\n', '\n')
          .trim();

      // More robust regex patterns with better error handling
      final questionRegex =
          RegExp(r'Question:\s*(.*?)(?=\s*Choices:|$)', dotAll: true);
      final choicesRegex =
          RegExp(r'Choices:\s*(.*?)(?=\s*Points:|$)', dotAll: true);
      final pointsRegex =
          RegExp(r'Points:\s*(.*?)(?=\s*Correct:|$)', dotAll: true);
      final correctRegex =
          RegExp(r'Correct:\s*(\d+)(?=\s*Chapter:|$)', dotAll: true);
      final chapterRegex =
          RegExp(r'Chapter:\s*(\d+)(?=\s*Help:|$)', dotAll: true);
      final helpRegex = RegExp(r'Help:\s*(.*?)$', dotAll: true);

      // Match and validate each section
      final questionMatch = questionRegex.firstMatch(content);
      final choicesMatch = choicesRegex.firstMatch(content);
      final pointsMatch = pointsRegex.firstMatch(content);
      final correctMatch = correctRegex.firstMatch(content);
      final chapterMatch = chapterRegex.firstMatch(content);
      final helpMatch = helpRegex.firstMatch(content);

      // Detailed validation with specific error messages
      if (questionMatch == null) {
        throw Exception('Question section not found or invalid');
      }
      if (choicesMatch == null) {
        throw Exception('Choices section not found or invalid');
      }
      if (pointsMatch == null) {
        throw Exception('Points section not found or invalid');
      }
      if (correctMatch == null) {
        throw Exception('Correct answer index not found or invalid');
      }
      if (chapterMatch == null) {
        throw Exception('Chapter number not found or invalid');
      }
      if (helpMatch == null) throw Exception('Help text not found or invalid');

      // Extract and validate question components
      String question = questionMatch.group(1)?.trim() ?? '';
      if (question.isEmpty) throw Exception('Question text cannot be empty');

      // Parse and validate choices
      List<String> choices = choicesMatch
          .group(1)!
          .split(RegExp(r',\s*'))
          .map((choice) => choice.trim())
          .where((choice) => choice.isNotEmpty)
          .toList();

      if (choices.length != 4) {
        throw Exception(
            'Exactly 4 choices are required, found: ${choices.length}');
      }

      // Parse and validate points
      List<double> points =
          pointsMatch.group(1)!.split(RegExp(r',\s*')).map((p) {
        double? value = double.tryParse(p.trim());
        if (value == null) throw Exception('Invalid point value: $p');
        return value;
      }).toList();

      if (points.length != choices.length) {
        throw Exception(
            'Mismatch between choices (${choices.length}) and points (${points.length})');
      }

      // Parse and validate correct answer index
      int correct = int.parse(correctMatch.group(1)!.trim());
      if (correct < 0 || correct >= choices.length) {
        throw Exception('Correct answer index out of range: $correct');
      }

      // Parse and validate chapter
      int chapter = int.parse(chapterMatch.group(1)!.trim());
      if (chapter <= 0) throw Exception('Invalid chapter number: $chapter');

      // Extract and validate help text
      String help = helpMatch.group(1)?.trim() ?? '';
      if (help.isEmpty) throw Exception('Help text cannot be empty');

      // Return validated question data
      return {
        'question': question,
        'choices': choices,
        'points': points,
        'correct': correct,
        'chapter': chapter,
        'help': help,
      };
    } catch (e) {
      print('Error parsing GPT response: $e');
      print('Original content:\n$content');
      rethrow;
    }
  }

  Future<String> generateFeedback(
    double totalScore,
    int questionsAnswered,
    Map<int, double> chapterScores,
  ) async {
    if (questionsAnswered < 10) {
      return "Complete more questions to get personalized feedback!";
    }

    final String prompt = '''
Analyze the following student performance data and provide personalized feedback:

Total Score: $totalScore
Questions Answered: $questionsAnswered
Chapter Performance:
${chapterScores.entries.map((e) => '- Chapter ${e.key}: ${e.value.toStringAsFixed(2)}').join('\n')}

Previous Question History:
${(await QuestionHistoryManager.getQuestionHistory()).join('\n')}

Please provide a detailed analysis in the following format:
1. Overall Performance: Brief summary of the student's overall progress
2. Strengths: Identify 2-3 chapters where the student excels
3. Areas for Improvement: Identify 2-3 chapters that need more focus
4. Specific Recommendations: 
   - Study strategies
   - Focus areas
   - Practice suggestions
5. Motivational Message: End with an encouraging note

Keep the tone positive and constructive while being specific about improvements needed.
''';

    final Map<String, dynamic> body = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content":
              "You are an educational advisor providing personalized feedback to students based on their performance data."
        },
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 250,
      "temperature": 0.7,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.LapiKey}',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate feedback: ${response.body}');
      }
    } catch (e) {
      print('Error generating feedback: $e');
      rethrow;
    }
  }
}
