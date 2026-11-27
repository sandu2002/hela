import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hela/models/haven_item.dart';
import 'package:hela/models/saved_list.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/pages/bookings/stays_page.dart' show StayHaven;
import 'package:hela/l10n/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global shared state for the HELA app.
///
/// Tracks bookmarked/saved guide IDs, saved havens/destinations, audio playback state,
/// and the current bottom-nav tab index so they persist across screens.
class HelaAppState extends ChangeNotifier {
  // ── Saved / Bookmarked Havens ──────────────────────────────────
  final List<HavenItem> _savedHavens = [];

  List<HavenItem> get savedHavens => List.unmodifiable(_savedHavens);

  bool isHavenSaved(String title) => _savedHavens.any((h) => h.title == title);

  void toggleSaveHaven(HavenItem item) {
    final index = _savedHavens.indexWhere((h) => h.title == item.title);
    if (index >= 0) {
      _savedHavens.removeAt(index);
    } else {
      _savedHavens.add(item);
    }
    notifyListeners();
  }

  void removeSavedHaven(String title) {
    _savedHavens.removeWhere((h) => h.title == title);
    notifyListeners();
  }

  // ── Saved / Bookmarked Experiences ─────────────────────────────
  final List<ExperienceItem> _savedExperiences = [];

  List<ExperienceItem> get savedExperiences =>
      List.unmodifiable(_savedExperiences);

  bool isExperienceSaved(String title) =>
      _savedExperiences.any((e) => e.title == title);

  void toggleSaveExperience(ExperienceItem item) {
    final index = _savedExperiences.indexWhere((e) => e.title == item.title);
    if (index >= 0) {
      _savedExperiences.removeAt(index);
    } else {
      _savedExperiences.add(item);
    }
    notifyListeners();
  }

  void removeSavedExperience(String title) {
    _savedExperiences.removeWhere((e) => e.title == title);
    notifyListeners();
  }

  // ── Saved / Bookmarked Stays ───────────────────────────────────
  final List<StayHaven> _savedStays = [];

  List<StayHaven> get savedStays => List.unmodifiable(_savedStays);

  bool isStaySaved(String title) => _savedStays.any((s) => s.title == title);

  void toggleSaveStay(StayHaven item) {
    final index = _savedStays.indexWhere((s) => s.title == item.title);
    if (index >= 0) {
      _savedStays.removeAt(index);
    } else {
      _savedStays.add(item);
    }
    notifyListeners();
  }

  void removeSavedStay(String title) {
    _savedStays.removeWhere((s) => s.title == title);
    notifyListeners();
  }

  // ── Saved / Bookmarked Smart Tours ─────────────────────────────
  static const String _savedToursPrefsKey = 'hela_saved_tours_v1';
  final List<TourPlan> _savedTours = [];

  List<TourPlan> get savedTours => List.unmodifiable(_savedTours);

  bool isTourSaved(String id) => _savedTours.any((t) => t.id == id);

  Future<void> restoreSavedTours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_savedToursPrefsKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _savedTours
        ..clear()
        ..addAll(list.map((e) => TourPlan.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Ignore corrupt local cache
    }
  }

  Future<void> _persistSavedTours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_savedTours.map((t) => t.toJson()).toList());
      await prefs.setString(_savedToursPrefsKey, encoded);
    } catch (_) {}
  }

  void toggleSaveTour(TourPlan plan) {
    final index = _savedTours.indexWhere((t) => t.id == plan.id);
    if (index >= 0) {
      _savedTours.removeAt(index);
    } else {
      _savedTours.add(plan.copyWith(isSaved: true));
    }
    notifyListeners();
    _persistSavedTours();
  }

  void saveTour(TourPlan plan) {
    final index = _savedTours.indexWhere((t) => t.id == plan.id);
    final saved = plan.copyWith(isSaved: true);
    if (index >= 0) {
      _savedTours[index] = saved;
    } else {
      _savedTours.add(saved);
    }
    notifyListeners();
    _persistSavedTours();
  }

  void removeSavedTour(String id) {
    _savedTours.removeWhere((t) => t.id == id);
    notifyListeners();
    _persistSavedTours();
  }

  void clearAllSavedTours() {
    _savedTours.clear();
    notifyListeners();
    _persistSavedTours();
  }

  int get totalSavedCount =>
      _savedHavens.length +
      _savedExperiences.length +
      _savedStays.length +
      _savedTours.length;

  // ── User Custom Saved Lists / Themed Collections ──────────────
  final List<CustomSavedList> _customLists = [
    CustomSavedList(
      id: 'list_beach',
      name: 'Beach Escapes',
      description: 'Sun, sand & coastal surf sanctuaries',
      icon: Icons.beach_access_rounded,
      color: const Color(0xFF0D9488),
      itemTitles: [],
    ),
    CustomSavedList(
      id: 'list_heritage',
      name: 'Cultural Wonders',
      description: 'Ancient rock citadels, sacred shrines & history',
      icon: Icons.temple_buddhist_rounded,
      color: const Color(0xFFD97706),
      itemTitles: [],
    ),
    CustomSavedList(
      id: 'list_nature',
      name: 'Nature & Safaris',
      description: 'Mist-shrouded peaks, tea valleys & wild elephants',
      icon: Icons.park_rounded,
      color: const Color(0xFF059669),
      itemTitles: [],
    ),
  ];

  List<CustomSavedList> get customLists => List.unmodifiable(_customLists);

  CustomSavedList? getCustomList(String id) {
    try {
      return _customLists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Checks whether a given saved item matches a custom collection.
  /// Matches if the title is explicitly included in the collection,
  /// or for preset themed collections, if the title/category matches relevant keywords.
  bool itemMatchesList(String title, String category, CustomSavedList list) {
    if (list.itemTitles.contains(title)) {
      return true;
    }

    final t = title.toLowerCase();
    final c = category.toLowerCase();

    if (list.id == 'list_beach' || list.name.toLowerCase().contains('beach')) {
      return c.contains('beach') ||
          c.contains('coast') ||
          c.contains('surf') ||
          t.contains('beach') ||
          t.contains('bay') ||
          t.contains('coast') ||
          t.contains('surf');
    }

    if (list.id == 'list_heritage' ||
        list.name.toLowerCase().contains('cultural') ||
        list.name.toLowerCase().contains('heritage')) {
      return c.contains('cultural') ||
          c.contains('heritage') ||
          c.contains('temple') ||
          c.contains('fort') ||
          c.contains('history') ||
          t.contains('sigiriya') ||
          t.contains('rock fortress') ||
          t.contains('temple') ||
          t.contains('fort') ||
          t.contains('citadel') ||
          t.contains('sacred') ||
          t.contains('ancient') ||
          t.contains('monastery');
    }

    if (list.id == 'list_nature' ||
        list.name.toLowerCase().contains('nature') ||
        list.name.toLowerCase().contains('safari')) {
      return c.contains('nature') ||
          c.contains('wildlife') ||
          c.contains('safari') ||
          c.contains('mountain') ||
          c.contains('highlands') ||
          c.contains('park') ||
          t.contains('park') ||
          t.contains('bridge') ||
          t.contains('falls') ||
          t.contains('valley') ||
          t.contains('plains') ||
          t.contains('peak') ||
          t.contains('rainforest') ||
          t.contains('forest');
    }

    return false;
  }

  /// Computes the exact real-time count of user-saved items belonging to this collection.
  int getSavedItemCountForList(CustomSavedList list) {
    int count = 0;
    final countedTitles = <String>{};

    for (final haven in _savedHavens) {
      if (!countedTitles.contains(haven.title) &&
          itemMatchesList(haven.title, haven.category, list)) {
        countedTitles.add(haven.title);
        count++;
      }
    }
    for (final tour in _savedTours) {
      if (!countedTitles.contains(tour.title) &&
          itemMatchesList(tour.title, 'tour', list)) {
        countedTitles.add(tour.title);
        count++;
      }
    }
    for (final stay in _savedStays) {
      if (!countedTitles.contains(stay.title) &&
          itemMatchesList(
            stay.title,
            '${stay.location} ${stay.ratingLabel}',
            list,
          )) {
        countedTitles.add(stay.title);
        count++;
      }
    }
    for (final exp in _savedExperiences) {
      if (!countedTitles.contains(exp.title) &&
          itemMatchesList(exp.title, exp.category, list)) {
        countedTitles.add(exp.title);
        count++;
      }
    }
    return count;
  }

  void createCustomList({
    required String name,
    String? description,
    IconData? icon,
    Color? color,
    List<String>? initialItemTitles,
  }) {
    final list = CustomSavedList(
      id: 'list_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description?.trim(),
      icon: icon ?? Icons.bookmark_rounded,
      color: color ?? const Color(0xFF00443E),
      itemTitles: initialItemTitles ?? [],
    );
    _customLists.add(list);
    notifyListeners();
  }

  void deleteCustomList(String id) {
    _customLists.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  void renameCustomList(String id, String newName) {
    final index = _customLists.indexWhere((l) => l.id == id);
    if (index >= 0) {
      _customLists[index] = _customLists[index].copyWith(name: newName.trim());
      notifyListeners();
    }
  }

  void toggleItemInCustomList(String listId, String itemTitle) {
    final index = _customLists.indexWhere((l) => l.id == listId);
    if (index >= 0) {
      final list = _customLists[index];
      final titles = List<String>.from(list.itemTitles);
      if (titles.contains(itemTitle)) {
        titles.remove(itemTitle);
      } else {
        titles.add(itemTitle);
      }
      _customLists[index] = list.copyWith(itemTitles: titles);
      notifyListeners();
    }
  }

  bool isItemInList(String listId, String itemTitle, [String category = '']) {
    final list = getCustomList(listId);
    if (list == null) return false;
    return itemMatchesList(itemTitle, category, list);
  }

  List<CustomSavedList> getListsContainingItem(
    String itemTitle, [
    String category = '',
  ]) {
    return _customLists
        .where((l) => itemMatchesList(itemTitle, category, l))
        .toList();
  }

  // ── Saved / Bookmarked Guides ──────────────────────────────────
  final Set<String> _savedGuideIds = <String>{};

  Set<String> get savedGuideIds => Set.unmodifiable(_savedGuideIds);

  bool isGuideSaved(String id) => _savedGuideIds.contains(id);

  void toggleGuide(String id) {
    if (_savedGuideIds.contains(id)) {
      _savedGuideIds.remove(id);
    } else {
      _savedGuideIds.add(id);
    }
    notifyListeners();
  }

  // ── Offline-saved Guides ───────────────────────────────────────
  final Set<String> _offlineGuideIds = <String>{};

  bool isGuideOffline(String id) => _offlineGuideIds.contains(id);

  void toggleOfflineGuide(String id) {
    if (_offlineGuideIds.contains(id)) {
      _offlineGuideIds.remove(id);
    } else {
      _offlineGuideIds.add(id);
    }
    notifyListeners();
  }

  // ── Audio Playback ─────────────────────────────────────────────
  bool _isAudioPlaying = false;
  double _audioPosition = 0.0; // 0.0 – 1.0
  double _audioSpeed = 1.0;

  bool get isAudioPlaying => _isAudioPlaying;
  double get audioPosition => _audioPosition;
  double get audioSpeed => _audioSpeed;

  void toggleAudioPlaying() {
    _isAudioPlaying = !_isAudioPlaying;
    notifyListeners();
  }

  void setAudioPlaying(bool playing) {
    _isAudioPlaying = playing;
    notifyListeners();
  }

  void setAudioPosition(double pos) {
    _audioPosition = pos.clamp(0.0, 1.0);
    notifyListeners();
  }

  void cycleAudioSpeed() {
    if (_audioSpeed == 1.0) {
      _audioSpeed = 1.25;
    } else if (_audioSpeed == 1.25) {
      _audioSpeed = 1.5;
    } else {
      _audioSpeed = 1.0;
    }
    notifyListeners();
  }

  // ── Bottom Nav ─────────────────────────────────────────────────
  int _currentNavIndex = 0;

  int get currentNavIndex => _currentNavIndex;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // ── Authentication & Profile ────────────────────────────────────
  // L-1: Removed real-looking hardcoded demo data; defaults to anonymous state
  bool _isAuthenticated = false;
  String _userName = 'Explorer';
  String _userEmail = '';
  String _userTitle = 'Sri Lanka Traveler';
  String _userBio = '';
  String _userPhone = '';
  String _userLocation = '';
  String? _userPhotoUrl;

  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userTitle => _userTitle;
  String get userBio => _userBio;
  String get userPhone => _userPhone;
  String get userLocation => _userLocation;
  String? get userPhotoUrl => _userPhotoUrl;

  void signIn({required String name, required String email, String? photoUrl}) {
    _isAuthenticated = true;
    _userName = name;
    _userEmail = email;
    _userPhotoUrl = photoUrl;
    notifyListeners();
  }

  void continueAsGuest() {
    _isAuthenticated = false;
    _userName = 'Guest Explorer';
    _userEmail = '';
    _userPhotoUrl = null;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userName = 'Guest';
    _userEmail = '';
    _userPhotoUrl = null;
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? email,
    String? title,
    String? bio,
    String? phone,
    String? location,
    String? photoUrl,
  }) {
    if (name != null && name.trim().isNotEmpty) _userName = name.trim();
    if (email != null && email.trim().isNotEmpty) _userEmail = email.trim();
    if (title != null && title.trim().isNotEmpty) _userTitle = title.trim();
    if (bio != null) _userBio = bio.trim();
    if (phone != null) _userPhone = phone.trim();
    if (location != null) _userLocation = location.trim();
    if (photoUrl != null) _userPhotoUrl = photoUrl;
    notifyListeners();
  }

  // ── Theme Mode ──────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  // ── Language & Localization ────────────────────────────────────
  static const String _languagePrefsKey = 'hela_selected_language_v1';
  String _selectedLanguage = 'EN';

  String get selectedLanguage => _selectedLanguage;

  bool get isRtl => _selectedLanguage == 'AR' || _selectedLanguage == 'UR';

  String get languageDisplayName =>
      LocalizationService.getDisplayName(_selectedLanguage);

  Future<void> restoreLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_languagePrefsKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _selectedLanguage = LocalizationService.getLanguage(saved).code;
        notifyListeners();
      }
    } catch (_) {
      // Ignore storage failures on startup
    }
  }

  void setLanguage(String code) {
    final normalized = LocalizationService.getLanguage(code).code;
    if (_selectedLanguage != normalized) {
      _selectedLanguage = normalized;
      notifyListeners();
      _persistLanguage(normalized);
    }
  }

  Future<void> _persistLanguage(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languagePrefsKey, code);
    } catch (_) {}
  }

  String tr(String key) => LocalizationService.tr(key, _selectedLanguage);

  // ── Travel & App Preferences (Profile Page) ─────────────────────
  String _preferredCurrency = 'USD (\$)';
  bool _smartTravelAlerts = true;
  String _mapRendering = 'Hybrid';
  bool _offlineGuideCached = true;
  int _offlineGuideSizeMb = 340;
  int _unreadAlertsCount = 2;

  String get preferredCurrency => _preferredCurrency;
  bool get smartTravelAlerts => _smartTravelAlerts;
  String get mapRendering => _mapRendering;
  bool get offlineGuideCached => _offlineGuideCached;
  int get offlineGuideSizeMb => _offlineGuideSizeMb;
  int get unreadAlertsCount => _unreadAlertsCount;

  void setPreferredCurrency(String currency) {
    if (_preferredCurrency != currency) {
      _preferredCurrency = currency;
      notifyListeners();
    }
  }

  void setSmartTravelAlerts(bool enabled) {
    if (_smartTravelAlerts != enabled) {
      _smartTravelAlerts = enabled;
      notifyListeners();
    }
  }

  void setMapRendering(String mode) {
    if (_mapRendering != mode) {
      _mapRendering = mode;
      notifyListeners();
    }
  }

  void setOfflineGuideCache({required bool cached, int sizeMb = 340}) {
    _offlineGuideCached = cached;
    _offlineGuideSizeMb = cached ? sizeMb : 0;
    notifyListeners();
  }

  void clearUnreadAlerts() {
    if (_unreadAlertsCount != 0) {
      _unreadAlertsCount = 0;
      notifyListeners();
    }
  }

  // ── Live Detected City (Home Header Pill) ───────────────────────
  String? _detectedCurrentCity;

  String? get detectedCurrentCity => _detectedCurrentCity;

  void setDetectedCurrentCity(String city) {
    final trimmed = city.trim();
    if (trimmed.isNotEmpty && _detectedCurrentCity != trimmed) {
      _detectedCurrentCity = trimmed;
      notifyListeners();
    }
  }
}

/// An InheritedNotifier that exposes [HelaAppState] down the tree.
///
/// Usage:
///   HelaAppStateProvider.of(context)  → HelaAppState
class HelaAppStateProvider extends InheritedNotifier<HelaAppState> {
  const HelaAppStateProvider({
    super.key,
    required HelaAppState state,
    required super.child,
  }) : super(notifier: state);

  static final HelaAppState _fallbackState = HelaAppState();

  static HelaAppState of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<HelaAppStateProvider>();
    return provider?.notifier ?? _fallbackState;
  }

  static HelaAppState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HelaAppStateProvider>()
        ?.notifier;
  }
}
