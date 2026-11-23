// Data models for travel preferences used in the Smart Tour Planner.

/// Represents the user's travel duration selection.
enum TravelDuration {
  oneDay(1, '1 Day'),
  twoDays(2, '2 Days'),
  threeDays(3, '3 Days'),
  fiveDays(5, '5 Days'),
  sevenDays(7, '7 Days'),
  custom(0, 'Custom');

  final int days;
  final String label;
  const TravelDuration(this.days, this.label);
}

/// Travel interest categories for destination matching.
enum TravelInterest {
  adventure('Adventure', '🧗'),
  culture('Culture', '🏛️'),
  romantic('Romantic', '💕'),
  trekking('Trekking', '🥾'),
  hiking('Hiking', '🏔️'),
  wildlife('Wildlife', '🐘'),
  nature('Nature', '🌿'),
  beaches('Beaches', '🏖️'),
  food('Food', '🍛'),
  photography('Photography', '📸'),
  familyFriendly('Family-friendly', '👨‍👩‍👧‍👦'),
  relaxation('Relaxation', '🧘');

  final String label;
  final String emoji;
  const TravelInterest(this.label, this.emoji);
}

/// Budget level preference.
enum BudgetLevel {
  low('Budget', 'Under \$50/day'),
  medium('Mid-range', '\$50–\$150/day'),
  high('Premium', '\$150+/day');

  final String label;
  final String description;
  const BudgetLevel(this.label, this.description);
}

/// Travel pace preference.
enum TravelPace {
  relaxed('Relaxed', '2–3 activities per day'),
  moderate('Moderate', '3–5 activities per day'),
  active('Active', '5+ activities per day');

  final String label;
  final String description;
  const TravelPace(this.label, this.description);
}

/// Accommodation type preference.
enum AccommodationType {
  hostel('Hostel'),
  guesthouse('Guesthouse'),
  hotel('Hotel'),
  resort('Resort'),
  villa('Villa'),
  ecoLodge('Eco Lodge'),
  noPreference('No Preference');

  final String label;
  const AccommodationType(this.label);
}

/// Starting location type.
enum StartingLocationType {
  airport('Airport'),
  city('City'),
  custom('Custom Location');

  final String label;
  const StartingLocationType(this.label);
}

/// Complete set of user preferences for tour planning.
class TourPreferences {
  final TravelDuration duration;
  final int customDays; // Used when duration == TravelDuration.custom
  final StartingLocationType startingLocationType;
  final String startingLocationName;
  final Set<TravelInterest> interests;
  final BudgetLevel budgetLevel;
  final double? budgetAmount; // Optional specific budget in USD
  final int numberOfTravelers;
  final TravelPace pace;
  final AccommodationType accommodationType;
  final String additionalNotes;

  const TourPreferences({
    this.duration = TravelDuration.threeDays,
    this.customDays = 3,
    this.startingLocationType = StartingLocationType.airport,
    this.startingLocationName = 'Bandaranaike International Airport',
    this.interests = const {},
    this.budgetLevel = BudgetLevel.medium,
    this.budgetAmount,
    this.numberOfTravelers = 2,
    this.pace = TravelPace.moderate,
    this.accommodationType = AccommodationType.noPreference,
    this.additionalNotes = '',
  });

  /// Effective number of travel days.
  int get effectiveDays =>
      duration == TravelDuration.custom ? customDays : duration.days;

  /// Creates a copy with updated fields.
  TourPreferences copyWith({
    TravelDuration? duration,
    int? customDays,
    StartingLocationType? startingLocationType,
    String? startingLocationName,
    Set<TravelInterest>? interests,
    BudgetLevel? budgetLevel,
    double? budgetAmount,
    int? numberOfTravelers,
    TravelPace? pace,
    AccommodationType? accommodationType,
    String? additionalNotes,
  }) {
    return TourPreferences(
      duration: duration ?? this.duration,
      customDays: customDays ?? this.customDays,
      startingLocationType: startingLocationType ?? this.startingLocationType,
      startingLocationName: startingLocationName ?? this.startingLocationName,
      interests: interests ?? this.interests,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      numberOfTravelers: numberOfTravelers ?? this.numberOfTravelers,
      pace: pace ?? this.pace,
      accommodationType: accommodationType ?? this.accommodationType,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  /// Serializes to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'duration': effectiveDays,
      'startingLocationType': startingLocationType.name,
      'startingLocationName': startingLocationName,
      'interests': interests.map((i) => i.name).toList(),
      'budgetLevel': budgetLevel.name,
      if (budgetAmount != null) 'budgetAmount': budgetAmount,
      'numberOfTravelers': numberOfTravelers,
      'pace': pace.name,
      'accommodationType': accommodationType.name,
      if (additionalNotes.isNotEmpty) 'additionalNotes': additionalNotes,
    };
  }

  /// Validates that the minimum required preferences are set.
  List<String> validate() {
    final errors = <String>[];
    if (interests.isEmpty) {
      errors.add('Please select at least one travel interest.');
    }
    if (duration == TravelDuration.custom && customDays < 1) {
      errors.add('Custom duration must be at least 1 day.');
    }
    if (startingLocationName.trim().isEmpty) {
      errors.add('Please specify a starting location.');
    }
    if (numberOfTravelers < 1) {
      errors.add('Number of travelers must be at least 1.');
    }
    return errors;
  }
}
