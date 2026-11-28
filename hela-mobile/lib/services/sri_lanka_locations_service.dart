import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/config/api_config.dart';

/// Represents a Sri Lankan location suggestion (city, town, sub-location, airport).
class SriLankaLocationResult {
  final String name;
  final String subtitle;
  final StartingLocationType type;
  final IconData icon;
  final String? shortLabel;
  final double? latitude;
  final double? longitude;

  const SriLankaLocationResult({
    required this.name,
    required this.subtitle,
    required this.type,
    required this.icon,
    this.shortLabel,
    this.latitude,
    this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SriLankaLocationResult &&
          runtimeType == other.runtimeType &&
          name.toLowerCase() == other.name.toLowerCase() &&
          subtitle.toLowerCase() == other.subtitle.toLowerCase();

  @override
  int get hashCode =>
      name.toLowerCase().hashCode ^ subtitle.toLowerCase().hashCode;
}

/// Service providing extensive local Sri Lanka locations and sub-locations,
/// with live OpenStreetMap Nominatim search for discovering any village, suburb or landmark.
class SriLankaLocationsService {
  static final http.Client _client = http.Client();

  /// Popular starting points shown as quick buttons.
  static const List<SriLankaLocationResult> popularStartingPoints = [
    SriLankaLocationResult(
      name: 'Bandaranaike International Airport',
      shortLabel: '✈️ Airport (BIA)',
      subtitle: 'Main International Airport, Katunayake',
      type: StartingLocationType.airport,
      icon: Icons.flight_takeoff_rounded,
    ),
    SriLankaLocationResult(
      name: 'Colombo Fort',
      shortLabel: '🏙️ Colombo',
      subtitle: 'Commercial Capital & Main Train Hub',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Negombo',
      shortLabel: '🌊 Negombo',
      subtitle: 'Coastal Town Near Airport (15 mins)',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kandy',
      shortLabel: '🏔️ Kandy',
      subtitle: 'Hill Capital & Temple of the Tooth',
      type: StartingLocationType.city,
      icon: Icons.landscape_rounded,
    ),
    SriLankaLocationResult(
      name: 'Galle',
      shortLabel: '🏰 Galle',
      subtitle: 'Historic Dutch Fort & Southern Coast',
      type: StartingLocationType.city,
      icon: Icons.fort_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ella',
      shortLabel: '🌿 Ella',
      subtitle: 'Scenic Mountain Town & Hiking Trails',
      type: StartingLocationType.city,
      icon: Icons.terrain_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nuwara Eliya',
      shortLabel: '🫖 Nuwara Eliya',
      subtitle: 'Tea Country & Cool Climate',
      type: StartingLocationType.city,
      icon: Icons.local_florist_rounded,
    ),
    SriLankaLocationResult(
      name: 'Sigiriya',
      shortLabel: '🏛️ Sigiriya',
      subtitle: 'Cultural Triangle & Ancient Fortress',
      type: StartingLocationType.city,
      icon: Icons.museum_rounded,
    ),
  ];

  /// Comprehensive directory of 250+ Sri Lankan cities, towns, and sub-locations
  /// across all 25 districts for instant offline auto-completion.
  static const List<SriLankaLocationResult> catalog = [
    // ── Central Province ──
    // Kandy District & Sub-locations
    SriLankaLocationResult(
      name: 'Kandy',
      subtitle: 'Central Province · Capital',
      type: StartingLocationType.city,
      icon: Icons.landscape_rounded,
    ),
    SriLankaLocationResult(
      name: 'Digana',
      subtitle: 'Kandy District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Peradeniya',
      subtitle: 'Kandy District · Botanical Gardens & Campus',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Katugastota',
      subtitle: 'Kandy District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kundasale',
      subtitle: 'Kandy District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pallekele',
      subtitle: 'Kandy District · Cricket Stadium & Industrial',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Gampola',
      subtitle: 'Kandy District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nawalapitiya',
      subtitle: 'Kandy District · Hill Country',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Teldeniya',
      subtitle: 'Kandy District · Victoria Reservoir',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Menikhinna',
      subtitle: 'Kandy District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wattegama',
      subtitle: 'Kandy District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kadugannawa',
      subtitle: 'Kandy District · Dawson Tower & Pass',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pilimathalawa',
      subtitle: 'Kandy District · Brass Crafts Center',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Akurana',
      subtitle: 'Kandy District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Gelioya',
      subtitle: 'Kandy District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Madawala',
      subtitle: 'Kandy District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hasalaka',
      subtitle: 'Kandy District · Knuckles Foothills',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Galagedara',
      subtitle: 'Kandy District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // Matale District & Sub-locations
    SriLankaLocationResult(
      name: 'Matale',
      subtitle: 'Central Province · Spice Capital',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Dambulla',
      subtitle: 'Matale District · Cave Temple & Hub',
      type: StartingLocationType.city,
      icon: Icons.museum_rounded,
    ),
    SriLankaLocationResult(
      name: 'Sigiriya',
      subtitle: 'Matale District · Ancient Rock Fortress',
      type: StartingLocationType.city,
      icon: Icons.museum_rounded,
    ),
    SriLankaLocationResult(
      name: 'Habarana',
      subtitle: 'Matale/Anuradhapura Border · Safari Hub',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Galewela',
      subtitle: 'Matale District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ukuwela',
      subtitle: 'Matale District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Rattota',
      subtitle: 'Matale District · Riverston Gateway',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Riverston',
      subtitle: 'Matale District · Knuckles Mountain Range',
      type: StartingLocationType.city,
      icon: Icons.terrain_rounded,
    ),
    SriLankaLocationResult(
      name: 'Naula',
      subtitle: 'Matale District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // Nuwara Eliya District & Sub-locations
    SriLankaLocationResult(
      name: 'Nuwara Eliya',
      subtitle: 'Central Province · Little England',
      type: StartingLocationType.city,
      icon: Icons.local_florist_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hatton',
      subtitle: 'Nuwara Eliya District · Tea Gateway',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Maskeliya',
      subtitle: 'Nuwara Eliya District · Adams Peak Base',
      type: StartingLocationType.city,
      icon: Icons.terrain_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nallathanniya',
      subtitle: 'Nuwara Eliya District · Sri Pada / Adams Peak',
      type: StartingLocationType.city,
      icon: Icons.terrain_rounded,
    ),
    SriLankaLocationResult(
      name: 'Talawakele',
      subtitle: 'Nuwara Eliya District · St. Clair Falls',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kotagala',
      subtitle: 'Nuwara Eliya District · Central Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nanu Oya',
      subtitle: 'Nuwara Eliya District · Scenic Train Hub',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kandapola',
      subtitle: 'Nuwara Eliya District · Highest Elevation',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ragala',
      subtitle: 'Nuwara Eliya District · Tea Estates',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ginigathena',
      subtitle: 'Nuwara Eliya District · Hill Pass',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Horton Plains',
      subtitle: 'Nuwara Eliya District · Worlds End',
      type: StartingLocationType.city,
      icon: Icons.landscape_rounded,
    ),

    // ── Western Province ──
    // Colombo District & Suburbs
    SriLankaLocationResult(
      name: 'Colombo',
      subtitle: 'Western Province · Commercial Capital',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Colombo Fort',
      subtitle: 'Colombo 01 · Main Railway Terminal',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pettah',
      subtitle: 'Colombo 11 · Central Market District',
      type: StartingLocationType.city,
      icon: Icons.storefront_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kollupitiya',
      subtitle: 'Colombo 03 · Coastal City Center',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Bambalapitiya',
      subtitle: 'Colombo 04 · Commercial Hub',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Cinnamon Gardens',
      subtitle: 'Colombo 07 · Premium Residential',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wellawatte',
      subtitle: 'Colombo 06 · Marine Drive',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Dehiwala',
      subtitle: 'Colombo District · Coastal Suburb & Zoo',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mount Lavinia',
      subtitle: 'Colombo District · Famous Beach & Hotel',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Moratuwa',
      subtitle: 'Colombo District · Coastal Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ratmalana',
      subtitle: 'Colombo District · Domestic Airport',
      type: StartingLocationType.airport,
      icon: Icons.flight_takeoff_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nugegoda',
      subtitle: 'Colombo District · Commercial Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Maharagama',
      subtitle: 'Colombo District · Textile Center',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kottawa',
      subtitle: 'Colombo District · Expressway Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Homagama',
      subtitle: 'Colombo District · Tech & University',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pannipitiya',
      subtitle: 'Colombo District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Piliyandala',
      subtitle: 'Colombo District · Bolgoda Lake',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Battaramulla',
      subtitle: 'Colombo District · Administrative Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Rajagiriya',
      subtitle: 'Colombo District · Gateway to Parliament',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Sri Jayawardenepura Kotte',
      subtitle: 'Western Province · National Capital',
      type: StartingLocationType.city,
      icon: Icons.account_balance_rounded,
    ),
    SriLankaLocationResult(
      name: 'Malabe',
      subtitle: 'Colombo District · IT & Education Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Avissawella',
      subtitle: 'Colombo District · Sabaragamuwa Gateway',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hanwella',
      subtitle: 'Colombo District · Western Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // Gampaha District & Sub-locations
    SriLankaLocationResult(
      name: 'Bandaranaike International Airport',
      subtitle: 'Katunayake · Main International Airport (CMB)',
      type: StartingLocationType.airport,
      icon: Icons.flight_takeoff_rounded,
    ),
    SriLankaLocationResult(
      name: 'Katunayake',
      subtitle: 'Gampaha District · Airport Zone',
      type: StartingLocationType.airport,
      icon: Icons.flight_takeoff_rounded,
    ),
    SriLankaLocationResult(
      name: 'Negombo',
      subtitle: 'Gampaha District · Beach Town & Lagoon',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wattala',
      subtitle: 'Gampaha District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ja-Ela',
      subtitle: 'Gampaha District · Expressway Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kandana',
      subtitle: 'Gampaha District · Western Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kelaniya',
      subtitle: 'Gampaha District · Raja Maha Viharaya',
      type: StartingLocationType.city,
      icon: Icons.temple_buddhist_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kiribathgoda',
      subtitle: 'Gampaha District · Commercial Town',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kadawatha',
      subtitle: 'Gampaha District · Central Expressway Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Gampaha',
      subtitle: 'Western Province · Botanical Garden',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Veyangoda',
      subtitle: 'Gampaha District · Main Rail Junction',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nittambuwa',
      subtitle: 'Gampaha District · Kandy Road',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mirigama',
      subtitle: 'Gampaha District · Central Expressway',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Minuwangoda',
      subtitle: 'Gampaha District · Western Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Divulapitiya',
      subtitle: 'Gampaha District · Western Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ragama',
      subtitle: 'Gampaha District · Medical & Rail Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kochchikade',
      subtitle: 'Gampaha/Negombo · Coastal Town',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // Kalutara District & Sub-locations
    SriLankaLocationResult(
      name: 'Kalutara',
      subtitle: 'Western Province · Sacred Bodhi & Beach',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Panadura',
      subtitle: 'Kalutara District · Coastal City',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wadduwa',
      subtitle: 'Kalutara District · Beach Resort Hub',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Beruwala',
      subtitle: 'Kalutara District · Historic Harbor & Beach',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Aluthgama',
      subtitle: 'Kalutara District · River & Beach Town',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Bentota',
      subtitle: 'Kalutara/Galle Border · Water Sports & Luxury Beach',
      type: StartingLocationType.city,
      icon: Icons.pool_rounded,
    ),
    SriLankaLocationResult(
      name: 'Horana',
      subtitle: 'Kalutara District · Industrial Town',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Bandaragama',
      subtitle: 'Kalutara District · Expressway Exit',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Matugama',
      subtitle: 'Kalutara District · Western Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ingiriya',
      subtitle: 'Kalutara District · Western Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // ── Southern Province ──
    // Galle District & Sub-locations
    SriLankaLocationResult(
      name: 'Galle',
      subtitle: 'Southern Province Capital · Historic Dutch Fort',
      type: StartingLocationType.city,
      icon: Icons.fort_rounded,
    ),
    SriLankaLocationResult(
      name: 'Galle Fort',
      subtitle: 'Galle · UNESCO World Heritage Fortress',
      type: StartingLocationType.city,
      icon: Icons.fort_rounded,
    ),
    SriLankaLocationResult(
      name: 'Unawatuna',
      subtitle: 'Galle District · Coral Beach & Nightlife',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hikkaduwa',
      subtitle: 'Galle District · Coral Reef Sanctuary & Surf',
      type: StartingLocationType.city,
      icon: Icons.scuba_diving_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ambalangoda',
      subtitle: 'Galle District · Traditional Mask Capital',
      type: StartingLocationType.city,
      icon: Icons.museum_rounded,
    ),
    SriLankaLocationResult(
      name: 'Koggala',
      subtitle: 'Galle District · Lake, Stilt Fishermen & Beach',
      type: StartingLocationType.city,
      icon: Icons.water_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ahangama',
      subtitle: 'Galle District · Surf Hub & Cafes',
      type: StartingLocationType.city,
      icon: Icons.surfing_rounded,
    ),
    SriLankaLocationResult(
      name: 'Midigama',
      subtitle: 'Galle District · Renowned Surf Breaks',
      type: StartingLocationType.city,
      icon: Icons.surfing_rounded,
    ),
    SriLankaLocationResult(
      name: 'Habaraduwa',
      subtitle: 'Galle District · Turtle Hatcheries & Beach',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Thalpe',
      subtitle: 'Galle District · Natural Rock Pools',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Elpitiya',
      subtitle: 'Galle District · Southern Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Baddegama',
      subtitle: 'Galle District · Southern Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Balapitiya',
      subtitle: 'Galle District · Madu Ganga River Safari',
      type: StartingLocationType.city,
      icon: Icons.sailing_rounded,
    ),

    // Matara District & Sub-locations
    SriLankaLocationResult(
      name: 'Matara',
      subtitle: 'Southern Province · Commercial Hub & Fort',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mirissa',
      subtitle: 'Matara District · Whale Watching & Coconut Tree Hill',
      type: StartingLocationType.city,
      icon: Icons.waves_rounded,
    ),
    SriLankaLocationResult(
      name: 'Weligama',
      subtitle: 'Matara District · Surf Bay & Stilt Fishing',
      type: StartingLocationType.city,
      icon: Icons.surfing_rounded,
    ),
    SriLankaLocationResult(
      name: 'Dikwella',
      subtitle: 'Matara District · Wewurukannala & Beach',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hiriketiya',
      subtitle: 'Matara District · Horseshoe Surf Bay',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Dondra',
      subtitle: 'Matara District · Southernmost Point & Lighthouse',
      type: StartingLocationType.city,
      icon: Icons.navigation_rounded,
    ),
    SriLankaLocationResult(
      name: 'Deniyaya',
      subtitle: 'Matara District · Sinharaja Rainforest Gateway',
      type: StartingLocationType.city,
      icon: Icons.forest_rounded,
    ),
    SriLankaLocationResult(
      name: 'Akuressa',
      subtitle: 'Matara District · Southern Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kamburugamuwa',
      subtitle: 'Matara District · Scenic Coastal Area',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Polhena',
      subtitle: 'Matara · Calm Reef Beach & Snorkeling',
      type: StartingLocationType.city,
      icon: Icons.scuba_diving_rounded,
    ),

    // Hambantota District & Sub-locations
    SriLankaLocationResult(
      name: 'Tangalle',
      subtitle: 'Hambantota District · Deep South Palm Beaches',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Tissamaharama',
      subtitle: 'Hambantota District · Yala Safari Base & Ancient Lake',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Yala',
      subtitle: 'Hambantota/Uva · National Park Safari Base',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kataragama',
      subtitle: 'Hambantota/Monaragala Border · Sacred Multi-Faith Shrine',
      type: StartingLocationType.city,
      icon: Icons.temple_hindu_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hambantota',
      subtitle: 'Southern Province · Port City & Salt Pans',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mattala Rajapaksa International Airport',
      subtitle: 'Hambantota · Southern Airport (HRI)',
      type: StartingLocationType.airport,
      icon: Icons.flight_takeoff_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kirinda',
      subtitle: 'Hambantota District · Historic Temple & Ocean Cliffs',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Beliatta',
      subtitle: 'Hambantota District · Southern Rail Terminal',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ranna',
      subtitle: 'Hambantota District · Kahandamodara Beach',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ambalantota',
      subtitle: 'Hambantota District · Southern Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // ── Uva Province ──
    // Badulla District & Sub-locations
    SriLankaLocationResult(
      name: 'Ella',
      subtitle: 'Badulla District · Nine Arch Bridge & Hiking',
      type: StartingLocationType.city,
      icon: Icons.terrain_rounded,
    ),
    SriLankaLocationResult(
      name: 'Badulla',
      subtitle: 'Uva Province Capital · Dunhinda Falls & Rail End',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Bandarawela',
      subtitle: 'Badulla District · Hill Health Resort',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Haputale',
      subtitle: 'Badulla District · Liptons Seat & Cloud Forests',
      type: StartingLocationType.city,
      icon: Icons.terrain_rounded,
    ),
    SriLankaLocationResult(
      name: 'Diyatalawa',
      subtitle: 'Badulla District · Army Cantonment & Pines',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mahiyanganaya',
      subtitle: 'Badulla District · Ancient Stupa & Vedda Heritage',
      type: StartingLocationType.city,
      icon: Icons.temple_buddhist_rounded,
    ),
    SriLankaLocationResult(
      name: 'Welimada',
      subtitle: 'Badulla District · Mountain Agriculture',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ohiya',
      subtitle: 'Badulla District · Horton Plains Station',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Passara',
      subtitle: 'Badulla District · Namunukula Foothills',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hali-Ela',
      subtitle: 'Badulla District · Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Koslanda',
      subtitle: 'Badulla District · Diyaluma Waterfall',
      type: StartingLocationType.city,
      icon: Icons.water_drop_rounded,
    ),

    // Monaragala District & Sub-locations
    SriLankaLocationResult(
      name: 'Monaragala',
      subtitle: 'Uva Province · Rubber & Agriculture',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wellawaya',
      subtitle: 'Monaragala District · Buduruwagala Gateway',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Buttala',
      subtitle: 'Monaragala District · Yala Edge',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Bibile',
      subtitle: 'Monaragala District · Indigenous Medicine',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // ── Sabaragamuwa Province ──
    // Ratnapura District & Sub-locations
    SriLankaLocationResult(
      name: 'Ratnapura',
      subtitle: 'Sabaragamuwa Province Capital · City of Gems',
      type: StartingLocationType.city,
      icon: Icons.diamond_rounded,
    ),
    SriLankaLocationResult(
      name: 'Balangoda',
      subtitle: 'Ratnapura District · Prehistoric Man Heritage',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Embilipitiya',
      subtitle: 'Ratnapura District · Udawalawe Safari Gateway',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Udawalawe',
      subtitle: 'Ratnapura District · Elephant National Park',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kuruwita',
      subtitle: 'Ratnapura District · Bopath Ella & Sri Pada Route',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pelmadulla',
      subtitle: 'Ratnapura District · Sabaragamuwa',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Rakwana',
      subtitle: 'Ratnapura District · Sinharaja Foothills',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kalawana',
      subtitle: 'Ratnapura District · Sinharaja Rainforest Route',
      type: StartingLocationType.city,
      icon: Icons.forest_rounded,
    ),
    SriLankaLocationResult(
      name: 'Eheliyagoda',
      subtitle: 'Ratnapura District · Sabaragamuwa',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // Kegalle District & Sub-locations
    SriLankaLocationResult(
      name: 'Kegalle',
      subtitle: 'Sabaragamuwa Province · Agriculture & Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kitulgala',
      subtitle: 'Kegalle District · White Water Rafting Capital',
      type: StartingLocationType.city,
      icon: Icons.kayaking_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pinnawala',
      subtitle: 'Kegalle District · Elephant Orphanage',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mawanella',
      subtitle: 'Kegalle District · Alagalla & Saradiel Village',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Warakapola',
      subtitle: 'Kegalle District · Kandy-Colombo Highway',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Rambukkana',
      subtitle: 'Kegalle District · Pinnawala Station',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Deraniyagala',
      subtitle: 'Kegalle District · Waterfalls',
      type: StartingLocationType.city,
      icon: Icons.water_drop_rounded,
    ),

    // ── North Central Province ──
    // Anuradhapura District & Sub-locations
    SriLankaLocationResult(
      name: 'Anuradhapura',
      subtitle: 'North Central Province Capital · Ancient UNESCO Capital',
      type: StartingLocationType.city,
      icon: Icons.account_balance_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mihintale',
      subtitle: 'Anuradhapura District · Cradle of Buddhism',
      type: StartingLocationType.city,
      icon: Icons.temple_buddhist_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kekirawa',
      subtitle: 'Anuradhapura District · Awukana Buddha Statue',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Medawachchiya',
      subtitle: 'Anuradhapura District · Northern Rail Junction',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Eppawala',
      subtitle: 'Anuradhapura District · North Central',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Tambuttegama',
      subtitle: 'Anuradhapura District · North Central',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nochchiyagama',
      subtitle: 'Anuradhapura District · Wilpattu East Base',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wilpattu',
      subtitle: 'Anuradhapura/Puttalam · Largest National Park',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),

    // Polonnaruwa District & Sub-locations
    SriLankaLocationResult(
      name: 'Polonnaruwa',
      subtitle: 'North Central Province · Medieval Royal City',
      type: StartingLocationType.city,
      icon: Icons.account_balance_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kaduruwela',
      subtitle: 'Polonnaruwa District · Commercial Town & Station',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Minneriya',
      subtitle: 'Polonnaruwa District · Elephant Gathering Safari',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Giritale',
      subtitle: 'Polonnaruwa District · Scenic Reservoir & Hotels',
      type: StartingLocationType.city,
      icon: Icons.water_rounded,
    ),
    SriLankaLocationResult(
      name: 'Hingurakgoda',
      subtitle: 'Polonnaruwa District · Domestic Airfield',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Medirigiriya',
      subtitle: 'Polonnaruwa District · Ancient Vatadage',
      type: StartingLocationType.city,
      icon: Icons.museum_rounded,
    ),

    // ── North Western (Wayamba) Province ──
    // Kurunegala District & Sub-locations
    SriLankaLocationResult(
      name: 'Kurunegala',
      subtitle: 'North Western Province Capital · Royal Rock City',
      type: StartingLocationType.city,
      icon: Icons.landscape_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kuliyapitiya',
      subtitle: 'Kurunegala District · Wayamba University',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Narammala',
      subtitle: 'Kurunegala District · Coconut Triangle',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Polgahawela',
      subtitle: 'Kurunegala District · Major Railway Junction',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Alawwa',
      subtitle: 'Kurunegala District · Maha Oya River',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wariyapola',
      subtitle: 'Kurunegala District · Wayamba',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pannala',
      subtitle: 'Kurunegala District · Industrial Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Maho',
      subtitle: 'Kurunegala District · Yapahuwa Kingdom Base',
      type: StartingLocationType.city,
      icon: Icons.fort_rounded,
    ),
    SriLankaLocationResult(
      name: 'Yapahuwa',
      subtitle: 'Kurunegala District · Ancient Rock Citadel',
      type: StartingLocationType.city,
      icon: Icons.fort_rounded,
    ),
    SriLankaLocationResult(
      name: 'Ibbagamuwa',
      subtitle: 'Kurunegala District · Wayamba',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // Puttalam District & Sub-locations
    SriLankaLocationResult(
      name: 'Puttalam',
      subtitle: 'North Western Province · Lagoon & Salt Works',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kalpitiya',
      subtitle: 'Puttalam District · Kite Surfing & Dolphin Safari',
      type: StartingLocationType.city,
      icon: Icons.kitesurfing_rounded,
    ),
    SriLankaLocationResult(
      name: 'Chilaw',
      subtitle: 'Puttalam District · Munneswaram Kovil & Coast',
      type: StartingLocationType.city,
      icon: Icons.temple_hindu_rounded,
    ),
    SriLankaLocationResult(
      name: 'Marawila',
      subtitle: 'Puttalam District · Beach Resorts',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Wennappuwa',
      subtitle: 'Puttalam District · Little Italy Suburb',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Anamaduwa',
      subtitle: 'Puttalam District · Wayamba',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nattandiya',
      subtitle: 'Puttalam District · Coconut Lands',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Dankotuwa',
      subtitle: 'Puttalam District · Porcelain Center',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // ── Northern Province ──
    // Jaffna District & Sub-locations
    SriLankaLocationResult(
      name: 'Jaffna',
      subtitle: 'Northern Province Capital · Cultural Center & Fort',
      type: StartingLocationType.city,
      icon: Icons.fort_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nallur',
      subtitle: 'Jaffna · Kandaswamy Kovil',
      type: StartingLocationType.city,
      icon: Icons.temple_hindu_rounded,
    ),
    SriLankaLocationResult(
      name: 'Point Pedro',
      subtitle: 'Jaffna District · Northernmost Point of Sri Lanka',
      type: StartingLocationType.city,
      icon: Icons.navigation_rounded,
    ),
    SriLankaLocationResult(
      name: 'Chavakachcheri',
      subtitle: 'Jaffna District · Thenmarachchi Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Valvettithurai',
      subtitle: 'Jaffna District · VVT Coast',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Karainagar',
      subtitle: 'Jaffna District · Casuarina Beach',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kayts',
      subtitle: 'Jaffna District · Island Suburb',
      type: StartingLocationType.city,
      icon: Icons.sailing_rounded,
    ),
    SriLankaLocationResult(
      name: 'Chunnakam',
      subtitle: 'Jaffna District · Valikamam Commercial Hub',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Jaffna International Airport',
      subtitle: 'Palaly · Northern Airport (JAF)',
      type: StartingLocationType.airport,
      icon: Icons.flight_takeoff_rounded,
    ),

    // Kilinochchi, Mullaitivu, Mannar, Vavuniya
    SriLankaLocationResult(
      name: 'Kilinochchi',
      subtitle: 'Northern Province · A9 Highway Town',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mullaitivu',
      subtitle: 'Northern Province · East Coast & Lagoon',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mannar',
      subtitle: 'Northern Province · Baobab Trees, Fort & Adams Bridge',
      type: StartingLocationType.city,
      icon: Icons.fort_rounded,
    ),
    SriLankaLocationResult(
      name: 'Talaimannar',
      subtitle: 'Mannar District · Pier & Historic Ferry Station',
      type: StartingLocationType.city,
      icon: Icons.anchor_rounded,
    ),
    SriLankaLocationResult(
      name: 'Vavuniya',
      subtitle: 'Northern Province · Northern Gateway City',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // ── Eastern Province ──
    // Trincomalee District & Sub-locations
    SriLankaLocationResult(
      name: 'Trincomalee',
      subtitle:
          'Eastern Province Capital · Natural Deep Harbor & Fort Frederick',
      type: StartingLocationType.city,
      icon: Icons.anchor_rounded,
    ),
    SriLankaLocationResult(
      name: 'Nilaveli',
      subtitle: 'Trincomalee District · Pigeon Island Snorkeling & Beach',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Uppuveli',
      subtitle: 'Trincomalee District · Beach Cafes & Water Sports',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kinniya',
      subtitle: 'Trincomalee District · Hot Springs & Longest Bridge',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Mutur',
      subtitle: 'Trincomalee District · Koddiyar Bay',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kantale',
      subtitle: 'Trincomalee District · Ancient Great Reservoir',
      type: StartingLocationType.city,
      icon: Icons.water_rounded,
    ),

    // Batticaloa District & Sub-locations
    SriLankaLocationResult(
      name: 'Batticaloa',
      subtitle: 'Eastern Province · Singing Fish Lagoon & Dutch Fort',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pasikudah',
      subtitle: 'Batticaloa District · Shallow Bay & Luxury Resorts',
      type: StartingLocationType.city,
      icon: Icons.pool_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kalkudah',
      subtitle: 'Batticaloa District · Natural Coastline',
      type: StartingLocationType.city,
      icon: Icons.beach_access_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kattankudy',
      subtitle: 'Batticaloa District · Heritage Mosque & Markets',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Valachchenai',
      subtitle: 'Batticaloa District · Fisheries & Rail Town',
      type: StartingLocationType.city,
      icon: Icons.train_rounded,
    ),
    SriLankaLocationResult(
      name: 'Eravur',
      subtitle: 'Batticaloa District · Eastern Province',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),

    // Ampara District & Sub-locations
    SriLankaLocationResult(
      name: 'Ampara',
      subtitle: 'Eastern Province · Valley Town & Senanayake Samudraya',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Arugam Bay',
      subtitle: 'Ampara District · World Renowned Surfing Mecca',
      type: StartingLocationType.city,
      icon: Icons.surfing_rounded,
    ),
    SriLankaLocationResult(
      name: 'Pottuvil',
      subtitle: 'Ampara District · Lagoon Mangrove Safari & Point',
      type: StartingLocationType.city,
      icon: Icons.sailing_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kalmunai',
      subtitle: 'Ampara District · Largest Commercial Hub in East',
      type: StartingLocationType.city,
      icon: Icons.location_city_rounded,
    ),
    SriLankaLocationResult(
      name: 'Akkaraipattu',
      subtitle: 'Ampara District · Eastern Coast',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Sammanthurai',
      subtitle: 'Ampara District · Agriculture Center',
      type: StartingLocationType.city,
      icon: Icons.location_on_rounded,
    ),
    SriLankaLocationResult(
      name: 'Oluvil',
      subtitle: 'Ampara District · South Eastern University & Harbor',
      type: StartingLocationType.city,
      icon: Icons.school_rounded,
    ),
    SriLankaLocationResult(
      name: 'Kumana',
      subtitle: 'Ampara District · National Park Bird Sanctuary',
      type: StartingLocationType.city,
      icon: Icons.pets_rounded,
    ),
    SriLankaLocationResult(
      name: 'Panama',
      subtitle: 'Ampara District · Surf Point & Lagoon',
      type: StartingLocationType.city,
      icon: Icons.surfing_rounded,
    ),
  ];

  /// Instant local search across the 250+ catalog items.
  static List<SriLankaLocationResult> searchLocal(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    // Prefix matches come first, then substring matches
    final prefixMatches = <SriLankaLocationResult>[];
    final otherMatches = <SriLankaLocationResult>[];

    for (final loc in catalog) {
      final nameLower = loc.name.toLowerCase();
      final subLower = loc.subtitle.toLowerCase();

      if (nameLower.startsWith(q)) {
        prefixMatches.add(loc);
      } else if (nameLower.contains(q) || subLower.contains(q)) {
        otherMatches.add(loc);
      }
    }

    return [...prefixMatches, ...otherMatches].take(8).toList();
  }

  /// Live OpenStreetMap Nominatim place search restricted to Sri Lanka (countrycodes=lk).
  /// Discovers any village, street, suburb, hotel, or sub-location that may not be in local catalog.
  static Future<List<SriLankaLocationResult>> searchLive(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];

    try {
      final uri = Uri.parse(
        '${ApiConfig.nominatimApiUrl}?q=${Uri.encodeComponent(q)}&countrycodes=lk&format=json&addressdetails=1&limit=6',
      );

      final response = await _client
          .get(
            uri,
            headers: {
              'User-Agent': 'HelaTravelPlanner/1.0 (contact@hela.travel)',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode != 200) return const [];

      final data = jsonDecode(response.body) as List<dynamic>;
      final results = <SriLankaLocationResult>[];

      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final name = (item['name'] as String?)?.trim();
        final displayName = (item['display_name'] as String?) ?? '';
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lon = double.tryParse(item['lon']?.toString() ?? '');
        final typeStr = (item['type'] as String?) ?? '';
        final classStr = (item['class'] as String?) ?? '';

        final mainName = (name != null && name.isNotEmpty)
            ? name
            : displayName.split(',').first.trim();

        // Build a readable subtitle from address details
        final address = item['address'] as Map<String, dynamic>?;
        String subtitle = '';
        if (address != null) {
          final parts = <String>[];
          if (address['suburb'] != null && address['suburb'] != mainName) {
            parts.add(address['suburb'].toString());
          }
          if (address['city'] != null && address['city'] != mainName) {
            parts.add(address['city'].toString());
          } else if (address['town'] != null && address['town'] != mainName) {
            parts.add(address['town'].toString());
          } else if (address['village'] != null &&
              address['village'] != mainName) {
            parts.add(address['village'].toString());
          }
          if (address['state_district'] != null) {
            parts.add(address['state_district'].toString());
          }
          if (address['state'] != null) {
            parts.add(address['state'].toString());
          }
          subtitle = parts.take(2).join(' · ');
        }

        if (subtitle.isEmpty) {
          final split = displayName.split(',');
          if (split.length > 2) {
            subtitle = split.skip(1).take(2).map((s) => s.trim()).join(' · ');
          } else {
            subtitle = 'Sri Lanka';
          }
        }

        StartingLocationType locType = StartingLocationType.city;
        IconData icon = Icons.location_on_rounded;

        final isAirport =
            typeStr.contains('aerodrome') ||
            classStr.contains('aerodrome') ||
            mainName.toLowerCase().contains('airport');
        if (isAirport) {
          locType = StartingLocationType.airport;
          icon = Icons.flight_takeoff_rounded;
        } else if (typeStr == 'station' || classStr == 'railway') {
          icon = Icons.train_rounded;
        } else if (typeStr == 'beach' ||
            mainName.toLowerCase().contains('beach')) {
          icon = Icons.beach_access_rounded;
        }

        results.add(
          SriLankaLocationResult(
            name: mainName,
            subtitle: subtitle,
            type: locType,
            icon: icon,
            latitude: lat,
            longitude: lon,
          ),
        );
      }

      return results;
    } catch (_) {
      // In case of timeout or offline, fail gracefully
      return const [];
    }
  }

  /// Automatically deduces the StartingLocationType based on location string.
  static StartingLocationType detectType(String locationName) {
    final lower = locationName.toLowerCase();
    if (lower.contains('airport') ||
        lower.contains('bia') ||
        lower.contains('bandaranaike') ||
        lower.contains('mattala') ||
        lower.contains('cmb') ||
        lower.contains('hri') ||
        lower.contains('aerodrome')) {
      return StartingLocationType.airport;
    }

    final match = catalog.any(
      (loc) =>
          loc.name.toLowerCase() == lower ||
          loc.subtitle.toLowerCase().contains(lower),
    );
    if (match) {
      return StartingLocationType.city;
    }

    return StartingLocationType.custom;
  }
}
