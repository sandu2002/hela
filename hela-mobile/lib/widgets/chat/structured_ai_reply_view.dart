import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';

/// Font family shared across Home screen and Ask HELA typography.
const String kHelaFontFamily = 'Plus Jakarta Sans';

/// Parsed block element from an AI response string.
sealed class AiReplyBlock {
  const AiReplyBlock();
}

/// Section heading parsed from `### Title` or `**Title:**` header lines.
class AiHeadingBlock extends AiReplyBlock {
  final String title;
  final int level;
  const AiHeadingBlock({required this.title, required this.level});
}

/// Standard prose paragraph block.
class AiParagraphBlock extends AiReplyBlock {
  final String text;
  const AiParagraphBlock({required this.text});
}

/// A single structured key-point / bullet item.
class AiKeyPointItem {
  final String? label;
  final String body;
  final bool isNested;
  final String? orderNumber;

  const AiKeyPointItem({
    this.label,
    required this.body,
    this.isNested = false,
    this.orderNumber,
  });
}

/// Grouped list of consecutive key points / bullet items.
class AiKeyPointsGroupBlock extends AiReplyBlock {
  final List<AiKeyPointItem> items;
  const AiKeyPointsGroupBlock({required this.items});
}

/// Parses raw Markdown / plain-text AI responses into structured visual blocks
/// so users see clear sections and key points instead of raw `#` / `*` syntax.
class AiReplyParser {
  static final RegExp _headingRegex = RegExp(r'^(#{1,4})\s+(.+)$');
  static final RegExp _bulletRegex = RegExp(
    r'^(\s*)([*\-•+]|(\d+)[.)])\s+(.+)$',
  );
  static final RegExp _dividerRegex = RegExp(r'^\s*([-*_])\1{2,}\s*$');
  static final RegExp _boldLabelRegex = RegExp(
    r'^\*\*([^*]+?)\*\*\s*:?\s*(.*)$',
  );
  static final RegExp _plainLabelRegex = RegExp(r'^([^:]{2,42}):\s+(.+)$');

  /// Converts [rawText] into an ordered list of [AiReplyBlock] items.
  static List<AiReplyBlock> parse(String rawText) {
    final normalized = rawText.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) return const [];

    final lines = normalized.split('\n');
    final blocks = <AiReplyBlock>[];
    final paragraphBuffer = <String>[];
    final keyPointBuffer = <AiKeyPointItem>[];

    void flushParagraph() {
      if (paragraphBuffer.isEmpty) return;
      final joined = paragraphBuffer.join(' ').trim();
      if (joined.isNotEmpty) {
        blocks.add(AiParagraphBlock(text: joined));
      }
      paragraphBuffer.clear();
    }

    void flushKeyPoints() {
      if (keyPointBuffer.isEmpty) return;
      blocks.add(
        AiKeyPointsGroupBlock(items: List.unmodifiable(keyPointBuffer)),
      );
      keyPointBuffer.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        flushParagraph();
        flushKeyPoints();
        continue;
      }

      if (_dividerRegex.hasMatch(trimmed)) {
        flushParagraph();
        flushKeyPoints();
        continue;
      }

      final headingMatch = _headingRegex.firstMatch(trimmed);
      if (headingMatch != null) {
        flushParagraph();
        flushKeyPoints();
        final level = headingMatch.group(1)!.length;
        final rawTitle = headingMatch.group(2)!.trim();
        blocks.add(
          AiHeadingBlock(
            title: _stripMarkdownDecorations(rawTitle),
            level: level,
          ),
        );
        continue;
      }

      final bulletMatch = _bulletRegex.firstMatch(line);
      if (bulletMatch != null) {
        flushParagraph();
        final indent = bulletMatch.group(1)?.length ?? 0;
        final orderNumber = bulletMatch.group(3);
        final content = bulletMatch.group(4)!.trim();
        keyPointBuffer.add(
          _parseKeyPoint(
            content,
            isNested: indent >= 2,
            orderNumber: orderNumber,
          ),
        );
        continue;
      }

      // Standalone short bold heading line (e.g. **Practical Advice:**)
      if (trimmed.startsWith('**') &&
          trimmed.endsWith('**') &&
          trimmed.length <= 70 &&
          !trimmed.substring(2, trimmed.length - 2).contains('**')) {
        flushParagraph();
        flushKeyPoints();
        final inner = _stripMarkdownDecorations(
          trimmed,
        ).replaceFirst(RegExp(r':$'), '');
        if (inner.isNotEmpty) {
          blocks.add(AiHeadingBlock(title: inner, level: 3));
        }
        continue;
      }

      flushKeyPoints();
      paragraphBuffer.add(trimmed);
    }

    flushParagraph();
    flushKeyPoints();
    return blocks;
  }

  static AiKeyPointItem _parseKeyPoint(
    String content, {
    required bool isNested,
    String? orderNumber,
  }) {
    final boldMatch = _boldLabelRegex.firstMatch(content);
    if (boldMatch != null) {
      final rawLabel = boldMatch
          .group(1)!
          .trim()
          .replaceFirst(RegExp(r':$'), '');
      final body = boldMatch.group(2)!.trim();
      return AiKeyPointItem(
        label: _stripMarkdownDecorations(rawLabel),
        body: body,
        isNested: isNested,
        orderNumber: orderNumber,
      );
    }

    final plainMatch = _plainLabelRegex.firstMatch(content);
    if (plainMatch != null && !content.contains('://')) {
      final rawLabel = plainMatch.group(1)!.trim();
      final body = plainMatch.group(2)!.trim();
      return AiKeyPointItem(
        label: _stripMarkdownDecorations(rawLabel),
        body: body,
        isNested: isNested,
        orderNumber: orderNumber,
      );
    }

    return AiKeyPointItem(
      body: content,
      isNested: isNested,
      orderNumber: orderNumber,
    );
  }

  static String _stripMarkdownDecorations(String input) {
    return input
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'__(.+?)__'), r'$1')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll('*', '')
        .trim();
  }
}

/// Renders an AI response using structured sections, styled key-point cards,
/// and inline bold/italic spans with HELA's Home screen `Plus Jakarta Sans` font.
class StructuredAiReplyView extends StatelessWidget {
  final String text;

  const StructuredAiReplyView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    final blocks = AiReplyParser.parse(text);

    if (blocks.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontFamily: kHelaFontFamily,
          fontSize: 13.5,
          height: 1.5,
          color: colors.onSurface,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < blocks.length; i++) ...[
          if (i > 0) SizedBox(height: blocks[i] is AiHeadingBlock ? 14 : 10),
          _buildBlock(context, blocks[i], colors),
        ],
      ],
    );
  }

  Widget _buildBlock(
    BuildContext context,
    AiReplyBlock block,
    HelaColorPalette colors,
  ) {
    return switch (block) {
      AiHeadingBlock() => _buildHeading(block, colors),
      AiParagraphBlock() => _buildInlineRichText(
        block.text,
        baseStyle: TextStyle(
          fontFamily: kHelaFontFamily,
          fontSize: 13.5,
          height: 1.52,
          fontWeight: FontWeight.w400,
          color: colors.onSurface.withValues(alpha: 0.9),
        ),
        boldColor: colors.onSurface,
      ),
      AiKeyPointsGroupBlock() => _buildKeyPointsCard(block, colors),
    };
  }

  Widget _buildHeading(AiHeadingBlock heading, HelaColorPalette colors) {
    final icon = _pickSectionIcon(heading.title);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: colors.isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: colors.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            heading.title,
            style: TextStyle(
              fontFamily: kHelaFontFamily,
              fontSize: heading.level <= 2 ? 15 : 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyPointsCard(
    AiKeyPointsGroupBlock group,
    HelaColorPalette colors,
  ) {
    final cardBg = colors.isDark
        ? colors.surfaceContainer.withValues(alpha: 0.85)
        : const Color(0xFFF3FBF8);
    final borderColor = colors.isDark
        ? colors.architecturalBorder
        : const Color(0xFFCDEEE3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < group.items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.only(
                  top: 7,
                  bottom: 7,
                  left: group.items[i].isNested ? 20 : 0,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: borderColor.withValues(alpha: 0.55),
                ),
              ),
            _buildKeyPointRow(group.items[i], colors),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyPointRow(AiKeyPointItem item, HelaColorPalette colors) {
    final leftIndent = item.isNested ? 18.0 : 0.0;
    final hasLabel = item.label != null && item.label!.isNotEmpty;
    final hasBody = item.body.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: leftIndent, top: 1, bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: item.orderNumber != null
                ? Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.orderNumber!,
                      style: TextStyle(
                        fontFamily: kHelaFontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: colors.onPrimary,
                      ),
                    ),
                  )
                : Container(
                    width: item.isNested ? 6 : 8,
                    height: item.isNested ? 6 : 8,
                    margin: EdgeInsets.only(
                      top: item.isNested ? 5 : 4,
                      right: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.isNested
                          ? Colors.transparent
                          : colors.primaryContainer,
                      shape: BoxShape.circle,
                      border: item.isNested
                          ? Border.all(color: colors.primary, width: 1.5)
                          : null,
                    ),
                  ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: hasLabel && !hasBody
                ? Text(
                    item.label!,
                    style: TextStyle(
                      fontFamily: kHelaFontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                      letterSpacing: -0.1,
                    ),
                  )
                : hasLabel
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label!,
                        style: TextStyle(
                          fontFamily: kHelaFontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildInlineRichText(
                        item.body,
                        baseStyle: TextStyle(
                          fontFamily: kHelaFontFamily,
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: colors.onSurface.withValues(alpha: 0.9),
                        ),
                        boldColor: colors.onSurface,
                      ),
                    ],
                  )
                : _buildInlineRichText(
                    item.body,
                    baseStyle: TextStyle(
                      fontFamily: kHelaFontFamily,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: colors.onSurface.withValues(alpha: 0.9),
                    ),
                    boldColor: colors.onSurface,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineRichText(
    String raw, {
    required TextStyle baseStyle,
    required Color boldColor,
  }) {
    final normalizedLinks = raw.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (m) => m.group(1) ?? '',
    );

    final spans = _parseInlineSpans(
      normalizedLinks,
      baseStyle: baseStyle,
      boldColor: boldColor,
    );

    if (spans.length == 1) {
      return Text(spans.first.toPlainText(), style: spans.first.style);
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }

  List<InlineSpan> _parseInlineSpans(
    String input, {
    required TextStyle baseStyle,
    required Color boldColor,
  }) {
    final tokenRegex = RegExp(
      r'(\*\*[^*]+\*\*|__[^_]+__|\*[^*\n]+?\*|`[^`\n]+`)',
    );
    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in tokenRegex.allMatches(input)) {
      if (match.start > lastIndex) {
        final plain = input
            .substring(lastIndex, match.start)
            .replaceAll('*', '');
        if (plain.isNotEmpty) {
          spans.add(TextSpan(text: plain, style: baseStyle));
        }
      }

      final token = match.group(0)!;
      if (token.startsWith('**') && token.endsWith('**') ||
          token.startsWith('__') && token.endsWith('__')) {
        final inner = token.substring(2, token.length - 2);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: boldColor,
            ),
          ),
        );
      } else if (token.startsWith('`') && token.endsWith('`')) {
        final inner = token.substring(1, token.length - 1);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: boldColor,
            ),
          ),
        );
      } else if (token.startsWith('*') && token.endsWith('*')) {
        final inner = token.substring(1, token.length - 1);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      }
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      final tail = input.substring(lastIndex).replaceAll('*', '');
      if (tail.isNotEmpty) {
        spans.add(TextSpan(text: tail, style: baseStyle));
      }
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: input.replaceAll('*', ''), style: baseStyle));
    }
    return spans;
  }

  static IconData _pickSectionIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('advice') || lower.contains('tip')) {
      return Icons.tips_and_updates_rounded;
    }
    if (lower.contains('insight') || lower.contains('local')) {
      return Icons.lightbulb_rounded;
    }
    if (lower.contains('train') || lower.contains('rail')) {
      return Icons.train_rounded;
    }
    if (lower.contains('route') ||
        lower.contains('distance') ||
        lower.contains('time') ||
        lower.contains('travel')) {
      return Icons.route_rounded;
    }
    if (lower.contains('cost') ||
        lower.contains('price') ||
        lower.contains('budget') ||
        lower.contains('fare')) {
      return Icons.payments_rounded;
    }
    if (lower.contains('weather') || lower.contains('overview')) {
      return Icons.wb_sunny_rounded;
    }
    if (lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('dining')) {
      return Icons.restaurant_rounded;
    }
    return Icons.auto_awesome_rounded;
  }
}
