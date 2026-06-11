import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'exam_monologue_screen.dart';

class ExamPreparationScreen extends StatefulWidget {
  const ExamPreparationScreen({super.key});

  @override
  State<ExamPreparationScreen> createState() => _ExamPreparationScreenState();
}

class _ExamPreparationScreenState extends State<ExamPreparationScreen> {
  Uint8List? _cachedImage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<ExamProvider>();
    final imageBase64 = provider.examSet?.question2.imageBase64;

    if (imageBase64 != null && _cachedImage == null) {
      try {
        _cachedImage = base64Decode(imageBase64);
      } catch (_) {
        _cachedImage = null;
      }
    }
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();

    // LOADING
    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFC5A880)))),
      );
    }

    // ERROR
    if (provider.errorMessage != null && provider.examSet == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text('Błąd losowania zestawu', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: const Color(0xFF8B95A5)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => provider.drawSetOfQuestions(), child: const Text('Spróbuj ponownie')),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Krok 1 z 4: Przygotowanie', style: GoogleFonts.outfit(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white60),
            onPressed: () {
              provider.resetExam();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TIMER - ONLY THIS REBUILDS
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E232A), borderRadius: BorderRadius.circular(20)),
            child: Selector<ExamProvider, int>(
              selector: (_, p) => p.preparationTime,
              builder: (_, time, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFC5A880)),
                    const SizedBox(width: 12),
                    Text(
                      _formatDuration(time),
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionCard(title: 'Zadanie 1: Pytanie Jawne', content: examSet.question1.question),
                  const SizedBox(height: 24),
                  _buildQuestionCard(title: 'Zadanie 2: Pytanie Niejawne', content: examSet.question2.question, imageBytes: _cachedImage),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  provider.skipPreparation();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamMonologueScreen()));
                },
                child: const Text('Zakończ przygotowanie'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({required String title, required String content, Uint8List? imageBytes}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1E232A), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(color: const Color(0xFFC5A880))),
          const SizedBox(height: 12),
          Text(content, style: GoogleFonts.outfit(color: Colors.white, height: 1.5)),
          if (imageBytes != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ],
        ],
      ),
    );
  }
}
