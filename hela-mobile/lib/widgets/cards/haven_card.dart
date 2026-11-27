import 'package:flutter/material.dart';
import 'package:hela/pages/home/home_page.dart';
import 'package:hela/widgets/common/hela_network_image.dart';

/// Reusable Destination / Haven Card conforming to Lankan Tropical Modernism:
/// - 16px radius, subtle architectural border, ambient tea-tinted depth
/// - Location badge with pin icon
/// - Interactive bookmark icon button
/// - Rating badge (Golden Amber star + score) and explorer social proof text
/// - Multi-line title
/// - Category and price display ("From $X / person")
/// - "Explore" action button with customizable callback
class HavenCard extends StatelessWidget {
  final String title;
  final String location;
  final String category;
  final String price;
  final double rating;
  final String badgeText;
  final String imageUrl;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onExploreTap;
  final VoidCallback? onTap;
  final double width;
  final double? height;

  const HavenCard({
    super.key,
    required this.title,
    required this.location,
    required this.category,
    required this.price,
    required this.rating,
    required this.badgeText,
    required this.imageUrl,
    this.isBookmarked = false,
    this.onBookmarkTap,
    this.onExploreTap,
    this.onTap,
    this.width = 285,
    this.height,
  });

  /// Factory constructor to easily create a [HavenCard] from a [HavenItem].
  factory HavenCard.fromHavenItem(
    HavenItem item, {
    Key? key,
    bool isBookmarked = false,
    VoidCallback? onBookmarkTap,
    VoidCallback? onExploreTap,
    VoidCallback? onTap,
    double width = 285,
    double? height,
  }) {
    return HavenCard(
      key: key,
      title: item.title,
      location: item.location,
      category: item.category,
      price: item.price,
      rating: item.rating,
      badgeText: item.badgeText,
      imageUrl: item.imageUrl,
      isBookmarked: isBookmarked,
      onBookmarkTap: onBookmarkTap,
      onExploreTap: onExploreTap,
      onTap: onTap,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);

    return GestureDetector(
      onTap: onTap ?? onExploreTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.architecturalBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Full Background Image
              Positioned.fill(
                child: _buildImage(colors),
              ),

              // Forest Dark Green / Ocean Teal Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.40, 0.72, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                        colors.primary.withValues(alpha: 0.78),
                        colors.primary.withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                ),
              ),

              // Content inside card
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Badges Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Location Badge
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.tertiaryFixed,
                                borderRadius: BorderRadius.circular(9999),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 13,
                                    color: colors.onTertiaryFixed,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.onTertiaryFixed,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Bookmark Button
                          Material(
                            color: isBookmarked
                                ? colors.primaryContainer.withValues(alpha: 0.95)
                                : colors.primaryContainer.withValues(alpha: 0.75),
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
                                  color: isBookmarked
                                      ? colors.coralSunrise
                                      : colors.onPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Card Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rating & Explorer badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerLowest
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: colors.goldenAmber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      rating.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    color: colors.surfaceContainerLow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Card Title
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.5,
                              height: 1.25,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          // Bottom Divider & Details
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category,
                                      style: TextStyle(
                                        color: colors.onPrimaryContainer,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'From $price',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' / person',
                                            style: TextStyle(
                                              color: colors.surfaceContainerHighest,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Explore Action Button
                                ElevatedButton(
                                  onPressed: onExploreTap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.tertiaryFixed,
                                    foregroundColor: colors.onTertiaryFixed,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Explore',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(HelaColorPalette colors) {
    return HelaNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: colors.primaryContainer,
          child: Center(
            child: Icon(
              Icons.landscape_rounded,
              color: colors.onPrimaryContainer,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}
