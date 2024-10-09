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

        // Parse the content and extract the question, choices, points, and correct answer
        return _parseGeneratedQuestion(content);
      } else {
        throw Exception('Failed to generate question: ${response.body}');
      }
    } catch (e) {
      print('Error generating question: $e');
      throw e;
    }
  }

  // Create a dynamic prompt for the OpenAI API
  String createDynamicPrompt(int difficulty, int score, int numAnswered) {
    return '''
    Generate a multiple-choice question based on the following criteria:
    - Current difficulty level: $difficulty
    - User's current score: $score
    - Number of questions answered: $numAnswered
    - Four multiple-choice answers.
    - Each answer should have a point value based on its closeness to the correct answer (1, 0.75, 0.5, 0.25).
    - Indicate the index of the correct answer (0-based index).
    - Provide a short help explanation for the correct answer.
    Example:
    Question: What is a primary source of Vitamin C?
    Choices: Oranges, Apples, Oranges & Strawberries, Potatoes
    Points: 1, 0.25, 0.75, 0.5
    Correct: 0
    Help: Think about common fruits known for high vitamin C content.
    ''';
  }

  // Parses the response content and formats it into a structured Map
  Map<String, dynamic> _parseGeneratedQuestion(String content) {
    final questionRegex = RegExp(r'Question:\s*(.*)');
    final choicesRegex = RegExp(r'Choices:\s*([\s\S]*?)\nPoints:');
    final pointsRegex = RegExp(r'Points:\s*([\s\S]*?)\n');
    final correctRegex = RegExp(r'Correct:\s*(\d+)');
    final helpRegex = RegExp(r'Help:\s*(.*)');

    final questionMatch = questionRegex.firstMatch(content);
    final choicesMatch = choicesRegex.firstMatch(content);
    final pointsMatch = pointsRegex.firstMatch(content);
    final correctMatch = correctRegex.firstMatch(content);
    final helpMatch = helpRegex.firstMatch(content);

    if (questionMatch != null &&
        choicesMatch != null &&
        pointsMatch != null &&
        correctMatch != null &&
        helpMatch != null) {
      String question = questionMatch.group(1)!.trim();
      String help = helpMatch.group(1)!.trim();

      // Split choices by number and period
      List<String> choices = choicesMatch
          .group(1)!
          .split(RegExp(r'\d+\.\s*'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Split points by commas or spaces
      List<double> points = pointsMatch
          .group(1)!
          .split(RegExp(r'[\s,]+'))
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList();

      int correct = int.tryParse(correctMatch.group(1)!.trim()) ?? 0;

      // Ensure points list matches the choices list length
      if (points.length != choices.length) {
        throw Exception('Mismatch between choices and points length');
      }

      return {
        'question': question,
        'choices': choices,
        'points': points,
        'correct': correct,
        'help': help,
      };
    } else {
      throw Exception('Failed to parse question: Unexpected format');
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
