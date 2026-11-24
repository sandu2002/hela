import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/explore_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/bookings_page.dart';
import 'package:hela/pages/profile_page.dart';

/// Unified, consistent Bottom Navigation Bar for HELA
/// Conforms to the Stitch Lankan Tropical Modernism specification:
/// - 64px docked height + safe area
/// - Inactive icons/labels: #63736E (colors.outline)
/// - Active tab: #0B5D56 (colors.primaryContainer) with a 4px active indicator dot below
/// - 5 Global Tabs: Home, Explore, My Trips, Bookings, Profile
class HelaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onAskHela;

  const HelaBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTabSelected,
    this.onAskHela,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItemData(
      label: 'Explore',
      icon: Icons.near_me_outlined,
      activeIcon: Icons.near_me_rounded,
    ),
    _NavItemData(
      label: 'My Trips',
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
    ),
    _NavItemData(
      label: 'Bookings',
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number_rounded,
    ),
    _NavItemData(
      label: 'Profile',
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
    ),
  ];

  void _handleTap(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
      return;
    }

    if (index == currentIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const HelaHomePage();
        break;
      case 1:
        targetPage = const ExplorePage();
        break;
      case 2:
        targetPage = const TripPlannerPage();
        break;
      case 3:
        targetPage = const BookingsPage();
        break;
      case 4:
        targetPage = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  static void openAskHelaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AskHelaBottomSheet(),
    );
  }

  static Widget buildFloatingAskHelaButton(BuildContext context) {
    final colors = HelaColors.of(context);
    return InkWell(
      onTap: () => openAskHelaSheet(context),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.goldenAmber.withValues(alpha: 0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: colors.tertiaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: colors.goldenAmber, width: 1.5),
              ),
              child: Icon(Icons.psychology_rounded, size: 15, color: colors.goldenAmber),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Guide',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: colors.goldenAmber,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ask HELA',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.auto_awesome_rounded, size: 15, color: colors.onPrimaryContainer),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final isDark = colors.isDark;

    return Container(
      decoration: BoxDecoration(
        color: colors.navBarBackground.withValues(alpha: isDark ? 0.98 : 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.3)
                : colors.architecturalBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(
              _items.length,
              (index) => Expanded(child: _buildNavItem(context, index, colors)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, HelaColorPalette colors) {
    final item = _items[index];
    final isActive = currentIndex == index;
    final activeColor = colors.primaryContainer;
    final inactiveColor = colors.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleTap(context, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
                fontFamily: 'Inter',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // 4px Teal indicator dot for active tab
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// ── Ask HELA Interactive AI Concierge Sheet ────────────────────────
class _AskHelaBottomSheet extends StatefulWidget {
  const _AskHelaBottomSheet();

  @override
  State<_AskHelaBottomSheet> createState() => _AskHelaBottomSheetState();
}

class _AskHelaBottomSheetState extends State<_AskHelaBottomSheet> {
  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Ayubowan! I am HELA, your 24/7 Sri Lanka Travel Companion. Ask me anything about trains, tuk-tuks, secret trails, or cultural etiquette.',
    },
  ];
  bool _isResponding = false;

  final List<String> _suggestedPrompts = [
    'Nine Arch train times',
    'Tuk-tuk fair rate in Colombo',
    'Temple dress etiquette',
    'Sigiriya best sunrise time',
    'Current monsoon weather',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _sendQuery(String query) {
    if (query.trim().isEmpty) return;
    final text = query.trim();
    _queryController.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isResponding = true;
    });

    // Smart contextual response generator
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      String reply;
      final lower = text.toLowerCase();
      if (lower.contains('train') || lower.contains('ella')) {
        reply = 'The Main Line scenic train from Kandy to Ella runs daily. The most picturesque departures are the 08:47 Express and 11:10 Podi Menike. Tip: Reserve 1st/2nd class observation seats 30 days ahead!';
      } else if (lower.contains('tuk') || lower.contains('fare') || lower.contains('meter')) {
        reply = 'Official Sri Lanka Tuk-Tuk rate: LKR 100-120 for the 1st km, and LKR 80-90 per subsequent km. Always look for the illuminated "METER TAXI" roof sign or use HELA Fair Ride calculator!';
      } else if (lower.contains('temple') || lower.contains('dress') || lower.contains('etiquette')) {
        reply = 'Sacred site etiquette: Wear white or light-colored attire covering shoulders and knees. Remove shoes and hats before entering, and never take photos with your back turned directly to a Buddha statue.';
      } else if (lower.contains('sigiriya') || lower.contains('sunrise')) {
        reply = 'Sigiriya gates open at 06:30 AM. Arrive by 06:15 AM to avoid heat and crowds. Alternatively, climb Pidurangala Rock at 05:00 AM for the iconic sunrise panorama over Sigiriya!';
      } else {
        reply = 'Sri Lanka is wonderful right now! Whether you are heading to the mist-covered hill country or the golden south coast, I can help you plan verified routes, check fair transit prices, and discover hidden gems.';
      }

      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isResponding = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colors.primaryContainer, colors.primary],
                    ),
                    border: Border.all(color: colors.goldenAmber, width: 1.5),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Ask HELA AI',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '24/7 LIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: colors.onTertiaryFixedVariant,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Your Personal Sri Lanka Travel Concierge',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.outline),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 20),

          // Suggested Query Chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedPrompts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _suggestedPrompts[index];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                      fontFamily: 'Inter',
                    ),
                  ),
                  backgroundColor: colors.surfaceContainerLow,
                  side: BorderSide(color: colors.architecturalBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  onPressed: () => _sendQuery(prompt),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Message Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? colors.primaryContainer : colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(2),
                      ),
                      border: Border.all(
                        color: isUser ? colors.primaryContainer : colors.architecturalBorder,
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isUser ? Colors.white : colors.onSurface,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isResponding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.primaryContainer),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HELA is thinking...',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    onSubmitted: _sendQuery,
                    decoration: InputDecoration(
                      hintText: 'Ask anything about Sri Lanka...',
                      hintStyle: TextStyle(fontSize: 13, color: colors.outline),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _sendQuery(_queryController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
