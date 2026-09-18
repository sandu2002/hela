import 'package:flutter/material.dart';

/// Global shared state for the HELA app.
///
/// Tracks bookmarked/saved guide IDs, audio playback state,
/// and the current bottom-nav tab index so they persist across screens.
class HelaAppState extends ChangeNotifier {
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

  // ── Authentication ─────────────────────────────────────────────
  bool _isAuthenticated = false;
  String _userName = 'Guest';
  String _userEmail = '';
  String? _userPhotoUrl;

  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get userPhotoUrl => _userPhotoUrl;

  void signIn({required String name, required String email, String? photoUrl}) {
    _isAuthenticated = true;
    _userName = name;
    _userEmail = email;
    _userPhotoUrl = photoUrl;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userName = 'Guest';
    _userEmail = '';
    _userPhotoUrl = null;
    notifyListeners();
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

  static HelaAppState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<HelaAppStateProvider>();
    assert(provider != null, 'No HelaAppStateProvider found in context');
    return provider!.notifier!;
  }
}
