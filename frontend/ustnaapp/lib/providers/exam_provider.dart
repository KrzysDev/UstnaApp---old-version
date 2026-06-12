import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';

class ExamProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();
  late ApiService _apiService;

  String _baseUrl = '';
  String get baseUrl => _baseUrl;

  ExamProvider() {
    _baseUrl = "https://ustnaapp.onrender.com/api";
    _apiService = ApiService(baseUrl: _baseUrl);
  }

  void updateBaseUrl(String url) {
    if (url.trim().isNotEmpty) {
      _baseUrl = url.trim();
      _apiService = ApiService(baseUrl: _baseUrl);
      notifyListeners();
    }
  }

  // --- Exam States ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ExamSet? _examSet;
  ExamSet? get examSet => _examSet;

  // Preparation state
  int _preparationTime = 15 * 60; // 15 minutes in seconds
  int get preparationTime => _preparationTime;
  Timer? _prepTimer;
  bool get isPrepTimerActive => _prepTimer != null;

  // Monologue state
  bool _isRecordingMonologue = false;
  bool get isRecordingMonologue => _isRecordingMonologue;

  bool _isTranscribingMonologue = false;
  bool get isTranscribingMonologue => _isTranscribingMonologue;

  String _monologueTranscript = '';
  String get monologueTranscript => _monologueTranscript;

  // Board questions state
  bool _isGeneratingBoardQuestions = false;
  bool get isGeneratingBoardQuestions => _isGeneratingBoardQuestions;

  List<String> _boardQuestions = [];
  List<String> get boardQuestions => _boardQuestions;

  int _currentBoardQuestionIndex = 0;
  int get currentBoardQuestionIndex => _currentBoardQuestionIndex;

  bool _isRecordingBoardAnswer = false;
  bool get isRecordingBoardAnswer => _isRecordingBoardAnswer;

  bool _isTranscribingBoardAnswer = false;
  bool get isTranscribingBoardAnswer => _isTranscribingBoardAnswer;

  List<String> _boardAnswers = ['', ''];
  List<String> get boardAnswers => _boardAnswers;

  // Evaluation state
  bool _isEvaluating = false;
  bool get isEvaluating => _isEvaluating;

  EvaluationResult? _evaluationResult;
  EvaluationResult? get evaluationResult => _evaluationResult;

  // Clean error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset exam state
  void resetExam() {
    _prepTimer?.cancel();
    _prepTimer = null;
    _isLoading = false;
    _errorMessage = null;
    _examSet = null;
    _preparationTime = 15 * 60;
    _isRecordingMonologue = false;
    _isTranscribingMonologue = false;
    _monologueTranscript = '';
    _isGeneratingBoardQuestions = false;
    _boardQuestions = [];
    _currentBoardQuestionIndex = 0;
    _isRecordingBoardAnswer = false;
    _isTranscribingBoardAnswer = false;
    _boardAnswers = ['', ''];
    _isEvaluating = false;
    _evaluationResult = null;
    notifyListeners();
  }

  // --- Step 0: Draw Questions ---
  Future<void> drawSetOfQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _examSet = await _apiService.getRandomSetOfQuestions();
      _preparationTime = 15 * 60;
      startPreparationTimer();
    } catch (e) {
      _errorMessage = 'Nie udało się wylosować zestawu pytań: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Step 1: Preparation Timer ---
  void startPreparationTimer() {
    _prepTimer?.cancel();
    _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_preparationTime > 0) {
        _preparationTime--;
        notifyListeners();
      } else {
        _prepTimer?.cancel();
        _prepTimer = null;
        notifyListeners();
      }
    });
  }

  void stopPreparationTimer() {
    _prepTimer?.cancel();
    _prepTimer = null;
    notifyListeners();
  }

  void skipPreparation() {
    stopPreparationTimer();
  }

  // --- Step 2: Monologue ---
  Future<void> startMonologueRecording() async {
    _errorMessage = null;
    try {
      await _audioService.startRecording();
      _isRecordingMonologue = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopMonologueRecording() async {
    try {
      final path = await _audioService.stopRecording();
      _isRecordingMonologue = false;

      if (path != null) {
        _isTranscribingMonologue = true;
        notifyListeners();

        final text = await _apiService.transcribeAudio(path);
        _monologueTranscript = text.isNotEmpty ? text : 'Brak transkrypcji (brak wykrytej mowy).';
      } else {
        _errorMessage = 'Nie udało się odnaleźć pliku z nagraniem.';
      }
    } catch (e) {
      _errorMessage = 'Błąd transkrypcji monologu: $e';
      _monologueTranscript = 'Błąd transkrypcji. Wpisz swoją odpowiedź tutaj ręcznie.';
    } finally {
      _isTranscribingMonologue = false;
      notifyListeners();
    }
  }

  void updateMonologueTranscript(String text) {
    _monologueTranscript = text;
    notifyListeners();
  }

  // --- Step 3: Board Questions Generation ---
  Future<void> generateBoardQuestions() async {
    _isGeneratingBoardQuestions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_examSet == null) throw Exception('Brak aktywnego zestawu egzaminacyjnego.');

      final questions = await _apiService.getBoardQuestions(topic1: _examSet!.question1.question, topic2: _examSet!.question2.question, studentAnswer: _monologueTranscript);

      _boardQuestions = questions;
      _currentBoardQuestionIndex = 0;
      _boardAnswers = ['', ''];
    } catch (e) {
      _errorMessage = 'Nie udało się wygenerować pytań komisji: $e';
      // Fallback standard questions in case LLM fails or returns empty
      _boardQuestions = ['Proszę rozwinąć wątek dotyczący lektury z zadania 1. w kontekście postawy bohatera.', 'W jaki sposób załączone dzieło z zadania 2. odnosi się do współczesnych realiów?'];
    } finally {
      _isGeneratingBoardQuestions = false;
      notifyListeners();
    }
  }

  // --- Step 3b: Recording Board Answers ---
  Future<void> startBoardAnswerRecording() async {
    _errorMessage = null;
    try {
      await _audioService.startRecording();
      _isRecordingBoardAnswer = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopBoardAnswerRecording() async {
    try {
      final path = await _audioService.stopRecording();
      _isRecordingBoardAnswer = false;

      if (path != null) {
        _isTranscribingBoardAnswer = true;
        notifyListeners();

        final text = await _apiService.transcribeAudio(path);
        _boardAnswers[_currentBoardQuestionIndex] = text.isNotEmpty ? text : 'Brak transkrypcji (brak wykrytej mowy).';
      } else {
        _errorMessage = 'Nie udało się odnaleźć pliku z nagraniem.';
      }
    } catch (e) {
      _errorMessage = 'Błąd transkrypcji odpowiedzi: $e';
      _boardAnswers[_currentBoardQuestionIndex] = 'Błąd transkrypcji. Wpisz swoją odpowiedź tutaj ręcznie.';
    } finally {
      _isTranscribingBoardAnswer = false;
      notifyListeners();
    }
  }

  void updateBoardAnswer(int index, String text) {
    if (index >= 0 && index < _boardAnswers.length) {
      _boardAnswers[index] = text;
      notifyListeners();
    }
  }

  void setBoardQuestionIndex(int index) {
    _currentBoardQuestionIndex = index;
    notifyListeners();
  }

  // --- Step 4: Final Evaluation ---
  Future<void> submitForEvaluation() async {
    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_examSet == null) throw Exception('Brak aktywnego zestawu.');
      if (_boardQuestions.length < 2) throw Exception('Brak pytań komisji.');

      // Combine board answers into one string as expected by the backend EvaluationRequest
      final combinedBoardAnswers = 'Odpowiedź na Pytanie 1: ${_boardAnswers[0]}\n\nOdpowiedź na Pytanie 2: ${_boardAnswers[1]}';

      final result = await _apiService.evaluateResponse(question1: _examSet!.question1.question, question2: _examSet!.question2.question, responseText: _monologueTranscript, examinationBoardQuestion1: _boardQuestions[0], examinationBoardQuestion2: _boardQuestions[1], examinationBoardAnswers: combinedBoardAnswers);

      _evaluationResult = result;
    } catch (e) {
      _errorMessage = 'Nie udało się uzyskać oceny z serwera: $e';
    } finally {
      _isEvaluating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _prepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
