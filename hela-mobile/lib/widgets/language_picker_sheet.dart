import 'package:flutter/material.dart';
import 'package:hela/services/localization_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';

/// Opens the shared HELA Language Picker bottom sheet with search and updates [HelaAppState].
Future<void> showHelaLanguagePickerSheet(
  BuildContext context, {
  ValueChanged<HelaLanguageItem>? onLanguageSelected,
}) {
  final appState = HelaAppStateProvider.of(context);
  final currentCode = appState.selectedLanguage;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      String query = '';
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final colors = HelaColors.of(ctx);
          final normalized = query.trim().toLowerCase();
          final filtered = LocalizationService.supportedLanguages.where((lang) {
            if (normalized.isEmpty) return true;
            return lang.name.toLowerCase().contains(normalized) ||
                lang.nativeName.toLowerCase().contains(normalized) ||
                lang.code.toLowerCase().contains(normalized);
          }).toList();

          return Material(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.78,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: colors.architecturalBorder,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  appState.tr('select_language'),
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: colors.onSurfaceVariant,
                                ),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          Text(
                            appState.tr('language_desc'),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (value) =>
                                setSheetState(() => query = value),
                            decoration: InputDecoration(
                              hintText: appState.tr('search_language'),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 20,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: colors.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colors.architecturalBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colors.architecturalBorder,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final lang = filtered[index];
                          final isSelected =
                              lang.code.toUpperCase() ==
                              currentCode.toUpperCase();
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              selected: isSelected,
                              selectedTileColor: colors.primary.withValues(
                                alpha: 0.08,
                              ),
                              leading: Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 22),
                              ),
                              title: Text(
                                lang.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? colors.primary
                                      : colors.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                lang.nativeName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: colors.primary,
                                    )
                                  : null,
                              onTap: () {
                                appState.setLanguage(lang.code);
                                Navigator.pop(ctx);
                                onLanguageSelected?.call(lang);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
