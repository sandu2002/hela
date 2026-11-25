import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/pages/smart_tour/travel_preferences_page.dart';

/// Smart Tour Planner Home — the entry point for AI-powered trip planning.
///
/// Features:
/// - Hero visual with Sri Lanka travel imagery
/// - Compelling headline and supporting text
/// - "Start Planning" CTA button
/// - Quick travel inspiration cards
class SmartTourHomePage extends StatefulWidget {
  const SmartTourHomePage({super.key});

  @override
  State<SmartTourHomePage> createState() => _SmartTourHomePageState();
}

class _SmartTourHomePageState extends State<SmartTourHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroHeader(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      _buildInfoCards(),
                      const SizedBox(height: 28),
                      _buildInspirationSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      stretch: true,
      backgroundColor: HelaColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient (fallback for image)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D2614),
                    Color(0xFF19331F),
                    Color(0xFF2F4A34),
                  ],
                ),
              ),
            ),
            // Network hero image
            Image.network(
              'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=1000&auto=format&fit=crop&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
            // Dark overlay for text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.65, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            // Hero content
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: HelaColors.tertiaryFixed.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF1A1D00)),
                        SizedBox(width: 6),
                        Text(
                          'AI-Powered Planner',
                          style: TextStyle(
                            color: Color(0xFF1A1D00),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Plan Your Perfect\nSri Lanka Trip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Not sure where to go? Tell us what you love\nand we\'ll craft your ideal itinerary.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Start Planning button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _navigateToPreferences(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HelaColors.tertiaryFixed,
                        foregroundColor: HelaColors.onTertiaryFixed,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Start Planning',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
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

  Widget _buildInfoCards() {
    final cards = [
      _InfoCardData(
        icon: Icons.auto_awesome_rounded,
        title: 'AI-Powered',
        subtitle: 'Smart recommendations tailored to your interests',
        color: HelaColors.primaryContainer,
      ),
      _InfoCardData(
        icon: Icons.verified_rounded,
        title: 'Verified Data',
        subtitle: 'Real places from OpenStreetMap with source attribution',
        color: HelaColors.secondary,
      ),
      _InfoCardData(
        icon: Icons.edit_note_rounded,
        title: 'Fully Customizable',
        subtitle: 'Adjust your itinerary with AI chat or manual controls',
        color: const Color(0xFF4A6741),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How It Works',
          style: TextStyle(
            color: HelaColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        ...cards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildInfoCard(card),
            )),
      ],
    );
  }

  Widget _buildInfoCard(_InfoCardData card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HelaColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: card.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(card.icon, color: card.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  card.subtitle,
                  style: const TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationSection() {
    final inspirations = [
      _InspirationData(
        title: 'Highland Tea Country',
        subtitle: '5 days · Culture & Nature',
        emoji: '🏔️',
      ),
      _InspirationData(
        title: 'Coastal Safari Trail',
        subtitle: '3 days · Wildlife & Beaches',
        emoji: '🐘',
      ),
      _InspirationData(
        title: 'Ancient Kingdoms',
        subtitle: '4 days · Heritage & History',
        emoji: '🏛️',
      ),
      _InspirationData(
        title: 'Romantic Getaway',
        subtitle: '7 days · Romance & Relaxation',
        emoji: '💕',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Need Inspiration?',
          style: TextStyle(
            color: HelaColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Popular trip themes to get you started',
          style: TextStyle(
            color: HelaColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: inspirations
              .map((i) => _buildInspirationChip(i))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInspirationChip(_InspirationData data) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _navigateToPreferences(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: HelaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HelaColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: HelaColors.outline),
          ],
        ),
      ),
    );
  }

  void _navigateToPreferences(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TravelPreferencesPage(),
      ),
    );
  }
}

class _InfoCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _InspirationData {
  final String title;
  final String subtitle;
  final String emoji;

  const _InspirationData({
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}
