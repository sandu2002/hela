import 'package:flutter/material.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/destination.dart';

/// Represents the current phase of the tour planning process.
enum TourPlannerPhase {
  /// User is entering travel preferences.
  preferences,

  /// System is searching for destinations.
  discovering,

  /// Showing discovered destination recommendations.
  recommendations,

  /// AI is generating the itinerary.
  generating,

  /// Showing the generated tour plan.
  planReady,

  /// User is customizing the plan via chat.
  customizing,

  /// An error occurred.
  error,
}

/// State management for the Smart Tour Planner feature.
///
/// Tracks the user's progress through preferences → discovery →
/// AI generation → customization → save.
class TourPlannerState extends ChangeNotifier {
  // ── Current Phase ──────────────────────────────────────────────
  TourPlannerPhase _phase = TourPlannerPhase.preferences;
  TourPlannerPhase get phase => _phase;

  void setPhase(TourPlannerPhase phase) {
    _phase = phase;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Travel Preferences ─────────────────────────────────────────
  TourPreferences _preferences = const TourPreferences();
  TourPreferences get preferences => _preferences;

  void updatePreferences(TourPreferences preferences) {
    _preferences = preferences;
    notifyListeners();
  }

  // ── Discovered Destinations ────────────────────────────────────
  List<Destination> _discoveredDestinations = [];
  List<Destination> get discoveredDestinations => _discoveredDestinations;

  Set<String> _selectedDestinationIds = {};
  Set<String> get selectedDestinationIds => _selectedDestinationIds;

  List<Destination> get selectedDestinations => _discoveredDestinations
      .where((d) => _selectedDestinationIds.contains(d.sourceId))
      .toList();

  void setDiscoveredDestinations(List<Destination> destinations) {
    _discoveredDestinations = destinations;
    // Auto-select top destinations
    _selectedDestinationIds = destinations
        .take(5)
        .map((d) => d.sourceId)
        .toSet();
    _phase = TourPlannerPhase.recommendations;
    notifyListeners();
  }

  void toggleDestinationSelection(String sourceId) {
    if (_selectedDestinationIds.contains(sourceId)) {
      _selectedDestinationIds.remove(sourceId);
    } else {
      _selectedDestinationIds.add(sourceId);
    }
    notifyListeners();
  }

  // ── Tour Plan ──────────────────────────────────────────────────
  TourPlan? _currentPlan;
  TourPlan? get currentPlan => _currentPlan;

  List<TourPlan> _planHistory = [];
  List<TourPlan> get planHistory => _planHistory;

  void setCurrentPlan(TourPlan plan) {
    if (_currentPlan != null) {
      _planHistory.add(_currentPlan!);
    }
    _currentPlan = plan;
    _phase = TourPlannerPhase.planReady;
    notifyListeners();
  }

  void revertToPreviousVersion() {
    if (_planHistory.isNotEmpty) {
      _currentPlan = _planHistory.removeLast();
      notifyListeners();
    }
  }

  // ── Chat Messages ──────────────────────────────────────────────
  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  void addChatMessage(ChatMessage message) {
    _chatMessages.add(message);
    notifyListeners();
  }

  void clearChat() {
    _chatMessages.clear();
    notifyListeners();
  }

  // ── Loading & Error ────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _loadingMessage = 'Planning your adventure...';
  String get loadingMessage => _loadingMessage;

  void setLoading(bool loading, {String? message}) {
    _isLoading = loading;
    if (message != null) _loadingMessage = message;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _phase = TourPlannerPhase.error;
    notifyListeners();
  }

  // ── Saved Tours ────────────────────────────────────────────────
  final List<TourPlan> _savedTours = [];
  List<TourPlan> get savedTours => List.unmodifiable(_savedTours);

  void saveTour(TourPlan plan) {
    final saved = plan.copyWith(isSaved: true);
    _savedTours.add(saved);
    if (_currentPlan?.id == plan.id) {
      _currentPlan = saved;
    }
    notifyListeners();
  }

  void removeSavedTour(String id) {
    _savedTours.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ── Reset ──────────────────────────────────────────────────────
  void reset() {
    _phase = TourPlannerPhase.preferences;
    _preferences = const TourPreferences();
    _discoveredDestinations = [];
    _selectedDestinationIds = {};
    _currentPlan = null;
    _planHistory = [];
    _chatMessages = [];
    _isLoading = false;
    _errorMessage = null;
    _loadingMessage = 'Planning your adventure...';
    notifyListeners();
  }
}

/// InheritedNotifier to expose [TourPlannerState] down the widget tree.
class TourPlannerStateProvider extends InheritedNotifier<TourPlannerState> {
  static final TourPlannerState _sharedFallback = TourPlannerState();

  const TourPlannerStateProvider({
    super.key,
    required TourPlannerState state,
    required super.child,
  }) : super(notifier: state);

  static TourPlannerState of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TourPlannerStateProvider>();
    return provider?.notifier ?? _sharedFallback;
  }

  /// Access the state without listening for changes.
  static TourPlannerState read(BuildContext context) {
    final provider = context
        .getInheritedWidgetOfExactType<TourPlannerStateProvider>();
    return provider?.notifier ?? _sharedFallback;
  }
}
