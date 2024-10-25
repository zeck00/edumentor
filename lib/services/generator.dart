import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edumentor/const.dart'; // Make sure your API key and other constants are here

class GPTQuestionGenerator {
  // Generates a question based on user score and progress (number of questions answered)
  Future<Map<String, dynamic>> generateQuestion(
      int difficulty, int score, int numAnswered) async {
    final String prompt = createDynamicPrompt(difficulty, score, numAnswered);

    // API request body
    final Map<String, dynamic> body = {
      "model": "gpt-4",
      "messages": [
        {
          "role": "system",
          "content":
              "You are an AI used to generate MCQs (Multiple Choice Questions) for a student assessment system. You will generate questions, answers, and assign specific points to each answer based on how close they are to the correct answer. The points for correct answers are 1, and partial answers receive 0.25, 0.5, or 0.75 based on their closeness to the correct answer. The points should not be random, they should reflect how much the answer approximates the truth. The questions should progressively get harder depending on the user's performance."
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
          'Authorization':
              'Bearer ${ApiKeys.LapiKey}', // Make sure the API key is correct
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Print the full raw GPT response to debug
        print("GPT response content:\n$content");

        // Parse the content and extract the question, choices, points, and correct answer
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
  String createDynamicPrompt(int difficulty, int score, int numAnswered) {
    return '''
    Generate a multiple-choice question related to health sciences and nutrition based on the following chapters:
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

    Include four multiple-choice answers, with each answer being scored based on its closeness to the correct answer (1, 0.75, 0.5, 0.25). 
    Indicate the index of the correct answer (0-based index) and provide a short help explanation for the correct answer.

    Example:
    Question: Which vitamin is essential for calcium absorption in the body?
    Choices: Vitamin A, Vitamin D, Vitamin C, Vitamin B12
    Points: 0.25, 1, 0.5, 0.25
    Correct: 1
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
      final helpRegex = RegExp(r'Help:\s*(.*)');

      // Extract the main parts of the question
      final questionMatch = questionRegex.firstMatch(content);
      final choicesMatch = choicesRegex.firstMatch(content);
      final pointsMatch = pointsRegex.firstMatch(content);
      final correctMatch = correctRegex.firstMatch(content);
      final helpMatch = helpRegex.firstMatch(content);

      // Validate that we found everything
      if (questionMatch == null ||
          choicesMatch == null ||
          pointsMatch == null ||
          correctMatch == null ||
          helpMatch == null) {
        throw Exception(
            'Failed to parse: missing key elements in the GPT response.');
      }

      // Parse the question and help text
      String question = questionMatch.group(1)!.trim();
      String help = helpMatch.group(1)!.trim();

      // LOG: Show raw choices content before parsing
      print("Raw choices content: ${choicesMatch.group(1)}");

      // Parse the choices
      List<String> choices = choicesMatch
          .group(1)!
          .split(RegExp(
              r'\n|^\d+\.\s*|,\s*')) // Split by newline, numbered lists, or commas
          .map((choice) => choice.trim())
          .where((choice) => choice.isNotEmpty) // Remove empty entries
          .toList();

      // LOG: Show parsed choices to ensure they are separated correctly
      print("Parsed choices: $choices");

      // Parse the points
      List<double> points = pointsMatch
          .group(1)!
          .split(RegExp(r'[\s,]+')) // Split by spaces or commas
          .map((point) =>
              double.tryParse(point.trim()) ??
              0.0) // Ensure all points are converted to double
          .toList();

      // Parse the correct answer index
      int correct = int.tryParse(correctMatch.group(1)!.trim()) ?? 0;

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
        'help': help,
      };
    } catch (e) {
      print('Error parsing GPT response: $e');
      rethrow; // Rethrow the error to ensure it surfaces in the app
    }
  }

  // Generates a batch of questions based on progress
  Future<List<Map<String, dynamic>>> generateNewQuestions(int numQuestions,
      int startingDifficulty, int currentScore, int totalAnswered) async {
    List<Map<String, dynamic>> questions = [];

    for (int i = 0; i < numQuestions; i++) {
      final questionData = await generateQuestion(
          startingDifficulty + i, currentScore, totalAnswered + i);
      questions.add(questionData);
    }

    return questions;
  }
}
