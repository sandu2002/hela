import 'package:flutter/material.dart';

/// Shared HELA brand logo loaded from the bundled asset image.
class HelaLogo extends StatelessWidget {
  static const String assetPath = 'assets/images/hela_logo.png';

  final double size;
  final bool framed;
  final bool isCircle;
  final double padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const HelaLogo({
    super.key,
    this.size = 40,
    this.framed = false,
    this.isCircle = false,
    this.padding = 4,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 10,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final innerSize = framed ? (size - (padding * 2)).clamp(8.0, size) : size;
    final image = Image.asset(
      assetPath,
      width: innerSize,
      height: innerSize,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.eco_rounded,
        size: innerSize * 0.72,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    if (!framed) return image;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark ? const Color(0xFF142721) : Colors.white),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
        boxShadow: boxShadow,
      ),
      alignment: Alignment.center,
      child: image,
    );
  }
}
