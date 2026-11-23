import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/pages/cultural_guide/article_detail_page.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';

/// Unique ID for this cultural guide article (used by HelaAppState)
const String _culturalGuideId = 'sacred-bo-tree-sigiriya';

class CulturalGuidePage extends StatefulWidget {
  const CulturalGuidePage({super.key});

  @override
  State<CulturalGuidePage> createState() => _CulturalGuidePageState();
}

class _CulturalGuidePageState extends State<CulturalGuidePage> {
  bool _isPlayingAudio = false;
  double _audioPosition = 0.34; // simulated position (0.0–1.0)
  double _audioSpeed = 1.0;
  Timer? _audioTimer;

  static const double _totalDurationSec = 750; // 12:30 total

  @override
  void dispose() {
    _audioTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });
    if (_isPlayingAudio) {
      _audioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _audioPosition += (1.0 / _totalDurationSec) * _audioSpeed;
          if (_audioPosition >= 1.0) {
            _audioPosition = 1.0;
            _isPlayingAudio = false;
            _audioTimer?.cancel();
          }
        });
      });
    } else {
      _audioTimer?.cancel();
    }
  }

  void _toggleAudioSpeed() {
    setState(() {
      if (_audioSpeed == 1.0) {
        _audioSpeed = 1.25;
      } else if (_audioSpeed == 1.25) {
        _audioSpeed = 1.5;
      } else {
        _audioSpeed = 1.0;
      }
    });
  }

  String _formatTime(double fraction) {
    final totalSeconds = (fraction * _totalDurationSec).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildNetworkImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: HelaColors.surfaceContainerHigh,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: HelaColors.secondary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HelaColors.primaryContainer, HelaColors.primary],
            ),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, color: HelaColors.onPrimaryContainer, size: 32),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.background,
      appBar: _buildTopAppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 12),
                  _buildAudioGuideSection(),
                  const SizedBox(height: 16),
                  _buildArticleContentSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      backgroundColor: HelaColors.surface.withValues(alpha: 0.92),
      elevation: 0,
      scrolledUnderElevation: 1.5,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HelaHomePage()),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back_rounded, color: HelaColors.primary, size: 24),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: HelaColors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'CULTURAL HERITAGE',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Share.share(
                        'Explore the Sacred Bo Tree & Sigiriya Frescoes on HELA — Discover Sri Lanka 🇱🇰',
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.share_rounded, color: HelaColors.onSurfaceVariant, size: 22),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      final appState = HelaAppStateProvider.of(context);
                      appState.toggleGuide(_culturalGuideId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            appState.isGuideSaved(_culturalGuideId)
                                ? 'Article bookmarked'
                                : 'Bookmark removed',
                          ),
                        ),
                      );
                    },
                    child: Builder(
                      builder: (context) {
                        final isBookmarked = HelaAppStateProvider.of(context).isGuideSaved(_culturalGuideId);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: HelaColors.primary,
                            size: 22,
                          ),
                        );
                      },
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

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Stack(
        children: [
          // Background Decorative Watermark (Mandala SVG styled circles)
          Positioned(
            top: -20,
            right: -30,
            child: SizedBox(
              width: 190,
              height: 190,
              child: CustomPaint(
                painter: _MandalaWatermarkPainter(),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verification archive badge
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: HelaColors.tertiaryFixedDim,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'CEYLON HERITAGE ARCHIVE · VOL. 14',
                    style: TextStyle(
                      color: HelaColors.secondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Article Title
              const Text(
                'The Living Secrets of the Sacred Bo Tree & Sigiriya Frescoes',
                style: TextStyle(
                  color: HelaColors.onSurface,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 14),

              // Curator info
              Container(
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: HelaColors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: HelaColors.secondaryContainer.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: HelaColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Curated by Dr. Indika Bandara',
                          style: TextStyle(
                            color: HelaColors.onSurface,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            Text(
                              'Historian & Folklorist',
                              style: TextStyle(
                                color: HelaColors.onSurfaceVariant,
                                fontSize: 11.5,
                              ),
                            ),
                            Text(
                              ' · ',
                              style: TextStyle(color: HelaColors.onSurfaceVariant),
                            ),
                            Icon(Icons.schedule_rounded, size: 13, color: HelaColors.secondary),
                            SizedBox(width: 3),
                            Text(
                              '7 min read',
                              style: TextStyle(
                                color: HelaColors.secondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioGuideSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Audio Player Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: HelaColors.outlineVariant.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2E24).withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Player Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: HelaColors.primaryContainer,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _togglePlayPause,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: HelaColors.onPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'SPOKEN AUDIO GUIDE',
                              style: TextStyle(
                                color: HelaColors.secondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Voice of Ceylon',
                              style: TextStyle(
                                color: HelaColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Sinhala Folklore Narrator',
                              style: TextStyle(
                                color: HelaColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _toggleAudioSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: HelaColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${_audioSpeed}x',
                          style: const TextStyle(
                            color: HelaColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Simulated Audio Visualizer Bars
                SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(19, (i) {
                      final heights = [3, 4, 5, 3, 6, 4, 5, 2, 4, 3, 5, 4, 2, 4, 3, 5, 2, 4, 2];
                      final h = heights[i];
                      final barPosition = i / 19.0;
                      final isPast = barPosition <= _audioPosition;
                      return Container(
                        width: 4,
                        height: h * 4.0,
                        decoration: BoxDecoration(
                          color: isPast
                              ? (_isPlayingAudio ? HelaColors.tertiaryFixedDim : HelaColors.primaryContainer)
                              : HelaColors.outlineVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),

                // Audio Scrubber Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: HelaColors.secondary,
                    inactiveTrackColor: HelaColors.outlineVariant.withValues(alpha: 0.4),
                    thumbColor: HelaColors.secondary,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    overlayColor: HelaColors.secondary.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: _audioPosition,
                    onChanged: (value) {
                      setState(() {
                        _audioPosition = value;
                      });
                    },
                  ),
                ),

                // Time Duration Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(_audioPosition),
                      style: const TextStyle(
                        color: HelaColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _isPlayingAudio ? 'Listening to Chapter 1' : 'Paused',
                      style: const TextStyle(
                        color: HelaColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '12:30',
                      style: TextStyle(
                        color: HelaColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Offline Save CTA Button
          Builder(
            builder: (context) {
              final isSavedForOffline = HelaAppStateProvider.of(context).isGuideOffline(_culturalGuideId);
              return OutlinedButton(
                onPressed: () {
                  final appState = HelaAppStateProvider.of(context);
                  appState.toggleOfflineGuide(_culturalGuideId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        appState.isGuideOffline(_culturalGuideId)
                            ? 'Guide downloaded for offline reading'
                            : 'Removed from offline storage',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: HelaColors.primary,
                  backgroundColor: HelaColors.surface,
                  side: BorderSide(
                    color: isSavedForOffline ? HelaColors.secondary : HelaColors.secondary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSavedForOffline ? Icons.check_circle_rounded : Icons.cloud_download_rounded,
                      color: HelaColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isSavedForOffline ? 'Saved for Offline Reading' : 'Save Guide for Offline Reading',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Intro with drop-cap styling
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontSize: 15.5,
                height: 1.6,
              ),
              children: const [
                TextSpan(
                  text: 'D',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text:
                      'eep within the ancient kingdom of Anuradhapura stands the Jaya Sri Maha Bodhi, recognized by chroniclers as the world’s oldest recorded tree planted by human hands in 288 BCE. Brought as a southern sapling from Bodh Gaya by Sanghamitta Theri, it represents an unbroken lineage of botanical devotion sustained across two millennia.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Rich Media: Jaya Sri Maha Bodhi Photo Figure
          Container(
            decoration: BoxDecoration(
              color: HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: HelaColors.outlineVariant.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2E24).withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: _buildNetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAYxKw1c9HqNT6wjQDwxM5kvv2d4wqST36qis5qQ20zuDexVTsFD1GGkTL4Az83nyqACt7JvFRjgg1mV8g5g1CPAp7CQfGrz47Mj87TREZv1jz38kyTSauoJWbSPSmkrjEWgpc2qkCZsyqeN_7oPv8N3BKG6kE1oZmd5pG8TRB674PZzI0T9f3RJph8Z6BYSt14p8MWQ3e5X1vH54SM696I-Y3NE_O42ep3KYiUPqS6lxJSrTZIrQdJiA',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: HelaColors.primaryContainer.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'UNESCO World Heritage',
                            style: TextStyle(
                              color: HelaColors.surfaceContainerLowest,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: HelaColors.surfaceContainerLowest,
                      border: Border(
                        top: BorderSide(
                          color: HelaColors.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'The sacred upper terrace at Mahamewna Gardens',
                          style: TextStyle(
                            color: HelaColors.onSurfaceVariant,
                            fontSize: 11.5,
                          ),
                        ),
                        Text(
                          'Photo: Arch. Lanka',
                          style: TextStyle(
                            color: HelaColors.secondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Sigiriya Frescoes Narrative
          const Text(
            'The Sigiriya Frescoes: Clouds and Petals',
            style: TextStyle(
              color: HelaColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Five hundred feet above the surrounding jungle canopy on the western face of the Lion Rock, natural sheltered alcoves preserve the legendary cloud maidens. Rendered in mineral ochres, cinnabar, and clay tempera, the frescoes reflect an era of unparalleled aesthetic subtlety during the 5th-century reign of King Kashyapa.',
            style: TextStyle(
              color: HelaColors.onSurfaceVariant,
              fontSize: 14.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),

          // Pull Quote with Ivory Container & Left Sage Border
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: HelaColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border(
                left: BorderSide(
                  color: HelaColors.secondary,
                  width: 4,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2E24).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '“The golden ladies of the rock do not merely depict celestial nymphs; they celebrate the monsoon mist that sustained the island’s hydraulic civilization.”',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontSize: 16.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '— Mahavamsa Historical Annotations, Chapter XXVIII',
                  style: TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mindful Travel / Etiquette Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HelaColors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: HelaColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.self_improvement_rounded,
                      color: HelaColors.secondary,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Temple Etiquette & Mindful Conduct',
                      style: TextStyle(
                        color: HelaColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Visitors to sacred monastic grounds must wear modest attire covering shoulders and knees; white garments are traditionally preferred as symbols of purity. Always remove footwear and head coverings prior to entering the temple courtyard. Photography with your back turned to the Buddha statue is strictly prohibited.',
                  style: TextStyle(
                    color: HelaColors.onSurface,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildEtiquettePill(Icons.check_circle_rounded, 'White Attire Recommended'),
                    _buildEtiquettePill(Icons.do_not_step_rounded, 'Barefoot Courtyards'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Next Story Card
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UP NEXT IN FOLKLORE',
                style: TextStyle(
                  color: HelaColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ArticleDetailPage(
                        title: 'The Fire Dancers of Kandy',
                        subtitle: 'Rhythm, ritual percussion, and sacred temple fires',
                        authorName: 'Dr. Indika Bandara',
                        readTime: '5 min read',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB3-kdVWZM3O-qKSPOTOUjkBhdviLIEcPxbxEwNVv0tAdMZyNHDEokbqtcE8gxycEa8fZ-bqdZ7tD8pqMviT6eXKtTWjF7lh5iXQyKUEQvrVJ48YsVV6lWFMYYif2wsT-tzYEXOySz4879-dYxtyQBAwCo_F9tef029yUlDHPQuFJR8qlnq20rH8-KoyOWlNh_7bBUFrA3tAzSa3VATvdiXW6qqCQzYA8RRVrTUWMMfnrqebVkZFFu6OQ',
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F2E24).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: _buildNetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuB3-kdVWZM3O-qKSPOTOUjkBhdviLIEcPxbxEwNVv0tAdMZyNHDEokbqtcE8gxycEa8fZ-bqdZ7tD8pqMviT6eXKtTWjF7lh5iXQyKUEQvrVJ48YsVV6lWFMYYif2wsT-tzYEXOySz4879-dYxtyQBAwCo_F9tef029yUlDHPQuFJR8qlnq20rH8-KoyOWlNh_7bBUFrA3tAzSa3VATvdiXW6qqCQzYA8RRVrTUWMMfnrqebVkZFFu6OQ',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'NEXT STORY · 5 MIN',
                              style: TextStyle(
                                color: HelaColors.tertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'The Fire Dancers of Kandy',
                              style: TextStyle(
                                color: HelaColors.onSurface,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Rhythm, ritual percussion, and sacred temple fires',
                              style: TextStyle(
                                color: HelaColors.onSurfaceVariant,
                                fontSize: 11.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: HelaColors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEtiquettePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: HelaColors.secondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: HelaColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw the decorative watermark mandala pattern
class _MandalaWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HelaColors.primary.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, 70, paint);
    canvas.drawCircle(center, 55, paint);
    canvas.drawCircle(center, 40, paint);
    canvas.drawCircle(center, 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
