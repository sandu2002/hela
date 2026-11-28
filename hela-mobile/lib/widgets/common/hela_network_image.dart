import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared network image widget with bounded disk/memory caching via
/// [CachedNetworkImage], loading placeholder, and graceful error fallback.
class HelaNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext context, String url)? placeholderBuilder;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;

  const HelaNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  static bool isValidNetworkUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    return uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'https' || uri.scheme == 'http');
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty || !isValidNetworkUrl(trimmed)) {
      return errorBuilder?.call(context, 'Invalid image URL', null) ??
          _defaultFallback(context);
    }

    final boundedMemWidth = width != null && width!.isFinite
        ? (width! * 2).round().clamp(120, 1200)
        : 900;

    return CachedNetworkImage(
      imageUrl: trimmed,
      httpHeaders: const {
        'User-Agent': 'HELA-Travel-App/1.0 (https://hela.lk; contact@hela.lk)',
      },
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: boundedMemWidth,
      placeholder:
          placeholderBuilder ??
          (ctx, _) => Container(
            width: width,
            height: height,
            color: Theme.of(
              ctx,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ),
      errorWidget: (ctx, _, error) =>
          errorBuilder?.call(ctx, error, null) ?? _defaultFallback(ctx),
    );
  }

  Widget _defaultFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
