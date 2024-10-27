import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edumentor/const.dart';

class GPTQuestionGenerator {
  // Generates a question based on user score, progress, and chapter context.
  Future<Map<String, dynamic>> generateQuestion(
    int difficulty,
    int score,
    int numAnswered,
    String bestChapter,
    String worstChapter,
    int chapterNo,
  ) async {
    final String prompt = createDynamicPrompt(
      difficulty,
      score,
      numAnswered,
      bestChapter,
      worstChapter,
      chapterNo,
    );

    // API request body
    final Map<String, dynamic> body = {
      "model": "gpt-4",
      "messages": [
        {
          "role": "system",
          "content":
              "You are an AI used to generate MCQs (Multiple Choice Questions) for a student assessment system. Each question should be based on the student's performance, with a focus on the selected chapter, the best-performing chapter, and the weakest-performing chapter."
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
    int difficulty,
    int score,
    int numAnswered,
    String bestChapter,
    String worstChapter,
    int chapterNo,
  ) {
    print("Generating question for chapter: $chapterNo");

    return '''
    Generate a multiple-choice question for a student in health sciences and nutrition focusing on the chapter: $chapterNo.

    The student's best-performing chapter is: $bestChapter.
    The student's weakest-performing chapter is: $worstChapter.
    The student's chosen practice chapters are: $chapterNo.
    Current score: $score. Questions answered so far: $numAnswered.

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

    Please provide:
    - A question related to one of the chapters above (focus on $chapterNo and $worstChapter).
    - Four multiple-choice answers, with each answer being scored based on its closeness to the correct answer: 1 (correct), 0.75 (closely related), 0.5 (somewhat related), and 0.25 (incorrect).
    - The correct answer's index (0-based).
    - The chapter of the question.
    - A brief help explanation of why the correct answer is right and guides the student to the correct answer.

      Example:
      Question: Which vitamin is essential for calcium absorption in the body?
      Choices: Vitamin A, Vitamin D, Vitamin C, Vitamin B12
      Points: 0.25, 1, 0.5, 0.25
      Correct: 1
      Chapter: 6
      Help: Vitamin D helps the body absorb calcium, which is crucial for bone health.
    ''';
  }

  // Parses the response content and formats it into a structured Map
  Map<String, dynamic> _parseGeneratedQuestion(String content) {
    try {
      final questionRegex = RegExp(r'Question:\s*(.*)');
      final choicesRegex = RegExp(r'Choices:\s*([\s\S]*?)\nPoints:');
      final pointsRegex = RegExp(r'Points:\s*([\s\S]*?)\n');
      final correctRegex = RegExp(r'Correct:\s*(\d+)');
      final chapterRegex = RegExp(r'Chapter:\s*(\d+)');
      final helpRegex = RegExp(r'Help:\s*(.*)');

      // Extract the main parts of the question
      final questionMatch = questionRegex.firstMatch(content);
      final choicesMatch = choicesRegex.firstMatch(content);
      final pointsMatch = pointsRegex.firstMatch(content);
      final correctMatch = correctRegex.firstMatch(content);
      final chapterMatch = chapterRegex.firstMatch(content);
      final helpMatch = helpRegex.firstMatch(content);

      // Validate that we found everything
      if (questionMatch == null ||
          choicesMatch == null ||
          pointsMatch == null ||
          correctMatch == null ||
          chapterMatch == null ||
          helpMatch == null) {
        throw Exception(
            'Failed to parse: missing key elements in the GPT response.');
      }

      // Parse the question and help text
      String question = questionMatch.group(1)!.trim();
      String help = helpMatch.group(1)!.trim();

      // Parse the choices
      List<String> choices = choicesMatch
          .group(1)!
          .split(RegExp(r'\n|^\d+\.\s*|,\s*'))
          .map((choice) => choice.trim())
          .where((choice) => choice.isNotEmpty)
          .toList();

      // Parse the points
      List<double> points = pointsMatch
          .group(1)!
          .split(RegExp(r'[\s,]+'))
          .map((point) => double.tryParse(point.trim()) ?? 0.0)
          .toList();

      // Parse the correct answer index and chapter
      int correct = int.tryParse(correctMatch.group(1)!.trim()) ?? 0;
      String chapter = chapterMatch.group(1)!.trim();

      // Ensure the choices and points lengths match EXACTLY
      if (choices.length != points.length) {
        throw Exception(
            'Mismatch between number of choices and points! Choices: ${choices.length}, Points: ${points.length}');
      }

      // Return the structured data
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
      rethrow;
    }
  }
}
