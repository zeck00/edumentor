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

  Map<String, dynamic> _parseGeneratedQuestion(String content) {
    try {
      // Clean up content by removing ** and extra whitespace.
      content = content.replaceAll(RegExp(r'\*\*|\n|\r'), ' ').trim();
      print('Cleaned Content: $content');

      // Define regex patterns with ** markers as section delimiters.
      final questionRegex =
          RegExp(r'Question:\s*(.*?)\s*Choices:', dotAll: true);
      final choicesRegex =
          RegExp(r'Choices:\s*([\s\S]*?)\s*Points:', dotAll: true);
      final pointsRegex =
          RegExp(r'Points:\s*([\s\S]*?)\s*Correct:', dotAll: true);
      final correctRegex = RegExp(r'Correct:\s*(\d+)', dotAll: true);
      final chapterRegex = RegExp(r'Chapter:\s*(\d+)', dotAll: true);
      final helpRegex = RegExp(r'Help:\s*(.*?)$', dotAll: true);

      // Match each section with error checking.
      final questionMatch = questionRegex.firstMatch(content);
      final choicesMatch = choicesRegex.firstMatch(content);
      final pointsMatch = pointsRegex.firstMatch(content);
      final correctMatch = correctRegex.firstMatch(content);
      final chapterMatch = chapterRegex.firstMatch(content);
      final helpMatch = helpRegex.firstMatch(content);

      if (questionMatch == null ||
          choicesMatch == null ||
          pointsMatch == null ||
          correctMatch == null ||
          chapterMatch == null ||
          helpMatch == null) {
        throw Exception(
            'Failed to parse: missing key elements in the GPT response.');
      }

      // Extract question, help, chapter, and correct answer index.
      String question = questionMatch.group(1)!.trim();
      String help = helpMatch.group(1)!.trim();
      int chapter =
          int.parse(chapterMatch.group(1)!.trim()); // Ensure chapter is an int
      int correct = int.parse(
          correctMatch.group(1)!.trim()); // Ensure correct answer is an int

      // Extract and clean up choices.
      List<String> choices = choicesMatch
          .group(1)!
          .split(RegExp(r'\s*\d+\.\s*|\s*[A-Z]\)\s*|,'))
          .map((choice) => choice.trim())
          .where((choice) => choice.isNotEmpty)
          .toList();

      // Parse points and validate lengths.
      List<double> points = pointsMatch
          .group(1)!
          .split(RegExp(r'[\s,]+'))
          .map((p) => double.tryParse(p.trim()) ?? 0.0)
          .toList();

      if (choices.length != points.length) {
        print(
            "Mismatch found - Choices: ${choices.length}, Points: ${points.length}");
        throw Exception('Mismatch between number of choices and points.');
      }

      // Return parsed question data.
      return {
        'question': question,
        'choices': choices,
        'points': points,
        'correct': correct, // Cast as integer
        'chapter': chapter, // Cast as integer
        'help': help,
      };
    } catch (e) {
      print('Error parsing GPT response: $e');
      rethrow;
    }
  }
}
