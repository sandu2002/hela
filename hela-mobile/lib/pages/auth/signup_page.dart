import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/onbording/onboarding_page.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/services/insforge_auth_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/hela_network_image.dart';

/// Authentication mode — Sign Up or Sign In
enum AuthMode { signUp, signIn }

/// ── Password Strength Evaluation ──────────────────────────────────
enum PasswordStrength { none, weak, fair, good, strong }

PasswordStrength _evaluatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.none;
  int score = 0;
  if (password.length >= 6) score++;
  if (password.length >= 8) score++;
  if (password.length >= 10) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,\.<>\?/\\|`~]').hasMatch(password)) {
    score++;
  }

  if (score <= 1) return PasswordStrength.weak;
  if (score <= 3) return PasswordStrength.fair;
  if (score <= 4) return PasswordStrength.good;
  return PasswordStrength.strong;
}

Color _strengthColor(PasswordStrength s) {
  switch (s) {
    case PasswordStrength.none:
      return HelaColors.outlineVariant;
    case PasswordStrength.weak:
      return HelaColors.error;
    case PasswordStrength.fair:
      return HelaColors.goldenAmber;
    case PasswordStrength.good:
      return const Color(0xFF38977F);
    case PasswordStrength.strong:
      return HelaColors.primary;
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

/// ── Custom Vector Google "G" Logo ──────────────────────────────
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
    final double r = s * 0.44;
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
      1.15,
      false,
      paint,
    );

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.85,
      1.15,
      false,
      paint,
    );

    // Horizontal blue bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx - strokeW * 0.2, cy - strokeW / 2, r + strokeW / 2, strokeW),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ── Custom Vector Apple Logo ───────────────────────────────────
class _AppleIcon extends StatelessWidget {
  final double size;
  final Color color;
  const _AppleIcon({this.size = 20, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.apple_rounded, size: size, color: color);
  }
}

/// ── Signup / Auth Page ─────────────────────────────────────────
class SignUpPage extends StatefulWidget {
  final AuthMode initialMode;

  const SignUpPage({super.key, this.initialMode = AuthMode.signUp});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

typedef SignupPage = SignUpPage;

class _SignUpPageState extends State<SignUpPage> {
  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;
  String _selectedCountry = '';
  PasswordStrength _strength = PasswordStrength.none;

  final List<Map<String, String>> _countries = const [
    {'code': '', 'label': 'Select country (for currency & visa guidance)'},
    {'code': 'UK', 'label': 'United Kingdom (GBP)'},
    {'code': 'DE', 'label': 'Germany & EU (EUR)'},
    {'code': 'US', 'label': 'United States (USD)'},
    {'code': 'AU', 'label': 'Australia (AUD)'},
    {'code': 'IN', 'label': 'India (INR)'},
    {'code': 'FR', 'label': 'France (EUR)'},
    {'code': 'OTHER', 'label': 'Other / Worldwide'},
  ];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final s = _evaluatePasswordStrength(_passwordController.text);
    if (s != _strength) {
      setState(() => _strength = s);
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.signUp ? AuthMode.signIn : AuthMode.signUp;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _handlePrimarySubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mode == AuthMode.signUp && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service to continue.'),
          backgroundColor: HelaColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      final auth = InsForgeAuthService.instance;
      final InsForgeAuthResult result;

      if (_mode == AuthMode.signUp) {
        result = await auth.signUp(email: email, password: password, name: name);
      } else {
        result = await auth.signIn(email: email, password: password);
      }

      if (!mounted) return;

      if (result.isSuccess && result.user != null) {
        final user = result.user!;
        HelaAppStateProvider.of(context).signIn(
          name: user.name,
          email: user.email,
          photoUrl: user.avatarUrl,
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HelaHomePage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Authentication failed. Please try again.'),
            backgroundColor: HelaColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: HelaColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _exploreAsGuest() {
    HelaAppStateProvider.of(context).continueAsGuest();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HelaHomePage()),
      (route) => false,
    );
  }

  void _showTermsDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Full-Bleed Hero Banner with Floating Controls & Tabs ──
            _buildCulturalBanner(colors),

            // ── Body Content ──────────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Intro Copy ──────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _mode == AuthMode.signUp
                                ? 'Unlock personalized AI itineraries, verified tuk-tuk fares, and scenic tea train connections across Sri Lanka.'
                                : 'Sign in to access your saved itineraries, Sri Lanka transit passes, and offline island guides.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: colors.onSurfaceVariant,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Social Sign-Up Options ─────────────────────
                        _buildSocialButtons(colors, isDark),
                        const SizedBox(height: 20),

                        // ── Divider ────────────────────────────────────
                        _buildDivider(colors),
                        const SizedBox(height: 20),

                        // ── Form ───────────────────────────────────────
                        _buildForm(colors),
                        const SizedBox(height: 24),

                        // ── Guest & Sign In / Sign Up Footer ───────────
                        _buildFooter(colors),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCulturalBanner(HelaColorPalette colors) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SizedBox(
      width: double.infinity,
      height: 300 + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HelaNetworkImage(
            imageUrl: SriLankaImages.sigiriya,
            width: double.infinity,
            height: 300 + topPadding,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.network(
                SriLankaImages.sigiriyaMonolith,
                width: double.infinity,
                height: 300 + topPadding,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Image.network(
                  'https://images.unsplash.com/photo-1580794749460-76f97b7180d8?auto=format&fit=crop&w=1200&q=80',
                  width: double.infinity,
                  height: 300 + topPadding,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          // Top + Bottom Gradient Scrim for crisp status bar & overlay legibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.28, 0.55, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.34),
                  Colors.transparent,
                  colors.primary.withValues(alpha: 0.42),
                  colors.primary.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),

          // Centered overlay controls (matches form width on larger screens, full-bleed on mobile)
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Floating Circular Back Button (top-left)
                    Positioned(
                      top: topPadding + 10,
                      left: 16,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        elevation: 2,
                        shadowColor: Colors.black26,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const OnboardingPage(),
                                ),
                              );
                            }
                          },
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Title & Frosted Sign Up / Sign In Tab Bar over the image
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 36,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.tertiaryFixed,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 10,
                                      color: colors.onTertiaryFixed,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ayubowan',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: colors.onTertiaryFixed,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Your Island Story Awaits',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _mode == AuthMode.signUp
                                ? 'Begin Your Journey'
                                : 'Welcome Back',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Frosted Sign Up / Sign In Tabs on top of the image
                          _buildModeTabBar(colors),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Curved Bottom Sheet Cap seamlessly blending into Scaffold background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 22,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(HelaColorPalette colors, bool isDark) {
    return Column(
      children: [
        // Google Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _handleSocialLogin('Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.surfaceContainerLowest,
              foregroundColor: colors.onSurface,
              elevation: 1,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: colors.architecturalBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GoogleIcon(size: 20),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Apple Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _handleSocialLogin('Apple'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? colors.surfaceContainerHighest : colors.onSurface,
              foregroundColor: Colors.white,
              elevation: 1,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _AppleIcon(size: 22, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Continue with Apple',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-in is initializing secure OAuth tokens...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDivider(HelaColorPalette colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.outlineVariant.withValues(alpha: 0.5), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _mode == AuthMode.signUp ? 'or sign up with email' : 'or sign in with email',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.outline,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.outlineVariant.withValues(alpha: 0.5), thickness: 1)),
      ],
    );
  }

  Widget _buildModeTabBar(HelaColorPalette colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildModeTabItem(
                  label: 'Sign Up',
                  isSelected: _mode == AuthMode.signUp,
                  colors: colors,
                  onTap: () {
                    if (_mode != AuthMode.signUp) {
                      setState(() {
                        _mode = AuthMode.signUp;
                        _formKey.currentState?.reset();
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: _buildModeTabItem(
                  label: 'Sign In',
                  isSelected: _mode == AuthMode.signIn,
                  colors: colors,
                  onTap: () {
                    if (_mode != AuthMode.signIn) {
                      setState(() {
                        _mode = AuthMode.signIn;
                        _formKey.currentState?.reset();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabItem({
    required String label,
    required bool isSelected,
    required HelaColorPalette colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? colors.primary
                  : Colors.white.withValues(alpha: 0.92),
              fontFamily: 'Inter',
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(HelaColorPalette colors) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name (Only for Sign Up)
          if (_mode == AuthMode.signUp) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'As in passport',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.outline,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colors.onSurface, fontSize: 14, fontFamily: 'Inter'),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceContainerLowest,
                hintText: 'e.g. Sarah Jenkins',
                hintStyle: TextStyle(
                  color: colors.outline.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                prefixIcon: Icon(Icons.person_outline_rounded, color: colors.primary, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.architecturalBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.architecturalBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
              validator: (v) {
                if (_mode == AuthMode.signUp && (v == null || v.trim().isEmpty)) {
                  return 'Please enter your full name';
                }
                if (v != null && v.trim().length > 100) {
                  return 'Name must be 100 characters or fewer';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
          ],

          // Email Address
          Text(
            'Email Address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: colors.onSurface, fontSize: 14, fontFamily: 'Inter'),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surfaceContainerLowest,
              hintText: 'sarah@example.com',
              hintStyle: TextStyle(
                color: colors.outline.withValues(alpha: 0.7),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              prefixIcon: Icon(Icons.mail_outline_rounded, color: colors.primary, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.architecturalBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.architecturalBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Create / Enter Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _mode == AuthMode.signUp ? 'Create Password' : 'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
              if (_mode == AuthMode.signUp)
                Text(
                  'Min. 8 characters',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.outline,
                    fontFamily: 'Inter',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: colors.onSurface, fontSize: 14, fontFamily: 'Inter'),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surfaceContainerLowest,
              hintText: 'At least 8 characters',
              hintStyle: TextStyle(
                color: colors.outline.withValues(alpha: 0.7),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: colors.outline,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.architecturalBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.architecturalBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your password';
              if (_mode == AuthMode.signUp && v.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),

          // Password Strength Meter (Only for Sign Up)
          if (_mode == AuthMode.signUp && _passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _strength.index / PasswordStrength.values.length,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(_strengthColor(_strength)),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _strengthLabel(_strength),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _strengthColor(_strength),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Country of Origin (Only for Sign Up)
          if (_mode == AuthMode.signUp) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Country of Origin',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFED7AA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AI TIP',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9A3412),
                          letterSpacing: 0.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.outline,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCountry.isEmpty ? '' : _selectedCountry,
              isExpanded: true,
              style: TextStyle(color: colors.onSurface, fontSize: 14, fontFamily: 'Inter'),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceContainerLowest,
                prefixIcon: Icon(Icons.public_rounded, color: colors.primary, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.architecturalBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.architecturalBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.outline, size: 22),
              items: _countries.map((c) {
                return DropdownMenuItem<String>(
                  value: c['code'],
                  child: Text(
                    c['label']!,
                    style: TextStyle(
                      color: c['code']!.isEmpty ? colors.outline.withValues(alpha: 0.7) : colors.onSurface,
                      fontSize: 13.5,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedCountry = val ?? '');
              },
            ),
            const SizedBox(height: 14),

            // Terms & Conditions Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreedToTerms,
                    activeColor: colors.primary,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: colors.outlineVariant, width: 1.5),
                    onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          const TextSpan(text: "I agree to HELA's "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _showTermsDialog(
                                'Terms of Service',
                                'By using HELA, you agree to discover Sri Lanka responsibly, honor local cultural guidelines, and receive verified transit & schedule updates.',
                              ),
                              child: Text(
                                'Terms of Service',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' & '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => _showTermsDialog(
                                'Privacy Policy',
                                'Your travel preferences and location data are encrypted and protected by Sri Lanka Tourism Board safety protocols.',
                              ),
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(
                            text: '. Send me curated weather updates & train schedule alerts.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),

          // Primary Action Button (52px height, Ocean Teal)
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePrimarySubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                shadowColor: colors.primary.withValues(alpha: 0.3),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _mode == AuthMode.signUp ? 'Create HELA Account' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(HelaColorPalette colors) {
    return Column(
      children: [
        // Frictionless Guest Pill
        Material(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(9999),
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: _exploreAsGuest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_rounded, size: 16, color: colors.onSecondaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    'Explore as Guest first',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSecondaryContainer,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Toggle Sign In / Sign Up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _mode == AuthMode.signUp ? 'Already have an account?' : "Don't have an account?",
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _toggleMode,
              child: Text(
                _mode == AuthMode.signUp ? 'Sign In' : 'Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Trust Reassurance Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_rounded, size: 16, color: colors.secondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Encrypted & Protected by Sri Lanka Tourism Board Safety Protocols',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: colors.outline,
                    fontFamily: 'Inter',
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
