import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';

/// Reusable Destination / Haven Card
///
/// Features:
/// - Hero background image with gradient darkening
/// - Location badge with pin icon
/// - Interactive bookmark icon button
/// - Rating badge (star + score) and explorer social proof text
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
    return GestureDetector(
      onTap: onTap ?? onExploreTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: HelaColors.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Full Background Image
              Positioned.fill(
                child: _buildImage(),
              ),

              // Forest Dark Green Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 0.75, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                        HelaColors.primary.withValues(alpha: 0.78),
                        HelaColors.primary.withValues(alpha: 0.96),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: HelaColors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: HelaColors.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    color: HelaColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bookmark Button
                          Material(
                            color: isBookmarked
                                ? HelaColors.primaryContainer.withValues(alpha: 0.95)
                                : HelaColors.primaryContainer.withValues(alpha: 0.75),
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
                                      ? HelaColors.tertiaryFixed
                                      : HelaColors.onPrimary,
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
                                  color: HelaColors.surfaceContainerLowest
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      rating.toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: HelaColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  badgeText,
                                  style: const TextStyle(
                                    color: HelaColors.surfaceContainerLow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
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
                              color: HelaColors.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 12),

                          // Bottom Divider & Details
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: HelaColors.onPrimary
                                      .withValues(alpha: 0.2),
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
                                      style: const TextStyle(
                                        color: HelaColors.onPrimaryContainer,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'From $price',
                                            style: const TextStyle(
                                              color: HelaColors.onPrimary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' / person',
                                            style: TextStyle(
                                              color: HelaColors
                                                  .surfaceContainerHighest,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
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
                                    backgroundColor: HelaColors.tertiaryFixed,
                                    foregroundColor: HelaColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Explore',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
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

  Widget _buildImage() {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: HelaColors.primaryContainer,
          child: const Center(
            child: Icon(
              Icons.landscape_rounded,
              color: HelaColors.onPrimaryContainer,
              size: 40,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: HelaColors.surfaceContainerHigh,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: HelaColors.secondary,
            ),
          ),
        );
      },
    );
  }
}
