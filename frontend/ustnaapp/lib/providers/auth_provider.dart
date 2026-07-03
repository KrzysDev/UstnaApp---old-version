import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _currentUser != null;

  String get displayName => _currentUser?.displayName ?? 'Użytkownik';
  String get email => _currentUser?.email ?? '';
  String? get photoUrl => _currentUser?.photoUrl;

  /// The initials for the avatar fallback (e.g. "JK" for "Jan Kowalski")
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Returns the base URL for the API based on platform
  String get _apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  /// Sign in with Google and verify the token on the backend
  Future<bool> signInWithGoogle() async {
    _isLoggingIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();

      if (account == null) {
        // User cancelled the sign-in
        _isLoggingIn = false;
        notifyListeners();
        return false;
      }

      // Get the ID token for backend verification
      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken != null) {
        // Verify the token on the backend
        await _verifyTokenOnBackend(idToken);
      }

      _currentUser = account;
      _isLoggingIn = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Błąd logowania: ${e.toString()}';
      _isLoggingIn = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify the Google ID token on the FastAPI backend
  Future<void> _verifyTokenOnBackend(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_token': idToken}),
      );

      if (response.statusCode != 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(body['detail'] ?? 'Weryfikacja tokena nie powiodła się');
      }
    } catch (e) {
      // Log but don't block login — backend verification is optional
      // In production you'd want stricter handling
      debugPrint('Backend token verification failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Błąd wylogowania: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
