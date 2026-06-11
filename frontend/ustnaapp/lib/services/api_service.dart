import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  String baseUrl;

  ApiService({required this.baseUrl});

  /// Fetches the list of all public questions.
  Future<List<String>> getPublicQuestions() async {
    final response = await http.get(Uri.parse('$baseUrl/questions/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> questionsList = data['questions'] ?? [];
      return questionsList.map((q) => q.toString()).toList();
    } else {
      throw HttpException('Błąd podczas pobierania pytań jawnych: ${response.statusCode}');
    }
  }

  /// Draws a random set of questions (Question 1 - public, Question 2 - secret).
  Future<ExamSet> getRandomSetOfQuestions() async {
    final response = await http.get(Uri.parse('$baseUrl/set-of-questions/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return ExamSet.fromJson(data);
    } else {
      throw HttpException('Błąd podczas losowania zestawu: ${response.statusCode}');
    }
  }

  /// Uploads recorded PCM audio to get transcribed text.
  Future<String> transcribeAudio(String filePath) async {
    final uri = Uri.parse('$baseUrl/transcribing/');
    final request = http.MultipartRequest('POST', uri);
    
    // Add file to multipart request
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', 
        filePath,
        filename: 'recording.pcm',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      String result = utf8.decode(response.bodyBytes);
      // Clean up string quotes if returned by FastAPI as JSON-wrapped string
      if (result.startsWith('"') && result.endsWith('"') && result.length >= 2) {
        result = result.substring(1, result.length - 1);
      }
      // Decode escaped characters if any
      try {
        result = json.decode('"$result"');
      } catch (_) {}
      return result.trim();
    } else {
      throw HttpException('Błąd transkrypcji audio: ${response.statusCode}');
    }
  }

  /// Generates the two examination board questions based on the monologue.
  Future<List<String>> getBoardQuestions({
    required String topic1,
    required String topic2,
    required String studentAnswer,
  }) async {
    final uri = Uri.parse('$baseUrl/examination-board-questions/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'topic_1': topic1,
        'topic_2': topic2,
        'student_answer': studentAnswer,
      }),
    );

    if (response.statusCode == 200) {
      // The FastAPI endpoint returns a string from AI which is supposed to be JSON.
      // Sometimes it is returned as a JSON string, sometimes direct JSON.
      final String rawBody = utf8.decode(response.bodyBytes);
      dynamic decoded = json.decode(rawBody);

      // If it parsed into a String (because backend returned a JSON string), decode it again
      if (decoded is String) {
        String cleanJson = decoded.trim();
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.substring(7);
        } else if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.substring(3);
        }
        if (cleanJson.endsWith('```')) {
          cleanJson = cleanJson.substring(0, cleanJson.length - 3);
        }
        cleanJson = cleanJson.trim();
        decoded = json.decode(cleanJson);
      }

      final List<dynamic> questionsList = decoded['questions'] ?? [];
      return questionsList.map((q) => q.toString()).toList();
    } else {
      throw HttpException('Błąd pobierania pytań komisji: ${response.statusCode}');
    }
  }

  /// Sends the complete exam response for final scoring and feedback.
  Future<EvaluationResult> evaluateResponse({
    required String question1,
    required String question2,
    required String responseText,
    required String examinationBoardQuestion1,
    required String examinationBoardQuestion2,
    required String examinationBoardAnswers,
  }) async {
    final uri = Uri.parse('$baseUrl/response-evaluation/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'question1': question1,
        'question2': question2,
        'response': responseText,
        'examination_board_question1': examinationBoardQuestion1,
        'examination_board_question2': examinationBoardQuestion2,
        'examination_board_answers': examinationBoardAnswers,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return EvaluationResult.fromJson(data);
    } else {
      throw HttpException('Błąd podczas oceniania wypowiedzi: ${response.statusCode}');
    }
  }
}
