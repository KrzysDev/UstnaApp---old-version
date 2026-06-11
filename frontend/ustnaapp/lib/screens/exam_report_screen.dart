import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';

class ExamReportScreen extends StatefulWidget {
  const ExamReportScreen({super.key});

  @override
  State<ExamReportScreen> createState() => _ExamReportScreenState();
}

class _ExamReportScreenState extends State<ExamReportScreen> {
  int _tipIndex = 0;
  Timer? _tipTimer;
  final List<String> _maturaTips = [
    'Komisja ocenia Twoje wypowiedzi w 4 kryteriach: merytoryka, kompozycja, rozmowa i język.',
    'Błąd kardynalny to nieznajomość treści lektury obowiązkowej i skutkuje przyznaniem 0 punktów z całego zadania.',
    'Na maturze ustnej musisz zdobyć minimum 9 na 30 punktów (30%), aby zdać.',
    'Spójność wypowiedzi jest kluczowa — upewnij się, że Twoja prezentacja ma jasny wstęp, rozwinięcie i zakończenie.',
    'Podczas rozmowy z komisją staraj się odpowiadać wyczerpująco i unikać odpowiedzi jednozdaniowych.',
  ];

  @override
  void initState() {
    super.initState();
    // Rotate tips during long AI evaluation call
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _tipIndex = (_tipIndex + 1) % _maturaTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExamProvider>(context);

    // 1. Loading screen during evaluation
    if (provider.isEvaluating) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C0E12),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880)),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'AI Egzaminator ocenia egzamin...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Przesłano transkrypcję monologu i rozmowy. RAG analizuje bazę wiedzy pod kątem kryteriów CKE.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF8B95A5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Rotational Study Tip Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E232A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFC5A880).withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFC5A880), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Porada Maturalna',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFC5A880),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _maturaTips[_tipIndex],
                          key: ValueKey<int>(_tipIndex),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Error screen
    if (provider.errorMessage != null && provider.evaluationResult == null) {
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
                  'Błąd generowania oceny',
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
                  onPressed: () => provider.submitForEvaluation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A880),
                    foregroundColor: const Color(0xFF1E232A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Spróbuj ponownie'),
                ),
                TextButton(
                  onPressed: () {
                    provider.resetExam();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Anuluj i wyjdź', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = provider.evaluationResult;
    if (result == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0E12),
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880))),
        ),
      );
    }

    // Math metrics
    final scorePercent = result.score;
    final scorePoints = (scorePercent * 30) ~/ 100;
    final isPassed = scorePercent >= 30; // 30% or 9/30 points required to pass
    final accentColor = isPassed ? const Color(0xFF4EAD77) : const Color(0xFFE55C5C);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Krok 4 z 4: Wyniki Symulacji',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Display Card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1E232A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Circular Rating Visual
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          value: scorePercent / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$scorePercent%',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$scorePoints / 30 pkt',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFF8B95A5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Pass Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isPassed ? 'EGZAMIN ZDANY' : 'EGZAMIN NIEZDANY',
                      style: GoogleFonts.outfit(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // AI Egzaminator Summary Evaluation
            Text(
              'Uzasadnienie Komisji',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E232A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: Text(
                result.summary,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Errors List Section
            Text(
              'Zarejestrowane Błędy i Uwagi',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            result.errors.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4EAD77).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4EAD77).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF4EAD77), size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Świetna robota!',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'AI nie wykryło poważniejszych błędów merytorycznych, kardynalnych ani kompozycyjnych w Twojej wypowiedzi.',
                                style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.errors.length,
                    itemBuilder: (context, index) {
                      final error = result.errors[index];
                      final isCardinal = error.errorType.toLowerCase().contains('kardynaln');
                      final errorColor = isCardinal ? const Color(0xFFE55C5C) : const Color(0xFFE2A03F);
                      
                      return Card(
                        color: const Color(0xFF1E232A),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: errorColor.withOpacity(0.15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCardinal ? Icons.cancel_outlined : Icons.warning_amber_rounded,
                                    color: errorColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    error.errorType,
                                    style: GoogleFonts.outfit(
                                      color: errorColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.whenIsOccurring,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF8B95A5),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 40),

            // Back to Main Menu button
            ElevatedButton(
              onPressed: () {
                provider.resetExam();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5A880),
                foregroundColor: const Color(0xFF1E232A),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Powrót do menu głównego',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
