import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';

/// Data model for an itinerary expedition card
class ItineraryCardData {
  final String title;
  final String subtitle;
  final String durationTag;
  final String categoryTag;
  final String routeName;
  final double rating;
  final int reviewsCount;
  final String price;
  final String imageUrl;
  final IconData badgeIcon;
  final List<String> highlights;

  const ItineraryCardData({
    required this.title,
    required this.subtitle,
    required this.durationTag,
    required this.categoryTag,
    required this.routeName,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.imageUrl,
    required this.badgeIcon,
    required this.highlights,
  });
}

/// Reusable Curated Itinerary / Expedition Card
///
/// Features:
/// - Top cover photo banner with dark green gradient vignette
/// - Top-left duration & theme pill badge (e.g. "4 Days · Cultural")
/// - Top-right interactive bookmark circular button
/// - Bottom overlay on image showing verified route name & star rating score with review count
/// - Editorial title and subtitle
/// - Bulleted highlights list with green checkmark icons
/// - Divider separator
/// - Price footer with "ESTIMATED PRICE" & "/ person"
/// - "View Route >" pill action button with custom callback
class ItineraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String durationTag;
  final String categoryTag;
  final String routeName;
  final double rating;
  final int reviewsCount;
  final String price;
  final String imageUrl;
  final IconData badgeIcon;
  final List<String> highlights;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onViewRouteTap;
  final VoidCallback? onTap;
  final String priceLabel;
  final String priceUnit;
  final String buttonText;
  final double? width;
  final double imageHeight;

  const ItineraryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.durationTag,
    this.categoryTag = '',
    required this.routeName,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.imageUrl,
    this.badgeIcon = Icons.account_balance_rounded,
    required this.highlights,
    this.isBookmarked = false,
    this.onBookmarkTap,
    this.onViewRouteTap,
    this.onTap,
    this.priceLabel = 'ESTIMATED PRICE',
    this.priceUnit = ' / person',
    this.buttonText = 'View Route',
    this.width,
    this.imageHeight = 190,
  });

  /// Factory constructor to easily instantiate an [ItineraryCard] from [ItineraryCardData].
  factory ItineraryCard.fromItineraryCardData(
    ItineraryCardData data, {
    Key? key,
    bool isBookmarked = false,
    VoidCallback? onBookmarkTap,
    VoidCallback? onViewRouteTap,
    VoidCallback? onTap,
    String? priceLabel,
    String? priceUnit,
    String? buttonText,
    double? width,
    double imageHeight = 190,
  }) {
    return ItineraryCard(
      key: key,
      title: data.title,
      subtitle: data.subtitle,
      durationTag: data.durationTag,
      categoryTag: data.categoryTag,
      routeName: data.routeName,
      rating: data.rating,
      reviewsCount: data.reviewsCount,
      price: data.price,
      imageUrl: data.imageUrl,
      badgeIcon: data.badgeIcon,
      highlights: data.highlights,
      isBookmarked: isBookmarked,
      onBookmarkTap: onBookmarkTap,
      onViewRouteTap: onViewRouteTap,
      onTap: onTap,
      priceLabel: priceLabel ?? 'ESTIMATED PRICE',
      priceUnit: priceUnit ?? ' / person',
      buttonText: buttonText ?? 'View Route',
      width: width,
      imageHeight: imageHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2E24).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Image banner with tags and overlay
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildImage(),
                  ),
                  // Gradient overlay on image bottom
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.4, 1.0],
                          colors: [
                            Colors.transparent,
                            HelaColors.primary.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top-left duration badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: HelaColors.primary.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badgeIcon,
                            size: 14,
                            color: HelaColors.tertiaryFixed,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            durationTag,
                            style: const TextStyle(
                              color: HelaColors.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-right bookmark button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: HelaColors.surfaceContainerLowest
                          .withValues(alpha: 0.85),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onBookmarkTap,
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 19,
                            color: HelaColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom bar over image
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: HelaColors.secondaryFixed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              routeName,
                              style: const TextStyle(
                                color: HelaColors.secondaryFixed,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: HelaColors.surfaceContainerLowest
                                .withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: HelaColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '($reviewsCount)',
                                style: const TextStyle(
                                  color: HelaColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: HelaColors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: HelaColors.onSurfaceVariant,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Highlights List
                  ...highlights.map((highlight) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 8),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: HelaColors.secondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              highlight,
                              style: const TextStyle(
                                color: HelaColors.onSurface,
                                fontSize: 12.5,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    color: HelaColors.surfaceContainer,
                  ),
                  const SizedBox(height: 12),

                  // Card Footer (Pricing & View Route Action)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: price,
                                  style: const TextStyle(
                                    color: HelaColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: priceUnit,
                                  style: const TextStyle(
                                    color: HelaColors.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: onViewRouteTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HelaColors.surfaceContainerLow,
                          foregroundColor: HelaColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              buttonText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }

  Widget _buildImage() {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HelaColors.primaryContainer, HelaColors.primary],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.landscape_rounded,
              color: HelaColors.onPrimaryContainer,
              size: 44,
            ),
          ),
        );
      },
    );
  }
}
