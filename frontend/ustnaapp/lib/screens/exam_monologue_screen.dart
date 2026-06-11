import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'exam_board_screen.dart';

class ExamMonologueScreen extends StatefulWidget {
  const ExamMonologueScreen({super.key});

  @override
  State<ExamMonologueScreen> createState() => _ExamMonologueScreenState();
}

class _ExamMonologueScreenState extends State<ExamMonologueScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _transcriptController;
  late AnimationController _pulseController;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _transcriptController.dispose();
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
    if (provider.isRecordingMonologue) {
      _stopTimer();
      _pulseController.stop();
      await provider.stopMonologueRecording();
      // Update text field with newly received transcript
      _transcriptController.text = provider.monologueTranscript;
    } else {
      _startTimer();
      _pulseController.repeat(reverse: true);
      await provider.startMonologueRecording();
    }
  }

  Future<void> _navigateToBoardQuestions(ExamProvider provider) async {
    // Save transcript state if edited
    provider.updateMonologueTranscript(_transcriptController.text);
    
    // Show generating loading screen and execute
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880)),
          ),
        );
      },
    );

    await provider.generateBoardQuestions();
    
    if (mounted) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      if (provider.errorMessage != null) {
        // Show error bar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E232A),
            content: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        );
        provider.clearError();
      } else {
        // Go to board questions
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ExamBoardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExamProvider>(context);
    final examSet = provider.examSet!;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Krok 2 z 4: Monolog',
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
                // Quick Questions Accordion for reference
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      'Podgląd Twoich pytań',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFC5A880),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    iconColor: const Color(0xFFC5A880),
                    collapsedIconColor: const Color(0xFF8B95A5),
                    backgroundColor: const Color(0xFF1E232A),
                    collapsedBackgroundColor: const Color(0xFF1E232A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zadanie 1 (Jawne):',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              examSet.question1.question,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                            ),
                            const Divider(height: 20, color: Colors.white10),
                            Text(
                              'Zadanie 2 (Niejawne):',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              examSet.question2.question,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Main Monologue Recording Interface
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_transcriptController.text.isEmpty && !provider.isTranscribingMonologue) ...[
                        // Initial micro instruction
                        Text(
                          'Nagrywanie Wypowiedzi Monologowej',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Wciśnij mikrofon, aby rozpocząć nagrywanie wypowiedzi. Staraj się wyczerpać oba tematy w czasie 10 minut.',
                          style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 13, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Microphone Button with Ripple Pulse Animation
                        GestureDetector(
                          onTap: () => _handleRecording(provider),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: provider.isRecordingMonologue
                                      ? Colors.redAccent.withOpacity(0.1 + (_pulseController.value * 0.15))
                                      : const Color(0xFFC5A880).withOpacity(0.05),
                                  border: Border.all(
                                    color: provider.isRecordingMonologue
                                        ? Colors.redAccent.withOpacity(0.5 + (_pulseController.value * 0.5))
                                        : const Color(0xFFC5A880).withOpacity(0.3),
                                    width: 4,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: provider.isRecordingMonologue
                                          ? Colors.redAccent
                                          : const Color(0xFFC5A880),
                                    ),
                                    child: Icon(
                                      provider.isRecordingMonologue
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded,
                                      color: const Color(0xFF1E232A),
                                      size: 38,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recording Timer Text
                        if (provider.isRecordingMonologue)
                          Text(
                            _formatRecordTime(_recordSeconds),
                            style: GoogleFonts.outfit(
                              color: Colors.redAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                      ] else if (provider.isTranscribingMonologue) ...[
                        // Transcribing Loading Spinner
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Trwa transkrypcja nagrania...',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sztuczna inteligencja przetwarza Twój głos na tekst.',
                          style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 13),
                        ),
                      ] else ...[
                        // Editable Transcript Screen
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transkrypcja Twojej wypowiedzi:',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF8B95A5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _handleRecording(provider),
                                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFC5A880)),
                                    label: Text(
                                      'Nagraj ponownie',
                                      style: GoogleFonts.outfit(color: const Color(0xFFC5A880), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TextField(
                                  controller: _transcriptController,
                                  maxLines: null,
                                  expands: true,
                                  style: const TextStyle(color: Colors.white, height: 1.5),
                                  decoration: InputDecoration(
                                    hintText: 'Tutaj pojawi się transkrypcja Twojej wypowiedzi...',
                                    hintStyle: const TextStyle(color: Colors.white30),
                                    filled: true,
                                    fillColor: const Color(0xFF1E232A),
                                    contentPadding: const EdgeInsets.all(20),
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
          
          // Floating validation bar if recording is complete
          if (_transcriptController.text.isNotEmpty && !provider.isTranscribingMonologue && !provider.isRecordingMonologue)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () => _navigateToBoardQuestions(provider),
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
                          'Zatwierdź i przejdź do pytań komisji',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
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
