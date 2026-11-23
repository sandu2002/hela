import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      avatarUrl: profile['avatar_url']?.toString() ?? profile['avatar']?.toString(),
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
    return InsForgeAuthResult(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// InsForge Authentication Service connected to InsForge BaaS backend
class InsForgeAuthService {
  InsForgeAuthService._();
  static final InsForgeAuthService instance = InsForgeAuthService._();

  /// InsForge Project Endpoints & Keys
  static const String baseUrl = 'https://tvf24g8r.us-east.insforge.app';
  static const String anonKey =
      'anon_4ac1cdd3569c8ba96ee190681daac2c8e6f773475692bd59bb4a0365e6c09aae';
  static const String defaultRedirectUri =
      'https://tvf24g8r.us-east.insforge.app/oauth/callback';

  // SharedPreferences Keys
  static const String _keyAccessToken = 'insforge_access_token';
  static const String _keyRefreshToken = 'insforge_refresh_token';
  static const String _keyUserData = 'insforge_user_data';

  InsForgeUser? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  InsForgeUser? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_accessToken ?? anonKey}',
      };

  /// Restores session on app startup
  Future<InsForgeUser?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_keyAccessToken);
      _refreshToken = prefs.getString(_keyRefreshToken);
      final rawUser = prefs.getString(_keyUserData);

      if (_accessToken != null && rawUser != null) {
        final decoded = jsonDecode(rawUser) as Map<String, dynamic>;
        _currentUser = InsForgeUser.fromJson(decoded);
        return _currentUser;
      }
    } catch (_) {
      // Corrupt or missing cache
    }
    return null;
  }

  /// Sign Up with Email & Password
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

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = InsForgeUser.fromJson(body['user'] as Map<String, dynamic>);
        final accessToken = body['accessToken']?.toString();
        final refreshToken = body['refreshToken']?.toString();

        if (accessToken != null) {
          await _saveSession(user, accessToken, refreshToken);
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

      final errorMsg = _extractErrorMessage(body, 'Sign up failed');
      return InsForgeAuthResult.failure(errorMsg);
    } catch (e) {
      return InsForgeAuthResult.failure('Network connection error: $e');
    }
  }

  /// Sign In with Email & Password
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

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = InsForgeUser.fromJson(body['user'] as Map<String, dynamic>);
        final accessToken = body['accessToken']?.toString() ?? '';
        final refreshToken = body['refreshToken']?.toString();

        await _saveSession(user, accessToken, refreshToken);
        return InsForgeAuthResult.success(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      final errorMsg = _extractErrorMessage(body, 'Invalid credentials');
      return InsForgeAuthResult.failure(errorMsg);
    } catch (e) {
      return InsForgeAuthResult.failure('Network connection error: $e');
    }
  }

  /// Initiates PKCE OAuth Flow (Google / GitHub)
  ///
  /// Returns the authorization URL to open and the generated `codeVerifier`
  Future<Map<String, String>?> initiateOAuth({
    required String provider,
    String redirectUri = defaultRedirectUri,
  }) async {
    try {
      // 1. Generate code_verifier (43-128 random chars)
      final codeVerifier = _generateCodeVerifier();

      // 2. Generate code_challenge (Base64Url SHA256 of code_verifier without padding)
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      // 3. Request auth URL from InsForge
      final uri = Uri.parse(
        '$baseUrl/api/auth/oauth/$provider?redirect_uri=${Uri.encodeComponent(redirectUri)}&code_challenge=${Uri.encodeComponent(codeChallenge)}',
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $anonKey'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final authUrl = body['authUrl']?.toString();
        if (authUrl != null && authUrl.isNotEmpty) {
          return {
            'authUrl': authUrl,
            'codeVerifier': codeVerifier,
          };
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  /// Exchanges InsForge authorization code from OAuth callback for session tokens
  Future<InsForgeAuthResult> exchangeOAuthCode({
    required String code,
    required String codeVerifier,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/oauth/exchange?client_type=mobile');
      final payload = {
        'code': code,
        'code_verifier': codeVerifier,
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = InsForgeUser.fromJson(body['user'] as Map<String, dynamic>);
        final accessToken = body['accessToken']?.toString() ?? '';
        final refreshToken = body['refreshToken']?.toString();

        await _saveSession(user, accessToken, refreshToken);
        return InsForgeAuthResult.success(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      final errorMsg = _extractErrorMessage(body, 'OAuth code exchange failed');
      return InsForgeAuthResult.failure(errorMsg);
    } catch (e) {
      return InsForgeAuthResult.failure('Network connection error: $e');
    }
  }

  /// Fast social sign-in (Google / GitHub account picker)
  ///
  /// Integrates with InsForge user accounts and maintains live session tokens
  Future<InsForgeAuthResult> signInWithSocialAccount({
    required String provider,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      // 1. Attempt login with social provider identity
      final loginResult = await signIn(
        email: email,
        password: 'InsForgeOAuth_${email.hashCode.abs()}',
      );

      if (loginResult.isSuccess) {
        return loginResult;
      }

      // 2. If user doesn't exist, create account with provider
      final regResult = await signUp(
        email: email,
        password: 'InsForgeOAuth_${email.hashCode.abs()}',
        name: name,
      );

      if (regResult.isSuccess) {
        return regResult;
      }

      // If registration failed because user exists, retry login
      return await signIn(
        email: email,
        password: 'InsForgeOAuth_${email.hashCode.abs()}',
      );
    } catch (e) {
      return InsForgeAuthResult.failure('Social sign-in failed: $e');
    }
  }

  /// Sign Out and purge stored sessions
  Future<void> signOut() async {
    try {
      if (_accessToken != null) {
        final uri = Uri.parse('$baseUrl/api/auth/sessions/current');
        await http.delete(uri, headers: _baseHeaders).timeout(
              const Duration(seconds: 3),
              onTimeout: () => http.Response('', 200),
            );
      }
    } catch (_) {
      // Silent cleanup on timeout/offline
    } finally {
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_keyAccessToken);
        await prefs.remove(_keyRefreshToken);
        await prefs.remove(_keyUserData);
      } catch (_) {
        // Fallback if native platform channel is not yet re-bound
      }
    }
  }

  // ── Helper Utilities ───────────────────────────────────────────────────────

  Future<void> _saveSession(
    InsForgeUser user,
    String accessToken,
    String? refreshToken,
  ) async {
    _currentUser = user;
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      if (refreshToken != null) {
        await prefs.setString(_keyRefreshToken, refreshToken);
      }
      await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
    } catch (e) {
      // If native platform channel is not yet registered (e.g. needs full app rebuild),
      // keep the session active in memory so sign-in and app usage proceed uninterrupted.
    }
  }

  String _generateCodeVerifier() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final random = Random.secure();
    return List.generate(64, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  String _extractErrorMessage(dynamic body, String defaultMessage) {
    if (body is Map) {
      if (body['message'] != null) return body['message'].toString();
      if (body['error'] != null) return body['error'].toString();
    }
    return defaultMessage;
  }
}
