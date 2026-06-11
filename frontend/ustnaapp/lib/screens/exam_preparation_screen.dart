import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'exam_monologue_screen.dart';

class ExamPreparationScreen extends StatelessWidget {
  const ExamPreparationScreen({super.key});

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExamProvider>(context);

    // If loading, show elegant loading screen
    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880)),
              ),
              const SizedBox(height: 24),
              Text(
                'Losowanie pytań egzaminacyjnych...',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Pobieranie pytania jawnego i niejawnego z serwera',
                style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // If error, show retry button
    if (provider.errorMessage != null && provider.examSet == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Błąd losowania zestawu',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.drawSetOfQuestions(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A880),
                    foregroundColor: const Color(0xFF1E232A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Spróbuj ponownie'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Powrót', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final examSet = provider.examSet;
    if (examSet == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0E12),
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880))),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Krok 1 z 4: Przygotowanie',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white60),
            onPressed: () {
              provider.resetExam();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer Widget
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E232A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFC5A880).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFFC5A880), size: 28),
                const SizedBox(width: 12),
                Text(
                  _formatDuration(provider.preparationTime),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable questions list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question 1 (Public)
                  _buildQuestionCard(
                    title: 'Zadanie 1: Pytanie Jawne',
                    content: examSet.question1.question,
                  ),
                  const SizedBox(height: 24),

                  // Question 2 (Secret)
                  _buildQuestionCard(
                    title: 'Zadanie 2: Pytanie Niejawne',
                    content: examSet.question2.question,
                    questionType: examSet.question2.questionType,
                    imageBase64: examSet.question2.imageBase64,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Action bottom panel
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  provider.skipPreparation();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExamMonologueScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A880),
                  foregroundColor: const Color(0xFF1E232A),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Zakończ przygotowanie i zacznij wypowiedź',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required String content,
    String? questionType,
    String? imageBase64,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E232A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: const Color(0xFFC5A880),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Image drawing support
          if (questionType == 'image' && imageBase64 != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white.withOpacity(0.02),
                constraints: const BoxConstraints(maxHeight: 250),
                width: double.infinity,
                child: Image.memory(
                  base64Decode(imageBase64),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Nie udało się załadować grafiki do zadania.',
                        style: GoogleFonts.outfit(color: Colors.redAccent),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
