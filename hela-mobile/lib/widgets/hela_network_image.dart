import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared network image widget with bounded disk/memory caching via
/// [CachedNetworkImage], loading placeholder, and graceful error fallback.
class HelaNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)?
      errorBuilder;

  const HelaNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return errorBuilder?.call(context, 'Empty URL', null) ??
          _defaultFallback(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width != null && width!.isFinite ? (width! * 2).round() : 900,
      placeholder: (ctx, _) => Container(
        width: width,
        height: height,
        color: Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
