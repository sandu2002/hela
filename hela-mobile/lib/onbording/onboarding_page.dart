import 'package:flutter/material.dart';
import 'package:hela/pages/auth/signup_page.dart';

/// Design tokens for HELA Onboarding
class OnboardingColors {
  static const Color primary = Color(0xFF19331F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2F4A34);
  static const Color onPrimaryContainer = Color(0xFF9AB99D);
  static const Color primaryFixed = Color(0xFFCBEBCC);
  static const Color primaryFixedDim = Color(0xFFAFCEB1);

  static const Color secondary = Color(0xFF40674D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFBFEAC9);
  static const Color onSecondaryContainer = Color(0xFF446B51);
  static const Color secondaryFixed = Color(0xFFC2EDCC);
  static const Color secondaryFixedDim = Color(0xFFA6D1B1);

  static const Color tertiary = Color(0xFF2C3100);
  static const Color tertiaryFixed = Color(0xFFDFEB6D);
  static const Color tertiaryFixedDim = Color(0xFFC3CF54);
  static const Color onTertiaryFixed = Color(0xFF1A1D00);

  static const Color surface = Color(0xFFFAF9F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F4EE);
  static const Color surfaceContainer = Color(0xFFEFEEE8);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E2);
  static const Color surfaceContainerHighest = Color(0xFFE3E3DD);
  static const Color surfaceVariant = Color(0xFFE3E3DD);
  static const Color surfaceDim = Color(0xFFDBDAD4);
  static const Color surfaceBright = Color(0xFFFAF9F3);

  static const Color onSurface = Color(0xFF1B1C19);
  static const Color onSurfaceVariant = Color(0xFF424842);
  static const Color outline = Color(0xFF737971);
  static const Color outlineVariant = Color(0xFFC2C8C0);
}

/// Slide model for Onboarding items
class OnboardingSlideData {
  final String category;
  final String title;
  final String description;
  final String imageUrl;
  final Widget heroOverlay;

  const OnboardingSlideData({
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.heroOverlay,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToSlide(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _nextSlide() {
    if (_currentIndex < 2) {
      _goToSlide(_currentIndex + 1);
    } else {
      _navigateToSignUp();
    }
  }

  void _skip() {
    if (_currentIndex < 2) {
      _goToSlide(2);
    } else {
      _navigateToSignUp();
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SignUpPage(initialMode: AuthMode.signIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background mandala & arcs
            const Positioned.fill(
              child: IgnorePointer(
                child: _MandalaBackdrop(),
              ),
            ),

            // Main Content Layout
            Column(
              children: [
                // Top Header Bar
                _buildTopBar(),

                // Carousel PageView Area
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      _buildSlideCard(
                        category: 'BESPOKE ITINERARIES',
                        title: 'Plan Effortlessly',
                        description:
                            'Your Sri Lankan journey, curated. Discover custom tea estate retreats, sacred ruins, and authentic island stories.',
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBDZaX0C2cA-nyO9MWQogSFi_5Mus5uMvE4ee3X-oBezYZKacGP8daKehduwS2OFtWQ2oL7bmoLFjXm91-Zuu45Uw0vzYza-DZB2KvNHN56pqfJGXKgw7geDxiLxSCSM9pZL2g356fzKHbAzQ3OaN3lAOzxvq-7GkXwkSTk7-XRL-PrPUXsVT7jQsiIIxTu2IbOJUcHFo8gCRXOGrL4eopYljGjWWQV4JFLJ_ytdAqEfgrzPrUwqKoc7g',
                        badgeIcon: Icons.verified_rounded,
                        badgeText: 'Curated Travel',
                        badgeTopLeft: true,
                        centerOverlay: _buildSlide1CenterBadge(),
                      ),
                      _buildSlideCard(
                        category: 'DEEP CULTURAL IMMERSION',
                        title: 'Explore Like a Local',
                        description:
                            'Venture beyond tourist trails. Connect with indigenous tea masters, coastal fishermen, and generational ceramic artisans.',
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBWKCCxRDe4DL99NH4WxuyC56ZtchSdIJPplEC1UqpcnYrkk1NaGRKUazF2YJajzd_QRchlc9eQNi-_Bw8Gl2JSD33-RNqjD7flMhx7vLhw2S1PVjPxzGOtn7NKWG7Gh657frNUhJiTtYiQTbixOvcQibCRAPjm3fL375SmDcFCBcX0k1NJD9WsGeO1LOWo6KU5m46d3cIdql3BMAr1eioFjkAl23e5PTn4KyxsHZOeGwrQwh2qNJ5d-w',
                        badgeIcon: Icons.eco_rounded,
                        badgeText: 'Highland Sanctuaries',
                        badgeTopLeft: false,
                        bottomOverlay: _buildSlide2BottomChip(),
                      ),
                      _buildSlideCard(
                        category: 'ETHICAL & TRANSPARENT',
                        title: 'Travel Fairly Priced',
                        description:
                            'No middleman markups or haggling stress. Verified local safari jeeps, scenic trains, and tuk-tuk hosts with honest pricing.',
                        imageUrl:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDvMgdaQ1SjL_jfjPlHOh4nkRs7L2_f43Ih9qAbNfmCZF5WfK5bpGNeRuHn11mDIPWOpL_eGbxwfTDmwVYlObzuycxz6WODahdIzWDlHmVOcoKcOqPKSXx0Gr84k-_pukutgpVh2kYMkTt_y_TRRcAZzCjudI6yy41lR4m3F49p3PS4N5NFExAcjbC7btjPY1rD2jNC_VlWNKwYPNsqyUaa2pmgvKNHpFFNEE8obXde8n0Os-RnzP-nHw',
                        badgeIcon: Icons.handshake_rounded,
                        badgeText: 'Direct to Community',
                        badgeTopLeft: true,
                        bottomOverlay: _buildSlide3BottomChip(),
                      ),
                    ],
                  ),
                ),

                // Bottom Footer: Indicators & CTAs
                _buildFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar with Micro-brand mark and Skip action
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // HELA Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: OnboardingColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: OnboardingColors.tertiaryFixed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'HELA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: OnboardingColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Skip Button
          TextButton(
            onPressed: _skip,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: OnboardingColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Carousel Card
  Widget _buildSlideCard({
    required String category,
    required String title,
    required String description,
    required String imageUrl,
    required IconData badgeIcon,
    required String badgeText,
    required bool badgeTopLeft,
    Widget? centerOverlay,
    Widget? bottomOverlay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: OnboardingColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: OnboardingColors.outlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: OnboardingColors.primary.withValues(alpha: 0.06),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: OnboardingColors.primary.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero Image Card with overlays
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: OnboardingColors.surfaceContainerLow,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: OnboardingColors.primaryContainer,
                              child: const Center(
                                child: Icon(
                                  Icons.landscape_rounded,
                                  color: OnboardingColors.onPrimaryContainer,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),

                        // Gradient Shadow
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                OnboardingColors.primary.withValues(alpha: 0.2),
                                OnboardingColors.primary.withValues(alpha: 0.8),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),

                        // Top Micro-Badge
                        Positioned(
                          top: 12,
                          left: badgeTopLeft ? 12 : null,
                          right: !badgeTopLeft ? 12 : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: OnboardingColors.surfaceContainerLowest
                                  .withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: OnboardingColors.outlineVariant
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  badgeIcon,
                                  color: OnboardingColors.secondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  badgeText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: OnboardingColors.primary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Optional Center Overlay (Slide 1)
                        if (centerOverlay != null)
                          Center(child: centerOverlay),

                        // Optional Bottom Overlay (Slide 2 & 3)
                        if (bottomOverlay != null)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: bottomOverlay,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Category Tag
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: OnboardingColors.secondary,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 8),

                // Main Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: OnboardingColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: OnboardingColors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Slide 1 Center Emblem
  Widget _buildSlide1CenterBadge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: OnboardingColors.surfaceContainerLowest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: OnboardingColors.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            color: OnboardingColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ceylon Sanctuary',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Slide 2 Bottom Chip (Explore Like a Local)
  Widget _buildSlide2BottomChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: OnboardingColors.primaryContainer.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: OnboardingColors.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: OnboardingColors.tertiaryFixed,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hidden Gems',
                  style: TextStyle(
                    fontSize: 11,
                    color: OnboardingColors.surfaceDim,
                  ),
                ),
                Text(
                  'Artisan Villages & Secret Waterfalls',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OnboardingColors.surface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Slide 3 Bottom Chip (Travel Fairly Priced)
  Widget _buildSlide3BottomChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: OnboardingColors.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: OnboardingColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: OnboardingColors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: OnboardingColors.onSecondaryContainer,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verified Chauffeurs',
                  style: TextStyle(
                    fontSize: 11,
                    color: OnboardingColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '100% Fair Tariffs',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: OnboardingColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: OnboardingColors.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Fixed Rate',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: OnboardingColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Footer: Pagination Dots and Action Buttons
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pagination Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final bool isActive = _currentIndex == index;
              return GestureDetector(
                onTap: () => _goToSlide(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? OnboardingColors.primaryContainer
                        : OnboardingColors.outlineVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Primary CTA Button (Golden-Lime Pill)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _nextSlide,
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingColors.tertiaryFixed,
                foregroundColor: OnboardingColors.onTertiaryFixed,
                elevation: 2,
                shadowColor: OnboardingColors.primary.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex == 2 ? 'Get Started' : 'Continue',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: OnboardingColors.onTertiaryFixed,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: OnboardingColors.onTertiaryFixed,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary Link: Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?',
                style: TextStyle(
                  fontSize: 13,
                  color: OnboardingColors.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: _navigateToSignIn,
                child: const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OnboardingColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Home Indicator Pill
          Container(
            width: 120,
            height: 4,
            decoration: BoxDecoration(
              color: OnboardingColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative Mandala & Botanical geometry background
class _MandalaBackdrop extends StatelessWidget {
  const _MandalaBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-Right concentric arcs
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: OnboardingColors.secondary.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: OnboardingColors.secondary.withValues(alpha: 0.10),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: OnboardingColors.secondary.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom-Left subtle arc
        Positioned(
          bottom: -70,
          left: -70,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: OnboardingColors.secondary.withValues(alpha: 0.10),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
