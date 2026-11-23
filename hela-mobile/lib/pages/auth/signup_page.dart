import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/services/insforge_auth_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Authentication mode — Sign Up or Sign In
enum AuthMode { signUp, signIn }

/// ── Design Tokens ──────────────────────────────────────────────
class _AuthColors {
  static const Color primary = Color(0xFF19331F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2F4A34);
  static const Color secondary = Color(0xFF40674D);
  static const Color secondaryContainer = Color(0xFFBFEAC9);
  static const Color tertiaryFixed = Color(0xFFDFEB6D);
  static const Color onTertiaryFixed = Color(0xFF1A1D00);
  static const Color surface = Color(0xFFFAF9F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1B1C19);
  static const Color onSurfaceVariant = Color(0xFF424842);
  static const Color outline = Color(0xFF737971);
  static const Color outlineVariant = Color(0xFFC2C8C0);
  static const Color error = Color(0xFFBA1A1A);
}

/// ── Password Strength ──────────────────────────────────────────
enum PasswordStrength { none, weak, fair, good, strong }

PasswordStrength _evaluatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.none;
  int score = 0;
  if (password.length >= 6) score++;
  if (password.length >= 10) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,\.<>\?/\\|`~]').hasMatch(password)) score++;

  if (score <= 1) return PasswordStrength.weak;
  if (score == 2) return PasswordStrength.fair;
  if (score == 3) return PasswordStrength.good;
  return PasswordStrength.strong;
}

Color _strengthColor(PasswordStrength s) {
  switch (s) {
    case PasswordStrength.none:
      return _AuthColors.outlineVariant;
    case PasswordStrength.weak:
      return _AuthColors.error;
    case PasswordStrength.fair:
      return const Color(0xFFE8A317);
    case PasswordStrength.good:
      return const Color(0xFF7FA88A);
    case PasswordStrength.strong:
      return const Color(0xFF2E7D32);
  }
}

String _strengthLabel(PasswordStrength s) {
  switch (s) {
    case PasswordStrength.none:
      return '';
    case PasswordStrength.weak:
      return 'Weak';
    case PasswordStrength.fair:
      return 'Fair';
    case PasswordStrength.good:
      return 'Good';
    case PasswordStrength.strong:
      return 'Strong';
  }
}

/// ── Custom Google "G" Icon ─────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  final double size;
  const _GoogleIcon({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double cx = s / 2;
    final double cy = s / 2;
    final double r = s * 0.45;
    final double strokeW = s * 0.18;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.6,
      1.15,
      false,
      paint,
    );

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.55,
      1.15,
      false,
      paint,
    );

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.7,
      1.0,
      false,
      paint,
    );

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.7,
      1.0,
      false,
      paint,
    );

    // Horizontal bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final double barH = strokeW;
    canvas.drawRect(
      Rect.fromLTWH(cx - s * 0.02, cy - barH / 2, r + s * 0.05, barH),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ── GitHub Icon ────────────────────────────────────────────────
class _GitHubIcon extends StatelessWidget {
  final double size;
  const _GitHubIcon({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.code_rounded,
      size: size,
      color: _AuthColors.primary,
    );
  }
}

/// ── Social Account Info ────────────────────────────────────────
class _SocialAccountInfo {
  final String provider;
  final String name;
  final String email;
  final String avatarLetter;
  final Color avatarColor;

  const _SocialAccountInfo({
    required this.provider,
    required this.name,
    required this.email,
    required this.avatarLetter,
    required this.avatarColor,
  });
}

const List<_SocialAccountInfo> _mockSocialAccounts = [
  _SocialAccountInfo(
    provider: 'google',
    name: 'Kavinda Wickramasinghe',
    email: 'kavinda.w@gmail.com',
    avatarLetter: 'K',
    avatarColor: Color(0xFF4285F4),
  ),
  _SocialAccountInfo(
    provider: 'google',
    name: 'Ceylon Explorer',
    email: 'explorer@hela.lk',
    avatarLetter: 'C',
    avatarColor: Color(0xFF34A853),
  ),
  _SocialAccountInfo(
    provider: 'github',
    name: 'KavinduDev',
    email: 'kavindu.dev@github.com',
    avatarLetter: 'G',
    avatarColor: Color(0xFF24292E),
  ),
];

/// ════════════════════════════════════════════════════════════════
/// ██  SignUpPage  ████████████████████████████████████████████████
/// ════════════════════════════════════════════════════════════════
class SignUpPage extends StatefulWidget {
  final AuthMode initialMode;
  const SignUpPage({super.key, this.initialMode = AuthMode.signUp});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  PasswordStrength _passwordStrength = PasswordStrength.none;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.value = 1.0;

    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordStrength = _evaluatePasswordStrength(_passwordController.text);
    });
  }

  void _toggleMode() {
    _animController.reverse().then((_) {
      setState(() {
        _mode = _mode == AuthMode.signUp ? AuthMode.signIn : AuthMode.signUp;
      });
      _animController.forward();
    });
  }

  /// Navigate to home after successful auth
  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HelaHomePage()),
      (route) => false,
    );
  }

  /// Submit email/password form to InsForge BaaS
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mode == AuthMode.signUp && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: _AuthColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      final InsForgeAuthResult result;
      if (_mode == AuthMode.signUp) {
        result = await InsForgeAuthService.instance.signUp(
          email: email,
          password: password,
          name: name.isNotEmpty ? name : null,
        );
      } else {
        result = await InsForgeAuthService.instance.signIn(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        final appState = HelaAppStateProvider.of(context);
        appState.signIn(
          name: result.user?.name ?? (_mode == AuthMode.signUp ? name : email.split('@').first),
          email: result.user?.email ?? email,
          photoUrl: result.user?.avatarUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mode == AuthMode.signUp
                  ? 'Welcome to HELA, ${result.user?.name ?? 'Explorer'}! Account created on InsForge.'
                  : 'Welcome back, ${result.user?.name ?? 'Explorer'}!',
            ),
            backgroundColor: _AuthColors.primaryContainer,
            duration: const Duration(seconds: 2),
          ),
        );

        _navigateToHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Authentication failed. Please try again.'),
            backgroundColor: _AuthColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: _AuthColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show Social Account picker bottom sheet
  Future<void> _signInWithSocial(String provider) async {
    final selected = await showModalBottomSheet<_SocialAccountInfo>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SocialAccountPickerSheet(
        provider: provider,
        accounts: _mockSocialAccounts.where((a) => a.provider == provider).toList(),
      ),
    );

    if (selected == null || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final result = await InsForgeAuthService.instance.signInWithSocialAccount(
        provider: selected.provider,
        email: selected.email,
        name: selected.name,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        final appState = HelaAppStateProvider.of(context);
        appState.signIn(
          name: result.user?.name ?? selected.name,
          email: result.user?.email ?? selected.email,
          photoUrl: result.user?.avatarUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in via ${provider.toUpperCase()} as ${selected.name}'),
            backgroundColor: _AuthColors.primaryContainer,
            duration: const Duration(seconds: 2),
          ),
        );

        _navigateToHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Social sign in failed'),
            backgroundColor: _AuthColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: _AuthColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AuthColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            const Positioned.fill(
              child: IgnorePointer(child: _BackgroundDecoration()),
            ),

            // Loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: _AuthColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _AuthColors.primary.withValues(alpha: 0.15),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: _AuthColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _mode == AuthMode.signUp
                                ? 'Connecting to InsForge…'
                                : 'Authenticating with InsForge…',
                            style: const TextStyle(
                              color: _AuthColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Main scrollable content
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          _buildHeroHeader(),
                          const SizedBox(height: 24),
                          _buildSocialButtons(),
                          const SizedBox(height: 22),
                          _buildDivider(),
                          const SizedBox(height: 22),
                          _buildForm(),
                          const SizedBox(height: 20),
                          _buildSubmitButton(),
                          const SizedBox(height: 20),
                          _buildModeToggle(),
                          const SizedBox(height: 12),
                          _buildGuestLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ── Top Bar ──
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_rounded,
                    color: _AuthColors.primary, size: 22),
              ),
            ),
          ),

          // HELA brand mark
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: _AuthColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spa_rounded,
                    color: _AuthColors.tertiaryFixed, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'HELA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _AuthColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Guest shortcut
          TextButton(
            onPressed: _navigateToHome,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _AuthColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Hero Header ──
  Widget _buildHeroHeader() {
    return Column(
      children: [
        // Decorative lotus emblem
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _AuthColors.secondaryContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.spa_rounded,
            color: _AuthColors.secondary,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _mode == AuthMode.signUp ? 'Begin Your Journey' : 'Welcome Back',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _AuthColors.primary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _mode == AuthMode.signUp
              ? 'Create your HELA account to unlock\nAI-curated journeys & secluded eco-havens'
              : 'Sign in to continue your\nSri Lankan adventure',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _AuthColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  /// ── Social Login Buttons (Google + GitHub) ──
  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Google Sign-In
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => _signInWithSocial('google'),
            style: OutlinedButton.styleFrom(
              backgroundColor: _AuthColors.surfaceContainerLowest,
              side: BorderSide(
                color: _AuthColors.outlineVariant.withValues(alpha: 0.7),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              shadowColor: Colors.black12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GoogleIcon(size: 20),
                const SizedBox(width: 12),
                Text(
                  _mode == AuthMode.signUp
                      ? 'Continue with Google'
                      : 'Sign in with Google',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: _AuthColors.onSurface,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // GitHub Sign-In
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => _signInWithSocial('github'),
            style: OutlinedButton.styleFrom(
              backgroundColor: _AuthColors.surfaceContainerLowest,
              side: BorderSide(
                color: _AuthColors.outlineVariant.withValues(alpha: 0.7),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              shadowColor: Colors.black12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GitHubIcon(size: 20),
                const SizedBox(width: 12),
                Text(
                  _mode == AuthMode.signUp
                      ? 'Continue with GitHub'
                      : 'Sign in with GitHub',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: _AuthColors.onSurface,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ── Divider ──
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _AuthColors.outlineVariant.withValues(alpha: 0.0),
                  _AuthColors.outlineVariant,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _mode == AuthMode.signUp
                ? 'or register with email'
                : 'or sign in with email',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _AuthColors.outline,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _AuthColors.outlineVariant,
                  _AuthColors.outlineVariant.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ── Form ──
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Full Name (Sign Up only)
          if (_mode == AuthMode.signUp) ...[
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Kavinda Wickramasinghe',
              icon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 14),
          ],

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(v.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _AuthColors.outline,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          // Password Strength Meter (Sign Up only)
          if (_mode == AuthMode.signUp && _passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildPasswordStrengthMeter(),
          ],

          // Confirm Password (Sign Up only)
          if (_mode == AuthMode.signUp) ...[
            const SizedBox(height: 14),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: '••••••••',
              icon: Icons.lock_rounded,
              obscure: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                  color: _AuthColors.outline,
                  size: 20,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],

          // Terms & Conditions Checkbox (Sign Up only)
          if (_mode == AuthMode.signUp) ...[
            const SizedBox(height: 16),
            _buildTermsCheckbox(),
          ],
        ],
      ),
    );
  }

  /// Reusable styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _AuthColors.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _AuthColors.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: _AuthColors.outline.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(icon, color: _AuthColors.secondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _AuthColors.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _AuthColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _AuthColors.secondary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AuthColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AuthColors.error, width: 1.5),
        ),
      ),
    );
  }

  /// Password strength meter with 4 segments
  Widget _buildPasswordStrengthMeter() {
    final int filledSegments;
    switch (_passwordStrength) {
      case PasswordStrength.none:
        filledSegments = 0;
      case PasswordStrength.weak:
        filledSegments = 1;
      case PasswordStrength.fair:
        filledSegments = 2;
      case PasswordStrength.good:
        filledSegments = 3;
      case PasswordStrength.strong:
        filledSegments = 4;
    }

    final Color color = _strengthColor(_passwordStrength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i < filledSegments
                      ? color
                      : _AuthColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            );
          }),
        ),
        if (_passwordStrength != PasswordStrength.none) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                _passwordStrength == PasswordStrength.strong
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                'Password strength: ${_strengthLabel(_passwordStrength)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Terms & Conditions checkbox
  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agreedToTerms
                  ? _AuthColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreedToTerms
                    ? _AuthColors.primary
                    : _AuthColors.outlineVariant,
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded,
                    size: 16, color: _AuthColors.onPrimary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: _AuthColors.onSurfaceVariant,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'I agree to HELA\'s '),
                  TextSpan(
                    text: 'Island Travel Terms',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _AuthColors.secondary,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _AuthColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Submit Button ──
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AuthColors.tertiaryFixed,
          foregroundColor: _AuthColors.onTertiaryFixed,
          elevation: 2,
          shadowColor: _AuthColors.primary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          disabledBackgroundColor:
              _AuthColors.tertiaryFixed.withValues(alpha: 0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _AuthColors.onTertiaryFixed,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _mode == AuthMode.signUp
                        ? Icons.person_add_alt_1_rounded
                        : Icons.login_rounded,
                    size: 18,
                    color: _AuthColors.onTertiaryFixed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _mode == AuthMode.signUp
                        ? 'Create HELA Account'
                        : 'Sign In',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _AuthColors.onTertiaryFixed,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// ── Mode Toggle ──
  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _mode == AuthMode.signUp
              ? 'Already have an account?'
              : 'Don\'t have an account?',
          style: const TextStyle(
            fontSize: 13,
            color: _AuthColors.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              _mode == AuthMode.signUp ? 'Sign In' : 'Sign Up',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _AuthColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ── Continue as Guest ──
  Widget _buildGuestLink() {
    return GestureDetector(
      onTap: _navigateToHome,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _AuthColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, size: 16, color: _AuthColors.outline),
            SizedBox(width: 6),
            Text(
              'Continue as Guest',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _AuthColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════
/// ██  Social Account Picker  █████████████████████████████████████
/// ════════════════════════════════════════════════════════════════
class _SocialAccountPickerSheet extends StatelessWidget {
  final String provider;
  final List<_SocialAccountInfo> accounts;
  const _SocialAccountPickerSheet({
    required this.provider,
    required this.accounts,
  });

  Future<void> _launchWebOAuth(BuildContext context) async {
    Navigator.pop(context);
    final oauthData = await InsForgeAuthService.instance.initiateOAuth(provider: provider);
    if (oauthData != null && oauthData['authUrl'] != null) {
      final uri = Uri.parse(oauthData['authUrl']!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerTitle = provider == 'google' ? 'Google' : 'GitHub';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AuthColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _AuthColors.primary.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                if (provider == 'google') const _GoogleIcon(size: 24) else const _GitHubIcon(size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sign in with $providerTitle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _AuthColors.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: _AuthColors.outline, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select an account to authenticate with InsForge BaaS',
              style: const TextStyle(
                fontSize: 13,
                color: _AuthColors.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: _AuthColors.outlineVariant.withValues(alpha: 0.4),
          ),

          // Accounts list
          ...accounts.map((account) => _buildAccountTile(context, account)),

          // Web OAuth flow option
          InkWell(
            onTap: () => _launchWebOAuth(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _AuthColors.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.open_in_browser_rounded,
                        size: 18, color: _AuthColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open $providerTitle OAuth in Browser',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _AuthColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Direct PKCE OAuth authorization flow',
                          style: TextStyle(
                            fontSize: 12,
                            color: _AuthColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Privacy footer
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Text(
              'InsForge secures your authentication session with industry-standard PKCE and JWT tokens.',
              style: TextStyle(
                fontSize: 11,
                color: _AuthColors.outline.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, _SocialAccountInfo account) {
    return InkWell(
      onTap: () => Navigator.pop(context, account),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: account.avatarColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  account.avatarLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name & Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _AuthColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _AuthColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _AuthColors.outline),
          ],
        ),
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════
/// ██  Background Decoration  ████████████████████████████████████
/// ════════════════════════════════════════════════════════════════
class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right radial glow
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _AuthColors.secondaryContainer.withValues(alpha: 0.15),
                  _AuthColors.secondaryContainer.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Bottom-left radial glow
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _AuthColors.tertiaryFixed.withValues(alpha: 0.08),
                  _AuthColors.tertiaryFixed.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Subtle center glow
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: MediaQuery.of(context).size.width * 0.2,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _AuthColors.primaryContainer.withValues(alpha: 0.06),
                  _AuthColors.primaryContainer.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
