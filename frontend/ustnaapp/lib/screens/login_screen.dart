import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleStart() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
  }

  Future<void> _nativeGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '169631831364-pkqujs7l48alujgjs3rohd370jn3enmq.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Logowanie zostało przerwane';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Brak ID Tokena.';
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session != null && mounted) {
        _handleStart();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd logowania: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF161A22), Color(0xFF0C0E12)]),
            ),
          ),

          // Subtle Gold Glow in Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFC5A880).withOpacity(0.08), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Logo Icon Container
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E232A),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFC5A880).withOpacity(0.2), width: 1.5),
                          boxShadow: [BoxShadow(color: const Color(0xFFC5A880).withOpacity(0.05), blurRadius: 20, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.menu_book_rounded, size: 72, color: Color(0xFFC5A880)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App Title
                    Text(
                      'UstnaApp',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Twój asystent maturalny',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF8B95A5), fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 48),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E232A).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow(context, Icons.check_circle_outline_rounded, 'Baza pytań jawnych', 'Przeglądaj oficjalne pytania CKE z języka polskiego.'),
                          const Divider(height: 24, color: Colors.white10),
                          _buildFeatureRow(context, Icons.record_voice_over_rounded, 'Symulacja egzaminu ustnego', 'Wylosuj zestaw, odpowiedz do mikrofonu i poczuj atmosferę matury.'),
                          const Divider(height: 24, color: Colors.white10),
                          _buildFeatureRow(context, Icons.auto_awesome_rounded, 'Ocena przez sztuczną inteligencję', 'Otrzymaj pełny raport z punktacją per kryterium i wykazem błędów.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Start Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5A880),
                        foregroundColor: const Color(0xFF1E232A),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Kontynuuj jako gość', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                    
                    // Google Login Button
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _nativeGoogleSignIn,
                      icon: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.login, color: Colors.white),
                      label: Text('Zaloguj przez Google', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC5A880)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFC5A880), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF8B95A5))),
            ],
          ),
        ),
      ],
    );
  }
}
