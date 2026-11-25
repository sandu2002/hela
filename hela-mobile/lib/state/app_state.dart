import 'package:flutter/material.dart';
import 'package:hela/models/haven_item.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/pages/stays_page.dart' show StayHaven;
import 'package:hela/services/localization_service.dart';
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

  List<ExperienceItem> get savedExperiences => List.unmodifiable(_savedExperiences);

  bool isExperienceSaved(String title) => _savedExperiences.any((e) => e.title == title);

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
  final List<TourPlan> _savedTours = [];

  List<TourPlan> get savedTours => List.unmodifiable(_savedTours);

  bool isTourSaved(String id) => _savedTours.any((t) => t.id == id);

  void toggleSaveTour(TourPlan plan) {
    final index = _savedTours.indexWhere((t) => t.id == plan.id);
    if (index >= 0) {
      _savedTours.removeAt(index);
    } else {
      _savedTours.add(plan.copyWith(isSaved: true));
    }
    notifyListeners();
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
  }

  void removeSavedTour(String id) {
    _savedTours.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void clearAllSavedTours() {
    _savedTours.clear();
    notifyListeners();
  }

  int get totalSavedCount =>
      _savedHavens.length + _savedExperiences.length + _savedStays.length + _savedTours.length;

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
  bool _isAuthenticated = false;
  String _userName = 'Kavinda Wickramasinghe';
  String _userEmail = 'kavinda.w@gmail.com';
  String _userTitle = '🌿 Tea Country Pathfinder · Level 4';
  String _userBio = 'Explorer of Ceylon highlands, tea estates, and ancient sanctuaries.';
  String _userPhone = '+94 77 123 4567';
  String _userLocation = 'Kandy, Central Province';
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
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // ── Language & Localization ────────────────────────────────────
  static const String _languagePrefsKey = 'hela_selected_language_v1';
  String _selectedLanguage = 'EN';

  String get selectedLanguage => _selectedLanguage;

  bool get isRtl => _selectedLanguage == 'AR';

  String get languageDisplayName => LocalizationService.getDisplayName(_selectedLanguage);

  Future<void> restoreLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_languagePrefsKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _selectedLanguage = saved.toUpperCase();
        notifyListeners();
      }
    } catch (_) {
      // Ignore storage failures on startup
    }
  }

  void setLanguage(String code) {
    final upper = code.toUpperCase();
    if (_selectedLanguage != upper) {
      _selectedLanguage = upper;
      notifyListeners();
      _persistLanguage(upper);
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
    final provider =
        context.dependOnInheritedWidgetOfExactType<HelaAppStateProvider>();
    return provider?.notifier ?? _fallbackState;
  }

  static HelaAppState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HelaAppStateProvider>()
        ?.notifier;
  }
}
