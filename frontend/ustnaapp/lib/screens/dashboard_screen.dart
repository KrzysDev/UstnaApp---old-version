import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import 'questions_list_screen.dart';
import 'exam_preparation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Po zalogowaniu (wejsciu na dashboard) wymuszamy odswiezenie
    // liczby darmowych prob z Supabase, bo provider mogl zostac
    // zainicjalizowany zanim uzytkownik byl zalogowany.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ExamProvider>().refreshFreeTries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final bool canStart = examProvider.canStartExam;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'UstnaApp',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
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
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC5A880).withOpacity(0.04),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // FREE TRIES INFO (if less than 3)
          Positioned(
            top: 80,
            right: 16,
            child: Selector<ExamProvider, int>(
              selector: (_, p) => p.freeTries,
              builder: (_, tries, __) {
                if (tries >= 3) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE55C5C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE55C5C).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$tries próba(y) free',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (examProvider.freeTriesError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE55C5C).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE55C5C).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFE55C5C),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Błąd bazy danych: ${examProvider.freeTriesError}',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFFE55C5C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Section header
                    Text(
                      'Rozpocznij Naukę',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 1. Sim Exam Button
                    Opacity(
                      opacity: canStart ? 1.0 : 0.45,
                      child: GestureDetector(
                        onTap: () async {
                          if (!examProvider.canStartExam) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Brak darmowych prób. Wykorzystałeś już wszystkie podejścia do egzaminu.',
                                ),
                                backgroundColor: Color(0xFFE55C5C),
                              ),
                            );
                            return;
                          }

                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1E232A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: const Color(
                                    0xFFC5A880,
                                  ).withOpacity(0.2),
                                ),
                              ),
                              title: Text(
                                'Rozpocząć symulację?',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              content: Text(
                                'Rozpoczęcie symulacji egzaminu spowoduje pobranie 1 darmowej próby. Po wyjściu z próby nie da się jej odzyskać.',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF8B95A5),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'Anuluj',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC5A880),
                                    foregroundColor: const Color(0xFF1E232A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Rozpocznij',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          examProvider.resetExam();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExamPreparationScreen(),
                            ),
                          );

                          await examProvider.drawSetOfQuestions();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFDCC19A), Color(0xFFC5A880)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC5A880).withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Symulacja Egzaminu',
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF12161A),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      canStart
                                          ? 'Wylosuj pytania (jawne + niejawne z obrazem/wierszem), zaprezentuj wypowiedź i porozmawiaj z komisją.'
                                          : 'Brak darmowych prób. Wykorzystałeś już wszystkie podejścia do egzaminu.',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: const Color(
                                          0xFF12161A,
                                        ).withOpacity(0.8),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF12161A,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  canStart
                                      ? Icons.play_arrow_rounded
                                      : Icons.lock_outline_rounded,
                                  size: 32,
                                  color: const Color(0xFF12161A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. Questions List Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QuestionsListScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E232A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lista Pytań Jawnych',
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'Przejrzyj listę pytań jawnych CKE opublikowanych na rok 2026 i przećwicz ich tematykę.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: const Color(0xFF8B95A5),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.format_list_bulleted_rounded,
                                size: 26,
                                color: Color(0xFFC5A880),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
