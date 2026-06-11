import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'exam_report_screen.dart';

class ExamBoardScreen extends StatefulWidget {
  const ExamBoardScreen({super.key});

  @override
  State<ExamBoardScreen> createState() => _ExamBoardScreenState();
}

class _ExamBoardScreenState extends State<ExamBoardScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _answerController;
  late AnimationController _pulseController;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-populate text field with current answer when index changes
    final provider = Provider.of<ExamProvider>(context);
    final currentAnswer = provider.boardAnswers[provider.currentBoardQuestionIndex];
    if (_answerController.text != currentAnswer && !provider.isTranscribingBoardAnswer) {
      _answerController.text = currentAnswer;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _pulseController.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _recordSeconds = 0;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void _stopTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
  }

  String _formatRecordTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _handleRecording(ExamProvider provider) async {
    if (provider.isRecordingBoardAnswer) {
      _stopTimer();
      _pulseController.stop();
      await provider.stopBoardAnswerRecording();
      _answerController.text = provider.boardAnswers[provider.currentBoardQuestionIndex];
    } else {
      _startTimer();
      _pulseController.repeat(reverse: true);
      await provider.startBoardAnswerRecording();
    }
  }

  void _handleNextOrSubmit(ExamProvider provider) async {
    // Save current text field state
    provider.updateBoardAnswer(provider.currentBoardQuestionIndex, _answerController.text);

    if (provider.currentBoardQuestionIndex == 0) {
      // Move to second question
      provider.setBoardQuestionIndex(1);
      _answerController.text = provider.boardAnswers[1];
    } else {
      // Proceed to evaluation report
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ExamReportScreen()),
      );
      await provider.submitForEvaluation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExamProvider>(context);
    final qIndex = provider.currentBoardQuestionIndex;
    final questions = provider.boardQuestions;
    
    // Safety check in case questions are empty
    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0E12),
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880))),
        ),
      );
    }

    final currentQuestionText = questions[qIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Krok 3 z 4: Rozmowa z komisją',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white60),
            onPressed: () {
              provider.resetExam();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A880),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: qIndex == 1 ? const Color(0xFFC5A880) : Colors.white12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Question Header Tag
                Text(
                  'KOMISJA EGZAMINACYJNA • PYTANIE ${qIndex + 1} Z 2',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFC5A880),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Question Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E232A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                  child: Text(
                    currentQuestionText,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Voice Recording Area or Text Input
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_answerController.text.isEmpty && !provider.isTranscribingBoardAnswer) ...[
                        Text(
                          'Nagraj swoją odpowiedź',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Wciśnij mikrofon i odpowiedz na powyższe pytanie komisji.',
                          style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        // Pulsating Mic Button
                        GestureDetector(
                          onTap: () => _handleRecording(provider),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: provider.isRecordingBoardAnswer
                                      ? Colors.redAccent.withOpacity(0.1 + (_pulseController.value * 0.15))
                                      : const Color(0xFFC5A880).withOpacity(0.05),
                                  border: Border.all(
                                    color: provider.isRecordingBoardAnswer
                                        ? Colors.redAccent.withOpacity(0.5 + (_pulseController.value * 0.5))
                                        : const Color(0xFFC5A880).withOpacity(0.3),
                                    width: 3.5,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: provider.isRecordingBoardAnswer
                                          ? Colors.redAccent
                                          : const Color(0xFFC5A880),
                                    ),
                                    child: Icon(
                                      provider.isRecordingBoardAnswer
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded,
                                      color: const Color(0xFF1E232A),
                                      size: 32,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Board recording timer
                        if (provider.isRecordingBoardAnswer)
                          Text(
                            _formatRecordTime(_recordSeconds),
                            style: GoogleFonts.outfit(
                              color: Colors.redAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ] else if (provider.isTranscribingBoardAnswer) ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Trwa transkrypcja odpowiedzi...',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        // Editable Text Box for transcript
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transkrypcja Twojej odpowiedzi:',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF8B95A5),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _handleRecording(provider),
                                    icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFC5A880)),
                                    label: Text(
                                      'Nagraj ponownie',
                                      style: GoogleFonts.outfit(color: const Color(0xFFC5A880), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TextField(
                                  controller: _answerController,
                                  maxLines: null,
                                  expands: true,
                                  style: const TextStyle(color: Colors.white, height: 1.5),
                                  decoration: InputDecoration(
                                    hintText: 'Wpisz lub nagraj swoją odpowiedź...',
                                    hintStyle: const TextStyle(color: Colors.white30),
                                    filled: true,
                                    fillColor: const Color(0xFF1E232A),
                                    contentPadding: const EdgeInsets.all(18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(color: Color(0xFFC5A880), width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Navigation Buttons
          if (_answerController.text.isNotEmpty && !provider.isTranscribingBoardAnswer && !provider.isRecordingBoardAnswer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () => _handleNextOrSubmit(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5A880),
                      foregroundColor: const Color(0xFF1E232A),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          qIndex == 0 ? 'Następne pytanie' : 'Przejdź do oceny egzaminu',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          qIndex == 0 ? Icons.arrow_forward_rounded : Icons.auto_awesome_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
