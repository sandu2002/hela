import 'package:flutter/material.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/state/tour_planner_state.dart';
import 'package:hela/pages/saved/saved_page.dart';
import 'package:hela/pages/home/home_page.dart';
import 'package:hela/pages/smart_tour/ai_chat_customization_page.dart';

/// Detailed view of the AI-generated tour plan and day-by-day itinerary.
class TourPlanDetailsPage extends StatefulWidget {
  final TourPlan plan;
  final TourPreferences? preferences;

  const TourPlanDetailsPage({super.key, required this.plan, this.preferences});

  @override
  State<TourPlanDetailsPage> createState() => _TourPlanDetailsPageState();
}

class _TourPlanDetailsPageState extends State<TourPlanDetailsPage> {
  late TourPlan _currentPlan;
  int _selectedDayIndex = 0;
  bool _isSaved = false;
  bool _isInitialized = false;

  TourPreferences get _effectivePreferences =>
      widget.preferences ?? const TourPreferences();

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
    _isSaved = widget.plan.isSaved;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final appState = HelaAppStateProvider.of(context);
      _isSaved = appState.isTourSaved(_currentPlan.id) || widget.plan.isSaved;
      _isInitialized = true;
    }
  }

  void _handleSave() {
    final appState = HelaAppStateProvider.of(context);
    final tourState = TourPlannerStateProvider.of(context);
    final willSave = !_isSaved;

    setState(() => _isSaved = willSave);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (willSave) {
      final savedPlan = _currentPlan.copyWith(isSaved: true);
      _currentPlan = savedPlan;
      appState.saveTour(savedPlan);
      tourState.saveTour(savedPlan);

      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          persist: false,
          content: Row(
            children: [
              const Icon(
                Icons.bookmark_added_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Saved "${_currentPlan.title}" to your Saved Page!',
                ),
              ),
            ],
          ),
          backgroundColor: HelaColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: HelaColors.tertiaryFixed,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SavedPage()));
            },
          ),
        ),
      );
    } else {
      final unsavedPlan = _currentPlan.copyWith(isSaved: false);
      _currentPlan = unsavedPlan;
      appState.removeSavedTour(_currentPlan.id);
      tourState.removeSavedTour(_currentPlan.id);

      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          persist: false,
          content: Row(
            children: [
              const Icon(
                Icons.bookmark_remove_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Removed "${_currentPlan.title}" from Saved Page'),
              ),
            ],
          ),
          backgroundColor: HelaColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        messenger.hideCurrentSnackBar();
      }
    });
  }

  Future<void> _openChatCustomizer() async {
    final updatedPlan = await Navigator.push<TourPlan>(
      context,
      MaterialPageRoute(
        builder: (_) => AiChatCustomizationPage(
          currentPlan: _currentPlan,
          preferences: _effectivePreferences,
        ),
      ),
    );

    if (updatedPlan != null && mounted) {
      setState(() {
        _currentPlan = updatedPlan;
        _selectedDayIndex = 0;
      });
    }
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HelaHomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _currentPlan.days;
    final activeDay = days.isNotEmpty && _selectedDayIndex < days.length
        ? days[_selectedDayIndex]
        : null;

    return Scaffold(
      backgroundColor: HelaColors.surface,
      appBar: AppBar(
        backgroundColor: HelaColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HelaColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Smart Tour',
          style: TextStyle(
            color: HelaColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: HelaColors.primary),
            tooltip: 'Home Page',
            onPressed: _goToHome,
          ),
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isSaved ? HelaColors.secondary : HelaColors.primary,
            ),
            tooltip: 'Save Tour',
            onPressed: _handleSave,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        children: [
          // Hero Tour Title Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF19331F), Color(0xFF274B2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: HelaColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: Color(0xFF1A1D00),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${_currentPlan.durationDays} Days Itinerary',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1D00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_currentPlan.estimatedTotalCostUsd != null)
                      Text(
                        '~\$${_currentPlan.estimatedTotalCostUsd!.toInt()} / person',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _currentPlan.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentPlan.summary,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (_currentPlan.customizationSummary != null &&
                    _currentPlan.customizationSummary!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: HelaColors.tertiaryFixed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Updated (v${_currentPlan.version}): ${_currentPlan.customizationSummary}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Day Navigation Tabs
          if (days.isNotEmpty) ...[
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedDayIndex == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HelaColors.primary
                            : HelaColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? HelaColors.primary
                              : HelaColors.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                      child: Text(
                        'Day ${index + 1}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : HelaColors.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Active Day Details
          if (activeDay != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HelaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeDay.title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: HelaColors.onSurface,
                      height: 1.3,
                    ),
                  ),
                  if (activeDay.summary.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      activeDay.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: HelaColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (activeDay.overnightStay != null &&
                      activeDay.overnightStay!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: HelaColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: HelaColors.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.hotel_rounded,
                            size: 14,
                            color: HelaColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              activeDay.overnightStay!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: HelaColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Activities Timeline
                  ...activeDay.activities.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final act = entry.value;
                    final isLast = idx == activeDay.activities.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline Column
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: HelaColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: HelaColors.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 14),

                          // Activity Content Card
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        act.startTime.isNotEmpty
                                            ? act.startTime
                                            : 'Stop ${idx + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          color: HelaColors.primary,
                                        ),
                                      ),
                                      if (act.estimatedDuration.isNotEmpty)
                                        Text(
                                          act.estimatedDuration,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: HelaColors.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    act.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: HelaColors.onSurface,
                                    ),
                                  ),
                                  if (act.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      act.description,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: HelaColors.onSurfaceVariant,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                  if (act.travelTimeFromPrevious != null &&
                                      act
                                          .travelTimeFromPrevious!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.directions_car_rounded,
                                          size: 13,
                                          color: HelaColors.secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${act.travelTimeFromPrevious} ${act.travelMethod != null ? "(${act.travelMethod})" : ""}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: HelaColors.secondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (act.tips.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: HelaColors.tertiaryFixed
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '💡 ${act.tips.first}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF1A1D00),
                                          fontWeight: FontWeight.w500,
                                        ),
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
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Budget & Tips Accordion
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HelaColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 18,
                      color: HelaColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Budget & Preparation',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: HelaColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_currentPlan.budgetBreakdown.isNotEmpty)
                  Text(
                    _currentPlan.budgetBreakdown,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: HelaColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                if (_currentPlan.travelTips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Essential Travel Tips:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: HelaColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._currentPlan.travelTips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: HelaColors.primary),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: HelaColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Completion & Return to Home Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: HelaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: HelaColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HelaColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: HelaColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tour Plan Complete',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: HelaColors.onSurface,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ready to explore Sri Lanka or plan another adventure?',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: HelaColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _goToHome,
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text(
                      'Back to Home Page',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HelaColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Sticky Bar: Navigation & AI Customization
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Home Redirection Button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _goToHome,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: HelaColors.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: const Tooltip(
                    message: 'Home Page',
                    child: Icon(
                      Icons.home_rounded,
                      color: HelaColors.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Save button
              OutlinedButton.icon(
                onPressed: _handleSave,
                icon: Icon(
                  _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 17,
                ),
                label: Text(_isSaved ? 'Saved' : 'Save'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HelaColors.primary,
                  side: const BorderSide(color: HelaColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // AI Chat Customize Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openChatCustomizer,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                  label: const Text(
                    'Customize with AI',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HelaColors.tertiaryFixed,
                    foregroundColor: HelaColors.onTertiaryFixed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
