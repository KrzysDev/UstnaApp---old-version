import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'questions_list_screen.dart';
import 'exam_preparation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showSettingsDialog(BuildContext context, ExamProvider provider) {
    final controller = TextEditingController(text: provider.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E232A),
          title: Text(
            'Ustawienia serwera API',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adres URL backendu FastAPI:', style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 13)),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF161A22),
                  hintText: 'http://10.0.2.2:8000/api',
                  hintStyle: const TextStyle(color: Colors.white30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFC5A880)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Anuluj', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            ),
            ElevatedButton(
              onPressed: () {
                provider.updateBaseUrl(controller.text);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF1E232A),
                    content: Text('Zaktualizowano URL API na: ${controller.text}', style: GoogleFonts.outfit(color: const Color(0xFFC5A880))),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC5A880), foregroundColor: const Color(0xFF1E232A)),
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'UstnaApp',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () => _showSettingsDialog(context, examProvider),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background soft glow
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFC5A880).withOpacity(0.04), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section header
                Text(
                  'Rozpocznij Naukę',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),

                // 1. Sim Exam Button (Primary CTA)
                GestureDetector(
                  onTap: () async {
                    examProvider.resetExam();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamPreparationScreen()));
                    await examProvider.drawSetOfQuestions();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDCC19A), Color(0xFFC5A880)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: const Color(0xFFC5A880).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Symulacja Egzaminu',
                                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF12161A)),
                              ),
                              const SizedBox(height: 8),
                              Text('Wylosuj pytania (jawne + niejawne z obrazem/wierszem), zaprezentuj wypowiedź i porozmawiaj z komisją.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF12161A).withOpacity(0.8), height: 1.4)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF12161A).withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded, size: 36, color: Color(0xFF12161A)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Browse Public Questions Button (Secondary)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuestionsListScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E232A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lista Pytań Jawnych',
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text('Przejrzyj listę pytań jawnych CKE opublikowanych na rok 2026 i przećwicz ich tematykę.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF8B95A5), height: 1.4)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                          child: const Icon(Icons.format_list_bulleted_rounded, size: 28, color: Color(0xFFC5A880)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
