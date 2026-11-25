import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── C-2: flutter_secure_storage replaces SharedPreferences for tokens ──────
// ── C-3: signInWithSocialAccount (deterministic hash password) REMOVED ─────
// ── H-1: Token refresh + expiry check added ───────────────────────────────
// ── H-2: All HTTP calls have explicit timeouts ────────────────────────────

/// User model returned by InsForge BaaS
class InsForgeUser {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool emailVerified;
  final List<String> providers;
  final Map<String, dynamic> metadata;

  const InsForgeUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.emailVerified = false,
    this.providers = const ['email'],
    this.metadata = const {},
  });

  factory InsForgeUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final providersList = (json['providers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['email'];

    return InsForgeUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: profile['name']?.toString() ??
          json['name']?.toString() ??
          (json['email']?.toString().split('@').first ?? 'Explorer'),
      avatarUrl:
          profile['avatar_url']?.toString() ?? profile['avatar']?.toString(),
      emailVerified: json['emailVerified'] == true,
      providers: providersList,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'emailVerified': emailVerified,
      'providers': providers,
      'metadata': metadata,
    };
  }
}

/// Authentication response wrapper
class InsForgeAuthResult {
  final bool isSuccess;
  final InsForgeUser? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  const InsForgeAuthResult({
    required this.isSuccess,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  factory InsForgeAuthResult.success({
    required InsForgeUser user,
    required String accessToken,
    String? refreshToken,
  }) {
    return InsForgeAuthResult(
      isSuccess: true,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  factory InsForgeAuthResult.failure(String message) {
    return InsForgeAuthResult(isSuccess: false, errorMessage: message);
  }
}

/// InsForge Authentication Service connected to InsForge BaaS backend.
///
/// Security hardening applied (audit 2026-11-25):
/// • Access & refresh tokens stored in [FlutterSecureStorage] (Keychain /
///   Android Keystore) — NOT plain SharedPreferences.
/// • Removed `signInWithSocialAccount` which derived passwords from email
///   hash — trivially guessable and exploitable for account takeover.
/// • All HTTP requests carry explicit 15-second timeouts.
/// • Token refresh attempted on session restore when access token is expired.
class InsForgeAuthService {
  InsForgeAuthService._();
  static final InsForgeAuthService instance = InsForgeAuthService._();

  /// InsForge Project Endpoints & Keys
  static const String baseUrl = 'https://tvf24g8r.us-east.insforge.app';
  static const String anonKey =
      'anon_4ac1cdd3569c8ba96ee190681daac2c8e6f773475692bd59bb4a0365e6c09aae';
  static const String defaultRedirectUri =
      'https://tvf24g8r.us-east.insforge.app/oauth/callback';

  static const Duration _timeout = Duration(seconds: 15);

  // ── C-2: Secure storage for tokens ──────────────────────────────────────
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Secure keys for tokens
  static const String _keyAccessToken  = 'hela_secure_access_token_v1';
  static const String _keyRefreshToken = 'hela_secure_refresh_token_v1';
  static const String _keyTokenExpiry  = 'hela_secure_token_expiry_v1';

  // Non-sensitive user profile stays in SharedPreferences (no PII beyond name/email)
  static const String _keyUserData = 'insforge_user_data';

  InsForgeUser? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  InsForgeUser? get currentUser  => _currentUser;
  String?       get accessToken  => _accessToken;
  String?       get refreshToken => _refreshToken;
  bool          get isAuthenticated =>
      _accessToken != null && _currentUser != null;

  Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_accessToken ?? anonKey}',
      };

  // ── H-1: Restore session with token refresh ──────────────────────────────

  /// Restores session on app startup.
  /// Attempts a token refresh if the stored access token looks expired.
  Future<InsForgeUser?> restoreSession() async {
    try {
      _accessToken  = await _secureStorage.read(key: _keyAccessToken);
      _refreshToken = await _secureStorage.read(key: _keyRefreshToken);
      final expiryStr = await _secureStorage.read(key: _keyTokenExpiry);

      final prefs   = await SharedPreferences.getInstance();
      final rawUser = prefs.getString(_keyUserData);

      if (_accessToken == null || rawUser == null) return null;

      _currentUser = InsForgeUser.fromJson(
        jsonDecode(rawUser) as Map<String, dynamic>,
      );

      // Check expiry and try to refresh
      if (_isTokenExpired(expiryStr)) {
        final refreshed = await _attemptTokenRefresh();
        if (!refreshed) {
          // Refresh failed — clear session so the app prompts sign-in
          await signOut();
          return null;
        }
      }

      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  bool _isTokenExpired(String? expiryIso) {
    if (expiryIso == null) return false; // No expiry stored → assume valid
    final expiry = DateTime.tryParse(expiryIso);
    if (expiry == null) return false;
    // Treat as expired 60 seconds before actual expiry for safety margin
    return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 60)));
  }

  /// Attempts to exchange the stored refresh token for a new access token.
  /// Returns true if successful.
  Future<bool> _attemptTokenRefresh() async {
    if (_refreshToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/api/auth/sessions/refresh');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $anonKey'},
            body: jsonEncode({'refreshToken': _refreshToken}),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccess  = body['accessToken']?.toString();
        final newRefresh = body['refreshToken']?.toString();
        final expiresIn  = (body['expiresIn'] as num?)?.toInt(); // seconds

        if (newAccess != null && newAccess.isNotEmpty) {
          _accessToken  = newAccess;
          if (newRefresh != null) _refreshToken = newRefresh;

          await _secureStorage.write(key: _keyAccessToken, value: _accessToken!);
          if (newRefresh != null) {
            await _secureStorage.write(key: _keyRefreshToken, value: newRefresh);
          }
          if (expiresIn != null) {
            final expiry = DateTime.now().add(Duration(seconds: expiresIn));
            await _secureStorage.write(
                key: _keyTokenExpiry, value: expiry.toIso8601String());
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<InsForgeAuthResult> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/users?client_type=mobile');
      final payload = {
        'email': email.trim(),
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      };

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $anonKey'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout); // H-2

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = InsForgeUser.fromJson(body['user'] as Map<String, dynamic>);
        final accessToken  = body['accessToken']?.toString();
        final refreshToken = body['refreshToken']?.toString();
        final expiresIn    = (body['expiresIn'] as num?)?.toInt();

        if (accessToken != null) {
          await _saveSession(user, accessToken, refreshToken, expiresIn: expiresIn);
          return InsForgeAuthResult.success(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        } else if (body['requireEmailVerification'] == true) {
          return InsForgeAuthResult.failure(
              'Account created! Please check your email for the verification code.');
        }
      }

      return InsForgeAuthResult.failure(
          _extractErrorMessage(body, 'Sign up failed'));
    } catch (e) {
      return InsForgeAuthResult.failure('Network connection error. Please try again.');
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<InsForgeAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/sessions?client_type=mobile');
      final payload = {
        'method': 'password',
        'email': email.trim(),
        'password': password,
      };

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $anonKey'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout); // H-2

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = InsForgeUser.fromJson(body['user'] as Map<String, dynamic>);
        final accessToken  = body['accessToken']?.toString() ?? '';
        final refreshToken = body['refreshToken']?.toString();
        final expiresIn    = (body['expiresIn'] as num?)?.toInt();

        await _saveSession(user, accessToken, refreshToken, expiresIn: expiresIn);
        return InsForgeAuthResult.success(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      return InsForgeAuthResult.failure(
          _extractErrorMessage(body, 'Invalid credentials'));
    } catch (e) {
      return InsForgeAuthResult.failure('Network connection error. Please try again.');
    }
  }

  // ── PKCE OAuth (Google / GitHub) ──────────────────────────────────────────
  // C-3: signInWithSocialAccount (email-hash password) has been REMOVED.
  // Use initiateOAuth → open authUrl in browser → exchangeOAuthCode instead.

  /// Initiates PKCE OAuth Flow (Google / GitHub).
  /// Returns the authorization URL to open and the generated `codeVerifier`.
  Future<Map<String, String>?> initiateOAuth({
    required String provider,
    String redirectUri = defaultRedirectUri,
  }) async {
    try {
      final codeVerifier  = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      final uri = Uri.parse(
        '$baseUrl/api/auth/oauth/$provider'
        '?redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&code_challenge=${Uri.encodeComponent(codeChallenge)}',
      );

      final response = await http
          .get(uri, headers: {'Authorization': 'Bearer $anonKey'})
          .timeout(_timeout); // H-2

      if (response.statusCode == 200) {
        final body    = jsonDecode(response.body);
        final authUrl = body['authUrl']?.toString();
        if (authUrl != null && authUrl.isNotEmpty) {
          return {'authUrl': authUrl, 'codeVerifier': codeVerifier};
        }
      }
    } catch (_) {}
    return null;
  }

  /// Exchanges an InsForge authorization code from OAuth callback for session tokens.
  Future<InsForgeAuthResult> exchangeOAuthCode({
    required String code,
    required String codeVerifier,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/oauth/exchange?client_type=mobile');
      final payload = {'code': code, 'code_verifier': codeVerifier};

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $anonKey'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout); // H-2

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = InsForgeUser.fromJson(body['user'] as Map<String, dynamic>);
        final accessToken  = body['accessToken']?.toString() ?? '';
        final refreshToken = body['refreshToken']?.toString();
        final expiresIn    = (body['expiresIn'] as num?)?.toInt();

        await _saveSession(user, accessToken, refreshToken, expiresIn: expiresIn);
        return InsForgeAuthResult.success(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      return InsForgeAuthResult.failure(
          _extractErrorMessage(body, 'OAuth code exchange failed'));
    } catch (e) {
      return InsForgeAuthResult.failure('Network connection error. Please try again.');
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (_accessToken != null) {
        final uri = Uri.parse('$baseUrl/api/auth/sessions/current');
        await http
            .delete(uri, headers: _baseHeaders)
            .timeout(const Duration(seconds: 5),
                onTimeout: () => http.Response('', 200));
      }
    } catch (_) {
      // Silent cleanup
    } finally {
      _currentUser  = null;
      _accessToken  = null;
      _refreshToken = null;

      // Clear secure token storage
      try {
        await _secureStorage.delete(key: _keyAccessToken);
        await _secureStorage.delete(key: _keyRefreshToken);
        await _secureStorage.delete(key: _keyTokenExpiry);
      } catch (_) {}

      // Clear profile cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_keyUserData);
      } catch (_) {}
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _saveSession(
    InsForgeUser user,
    String accessToken,
    String? refreshToken, {
    int? expiresIn,
  }) async {
    _currentUser  = user;
    _accessToken  = accessToken;
    _refreshToken = refreshToken;

    // Store tokens in platform-backed secure storage (C-2)
    try {
      await _secureStorage.write(key: _keyAccessToken, value: accessToken);
      if (refreshToken != null) {
        await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
      }
      if (expiresIn != null) {
        final expiry = DateTime.now().add(Duration(seconds: expiresIn));
        await _secureStorage.write(
            key: _keyTokenExpiry, value: expiry.toIso8601String());
      }
    } catch (_) {}

    // Store non-sensitive profile in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  String _generateCodeVerifier() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final random = Random.secure();
    return List.generate(64, (i) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateCodeChallenge(String verifier) {
    final bytes  = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  String _extractErrorMessage(dynamic body, String defaultMessage) {
    if (body is Map) {
      if (body['message'] != null) return body['message'].toString();
      if (body['error'] != null)   return body['error'].toString();
    }
    return defaultMessage;
  }
}
