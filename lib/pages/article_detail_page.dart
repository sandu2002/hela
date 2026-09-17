import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/stays_page.dart';
import 'package:hela/pages/trip_planner_page.dart';
import 'package:hela/pages/profile_page.dart';

/// A generic article / cultural guide detail page.
///
/// Used as a stub destination for "Up Next" links and category deep-dives.
/// Accepts data through constructor params so it can be reused for any article.
class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String authorName;
  final String readTime;
  final String imageUrl;
  final String bodyText;

  const ArticleDetailPage({
    super.key,
    required this.title,
    this.subtitle = '',
    this.authorName = 'HELA Cultural Team',
    this.readTime = '5 min read',
    this.imageUrl = '',
    this.bodyText = '',
  });

  Widget _buildNetworkImage(String url,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
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
            child: Icon(Icons.image_outlined,
                color: HelaColors.onPrimaryContainer, size: 32),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.background,
      appBar: AppBar(
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
                        MaterialPageRoute(
                            builder: (_) => const HelaHomePage()),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back_rounded,
                        color: HelaColors.primary, size: 24),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: HelaColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'FOLKLORE & HERITAGE',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing article...')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.share_rounded,
                            color: HelaColors.onSurfaceVariant, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                  // Hero Image
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24)),
                      child: _buildNetworkImage(
                        imageUrl,
                        width: double.infinity,
                        height: 220,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HelaColors.primaryContainer,
                            HelaColors.secondary,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(24)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_stories_rounded,
                              color: HelaColors.onPrimary,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coming Soon',
                              style: TextStyle(
                                color: HelaColors.onPrimary.withValues(alpha: 0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            color: HelaColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Author & Read Time
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: HelaColors.primaryContainer,
                              child: Text(
                                authorName.isNotEmpty
                                    ? authorName[0].toUpperCase()
                                    : 'H',
                                style: const TextStyle(
                                  color: HelaColors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName,
                                  style: const TextStyle(
                                    color: HelaColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded,
                                        size: 13, color: HelaColors.secondary),
                                    const SizedBox(width: 3),
                                    Text(
                                      readTime,
                                      style: const TextStyle(
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

                        const SizedBox(height: 20),
                        Divider(
                          color: HelaColors.outlineVariant.withValues(alpha: 0.4),
                          height: 1,
                        ),
                        const SizedBox(height: 20),

                        // Body text
                        if (bodyText.isNotEmpty)
                          Text(
                            bodyText,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 14.5,
                              height: 1.6,
                            ),
                          )
                        else
                          _buildComingSoonBody(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildComingSoonBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HelaColors.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: HelaColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.construction_rounded,
                color: HelaColors.secondary,
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                'Article Coming Soon',
                style: TextStyle(
                  color: HelaColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This cultural guide is being prepared by our team of historians and folklorists. Check back soon for the full story.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HelaColors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HelaColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border(
              left: BorderSide(
                color: HelaColors.secondary,
                width: 4,
              ),
            ),
          ),
          child: const Text(
            '"Every temple, every ritual, every story carries a thread of something much older — a civilization that never forgot its roots."',
            style: TextStyle(
              color: HelaColors.primary,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                label: 'Explore',
                icon: Icons.explore_rounded,
                activeIcon: Icons.explore,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HelaHomePage()),
                  );
                },
              ),
              _buildNavItem(
                context: context,
                label: 'Saved',
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const StaysPage()),
                  );
                },
              ),
              _buildNavItem(
                context: context,
                label: 'Journeys',
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const TripPlannerPage()),
                  );
                },
              ),
              _buildNavItem(
                context: context,
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: HelaColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: HelaColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
