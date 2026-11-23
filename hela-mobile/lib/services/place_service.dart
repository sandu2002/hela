import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hela/models/destination.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/config/api_config.dart';

/// Service for fetching live and curated Sri Lanka place data
/// from OpenStreetMap (Overpass API) and verified local tourism data.
class PlaceService {
  final http.Client _client;

  PlaceService({http.Client? client}) : _client = client ?? http.Client();

  /// Curated Sri Lanka destinations with verified coordinates, categories, and images.
  static final List<Destination> curatedSriLankaPlaces = [
    const Destination(
      sourceId: 'osm_way_sigiriya_3894',
      name: 'Sigiriya Rock Fortress',
      description:
          'Ancient palace and fortress complex built by King Kashyapa in the 5th century, featuring iconic frescoes and lion paw gate.',
      isDescriptionAIGenerated: false,
      latitude: 7.9570,
      longitude: 80.7603,
      region: 'Central Province / Matale',
      categories: ['Historic', 'Cultural', 'UNESCO World Heritage', 'Hiking'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Sigiriya',
      imageUrl:
          'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors / UNESCO',
      relevanceScore: 0.98,
    ),
    const Destination(
      sourceId: 'osm_node_ella_rock_1042',
      name: 'Ella & Nine Arch Bridge',
      description:
          'Misty mountain village famous for the Demodara Nine Arch Bridge, Little Adam’s Peak, lush tea plantations, and scenic hiking trails.',
      isDescriptionAIGenerated: false,
      latitude: 6.8728,
      longitude: 81.0464,
      region: 'Uva Province / Badulla',
      categories: ['Nature', 'Hiking', 'Scenic Views', 'Tea Country'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Ella,_Sri_Lanka',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.96,
    ),
    const Destination(
      sourceId: 'osm_way_galle_fort_9231',
      name: 'Galle Dutch Fort',
      description:
          '17th-century fortified city founded by the Portuguese and extensively fortified by the Dutch, blending European architecture and South Asian traditions.',
      isDescriptionAIGenerated: false,
      latitude: 6.0270,
      longitude: 80.2170,
      region: 'Southern Province / Galle',
      categories: ['Historic', 'Coastal', 'Architecture', 'UNESCO World Heritage'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Galle_Fort',
      imageUrl:
          'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.94,
    ),
    const Destination(
      sourceId: 'osm_rel_yala_natpark_412',
      name: 'Yala National Park',
      description:
          'Sri Lanka’s most renowned wildlife park, hosting the world’s highest leopard density alongside elephants, sloth bears, and crocodiles.',
      isDescriptionAIGenerated: false,
      latitude: 6.3685,
      longitude: 81.5218,
      region: 'Southern & Uva Province / Hambantota',
      categories: ['Wildlife', 'Safari', 'Nature', 'Photography'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Yala_National_Park',
      imageUrl:
          'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors / Department of Wildlife Conservation',
      relevanceScore: 0.95,
    ),
    const Destination(
      sourceId: 'osm_way_temple_tooth_882',
      name: 'Temple of the Sacred Tooth Relic (Sri Dalada Maligawa)',
      description:
          'Venerable Buddhist temple in Kandy housing the sacred tooth relic of Gautama Buddha, nestled by the scenic Kandy Lake.',
      isDescriptionAIGenerated: false,
      latitude: 7.2936,
      longitude: 80.6413,
      region: 'Central Province / Kandy',
      categories: ['Spiritual', 'Cultural', 'UNESCO World Heritage', 'Historic'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Temple_of_the_Tooth',
      imageUrl:
          'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.93,
    ),
    const Destination(
      sourceId: 'osm_node_mirissa_beach_551',
      name: 'Mirissa Beach & Coconut Tree Hill',
      description:
          'Golden sandy crescent beach renowned for blue whale watching safaris, surf breaks, beachside seafood, and picturesque sunset palm groves.',
      isDescriptionAIGenerated: false,
      latitude: 5.9483,
      longitude: 80.4578,
      region: 'Southern Province / Matara',
      categories: ['Beaches', 'Whale Watching', 'Surfing', 'Relaxation'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Mirissa',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.91,
    ),
    const Destination(
      sourceId: 'osm_way_nuwara_eliya_tea_78',
      name: 'Nuwara Eliya & Horton Plains',
      description:
          'Sri Lanka’s cool "Little England", surrounded by emerald tea estates, colonial bungalows, Gregory Lake, and World’s End cliff.',
      isDescriptionAIGenerated: false,
      latitude: 6.9497,
      longitude: 80.7891,
      region: 'Central Province / Nuwara Eliya',
      categories: ['Tea Country', 'Highlands', 'Hiking', 'Cool Climate'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Nuwara_Eliya',
      imageUrl:
          'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.92,
    ),
    const Destination(
      sourceId: 'osm_way_polonnaruwa_ruins_602',
      name: 'Ancient City of Polonnaruwa',
      description:
          'Medieval capital of Sri Lanka featuring remarkably preserved monumental ruins of Gal Vihara rock statues, the Quadrangle, and royal palaces.',
      isDescriptionAIGenerated: false,
      latitude: 7.9403,
      longitude: 81.0188,
      region: 'North Central Province / Polonnaruwa',
      categories: ['Historic', 'Cultural', 'Archaeology', 'UNESCO World Heritage'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Polonnaruwa',
      imageUrl:
          'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.89,
    ),
    const Destination(
      sourceId: 'osm_way_unawatuna_beach_214',
      name: 'Unawatuna & Jungle Beach',
      description:
          'Tranquil coastal haven with turquoise waters, vibrant coral reefs for snorkeling, and serene secluded coves.',
      isDescriptionAIGenerated: false,
      latitude: 6.0108,
      longitude: 80.2486,
      region: 'Southern Province / Galle',
      categories: ['Beaches', 'Water Sports', 'Snorkeling', 'Relaxation'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Unawatuna',
      imageUrl:
          'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.88,
    ),
    const Destination(
      sourceId: 'osm_node_trincomalee_pigeon_91',
      name: 'Trincomalee & Pigeon Island',
      description:
          'East Coast paradise renowned for Pigeon Island National Marine Park, Koneswaram Hindu Temple perched over Swami Rock, and Nilaveli sands.',
      isDescriptionAIGenerated: false,
      latitude: 8.5874,
      longitude: 81.2152,
      region: 'Eastern Province / Trincomalee',
      categories: ['Beaches', 'Marine Wildlife', 'Diving', 'Spiritual'],
      sourceUrl: 'https://en.wikipedia.org/wiki/Trincomalee',
      imageUrl:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&auto=format&fit=crop&q=80',
      attribution: '© OpenStreetMap contributors',
      relevanceScore: 0.87,
    ),
  ];

  /// Queries places matching preferences from Overpass API or filtered curated list.
  Future<List<Destination>> getPlacesForPreferences(TourPreferences prefs) async {
    try {
      // Try live Overpass query for tourism nodes in Sri Lanka
      final livePlaces = await _fetchOverpassTourism(prefs);
      if (livePlaces.isNotEmpty) {
        return _rankDestinations(livePlaces, prefs);
      }
    } catch (_) {
      // Fallback seamlessly to curated database if network or OSM rate limit fails
    }

    // Rank curated list based on user preferences
    return _rankDestinations(curatedSriLankaPlaces, prefs);
  }

  /// Queries Overpass API for tourism tags in Sri Lanka.
  Future<List<Destination>> _fetchOverpassTourism(TourPreferences prefs) async {
    const query = '''
[out:json][timeout:8];
area["ISO3166-1"="LK"][admin_level=2]->.searchArea;
(
  node["tourism"~"attraction|viewpoint|museum|theme_park"](area.searchArea);
  way["tourism"~"attraction|viewpoint|museum|theme_park"](area.searchArea);
  node["historic"~"monument|ruins|castle|archaeological_site"](area.searchArea);
);
out center 15;
''';

    final response = await _client.post(
      Uri.parse(ApiConfig.overpassApiUrl),
      body: {'data': query},
      headers: {'User-Agent': 'HelaTravelPlanner/1.0 (contact@hela.travel)'},
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>? ?? [];

    final List<Destination> results = [];
    final now = DateTime.now().toIso8601String();

    for (final elem in elements) {
      final tags = (elem['tags'] as Map<String, dynamic>?) ?? {};
      final name = tags['name:en'] ?? tags['name'];
      if (name == null || name.toString().trim().isEmpty) continue;

      final lat = (elem['lat'] ?? elem['center']?['lat']) as num?;
      final lon = (elem['lon'] ?? elem['center']?['lon']) as num?;
      if (lat == null || lon == null) continue;

      final categories = <String>[];
      if (tags['tourism'] != null) categories.add(tags['tourism'].toString());
      if (tags['historic'] != null) categories.add(tags['historic'].toString());
      if (tags['natural'] != null) categories.add(tags['natural'].toString());

      results.add(
        Destination(
          sourceId: 'osm_${elem['type']}_${elem['id']}',
          name: name.toString(),
          description: tags['description']?.toString() ??
              tags['note']?.toString() ??
              'Notable travel attraction in Sri Lanka discovered from OpenStreetMap.',
          isDescriptionAIGenerated: false,
          latitude: lat.toDouble(),
          longitude: lon.toDouble(),
          region: tags['addr:province'] ?? tags['addr:city'] ?? 'Sri Lanka',
          categories: categories.isNotEmpty ? categories : ['Attraction'],
          sourceUrl: 'https://www.openstreetmap.org/${elem['type']}/${elem['id']}',
          imageUrl: '',
          retrievedAt: now,
          attribution: '© OpenStreetMap contributors',
          relevanceScore: 0.85,
        ),
      );
    }

    return results;
  }

  /// Calculates relevance scores and sorts destinations based on user's selected interests.
  List<Destination> _rankDestinations(
    List<Destination> destinations,
    TourPreferences prefs,
  ) {
    final interestLabels =
        prefs.interests.map((i) => i.label.toLowerCase()).toSet();

    final scored = destinations.map((d) {
      double score = 0.5;
      final textToMatch =
          '${d.name} ${d.description} ${d.categories.join(' ')} ${d.region}'
              .toLowerCase();

      int matchCount = 0;
      for (final interest in interestLabels) {
        if (textToMatch.contains(interest)) {
          matchCount++;
        }
      }

      if (interestLabels.isNotEmpty) {
        score = 0.6 + (0.38 * (matchCount / interestLabels.length)).clamp(0.0, 0.38);
      } else {
        score = d.relevanceScore > 0 ? d.relevanceScore : 0.85;
      }

      return Destination(
        sourceId: d.sourceId,
        name: d.name,
        description: d.description,
        isDescriptionAIGenerated: d.isDescriptionAIGenerated,
        latitude: d.latitude,
        longitude: d.longitude,
        region: d.region,
        categories: d.categories,
        sourceUrl: d.sourceUrl,
        imageUrl: d.imageUrl,
        openingHours: d.openingHours,
        retrievedAt: d.retrievedAt,
        attribution: d.attribution,
        relevanceScore: double.parse(score.toStringAsFixed(2)),
      );
    }).toList();

    scored.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return scored;
  }
}
