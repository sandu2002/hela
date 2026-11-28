import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/pages/trip_planner/active_journey_page.dart';
import 'package:hela/pages/ask_hela/ask_hela_page.dart';
import 'package:hela/pages/bookings/fair_ride_page.dart';
import 'package:hela/services/ai_service.dart';
import 'package:hela/widgets/common/hela_network_image.dart';
import 'package:hela/services/route_map_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/maps/live_route_overview_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Itinerary Details Page - 100% matched to Google Stitch Design
/// (Screen d48a0b4b55994a0d876eccbe5db39ab5: HELA - Your Sri Lankan Adventure)
class ItineraryDetailsPage extends StatefulWidget {
  final String startLocation;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;
  final String budgetTier;
  final Set<String> interests;
  final String pace;
  final String extraNotes;
  final TourPlan? aiTourPlan;

  const ItineraryDetailsPage({
    super.key,
    this.startLocation = 'Bandaranaike Intl Airport (CMB)',
    required this.startDate,
    required this.endDate,
    this.adults = 2,
    this.children = 0,
    this.budgetTier = 'comfort',
    this.interests = const {
      'Beaches',
      'Nature',
      'Culture',
      'Hikes & Adventure',
      'Authentic Food',
    },
    this.pace = 'balanced',
    this.extraNotes = '',
    this.aiTourPlan,
  });

  @override
  State<ItineraryDetailsPage> createState() => _ItineraryDetailsPageState();
}

class _ItineraryDetailsPageState extends State<ItineraryDetailsPage> {
  int _selectedDayIndex = 0;
  bool _isSaved = false;
  late TourPlan? _currentPlan;
  final List<ChatMessage> _customizationMessages = [];
  final List<ChatTurn> _geminiCustomizationHistory = [];

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.aiTourPlan;
    _isSaved = widget.aiTourPlan?.isSaved ?? false;
    _loadPersistedCustomizationChat();
  }

  String get _chatStorageKey {
    final planId = _currentPlan?.id.isNotEmpty == true
        ? _currentPlan!.id
        : 'trip_${widget.startLocation.hashCode}_$_tripDays';
    return 'hela_itinerary_chat_$planId';
  }

  Future<void> _loadPersistedCustomizationChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_chatStorageKey);
      if (raw == null || raw.isEmpty || !mounted) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final restored = list
          .map((item) {
            final m = item as Map<String, dynamic>;
            return ChatMessage(
              id: m['id']?.toString() ?? '',
              content: m['content']?.toString() ?? '',
              isUser: m['isUser'] == true,
              timestamp: m['timestamp']?.toString() ?? '',
            );
          })
          .where((m) => m.content.isNotEmpty)
          .toList();

      if (restored.isNotEmpty && mounted) {
        setState(() {
          _customizationMessages
            ..clear()
            ..addAll(restored);
          _geminiCustomizationHistory
            ..clear()
            ..addAll(AIService.buildChatHistoryFromMessages(restored));
        });
      }
    } catch (_) {
      // Ignore corrupt local cache
    }
  }

  Future<void> _savePersistedCustomizationChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _customizationMessages
            .map(
              (m) => {
                'id': m.id,
                'content': m.content,
                'isUser': m.isUser,
                'timestamp': m.timestamp,
              },
            )
            .toList(),
      );
      await prefs.setString(_chatStorageKey, encoded);
    } catch (_) {
      // Ignore persistence errors
    }
  }

  Future<void> _clearCustomizationChat() async {
    setState(() {
      _customizationMessages.clear();
      _geminiCustomizationHistory.clear();
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatStorageKey);
    } catch (_) {}
  }

  TourPlan _ensureEditablePlan() {
    if (_currentPlan != null) return _currentPlan!;
    final days = List.generate(_tripDays, (idx) {
      return ItineraryDay(
        dayNumber: idx + 1,
        title: idx == 0
            ? '${widget.startLocation} → Sri Lanka Highlights'
            : 'Day ${idx + 1} Exploration',
        summary:
            'Curated Sri Lanka journey tailored to ${widget.interests.join(", ")}',
        overnightStay: idx == 0 ? 'Kandy' : 'Ella',
        activities: [
          ItineraryActivity(
            title: idx == 0
                ? 'Departure from ${widget.startLocation}'
                : 'Morning Scenic Excursion',
            description: 'Explore highlights at a ${widget.pace} pace.',
            startTime: '08:30 AM',
            estimatedDuration: '2.5 hours',
            category: 'Exploration',
            estimatedCostUsd: 20,
          ),
        ],
      );
    });
    return TourPlan(
      id: 'tour_${widget.startDate.millisecondsSinceEpoch}',
      title: 'Sri Lanka Bespoke Expedition',
      summary:
          'A $_tripDays-day journey starting from ${widget.startLocation}.',
      durationDays: _tripDays,
      days: days,
    );
  }

  int get _tripDays {
    if (_currentPlan != null && _currentPlan!.days.isNotEmpty) {
      return _currentPlan!.days.length;
    }
    final diff = widget.endDate.difference(widget.startDate).inDays;
    return diff > 0 ? diff : 5;
  }

  List<ItineraryDay> get _days => _currentPlan?.days ?? const [];

  ItineraryDay? get _activeDay {
    if (_days.isEmpty) return null;
    final safeIdx = _selectedDayIndex.clamp(0, _days.length - 1);
    return _days[safeIdx];
  }

  bool get _isDeepSeekGenerated =>
      _currentPlan?.dataSources.any(
        (s) => s.toLowerCase().contains('deepseek'),
      ) ??
      false;

  bool get _isGeminiGenerated =>
      _currentPlan?.dataSources.any(
        (s) => s.toLowerCase().contains('gemini'),
      ) ??
      false;

  String get _aiBadgeLabel {
    if (_isDeepSeekGenerated) return 'DEEPSEEK AI PLAN';
    if (_isGeminiGenerated) return 'GEMINI AI PLAN';
    return 'AI CURATED PLAN';
  }

  String _formatShortDate(int dayOffset) {
    final dt = widget.startDate.add(Duration(days: dayOffset));
    return '${_monthNames[dt.month - 1]} ${dt.day}';
  }

  String _formatFullDate(int dayOffset) {
    final dt = widget.startDate.add(Duration(days: dayOffset));
    return '${_monthNames[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _getDayOrigin(int dayIndex) {
    if (dayIndex <= 0) return widget.startLocation;
    if (dayIndex - 1 < _days.length) {
      final prevStay = _days[dayIndex - 1].overnightStay;
      if (prevStay != null && prevStay.trim().isNotEmpty) {
        return prevStay.trim();
      }
    }
    return widget.startLocation;
  }

  String _getDayDestination(int dayIndex) {
    if (dayIndex < _days.length) {
      final day = _days[dayIndex];
      if (day.overnightStay != null && day.overnightStay!.trim().isNotEmpty) {
        return day.overnightStay!.trim();
      }
      if (day.activities.isNotEmpty) {
        return day.activities.last.title;
      }
      if (day.title.isNotEmpty) return day.title;
    }
    const fallbackStays = [
      'Sigiriya',
      'Kandy',
      'Nuwara Eliya',
      'Ella',
      'Galle',
    ];
    return fallbackStays[dayIndex % fallbackStays.length];
  }

  String _shortLocationLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Sri Lanka';
    final codeMatch = RegExp(r'\(([A-Z]{3})\)').firstMatch(trimmed);
    if (codeMatch != null) return codeMatch.group(1)!;
    final first = trimmed.split(',').first.trim();
    if (first.length <= 20) return first;
    return '${first.substring(0, 18)}…';
  }

  String _estimatedDayCostDisplay(ItineraryDay? day) {
    if (day?.estimatedDayCostUsd != null && day!.estimatedDayCostUsd! > 0) {
      return '~\$${day.estimatedDayCostUsd!.round()}';
    }
    final lower = widget.budgetTier.toLowerCase();
    if (lower.startsWith('custom:')) {
      final amount = int.tryParse(lower.split(':').last) ?? 120;
      return '~\$$amount';
    }
    switch (lower) {
      case 'value':
        return r'~$55';
      case 'luxury':
        return r'~$260';
      case 'comfort':
      default:
        return r'~$140';
    }
  }

  String _formatPaceTitle(String pace) {
    final trimmed = pace.trim().toLowerCase();
    if (trimmed.isEmpty) return 'Balanced';
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  String _imageForActivity(ItineraryActivity act, int index) {
    if (act.destination != null && act.destination!.imageUrl.isNotEmpty) {
      return act.destination!.imageUrl;
    }
    // Check title and category first so arrival/dining stops aren't misclassified by route descriptions.
    final primaryText = '${act.title} ${act.category}'.toLowerCase();
    final fullText = '$primaryText ${act.description}'.toLowerCase();

    for (final text in [primaryText, fullText]) {
      if (text.contains('sigiriya') ||
          text.contains('lion rock') ||
          text.contains('polonnaruwa') ||
          text.contains('anuradhapura') ||
          text.contains('citadel')) {
        return SriLankaImages.sigiriya;
      }
      if (text.contains('rice') ||
          text.contains('curry') ||
          text.contains('feast') ||
          text.contains('lunch') ||
          text.contains('dinner') ||
          text.contains('breakfast') ||
          text.contains('meal') ||
          text.contains('culinary') ||
          text.contains('food')) {
        return SriLankaImages.riceAndCurry;
      }
      if (text.contains('villa') ||
          text.contains('hotel') ||
          text.contains('resort') ||
          text.contains('check-in') ||
          text.contains('stay') ||
          text.contains('lodge')) {
        return SriLankaImages.ella;
      }
      if (text.contains('arrival') ||
          text.contains('airport') ||
          text.contains('cmb') ||
          text.contains('pickup') ||
          text.contains('welcome')) {
        return SriLankaImages.bandaranaikeAirport;
      }
      if (text.contains('kandy') ||
          text.contains('temple') ||
          text.contains('tooth') ||
          text.contains('dalada') ||
          text.contains('cultural')) {
        return SriLankaImages.templeOfTheTooth;
      }
      if (text.contains('ella') ||
          text.contains('tea') ||
          text.contains('train') ||
          text.contains('nuwara') ||
          text.contains('hike') ||
          text.contains('nine arch')) {
        return SriLankaImages.nineArchBridge;
      }
      if (text.contains('galle') || text.contains('fort')) {
        return SriLankaImages.galleFort;
      }
      if (text.contains('yala') ||
          text.contains('udawalawe') ||
          text.contains('safari') ||
          text.contains('wildlife') ||
          text.contains('elephant') ||
          text.contains('leopard')) {
        return SriLankaImages.leopard;
      }
      if (text.contains('beach') ||
          text.contains('mirissa') ||
          text.contains('weligama') ||
          text.contains('arugam') ||
          text.contains('surf') ||
          text.contains('coast') ||
          text.contains('ocean')) {
        return SriLankaImages.mirissa;
      }
    }

    const fallbacks = [
      SriLankaImages.sigiriya,
      SriLankaImages.nineArchBridge,
      SriLankaImages.templeOfTheTooth,
      SriLankaImages.mirissa,
    ];
    return fallbacks[index % fallbacks.length];
  }

  String get _budgetPriceBadge {
    if (_currentPlan?.estimatedTotalCostUsd != null &&
        _currentPlan!.estimatedTotalCostUsd! > 0) {
      return '~\$${_currentPlan!.estimatedTotalCostUsd!.round()} est. total';
    }
    final lower = widget.budgetTier.toLowerCase();
    if (lower.startsWith('custom:')) {
      final amount = int.tryParse(lower.split(':').last) ?? 120;
      return 'Custom (~\$$amount/day)';
    }
    switch (lower) {
      case 'value':
        return r'Value (~$55/day)';
      case 'luxury':
        return r'Luxury (~$260/day)';
      case 'comfort':
      default:
        return r'Boutique (~$140/day)';
    }
  }

  Future<void> _openAiCustomizeSheet() async {
    final basePlan = _ensureEditablePlan();
    if (_currentPlan == null) {
      setState(() => _currentPlan = basePlan);
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AiCustomizeChatSheet(
        initialPlan: basePlan,
        focusedDayNumber: _selectedDayIndex + 1,
        messages: _customizationMessages,
        geminiHistory: _geminiCustomizationHistory,
        onPlanUpdated: (updatedPlan) {
          if (!mounted) return;
          setState(() {
            _currentPlan = updatedPlan;
            if (_days.isNotEmpty && _selectedDayIndex >= _days.length) {
              _selectedDayIndex = 0;
            }
            if (_isSaved) {
              HelaAppStateProvider.of(context).saveTour(updatedPlan);
            }
          });
          _savePersistedCustomizationChat();
        },
        onClearHistory: _clearCustomizationChat,
      ),
    );
  }

  Widget _buildNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return HelaNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFF0B5D56).withValues(alpha: 0.12),
        child: const Center(
          child: Icon(
            Icons.landscape_rounded,
            color: Color(0xFF0B5D56),
            size: 28,
          ),
        ),
      ),
    );
  }

  static const String _fontFamily = 'Plus Jakarta Sans';

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;

    return DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: _fontFamily),
      child: Scaffold(
        backgroundColor: isDark ? colors.background : const Color(0xFFF3FAF7),
        appBar: _buildAppBar(colors, isDark),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 114),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Trip Header Summary Card
                    _buildSummaryHeaderCard(colors),
                    const SizedBox(height: 10),

                    // 2. Quick Action Strip (Save, AI Adjust, Ask HELA, Book Taxi)
                    _buildQuickActionToolbar(colors),
                    const SizedBox(height: 12),

                    // 3. Interactive Scannable Day Selector
                    _buildDaySelector(colors),
                    const SizedBox(height: 14),

                    // 4. Route Map Overview Card
                    _buildRouteMapOverviewCard(colors),
                    const SizedBox(height: 22),

                    // 5. Vertical Timeline Section
                    _buildTimelineSection(colors),
                    const SizedBox(height: 18),

                    // 5b. AI Travel Tips & Advisories (when generated)
                    if (_currentPlan != null &&
                        (_currentPlan!.travelTips.isNotEmpty ||
                            _currentPlan!.warnings.isNotEmpty)) ...[
                      _buildAiTipsAndWarningsCard(colors),
                      const SizedBox(height: 18),
                    ],

                    // 6. AI Travel Assistant Dynamic Callout
                    _buildAiAssistantCallout(colors),
                    const SizedBox(height: 16),

                    // 7. HELA Fair-Price Assurance Card
                    _buildFairPriceAssuranceCard(colors),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildStickyBottomBar(colors),
      ),
    );
  }

  // ==========================================
  // TOP APP BAR
  // ==========================================
  PreferredSizeWidget _buildAppBar(HelaColorPalette colors, bool isDark) {
    final appState = HelaAppStateProvider.of(context);
    return AppBar(
      backgroundColor: (isDark ? colors.background : const Color(0xFFF3FAF7))
          .withValues(alpha: 0.96),
      elevation: 0,
      scrolledUnderElevation: 0.8,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: colors.architecturalBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 19,
                color: colors.onSurface,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        appState.tr('itinerary_details'),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: colors.onSurface,
          fontFamily: _fontFamily,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Share itinerary',
          icon: Icon(
            Icons.ios_share_rounded,
            size: 19,
            color: colors.onSurface,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Itinerary share link copied to clipboard!'),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: colors.onSurfaceVariant,
          ),
          onSelected: (value) {
            if (value == 'guide') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FairRidePage()),
              );
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Option selected: $value')));
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'pdf',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf_outlined, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Export Itinerary as PDF',
                    style: TextStyle(fontFamily: _fontFamily),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'offline',
              child: Row(
                children: [
                  Icon(Icons.download_for_offline_outlined, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Download for Offline Use',
                    style: TextStyle(fontFamily: _fontFamily),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'guide',
              child: Row(
                children: [
                  Icon(Icons.local_taxi_outlined, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Connect with Local Chauffeur',
                    style: TextStyle(fontFamily: _fontFamily),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // 1. TRIP HEADER SUMMARY CARD
  // ==========================================
  Widget _buildSummaryHeaderCard(HelaColorPalette colors) {
    final isDark = colors.isDark;
    final title = _currentPlan?.title.isNotEmpty == true
        ? _currentPlan!.title
        : 'Cultural Wonders & Emerald Peaks';
    final summary = _currentPlan?.summary.isNotEmpty == true
        ? _currentPlan!.summary
        : 'Sri Lanka Grand Highlights Expedition';
    final nights = _tripDays > 1 ? _tripDays - 1 : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.5)
              : const Color(0xFFD6EAE4),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0A4D46)).withValues(
              alpha: isDark ? 0.25 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top AI Badge & Edit Preferences Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.primary.withValues(alpha: 0.16)
                        : const Color(0xFFE3F5EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _aiBadgeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                            letterSpacing: 0.5,
                            fontFamily: _fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.surfaceContainerLow
                        : const Color(0xFFF3FAF7),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? colors.outlineVariant.withValues(alpha: 0.4)
                          : const Color(0xFFD5EBE4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 12.5,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit Preferences',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                          fontFamily: _fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Title & Concise Subtitle
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              fontFamily: _fontFamily,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              height: 1.35,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: 9),

          // Clean Metadata Pills
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: [
              _buildBadgePill(
                Icons.calendar_today_rounded,
                '$_tripDays Days / $nights Nights',
                colors,
              ),
              _buildBadgePill(
                Icons.group_outlined,
                '${widget.adults + widget.children} Travellers',
                colors,
              ),
              _buildBadgePill(
                Icons.payments_outlined,
                _budgetPriceBadge,
                colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePill(IconData icon, String label, HelaColorPalette colors) {
    final isDark = colors.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerLow : const Color(0xFFEFF8F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.35)
              : const Color(0xFFD8EDE7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
                fontFamily: _fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. QUICK ACTION BAR (Save, AI Adjust, Ask HELA, Book Taxi)
  // ==========================================
  Widget _buildQuickActionToolbar(HelaColorPalette colors) {
    final isDark = colors.isDark;
    final adjustCount = _customizationMessages.length ~/ 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.5)
              : const Color(0xFFD6EAE4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildActionToolItem(
            icon: _isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            label: _isSaved ? 'Saved' : 'Save',
            iconColor: _isSaved ? const Color(0xFFE11D48) : colors.primary,
            isActive: _isSaved,
            colors: colors,
            onTap: () {
              final appState = HelaAppStateProvider.of(context);
              if (_currentPlan != null) {
                appState.toggleSaveTour(_currentPlan!);
                setState(
                  () => _isSaved = appState.isTourSaved(_currentPlan!.id),
                );
              } else {
                setState(() => _isSaved = !_isSaved);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isSaved
                        ? 'Itinerary bookmarked to your Saved Trips!'
                        : 'Itinerary removed from Saved Trips.',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          _buildToolbarDivider(colors),
          _buildActionToolItem(
            icon: Icons.auto_fix_high_rounded,
            label: adjustCount > 0 ? 'AI Adjust ($adjustCount)' : 'AI Adjust',
            iconColor: colors.primary,
            colors: colors,
            onTap: _openAiCustomizeSheet,
          ),
          _buildToolbarDivider(colors),
          _buildActionToolItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Ask HELA',
            iconColor: colors.goldenAmber,
            colors: colors,
            onTap: () {
              final day = _activeDay;
              final summaryPrompt = day != null
                  ? 'I am looking at Day ${day.dayNumber} ("${day.title}") of my "${_currentPlan?.title ?? "Sri Lanka"}" trip starting from ${widget.startLocation}. Can you give me extra local insider tips for this day?'
                  : 'Can you help me with my $_tripDays-day Sri Lanka trip starting from ${widget.startLocation}?';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AskHelaPage(initialPrompt: summaryPrompt),
                ),
              );
            },
          ),
          _buildToolbarDivider(colors),
          _buildActionToolItem(
            icon: Icons.local_taxi_outlined,
            label: 'Book Taxi',
            iconColor: colors.primary,
            colors: colors,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FairRidePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarDivider(HelaColorPalette colors) {
    return Container(
      width: 1,
      height: 22,
      color: colors.architecturalBorder.withValues(alpha: 0.7),
    );
  }

  Widget _buildActionToolItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required HelaColorPalette colors,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final isDark = colors.isDark;
    return Expanded(
      child: Material(
        color: isActive
            ? iconColor.withValues(alpha: isDark ? 0.16 : 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(height: 2.5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                    fontFamily: _fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. INTERACTIVE SCANNABLE DAY SELECTOR
  // ==========================================
  Widget _buildDaySelector(HelaColorPalette colors) {
    final isDark = colors.isDark;
    final days = _days.isNotEmpty
        ? List.generate(_days.length, (idx) {
            final d = _days[idx];
            return {
              'day': 'Day ${d.dayNumber}',
              'date': _formatShortDate(idx),
              'route': d.title.isNotEmpty
                  ? d.title
                  : (d.overnightStay ?? 'Sri Lanka Route'),
            };
          })
        : List.generate(_tripDays, (idx) {
            const fallbackRoutes = [
              'Arrival & Heritage',
              'Cultural Triangle',
              'Kandy Tea Hills',
              'Ella Misty Rails',
              'Southern Coast',
            ];
            return {
              'day': 'Day ${idx + 1}',
              'date': _formatShortDate(idx),
              'route': fallbackRoutes[idx % fallbackRoutes.length],
            };
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Text(
                'Schedule by Day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  fontFamily: _fontFamily,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? colors.primary.withValues(alpha: 0.16)
                      : const Color(0xFFE3F5EF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${days.length} Days',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                    fontFamily: _fontFamily,
                  ),
                ),
              ),
              const Spacer(),
              if (days.length > 1)
                Row(
                  children: [
                    _buildDayNavChevron(
                      icon: Icons.chevron_left_rounded,
                      enabled: _selectedDayIndex > 0,
                      colors: colors,
                      onTap: () => setState(
                        () => _selectedDayIndex = (_selectedDayIndex - 1).clamp(
                          0,
                          days.length - 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    _buildDayNavChevron(
                      icon: Icons.chevron_right_rounded,
                      enabled: _selectedDayIndex < days.length - 1,
                      colors: colors,
                      onTap: () => setState(
                        () => _selectedDayIndex = (_selectedDayIndex + 1).clamp(
                          0,
                          days.length - 1,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(days.length, (idx) {
              final isSelected = _selectedDayIndex == idx;
              final d = days[idx];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedDayIndex = idx),
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(
                      minWidth: 104,
                      maxWidth: 174,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.cardBackground,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : (isDark
                                  ? colors.outlineVariant.withValues(alpha: 0.5)
                                  : const Color(0xFFD5EBE4)),
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.24),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              d['day']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? (isDark ? colors.onPrimary : Colors.white)
                                    : colors.onSurface,
                                fontFamily: _fontFamily,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                d['date']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? (isDark
                                            ? colors.onPrimary.withValues(
                                                alpha: 0.8,
                                              )
                                            : colors.secondaryContainer)
                                      : colors.onSurfaceVariant,
                                  fontFamily: _fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d['route']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? (isDark
                                      ? colors.onPrimary.withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.88))
                                : colors.onSurfaceVariant,
                            fontFamily: _fontFamily,
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
      ],
    );
  }

  Widget _buildDayNavChevron({
    required IconData icon,
    required bool enabled,
    required HelaColorPalette colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: colors.cardBackground,
      shape: CircleBorder(
        side: BorderSide(
          color: colors.architecturalBorder.withValues(
            alpha: enabled ? 0.9 : 0.4,
          ),
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? colors.primary
                : colors.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 4. DAY ROUTE OVERVIEW CARD
  // ==========================================
  Widget _buildRouteMapOverviewCard(HelaColorPalette colors) {
    final isDark = colors.isDark;
    final day = _activeDay;
    final dayNum = day?.dayNumber ?? (_selectedDayIndex + 1);
    final origin = _getDayOrigin(_selectedDayIndex);
    final destination = _getDayDestination(_selectedDayIndex);
    final conciseRoute =
        '${_shortLocationLabel(origin)} → ${_shortLocationLabel(destination)}';
    final stopNames = day != null && day.activities.isNotEmpty
        ? day.activities.map((a) => a.title).take(3).join(' → ')
        : conciseRoute;
    final dayCostText = _estimatedDayCostDisplay(day);
    final overnightText =
        (day?.overnightStay != null && day!.overnightStay!.isNotEmpty)
        ? day.overnightStay!
        : destination;
    final stopsCount = day?.activities.length ?? 4;
    final routeStops = RouteMapService.buildDayRouteStops(
      originLabel: origin,
      destinationLabel: destination,
      day: day,
    );

    void openExpandedRouteMap() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveRouteMapPage(
            dayNumber: dayNum,
            dateText: _formatFullDate(_selectedDayIndex),
            routeTitle: stopNames,
            origin: origin,
            destination: destination,
            stops: routeStops,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.5)
              : const Color(0xFFD6EAE4),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0A4D46)).withValues(
              alpha: isDark ? 0.25 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.primary.withValues(alpha: 0.16)
                            : const Color(0xFFE3F5EF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.alt_route_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Day $dayNum Route Overview',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          fontFamily: _fontFamily,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: openExpandedRouteMap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.surfaceContainerLow
                        : const Color(0xFFEFF8F5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Expand',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                          fontFamily: _fontFamily,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.open_in_full_rounded,
                        size: 12,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // Live interactive route map with real-time GPS location
          LiveRouteOverviewMap(
            dayNumber: dayNum,
            routeSummary: conciseRoute,
            stops: routeStops,
            stopsCount: stopsCount,
            height: 185,
            onExpandTap: openExpandedRouteMap,
          ),
          const SizedBox(height: 10),

          // Clean 3-Cell Route Specs Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerLow
                  : const Color(0xFFF3FAF7),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isDark
                    ? colors.outlineVariant.withValues(alpha: 0.35)
                    : const Color(0xFFE0F0EB),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildRouteSpec(
                      Icons.bedtime_outlined,
                      'Overnight',
                      overnightText,
                      colors,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colors.architecturalBorder.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildRouteSpec(
                      Icons.payments_outlined,
                      'Est. Day Cost',
                      dayCostText,
                      colors,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colors.architecturalBorder.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _buildRouteSpec(
                      Icons.speed_rounded,
                      'Pace',
                      _formatPaceTitle(widget.pace),
                      colors,
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

  Widget _buildRouteSpec(
    IconData icon,
    String label,
    String value,
    HelaColorPalette colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: colors.primary),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.onSurfaceVariant,
                    fontFamily: _fontFamily,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              fontFamily: _fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. TIMELINE SECTION (DYNAMIC AI STOPS)
  // ==========================================
  String _costLabelForActivity(ItineraryActivity act) {
    final lower = '${act.category} ${act.title}'.toLowerCase();
    if (lower.contains('meal') ||
        lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('breakfast') ||
        lower.contains('feast') ||
        lower.contains('food') ||
        lower.contains('culinary')) {
      return 'Meal Estimate';
    }
    if (lower.contains('unesco') ||
        lower.contains('sigiriya') ||
        lower.contains('ticket')) {
      return 'UNESCO Official Ticket';
    }
    if (lower.contains('villa') ||
        lower.contains('hotel') ||
        lower.contains('resort') ||
        lower.contains('stay')) {
      return 'Accommodation Estimate';
    }
    return 'Estimated Cost';
  }

  String _costValueForActivity(ItineraryActivity act) {
    if (act.estimatedCostUsd != null) {
      final cost = act.estimatedCostUsd!;
      if (cost <= 0) {
        return widget.budgetTier == 'luxury'
            ? 'Included in Luxury Package'
            : 'Included in Boutique Package';
      }
      final lower = '${act.category} ${act.title}'.toLowerCase();
      if (lower.contains('unesco') || lower.contains('sigiriya')) {
        return '~\$${cost.toStringAsFixed(0)} / adult (Official Rate)';
      }
      if (lower.contains('meal') ||
          lower.contains('lunch') ||
          lower.contains('dinner')) {
        final low = (cost * 0.8).round();
        final high = (cost * 1.2).round();
        return 'Approx. \$$low - \$$high / person';
      }
      return '~\$${cost.toStringAsFixed(0)} / person';
    }
    return 'Included / Flexible';
  }

  IconData _transitIconForMethod(String? method) {
    final lower = (method ?? '').toLowerCase();
    if (lower.contains('tuk')) return Icons.electric_rickshaw_rounded;
    if (lower.contains('train') || lower.contains('rail')) {
      return Icons.train_rounded;
    }
    if (lower.contains('walk')) return Icons.directions_walk_rounded;
    return Icons.directions_car_rounded;
  }

  Widget _buildTimelineSection(HelaColorPalette colors) {
    final day = _activeDay;
    final List<_TimelineStopData> stops;

    if (day != null && day.activities.isNotEmpty) {
      stops = List.generate(day.activities.length, (i) {
        final act = day.activities[i];
        final nextAct = (i + 1 < day.activities.length)
            ? day.activities[i + 1]
            : null;
        String? transitMethod;
        String? transitDetail;
        if (nextAct != null) {
          final method = nextAct.travelMethod?.trim();
          final time = nextAct.travelTimeFromPrevious?.trim();
          transitMethod = (method != null && method.isNotEmpty)
              ? method
              : 'Private Chauffeur AC Car';
          transitDetail = (time != null && time.isNotEmpty)
              ? time
              : 'Transfer to ${nextAct.title}';
        }

        final isFeatured =
            act.tips.isNotEmpty ||
            act.title.toLowerCase().contains('sigiriya') ||
            act.category.toLowerCase().contains('unesco') ||
            act.estimatedDuration.toLowerCase().contains('must-see');

        return _TimelineStopData(
          number: '${i + 1}',
          time: act.startTime.isNotEmpty ? act.startTime : 'Stop ${i + 1}',
          duration: act.estimatedDuration.isNotEmpty
              ? act.estimatedDuration
              : (act.category.isNotEmpty ? act.category : 'Curated'),
          title: act.title,
          imageUrl: _imageForActivity(act, i),
          description: act.description,
          costLabel: _costLabelForActivity(act),
          costValue: _costValueForActivity(act),
          isHighlight: isFeatured,
          insiderTip: act.tips.isNotEmpty ? act.tips.first : null,
          transitMethod: transitMethod,
          transitDetail: transitDetail,
        );
      });
    } else {
      stops = const [
        _TimelineStopData(
          number: '1',
          time: '08:30 AM',
          duration: '~1 hr',
          title: 'Arrival & Tropical Welcome at CMB',
          imageUrl: SriLankaImages.bandaranaikeAirport,
          description:
              'Private AC car pickup, high-speed Dialog SIM setup, fresh Thambili (king coconut) welcome drink, and departure towards the lush Central Province.',
          costLabel: 'Estimated Cost',
          costValue: 'Included in Boutique Package',
          transitMethod: 'Private Chauffeur AC Car',
          transitDetail: '140 km (~3h 20m via Ambepussa)',
        ),
        _TimelineStopData(
          number: '2',
          time: '12:30 PM',
          duration: '~1.5 hr',
          title: 'Traditional Rice & Curry Feast at Kurunegala',
          imageUrl: SriLankaImages.riceAndCurry,
          description:
              'Clay-pot village feast with fragrant coconut sambol, creamy dhal curry, polos (jackfruit curry), and fresh lake fish in an open-air garden pavilion.',
          costLabel: 'Meal Estimate',
          costValue: r'Approx. $8 - $12 / person',
          isMealHighlight: true,
          transitMethod: 'Country Road Drive',
          transitDetail: '38 km (~45m scenic country path)',
        ),
        _TimelineStopData(
          number: '3',
          time: '03:30 PM',
          duration: 'Must-See Wonder',
          title: 'Ascent of Sigiriya Lion Rock Citadel',
          imageUrl: SriLankaImages.sigiriya,
          description:
              'Golden-hour climb of King Kashyapa\'s UNESCO 5th-century palace fortress. Explore landscaped water gardens, the ancient Mirror Wall poetry, and sweeping 360° summit views.',
          costLabel: 'UNESCO Official Ticket',
          costValue: r'~$36 / adult (Official Rate)',
          isHighlight: true,
          insiderTip:
              'Ascending after 3:30 PM avoids harsh tropical midday heat and catches golden photography light on the west-facing lion paw terrace.',
          transitMethod: 'Scenic Tuk-Tuk Hop',
          transitDetail: '4 km (~10m jungle border lane)',
        ),
        _TimelineStopData(
          number: '4',
          time: '07:30 PM',
          duration: 'Evening Rest',
          title: 'Boutique Heritage Villa Check-In & Dinner',
          imageUrl: SriLankaImages.ella,
          description:
              'Unwind at an eco-resort overlooking the misty jungle canopy with traditional herbal tea and curated Sri Lankan fusion dining.',
          costLabel: 'Accommodation Estimate',
          costValue: 'Included in Boutique Package',
        ),
      ];
    }

    final dayTitle = day?.title.isNotEmpty == true
        ? day!.title
        : 'Arrival to the Ancient Citadel';
    final daySubtitle = day?.summary.isNotEmpty == true
        ? '${day!.summary} • ${stops.length} Curated Stops'
        : '$dayTitle • ${stops.length} Curated Stops';
    final isDark = colors.isDark;
    final highlightColor = isDark
        ? colors.goldenAmber
        : const Color(0xFF9A6700);
    final highlightBg = isDark
        ? colors.goldenAmber.withValues(alpha: 0.16)
        : const Color(0xFFFEF3C7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${day?.dayNumber ?? (_selectedDayIndex + 1)} Itinerary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: colors.onSurface,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    daySubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                      fontFamily: _fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.primary.withValues(alpha: 0.16)
                    : const Color(0xFFE3F5EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _formatShortDate(_selectedDayIndex),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                  fontFamily: _fontFamily,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Vertical Nodes with IntrinsicHeight connector line
        ...List.generate(stops.length, (idx) {
          final stop = stops[idx];
          final isLast = idx == stops.length - 1;
          final isHighlight = stop.isHighlight;
          final hasTip = stop.insiderTip != null && stop.insiderTip!.isNotEmpty;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline bullet node & continuous vertical track
                SizedBox(
                  width: 26,
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isHighlight ? highlightColor : colors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isHighlight
                                          ? highlightColor
                                          : colors.primary)
                                      .withValues(alpha: 0.22),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            stop.number,
                            style: TextStyle(
                              color: isDark && !isHighlight
                                  ? colors.onPrimary
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              fontFamily: _fontFamily,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: colors.architecturalBorder.withValues(
                                alpha: 0.75,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Stop Card + Transit Banner
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 4 : 18),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? colors.outlineVariant.withValues(alpha: 0.5)
                                  : const Color(0xFFD6EAE4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? Colors.black
                                            : const Color(0xFF0A4D46))
                                        .withValues(
                                          alpha: isDark ? 0.24 : 0.045,
                                        ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time + Duration/Highlight Pill
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 14,
                                        color: isHighlight
                                            ? highlightColor
                                            : colors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        stop.time,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: isHighlight
                                              ? highlightColor
                                              : colors.primary,
                                          fontFamily: _fontFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHighlight
                                            ? highlightBg
                                            : (isDark
                                                  ? colors.surfaceContainerLow
                                                  : const Color(0xFFEFF8F5)),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        stop.duration,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isHighlight
                                              ? highlightColor
                                              : colors.onSurfaceVariant,
                                          fontFamily: _fontFamily,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Title
                              Text(
                                stop.title,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                  height: 1.25,
                                  letterSpacing: -0.2,
                                  fontFamily: _fontFamily,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Landmark Photo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 136,
                                  width: double.infinity,
                                  child: _buildNetworkImage(stop.imageUrl),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Description
                              Text(
                                stop.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                  height: 1.44,
                                  fontFamily: _fontFamily,
                                ),
                              ),

                              // Insider Tip Box
                              if (hasTip) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colors.surfaceContainerLow
                                        : const Color(0xFFEAF7F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.tips_and_updates_rounded,
                                        size: 16,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Insider Tip: ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: colors.onSurface,
                                                  fontFamily: _fontFamily,
                                                ),
                                              ),
                                              TextSpan(
                                                text: stop.insiderTip!,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                  height: 1.35,
                                                  fontFamily: _fontFamily,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),

                              // Cost Row (Label left, Tinted Pill Badge right)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      stop.costLabel,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: colors.onSurfaceVariant,
                                        fontFamily: _fontFamily,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: stop.isMealHighlight
                                            ? (isDark
                                                  ? colors.goldenAmber
                                                        .withValues(alpha: 0.16)
                                                  : const Color(0xFFF5F1D8))
                                            : (isDark
                                                  ? colors.surfaceContainerLow
                                                  : const Color(0xFFE4F4EF)),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        stop.costValue,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: stop.isMealHighlight
                                              ? (isDark
                                                    ? colors.goldenAmber
                                                    : const Color(0xFF5D5314))
                                              : colors.primary,
                                          fontFamily: _fontFamily,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Next Transit Banner
                        if (stop.transitMethod != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colors.surfaceContainerLow
                                  : const Color(0xFFF1F9F6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? colors.outlineVariant.withValues(
                                        alpha: 0.4,
                                      )
                                    : const Color(0xFFD6EAE4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _transitIconForMethod(stop.transitMethod),
                                  size: 16,
                                  color: isHighlight
                                      ? highlightColor
                                      : colors.primary,
                                ),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 135,
                                  ),
                                  child: Text(
                                    '${stop.transitMethod}:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurface,
                                      fontFamily: _fontFamily,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    stop.transitDetail ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.onSurfaceVariant,
                                      fontFamily: _fontFamily,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // 5b. AI TRAVEL TIPS & ADVISORIES CARD
  // ==========================================
  Widget _buildAiTipsAndWarningsCard(HelaColorPalette colors) {
    final tips = _currentPlan?.travelTips ?? const [];
    final warnings = _currentPlan?.warnings ?? const [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'AI Local Tips & Advisories',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  fontFamily: _fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips
              .take(3)
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                            height: 1.35,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ...warnings
              .take(2)
              .map(
                (warn) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: colors.goldenAmber,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          warn,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                            height: 1.35,
                            fontFamily: _fontFamily,
                          ),
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

  // ==========================================
  // 6. AI TRAVEL ASSISTANT DYNAMIC CALLOUT
  // ==========================================
  Widget _buildAiAssistantCallout(HelaColorPalette colors) {
    final isDark = colors.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00443E), Color(0xFF0B5D56)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00443E).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF196E65),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 20,
              color: Color(0xFFAAF0E6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need custom changes to Day ${_selectedDayIndex + 1}?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: _fontFamily,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Swap stops, adjust timings, or fine-tune stays live using DeepSeek & Gemini AI.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFC5EBE4),
                    height: 1.35,
                    fontFamily: _fontFamily,
                  ),
                ),
                const SizedBox(height: 11),
                InkWell(
                  onTap: _openAiCustomizeSheet,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? colors.surfaceContainer : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_fix_high_rounded,
                          size: 14,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _customizationMessages.isNotEmpty
                              ? 'Ask HELA to Adjust Day ${_selectedDayIndex + 1} (${_customizationMessages.length ~/ 2})'
                              : 'Ask HELA to Adjust Day ${_selectedDayIndex + 1}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 7. HELA FAIR-PRICE ASSURANCE CARD
  // ==========================================
  Widget _buildFairPriceAssuranceCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.architecturalBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'HELA Fair-Price Assurance',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  fontFamily: _fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'All transfers in this itinerary utilize government-vetted tourist chauffeurs and official meter pricing. No hidden fuel surcharges or surprise tourist markups.',
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
              height: 1.35,
              fontFamily: _fontFamily,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'SLTDA Tourist Board Registered',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                            fontFamily: _fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Free cancellation up to 24h',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                            fontFamily: _fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  // ==========================================
  // FIXED BOTTOM STICKY BOOKING BAR
  // ==========================================
  Widget _buildStickyBottomBar(HelaColorPalette colors) {
    final appState = HelaAppStateProvider.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: colors.architecturalBorder)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final day = _activeDay;
                      final routeTitle =
                          day != null && day.activities.isNotEmpty
                          ? day.activities
                                .map((a) => a.title)
                                .take(3)
                                .join(' → ')
                          : '${_getDayOrigin(_selectedDayIndex)} → ${_getDayDestination(_selectedDayIndex)}';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveJourneyPage(
                            dayNumber:
                                day?.dayNumber ?? (_selectedDayIndex + 1),
                            dateText: _formatFullDate(_selectedDayIndex),
                            routeTitle: routeTitle,
                            origin: _getDayOrigin(_selectedDayIndex),
                            destination: _getDayDestination(_selectedDayIndex),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.isDark
                          ? colors.onPrimary
                          : Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appState.tr('start_my_journey'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFamily: _fontFamily,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_for_offline_rounded,
                      size: 13,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Turn-by-turn live navigation & offline mode included',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colors.onSurfaceVariant,
                          fontFamily: _fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineStopData {
  final String number;
  final String time;
  final String duration;
  final String title;
  final String imageUrl;
  final String description;
  final String costLabel;
  final String costValue;
  final bool isHighlight;
  final bool isMealHighlight;
  final String? insiderTip;
  final String? transitMethod;
  final String? transitDetail;

  const _TimelineStopData({
    required this.number,
    required this.time,
    required this.duration,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.costLabel,
    required this.costValue,
    this.isHighlight = false,
    this.isMealHighlight = false,
    this.insiderTip,
    this.transitMethod,
    this.transitDetail,
  });
}

/// Multi-turn Gemini AI customization chat bottom sheet that preserves full
/// conversation history and updates the live itinerary in place.
class _AiCustomizeChatSheet extends StatefulWidget {
  final TourPlan initialPlan;
  final int focusedDayNumber;
  final List<ChatMessage> messages;
  final List<ChatTurn> geminiHistory;
  final ValueChanged<TourPlan> onPlanUpdated;
  final Future<void> Function() onClearHistory;

  const _AiCustomizeChatSheet({
    required this.initialPlan,
    required this.focusedDayNumber,
    required this.messages,
    required this.geminiHistory,
    required this.onPlanUpdated,
    required this.onClearHistory,
  });

  @override
  State<_AiCustomizeChatSheet> createState() => _AiCustomizeChatSheetState();
}

class _AiCustomizeChatSheetState extends State<_AiCustomizeChatSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();

  late TourPlan _activePlan;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _activePlan = widget.initialPlan;
    if (widget.messages.isNotEmpty) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendRequest(String rawText) async {
    final query = rawText.trim();
    if (query.isEmpty || _isSending) return;

    _inputController.clear();
    final ts = _nowTime();

    setState(() {
      widget.messages.add(
        ChatMessage(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}',
          content: query,
          isUser: true,
          timestamp: ts,
        ),
      );
      _isSending = true;
    });
    _scrollToBottom();

    final updated = await _aiService.customizeTourPlan(
      currentPlan: _activePlan,
      userRequest: query,
      chatHistory: widget.geminiHistory,
      focusedDayNumber: widget.focusedDayNumber,
    );

    if (!mounted) return;

    final replyText = updated.customizationSummary?.trim().isNotEmpty == true
        ? updated.customizationSummary!.trim()
        : 'Updated your itinerary to v${updated.version} based on your request.';

    setState(() {
      _activePlan = updated;
      widget.messages.add(
        ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          content: replyText,
          isUser: false,
          timestamp: _nowTime(),
          updatedPlan: updated,
        ),
      );
      _isSending = false;
    });

    widget.onPlanUpdated(updated);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final suggestions = [
      'Make Day ${widget.focusedDayNumber} more relaxed',
      'Add a local Sri Lankan food stop on Day ${widget.focusedDayNumber}',
      'Include a scenic train ride or sunset viewpoint',
    ];

    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontFamily: _ItineraryDetailsPageState._fontFamily,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.architecturalBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 10, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: colors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask HELA • Adjust Day ${widget.focusedDayNumber}',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            Text(
                              widget.geminiHistory.isEmpty
                                  ? 'DeepSeek AI remembers our chat history as we refine'
                                  : 'Memory active • ${widget.messages.length} messages saved',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.messages.isNotEmpty)
                        IconButton(
                          tooltip: 'Clear Chat Memory',
                          icon: Icon(
                            Icons.delete_sweep_outlined,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                          onPressed: _isSending
                              ? null
                              : () async {
                                  await widget.onClearHistory();
                                  if (mounted) setState(() {});
                                },
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.architecturalBorder),

                // Chat History Scroll View
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    children: [
                      // Welcome / Memory Intro Bubble
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.architecturalBorder),
                        ),
                        child: Text(
                          'Ayubowan! Tell me how to customize Day ${widget.focusedDayNumber} or any part of "${_activePlan.title}". I remember every previous change we make so you can follow up naturally.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: suggestions.map((s) {
                          return ActionChip(
                            label: Text(
                              s,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: _isSending
                                ? null
                                : () => _sendRequest(s),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      ...widget.messages.map((msg) {
                        if (msg.isUser) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: 10,
                                left: 48,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    msg.content,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    msg.timestamp,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              right: 36,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(4),
                              ),
                              border: Border.all(
                                color: colors.architecturalBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 13,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      msg.updatedPlan != null
                                          ? 'Itinerary Updated (v${msg.updatedPlan!.version})'
                                          : 'HELA AI Assistant',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  msg.content,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  msg.timestamp,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      if (_isSending)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'DeepSeek AI is updating your itinerary...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Input Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 8, 10, 12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      top: BorderSide(color: colors.architecturalBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendRequest,
                          decoration: InputDecoration(
                            hintText:
                                'Ask to swap stops, change pace, or follow up...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            filled: true,
                            fillColor: colors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: colors.architecturalBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: colors.architecturalBorder,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: colors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _isSending
                              ? null
                              : () => _sendRequest(_inputController.text),
                          child: const Padding(
                            padding: EdgeInsets.all(11),
                            child: Icon(
                              Icons.send_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
