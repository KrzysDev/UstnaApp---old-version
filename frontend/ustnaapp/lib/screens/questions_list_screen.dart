import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';

class QuestionsListScreen extends StatefulWidget {
  const QuestionsListScreen({super.key});

  @override
  State<QuestionsListScreen> createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  late Future<List<String>> _questionsFuture;
  List<String> _allQuestions = [];
  List<String> _filteredQuestions = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ExamProvider>(context, listen: false);
    _questionsFuture = ApiService(baseUrl: provider.baseUrl).getPublicQuestions();
  }

  void _filterQuestions(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredQuestions = List.from(_allQuestions);
      });
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    // Check if query is a number
    final intQuery = int.tryParse(lowerQuery);

    setState(() {
      if (intQuery != null) {
        // Find question by 1-based index
        if (intQuery > 0 && intQuery <= _allQuestions.length) {
          _filteredQuestions = [_allQuestions[intQuery - 1]];
        } else {
          _filteredQuestions = [];
        }
      } else {
        // Search by substring
        _filteredQuestions = _allQuestions.where((q) => q.toLowerCase().contains(lowerQuery)).toList();
      }
    });
  }

  void _showQuestionDetail(BuildContext context, int indexInAll, String questionText) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E232A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(28.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFC5A880).withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
                        child: Text(
                          'Pytanie Jawne #${indexInAll + 1}',
                          style: GoogleFonts.outfit(color: const Color(0xFFC5A880), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Full Question Text
                  Text(
                    questionText,
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, height: 1.6, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 20),

                  // Guidelines / Tips header
                  Text(
                    'Wskazówki Egzaminacyjne',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFC5A880)),
                  ),
                  const SizedBox(height: 12),

                  _buildTipRow('Lektura obowiązkowa', 'Omów zagadnienie na podstawie wskazanej w pytaniu lektury obowiązkowej. Musisz wykazać się dobrą znajomością fabuły i bohaterów (uwaga na błędy kardynalne!).'),
                  const SizedBox(height: 12),
                  _buildTipRow('Przywołanie kontekstu', 'Zadbaj o właściwy kontekst (np. historycznoliteracki, biograficzny, filozoficzny lub kulturowy) i wyraźnie połącz go z głównym tematem wypowiedzi.'),
                  const SizedBox(height: 12),
                  _buildTipRow('Struktura wypowiedzi', 'Zorganizuj prezentację logicznie: sformułuj wstęp (z tezą/hipotezą), rozwiń argumenty i podsumuj wypowiedź trafnymi wnioskami.'),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTipRow(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $title',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9)),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(desc, style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF8B95A5), height: 1.4)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Pytania Jawne CKE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == snapshot.connectionState && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC5A880))));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Nie można załadować pytań',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upewnij się, że serwer FastAPI działa i adres URL w ustawieniach jest poprawny.\n\nSzczegóły: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: const Color(0xFF8B95A5), fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Brak pytań w bazie.', style: GoogleFonts.outfit(color: const Color(0xFF8B95A5))),
            );
          }

          // Data loaded successfully
          if (_allQuestions.isEmpty) {
            _allQuestions = snapshot.data!;
            _filteredQuestions = List.from(_allQuestions);
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterQuestions,
                  decoration: InputDecoration(
                    hintText: 'Wyszukaj po numerze (np. 12) lub treści...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white60),
                            onPressed: () {
                              _searchController.clear();
                              _filterQuestions('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF1E232A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),

              // Questions List
              Expanded(
                child: _filteredQuestions.isEmpty
                    ? Center(
                        child: Text('Nie znaleziono pasujących pytań.', style: GoogleFonts.outfit(color: const Color(0xFF8B95A5))),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredQuestions.length,
                        itemBuilder: (context, index) {
                          final questionText = _filteredQuestions[index];
                          // Find original 1-based index
                          final originalIndex = _allQuestions.indexOf(questionText);

                          return Card(
                            color: const Color(0xFF1E232A),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.02)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showQuestionDetail(context, originalIndex, questionText),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Index Circle badge
                                    Container(
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: const Color(0xFFC5A880).withOpacity(0.1), shape: BoxShape.circle),
                                      child: Text(
                                        '${originalIndex + 1}',
                                        style: GoogleFonts.outfit(color: const Color(0xFFC5A880), fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Question snippet text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            questionText,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.outfit(fontSize: 15, color: Colors.white, height: 1.4, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Pokaż szczegóły i wskazówki',
                                            style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFFC5A880), fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right_rounded, color: Colors.white30),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
