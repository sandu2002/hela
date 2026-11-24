import 'package:flutter/material.dart';
import 'package:hela/pages/auth/signup_page.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/state/app_state.dart';

/// Design tokens specifically tailored for HELA's Onboarding Experience
/// Conforms to the Stitch Lankan Tropical Modernism specification
class OnboardingTokens {
  static const Color background = Color(0xFFE9FEF9);
  static const Color primaryDark = Color(0xFF00443E);
  static const Color primaryTeal = Color(0xFF0B5D56);
  static const Color textDark = Color(0xFF0C1F1C);
  static const Color textMuted = Color(0xFF3F4947);
  static const Color mintContainer = Color(0xFFDEF2ED);
  static const Color mintBadge = Color(0xFFD2E7E2);
  static const Color mintBorder = Color(0xFFBEC9C6);
  static const Color dotInactive = Color(0xFFCADED9);
  static const Color peachBadge = Color(0xFFFFDEAA);
  static const Color peachText = Color(0xFF5F4100);
  static const Color cardSurface = Colors.white;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Selected language for language pill
  String _selectedLanguage = 'EN';

  // Selected category on Step 2 (Explore Every Corner)
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _step2Categories = [
    {
      'title': 'Tea Hills',
      'icon': '🍃',
      'locationTitle': 'Nine Arch Bridge',
      'locationSubtitle': 'Badulla Railway Line, Ella',
      'tagText': 'Ella Highlands • Scenic Rail',
      'tagIcon': Icons.train_rounded,
      'rating': '4.9',
      'imageUrl':
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=1000&auto=format&fit=crop&q=80',
      'tipTitle': 'Scenic Rail Tip',
      'tipBody':
          'Reserve 1st or 2nd class observation carriage seats at least 30 days ahead during peak season for panoramic misty views.',
      'actionText': 'Live Timetable ›',
    },
    {
      'title': 'Golden Beaches',
      'icon': '🏖️',
      'locationTitle': 'Mirissa Coconut Tree Hill',
      'locationSubtitle': 'Southern Coast, Mirissa',
      'tagText': 'Southern Coast • Surf & Whales',
      'tagIcon': Icons.surfing_rounded,
      'rating': '4.8',
      'imageUrl':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1000&auto=format&fit=crop&q=80',
      'tipTitle': 'Sunset & Surf Tip',
      'tipBody':
          'Best surf swell runs November to April on the South Coast. Head up Coconut Tree Hill around 5:30 PM for breathtaking sunset vistas.',
      'actionText': 'Tide Times ›',
    },
    {
      'title': 'Wildlife Safari',
      'icon': '🐾',
      'locationTitle': 'Yala Leopard Sanctuary',
      'locationSubtitle': 'Block 1 & Ruhuna, Hambantota',
      'tagText': 'Yala Wilderness • Big Game',
      'tagIcon': Icons.pets_rounded,
      'rating': '4.9',
      'imageUrl':
          'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=1000&auto=format&fit=crop&q=80',
      'tipTitle': 'Safari Etiquette Tip',
      'tipBody':
          'Book an early 5:30 AM morning safari gate entry. Leopards and sloth bears are most active before the afternoon tropical heat.',
      'actionText': 'Safari Rules ›',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToSlide(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
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

  void _previousSlide() {
    if (_currentIndex > 0) {
      _goToSlide(_currentIndex - 1);
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

  void _continueAsGuest() {
    // Set guest identity in global app state and navigate to home
    try {
      final appState = HelaAppStateProvider.of(context);
      appState.signOut();
    } catch (_) {}

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HelaHomePage()),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final languages = [
          {'code': 'EN', 'name': 'English', 'native': 'English'},
          {'code': 'SI', 'name': 'Sinhala', 'native': 'සිංහල'},
          {'code': 'TA', 'name': 'Tamil', 'native': 'தமிழ்'},
          {'code': 'DE', 'name': 'German', 'native': 'Deutsch'},
          {'code': 'FR', 'name': 'French', 'native': 'Français'},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose your preferred language for island discovery.',
                  style: TextStyle(
                    fontSize: 13,
                    color: OnboardingTokens.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                ...languages.map((lang) {
                  final isSelected = _selectedLanguage == lang['code'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? OnboardingTokens.mintBadge
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lang['code']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? OnboardingTokens.primaryDark
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    title: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: OnboardingTokens.textDark,
                      ),
                    ),
                    subtitle: Text(
                      lang['native']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OnboardingTokens.textMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: OnboardingTokens.primaryDark,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang['code']!;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLiveTimetable() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.88,
          minChildSize: 0.45,
          expand: false,
          builder: (_, scrollController) {
            final trains = [
              {
                'name': 'Ella Odyssey (Scenic Special)',
                'trainNo': 'Train #1007',
                'route': 'Colombo Fort ➔ Kandy ➔ Ella ➔ Badulla',
                'time': '05:30 AM – 03:25 PM',
                'highlights': 'Stops 10 mins at Nine Arch Bridge & St. Clair Falls',
                'class': '1st Observation & 2nd Reserved',
              },
              {
                'name': 'Podi Menike Express',
                'trainNo': 'Train #1005',
                'route': 'Colombo Fort ➔ Kandy ➔ Nanu Oya ➔ Ella',
                'time': '05:55 AM – 02:40 PM',
                'highlights': 'Scenic tea plantation mist route',
                'class': '1st, 2nd & 3rd Class',
              },
              {
                'name': 'Udarata Menike Express',
                'trainNo': 'Train #1015',
                'route': 'Colombo Fort ➔ Peradeniya ➔ Ella',
                'time': '08:30 AM – 05:28 PM',
                'highlights': 'Popular mountain climbing railway views',
                'class': '2nd & 3rd Class',
              },
              {
                'name': 'Night Mail Express',
                'trainNo': 'Train #1045',
                'route': 'Colombo Fort ➔ Ella ➔ Badulla',
                'time': '08:00 PM – 06:05 AM',
                'highlights': 'Overnight sleeper berths available',
                'class': 'Berth Sleepers & General',
              },
            ];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: OnboardingTokens.mintBadge,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.train_rounded,
                          color: OnboardingTokens.primaryDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Main Line Scenic Rail',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: OnboardingTokens.textDark,
                            ),
                          ),
                          Text(
                            'Live Daily Timetable & Observation Seats',
                            style: TextStyle(
                              fontSize: 12,
                              color: OnboardingTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ...trains.map((train) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: OnboardingTokens.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: OnboardingTokens.mintBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                train['name']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: OnboardingTokens.primaryDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  train['trainNo']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: OnboardingTokens.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: OnboardingTokens.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                train['time']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: OnboardingTokens.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            train['route']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: OnboardingTokens.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFE89812),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    train['highlights']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: OnboardingTokens.textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAskHelaSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final prompts = [
          'What is the best month to hike Ella Rock?',
          'What is the appropriate dress code for the Temple of the Tooth?',
          'What should I expect to pay for a tuk-tuk from Colombo to Mount Lavinia?',
          'Where can I see wild elephants responsibly in Sri Lanka?',
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: OnboardingTokens.peachBadge,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: OnboardingTokens.peachText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask HELA AI Guide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: OnboardingTokens.textDark,
                          ),
                        ),
                        Text(
                          'Your 24/7 Smart Sri Lanka Travel Companion',
                          style: TextStyle(
                            fontSize: 12,
                            color: OnboardingTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Popular Traveler Inquiries:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: OnboardingTokens.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                ...prompts.map((p) {
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _navigateToSignUp();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: OnboardingTokens.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: OnboardingTokens.mintBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: OnboardingTokens.primaryDark,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: OnboardingTokens.textDark,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: OnboardingTokens.textMuted,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToSignUp();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OnboardingTokens.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Sign Up to Unlock Full AI Chat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (changes according to current step)
            _buildTopBar(),

            // Swiping Carousel
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (idx) {
                  setState(() {
                    _currentIndex = idx;
                  });
                },
                children: [
                  _buildScreen1(),
                  _buildScreen2(),
                  _buildScreen3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TOP APP BAR
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SizedBox(
        height: 46,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Element
            if (_currentIndex == 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'HELA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: OnboardingTokens.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'HELA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: OnboardingTokens.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Sri Lanka Travel Companion',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: OnboardingTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              // Circular Back Button for Screen 2 & 3
              InkWell(
                onTap: _previousSlide,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: OnboardingTokens.mintContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: OnboardingTokens.mintBorder,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: OnboardingTokens.primaryDark,
                    size: 20,
                  ),
                ),
              ),

            // Center Element (Indicator on Screen 2)
            if (_currentIndex == 1)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final active = i == 1;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? OnboardingTokens.primaryDark
                          : OnboardingTokens.dotInactive,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              )
            else
              const SizedBox.shrink(),

            // Right Element
            if (_currentIndex == 0)
              // Language Selector Pill
              InkWell(
                onTap: _showLanguageSelector,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: OnboardingTokens.mintContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: OnboardingTokens.mintBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 16,
                        color: OnboardingTokens.primaryDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedLanguage,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: OnboardingTokens.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: OnboardingTokens.textDark,
                      ),
                    ],
                  ),
                ),
              )
            else if (_currentIndex == 1)
              // Skip Text Button
              TextButton(
                onPressed: () => _goToSlide(2),
                style: TextButton.styleFrom(
                  foregroundColor: OnboardingTokens.primaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: OnboardingTokens.primaryDark,
                  ),
                ),
              )
            else
              // Screen 3: Sparkle Badge HELA AI GUIDE
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: OnboardingTokens.peachBadge,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: OnboardingTokens.peachText,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'HELA AI GUIDE',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: OnboardingTokens.peachText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SCREEN 1: Welcome & Overview (Image 1)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildScreen1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 6),

          // Hero Image Card (Sigiriya at dawn)
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: SizedBox(
              height: 290,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=1000&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: OnboardingTokens.primaryDark,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.landscape_rounded,
                        color: Colors.white70,
                        size: 54,
                      ),
                    ),
                  ),

                  // Top-Right Pill: Golden Dawn
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wb_sunny_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Golden Dawn',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom-Left Pill: Sigiriya, Cultural Triangle
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: OnboardingTokens.primaryDark,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Sigiriya, Cultural Triangle',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: OnboardingTokens.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 3 Page Dots Indicator (Step 1 active)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 7,
                decoration: BoxDecoration(
                  color: OnboardingTokens.primaryDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: OnboardingTokens.dotInactive,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: OnboardingTokens.dotInactive,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Title
          const Text(
            'Discover Sri Lanka,\nYour Way',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: OnboardingTokens.textDark,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle
          const Text(
            'Your island adventure starts with HELA. From ancient kingdoms to sun-kissed coasts, explore effortlessly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: OnboardingTokens.textMuted,
            ),
          ),

          const SizedBox(height: 18),

          // Feature Highlights Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: OnboardingTokens.mintContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: OnboardingTokens.mintBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureBadge(
                  icon: Icons.check_circle_outline_rounded,
                  line1: 'Fair-Fare',
                  line2: 'Taxis',
                ),
                _buildBulletSeparator(),
                _buildFeatureBadge(
                  icon: Icons.train_outlined,
                  line1: 'Scenic',
                  line2: 'Rail',
                ),
                _buildBulletSeparator(),
                _buildFeatureBadge(
                  icon: Icons.face_retouching_natural_rounded,
                  line1: 'AI',
                  line2: 'Concierge',
                  iconColor: const Color(0xFF9E5C16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Primary CTA: Get Started
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextSlide,
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTokens.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Secondary CTA: Continue as Guest
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _continueAsGuest,
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTokens.mintContainer,
                foregroundColor: OnboardingTokens.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue as Guest',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: OnboardingTokens.primaryDark,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Footer link: Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                  fontSize: 13,
                  color: OnboardingTokens.textMuted,
                ),
              ),
              GestureDetector(
                onTap: _navigateToSignIn,
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.primaryDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String line1,
    required String line2,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? OnboardingTokens.primaryDark,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              line1,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: OnboardingTokens.textDark,
                height: 1.1,
              ),
            ),
            Text(
              line2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: OnboardingTokens.textMuted,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletSeparator() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: OnboardingTokens.mintBorder,
        shape: BoxShape.circle,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SCREEN 2: Explore Every Corner (Image 3)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildScreen2() {
    final activeCat = _step2Categories[_selectedCategoryIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

          // Hero Image Card with Overlays
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: SizedBox(
              height: 290,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    activeCat['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: OnboardingTokens.primaryDark,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.landscape_rounded,
                        color: Colors.white70,
                        size: 54,
                      ),
                    ),
                  ),

                  // Top-Left Tag
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            activeCat['tagIcon'] as IconData,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            activeCat['tagText'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Right Tag: Rating
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFFFB800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activeCat['rating'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Floating Card
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: OnboardingTokens.mintBadge,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: OnboardingTokens.primaryDark,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  activeCat['locationTitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: OnboardingTokens.textDark,
                                  ),
                                ),
                                Text(
                                  activeCat['locationSubtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: OnboardingTokens.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _showLiveTimetable,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    activeCat['actionText'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: OnboardingTokens.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Interactive Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_step2Categories.length, (idx) {
                final cat = _step2Categories[idx];
                final isSelected = _selectedCategoryIndex == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = idx;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFBCEEDA)
                            : OnboardingTokens.mintContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF7DD2B4)
                              : OnboardingTokens.mintBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat['icon'] as String),
                          const SizedBox(width: 6),
                          Text(
                            cat['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? OnboardingTokens.primaryDark
                                  : OnboardingTokens.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Step Badge & Verified Waypoints
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: OnboardingTokens.mintBadge,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 02 OF 03',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.primaryDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 15,
                    color: OnboardingTokens.primaryDark,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Verified Waypoints',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: OnboardingTokens.primaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          const Text(
            'Explore Every Corner',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: OnboardingTokens.textDark,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          const Text(
            'Uncover pristine tropical beaches, misty tea plantations, majestic wildlife, and centuries of vibrant cultural heritage curated for seamless journeys.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: OnboardingTokens.textMuted,
            ),
          ),

          const SizedBox(height: 16),

          // Tip Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F6EE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: OnboardingTokens.mintBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC7EDE0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: OnboardingTokens.primaryDark,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeCat['tipTitle'] as String,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: OnboardingTokens.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeCat['tipBody'] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: OnboardingTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Continue CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextSlide,
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTokens.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Explore as Guest Text Button
          Center(
            child: TextButton(
              onPressed: _continueAsGuest,
              child: const Text(
                'Explore as Guest',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: OnboardingTokens.textMuted,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SCREEN 3: Your Personal Travel Companion (Image 2)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildScreen3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

          // Hero Image Card (Sri Lankan Cultural Lamp Ceremony)
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: SizedBox(
              height: 270,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1620619767323-b95a89183081?w=1000&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: OnboardingTokens.primaryDark,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.temple_buddhist_rounded,
                        color: Colors.white70,
                        size: 54,
                      ),
                    ),
                  ),

                  // Bottom Overlay Pill: Ask HELA 24/7 Smart Companion
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: InkWell(
                      onTap: _showAskHelaSheet,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7A4810),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Ask HELA',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: OnboardingTokens.textDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: OnboardingTokens.textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                '24/7 Smart Companion',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: OnboardingTokens.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: OnboardingTokens.primaryDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3-Bar Segmented Progress Indicator (All 3 filled)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0E8D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0E8D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: OnboardingTokens.primaryDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Step Badge & Cultural Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: OnboardingTokens.mintBadge,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 03 OF 03',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.primaryDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.spa_rounded,
                    size: 16,
                    color: Color(0xFF7A4810),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Ayubowan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5B380E),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          const Text(
            'Your Personal Travel\nCompanion',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: OnboardingTokens.textDark,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          const Text(
            'Personalized AI trip planning, authentic cultural stories, and transparent local transit — everything you need in the palm of your hand.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: OnboardingTokens.textMuted,
            ),
          ),

          const SizedBox(height: 16),

          // 3 Feature Cards
          _buildFeatureCard(
            icon: Icons.explore_outlined,
            iconColor: OnboardingTokens.primaryDark,
            iconBg: OnboardingTokens.mintBadge,
            title: 'AI Itinerary Planner',
            subtitle: 'Tailored to your tempo, weather & seasons...',
          ),
          const SizedBox(height: 8),
          _buildFeatureCard(
            icon: Icons.temple_buddhist_rounded,
            iconColor: const Color(0xFF8A5A1E),
            iconBg: const Color(0xFFF7EBDC),
            title: 'Local Cultural Guide',
            subtitle: 'Sacred site etiquette, language tips & folklore...',
          ),
          const SizedBox(height: 8),
          _buildFeatureCard(
            icon: Icons.shield_outlined,
            iconColor: OnboardingTokens.primaryDark,
            iconBg: OnboardingTokens.mintBadge,
            title: 'Transparent Verified Rides',
            subtitle: 'Fixed-meter tuk-tuks & trusted island drivers...',
          ),

          const SizedBox(height: 20),

          // Primary CTA: Start Exploring
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _navigateToSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTokens.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Exploring',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Footer link: Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                  fontSize: 13,
                  color: OnboardingTokens.textMuted,
                ),
              ),
              GestureDetector(
                onTap: _navigateToSignIn,
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.primaryDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: OnboardingTokens.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: OnboardingTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
