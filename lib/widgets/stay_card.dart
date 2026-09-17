import 'package:flutter/material.dart';
import 'package:hela/pages/home_page.dart';
import 'package:hela/pages/stays_page.dart';

/// Reusable Eco-Haven / Stay Card
///
/// Features:
/// - Cover photo with dark vignette gradient
/// - Top-left "Best Price Guarantee" verified badge
/// - Top-right interactive bookmark button
/// - Pager dots overlay for multi-image simulation
/// - Stay title & subtitle location with pin icon
/// - Rating badge (star + score) and review count/label
/// - Amenity tag chips (e.g. Infinity Pool, Ayurveda Spa)
/// - Nightly price with fee note
/// - "View Haven" action button with arrow icon
class StayCard extends StatelessWidget {
  final String title;
  final String location;
  final double rating;
  final int reviewsCount;
  final String ratingLabel;
  final int pricePerNight;
  final String feeNote;
  final String imageUrl;
  final List<StayAmenity> amenities;
  final String badgeText;
  final IconData badgeIcon;
  final bool hasPagerDots;
  final Color buttonBgColor;
  final Color buttonTextColor;
  final String buttonText;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onViewTap;
  final VoidCallback? onTap;

  const StayCard({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.ratingLabel,
    required this.pricePerNight,
    required this.feeNote,
    required this.imageUrl,
    required this.amenities,
    this.badgeText = 'Best Price Guarantee',
    this.badgeIcon = Icons.verified_rounded,
    this.hasPagerDots = false,
    this.buttonBgColor = HelaColors.tertiaryFixedDim,
    this.buttonTextColor = HelaColors.primary,
    this.buttonText = 'View Haven',
    this.isBookmarked = false,
    this.onBookmarkTap,
    this.onViewTap,
    this.onTap,
  });

  /// Factory constructor to create a [StayCard] directly from a [StayHaven] model.
  factory StayCard.fromStayHaven(
    StayHaven stay, {
    Key? key,
    bool isBookmarked = false,
    VoidCallback? onBookmarkTap,
    VoidCallback? onViewTap,
    VoidCallback? onTap,
    String? badgeText,
    String? buttonText,
  }) {
    return StayCard(
      key: key,
      title: stay.title,
      location: stay.location,
      rating: stay.rating,
      reviewsCount: stay.reviewsCount,
      ratingLabel: stay.ratingLabel,
      pricePerNight: stay.pricePerNight,
      feeNote: stay.feeNote,
      imageUrl: stay.imageUrl,
      amenities: stay.amenities,
      hasPagerDots: stay.hasPagerDots,
      buttonBgColor: stay.buttonBgColor,
      buttonTextColor: stay.buttonTextColor,
      badgeText: badgeText ?? 'Best Price Guarantee',
      buttonText: buttonText ?? 'View Haven',
      isBookmarked: isBookmarked,
      onBookmarkTap: onBookmarkTap,
      onViewTap: onViewTap,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? onViewTap,
      child: Container(
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
            children: [
              // Cover Photo Container
              SizedBox(
                height: 210,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Network Image with Fallback
                    Positioned.fill(
                      child: _buildImage(),
                    ),

                    // Dark Vignette Gradients
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.4, 0.7, 1.0],
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top-Left Badge (e.g. Best Price Guarantee)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: HelaColors.tertiaryFixedDim,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              badgeIcon,
                              size: 13,
                              color: HelaColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              badgeText,
                              style: const TextStyle(
                                color: HelaColors.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top-Right Bookmark Button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: HelaColors.primaryContainer
                            .withValues(alpha: 0.72),
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
                              size: 18,
                              color: HelaColors.surfaceContainerLowest,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Floating Image Pager Dots
                    if (hasPagerDots)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: HelaColors.primary.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
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
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: HelaColors.primary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Location Subtitle
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: HelaColors.secondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              color: HelaColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Rating & Reviews Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: HelaColors.secondaryFixed
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: HelaColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: HelaColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($reviewsCount reviews) · $ratingLabel',
                          style: const TextStyle(
                            color: HelaColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Amenity Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: HelaColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: HelaColors.outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                amenity.icon,
                                size: 12,
                                color: HelaColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                amenity.label,
                                style: const TextStyle(
                                  color: HelaColors.onSurfaceVariant,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      color: HelaColors.surfaceContainer,
                    ),
                    const SizedBox(height: 10),

                    // Price & CTA Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'From \$$pricePerNight',
                                    style: const TextStyle(
                                      color: HelaColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' / night',
                                    style: TextStyle(
                                      color: HelaColors.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              feeNote,
                              style: const TextStyle(
                                color: HelaColors.secondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Action Button
                        ElevatedButton(
                          onPressed: onViewTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBgColor,
                            foregroundColor: buttonTextColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
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
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: HelaColors.surfaceContainerHigh,
          child: const Center(
            child: Icon(
              Icons.hotel_rounded,
              color: HelaColors.secondary,
              size: 44,
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
