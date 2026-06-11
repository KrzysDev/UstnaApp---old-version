class Question {
  final String question;
  final String questionType; // "text", "image", "poem"
  final String? imageBase64;
  final String? imageMimeType;
  final String? imageFilename;

  Question({
    required this.question,
    required this.questionType,
    this.imageBase64,
    this.imageMimeType,
    this.imageFilename,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      questionType: json['question_type'] ?? 'text',
      imageBase64: json['image_base64'],
      imageMimeType: json['image_mime_type'],
      imageFilename: json['image_filename'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'question_type': questionType,
      'image_base64': imageBase64,
      'image_mime_type': imageMimeType,
      'image_filename': imageFilename,
    };
  }
}

class ExamSet {
  final Question question1;
  final Question question2;

  ExamSet({
    required this.question1,
    required this.question2,
  });

  factory ExamSet.fromJson(Map<String, dynamic> json) {
    return ExamSet(
      question1: Question.fromJson(json['question1']),
      question2: Question.fromJson(json['question2']),
    );
  }
}

class EvaluationError {
  final String errorType;
  final String whenIsOccurring;

  EvaluationError({
    required this.errorType,
    required this.whenIsOccurring,
  });

  factory EvaluationError.fromJson(Map<String, dynamic> json) {
    return EvaluationError(
      errorType: json['error_type'] ?? '',
      whenIsOccurring: json['when_is_occuring'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error_type': errorType,
      'when_is_occuring': whenIsOccurring,
    };
  }
}

class EvaluationResult {
  final int score;
  final String summary;
  final List<EvaluationError> errors;

  EvaluationResult({
    required this.score,
    required this.summary,
    required this.errors,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    var errorList = json['errors'] as List? ?? [];
    List<EvaluationError> parsedErrors = errorList
        .map((e) => EvaluationError.fromJson(e as Map<String, dynamic>))
        .toList();

    return EvaluationResult(
      score: json['score'] ?? 0,
      summary: json['summary'] ?? '',
      errors: parsedErrors,
    );
  }
}
