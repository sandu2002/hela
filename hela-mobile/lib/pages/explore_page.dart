import 'package:flutter/material.dart';
import 'package:hela/data/place_details_catalog.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/models/haven_item.dart';
import 'package:hela/pages/cultural_guide/cultural_guide_page.dart';
import 'package:hela/pages/place_details_page.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/hela_bottom_nav_bar.dart';
import 'package:hela/widgets/hela_drawer.dart';

/// Data models for the Explore Sri Lanka Screen
class ExploreDestination {
  final String id;
  final String name;
  final String subtitle;
  final String region;
  final String rating;
  final String badge;
  final String priceTag;
  final String footerTag;
  final String imageUrl;
  final String category;

  const ExploreDestination({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.region,
    required this.rating,
    required this.badge,
    required this.priceTag,
    required this.footerTag,
    required this.imageUrl,
    required this.category,
  });
}

class HiddenGemItem {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String distance;
  final String rating;
  final String imageUrl;
  final String category;

  const HiddenGemItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    required this.category,
  });
}

class CulturalExperienceItem {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String price;
  final String tag;
  final String verifiedNote;
  final String ctaText;
  final String imageUrl;
  final String category;

  const CulturalExperienceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.price,
    required this.tag,
    required this.verifiedNote,
    required this.ctaText,
    required this.imageUrl,
    required this.category,
  });
}

class NearbyPlaceItem {
  final String title;
  final String subtitle;
  final String distance;
  final String status;
  final String imageUrl;
  final String category;

  const NearbyPlaceItem({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.status,
    required this.imageUrl,
    this.category = 'Culture',
  });
}

/// HELA - Explore Sri Lanka Page
/// Conforms to Google Stitch Screen: HELA - Explore Sri Lanka (`12d81a19983f4073aefbbe983c1507d8`)
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0; // 0: All, 1: Nature, 2: Beaches, 3: Culture, 4: Wildlife, 5: Adventure, 6: Food
  final Set<String> _savedIds = <String>{};

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'All', 'icon': null},
    {'label': 'Nature', 'icon': Icons.forest_rounded},
    {'label': 'Beaches', 'icon': Icons.waves_rounded},
    {'label': 'Culture', 'icon': Icons.temple_buddhist_rounded},
    {'label': 'Wildlife', 'icon': Icons.pets_rounded},
    {'label': 'Adventure', 'icon': Icons.hiking_rounded},
  ];

  final List<ExploreDestination> _popularDestinations = const [
    // ═══════════════════════════════════════════════════════════
    // BEACHES OF SRI LANKA
    // ═══════════════════════════════════════════════════════════
    ExploreDestination(
      id: 'mirissa',
      name: 'Mirissa Beach',
      subtitle: 'Coconut Tree Hill, Secret Beach & Whales',
      region: 'Matara • South Coast',
      rating: '4.9 • Marine',
      badge: 'South Coast',
      priceTag: 'Free Entry',
      footerTag: 'Whale Watch & Surf',
      imageUrl: SriLankaImages.mirissa,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'unawatuna',
      name: 'Unawatuna Beach',
      subtitle: 'Golden Sands, Coral Reef & Jungle Beach',
      region: 'Galle • South Coast',
      rating: '4.8 • Popular',
      badge: 'Coral Bay',
      priceTag: 'Free Entry',
      footerTag: 'Swimming & Snorkeling',
      imageUrl: SriLankaImages.unawatuna,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'bentota',
      name: 'Bentota Beach',
      subtitle: 'Golden Spit & Premier Watersports Lagoon',
      region: 'Galle District',
      rating: '4.8 • Watersports',
      badge: 'Golden Mile',
      priceTag: 'Free Entry',
      footerTag: 'Jet Ski & Windsurf',
      imageUrl: SriLankaImages.bentota,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'arugam_bay',
      name: 'Arugam Bay',
      subtitle: 'World-Class Point Breaks & Main Point',
      region: 'Ampara • East Coast',
      rating: '4.9 • Surf Capital',
      badge: 'World Surf Hub',
      priceTag: 'Free Entry',
      footerTag: 'Right-Hand Point Breaks',
      imageUrl: SriLankaImages.arugamBay,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'nilaveli',
      name: 'Nilaveli Beach',
      subtitle: 'Crystal Shallow Waters & Pigeon Island Hub',
      region: 'Trincomalee • East Coast',
      rating: '4.9 • Pristine',
      badge: 'White Sands',
      priceTag: 'Free Entry',
      footerTag: 'Snorkel & Marine Park',
      imageUrl: SriLankaImages.nilaveli,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'tangalle_silent',
      name: 'Tangalle Silent Beach',
      subtitle: 'Secluded Turquoise Cove & Wild Palm Groves',
      region: 'Hambantota • Deep South',
      rating: '4.9 • Secluded',
      badge: 'Untouched Haven',
      priceTag: 'Free Entry',
      footerTag: 'Azure Surf & Sunset',
      imageUrl: SriLankaImages.tangalle,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'hikkaduwa',
      name: 'Hikkaduwa Beach',
      subtitle: 'Coral Sanctuary, Sea Turtles & Vibrant Shore',
      region: 'Galle • South-West',
      rating: '4.7 • Marine',
      badge: 'Turtle Bay',
      priceTag: 'Free Entry',
      footerTag: 'Reef Walk & Scuba',
      imageUrl: SriLankaImages.hikkaduwa,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'weligama',
      name: 'Weligama Bay',
      subtitle: 'Gentle Surf Breaks & Stilt Fishermen',
      region: 'Matara • South Coast',
      rating: '4.8 • Surf School',
      badge: 'Beginner Surf',
      priceTag: 'Free Entry',
      footerTag: 'Surf Lessons & Cafes',
      imageUrl: SriLankaImages.weligama,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'hiriketiya',
      name: 'Hiriketiya Horseshoe Bay',
      subtitle: 'Horseshoe Cove, Point Break & Boho Cafes',
      region: 'Dikwella • South Coast',
      rating: '4.9 • Bohemian',
      badge: 'Secret Cove',
      priceTag: 'Free Entry',
      footerTag: 'Surf & Yoga Hub',
      imageUrl: SriLankaImages.hiriketiya,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'pasikudah',
      name: 'Pasikudah Bay',
      subtitle: 'Miles of Flat Calm Shallow Turquoise Lagoon',
      region: 'Batticaloa • East Coast',
      rating: '4.8 • Calm Seas',
      badge: 'Shallow Reef',
      priceTag: 'Free Entry',
      footerTag: 'Walk 150m into Sea',
      imageUrl: SriLankaImages.pasikudah,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'kalpitiya',
      name: 'Kalpitiya Beach & Lagoon',
      subtitle: 'Dolphin Watching & Premier Kitesurfing Spot',
      region: 'Puttalam • North-West',
      rating: '4.8 • Kitesurf',
      badge: 'Dolphin Coast',
      priceTag: 'Free Entry',
      footerTag: 'Dolphin Pods & Winds',
      imageUrl: SriLankaImages.kalpitiya,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'uppuveli',
      name: 'Uppuveli Beach',
      subtitle: 'Peaceful Golden Shore & Coral Reefs',
      region: 'Trincomalee • East Coast',
      rating: '4.7 • Coastal',
      badge: 'East Coast',
      priceTag: 'Free Entry',
      footerTag: 'Seafood & Sunrises',
      imageUrl: SriLankaImages.uppuveli,
      category: 'Beaches',
    ),
    ExploreDestination(
      id: 'koggala',
      name: 'Koggala Beach',
      subtitle: 'Iconic Stilt Fishermen & Coastal Lagoon',
      region: 'Galle • South Coast',
      rating: '4.7 • Heritage',
      badge: 'Stilt Fishermen',
      priceTag: 'Free Entry',
      footerTag: 'Stilt Fishing & Sunset',
      imageUrl: SriLankaImages.koggala,
      category: 'Beaches',
    ),

    // ═══════════════════════════════════════════════════════════
    // NATURE & HIGHLANDS
    // ═══════════════════════════════════════════════════════════
    ExploreDestination(
      id: 'ella',
      name: 'Ella Highlands',
      subtitle: 'Nine Arch Bridge, Ella Rock & Cloud Forest',
      region: 'Badulla District',
      rating: '4.9 • Valleys',
      badge: 'Highlands',
      priceTag: 'Free Access',
      footerTag: 'Cloud Forest Treks',
      imageUrl: SriLankaImages.nineArchBridge,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'nuwara_eliya',
      name: 'Nuwara Eliya',
      subtitle: 'Tea Factory Estates & Gregory Lake',
      region: 'Cool Highlands',
      rating: '4.8 • Highlands',
      badge: 'Little England',
      priceTag: '16°C Fresh Climate',
      footerTag: 'Tea Trails & Gardens',
      imageUrl: SriLankaImages.nuwaraEliya,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'horton_plains',
      name: 'Horton Plains & World\'s End',

      subtitle: '880m Sheer Cliff Drop & Baker\'s Falls',

      region: 'Central Plateau',
      rating: '4.9 • Plateau',
      badge: 'UNESCO Plateau',
      priceTag: '\$25 entry',
      footerTag: '9 km Circular Trek',
      imageUrl: SriLankaImages.hortonPlains,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'adams_peak',
      name: 'Adam\'s Peak (Sri Pada)',

      subtitle: 'Sacred Mountain Summit & Sunrise Shadow',
      region: 'Sabaragamuwa Ridge',
      rating: '4.9 • Sacred',
      badge: 'Pilgrimage Peak',
      priceTag: 'Free Access',
      footerTag: '5,500 Steps Sunrise Climb',
      imageUrl: SriLankaImages.adamsPeak,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'knuckles',
      name: 'Knuckles Mountain Range',
      subtitle: '34 Mist-Shrouded Wilderness Peaks',
      region: 'Matale & Kandy',
      rating: '4.8 • Wilderness',
      badge: 'Cloud Forest',
      priceTag: 'Free / Guide',
      footerTag: 'Biodiversity Trekking',
      imageUrl: SriLankaImages.knucklesRange,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'sinharaja',
      name: 'Sinharaja Rainforest',
      subtitle: 'Primary Lowland Tropical Rainforest',
      region: 'Southern Province',
      rating: '4.9 • UNESCO',
      badge: 'Biosphere Reserve',
      priceTag: '\$10 entry',
      footerTag: 'Endemic Birds & Canopy',
      imageUrl: SriLankaImages.sinharaja,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'diyaluma',
      name: 'Diyaluma Falls',
      subtitle: 'Sri Lanka\'s 2nd Highest Waterfall & Pools',

      region: 'Koslanda • Badulla',
      rating: '4.8 • Cascades',
      badge: 'Natural Pools',
      priceTag: 'Free Access',
      footerTag: 'Cliffside Infinity Pools',
      imageUrl: SriLankaImages.diyaluma,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'ravana_falls',
      name: 'Ravana Falls',
      subtitle: 'Mythological 25m Cascading Multi-Tier Falls',
      region: 'Ella Gap',
      rating: '4.7 • Scenic',
      badge: 'Legendary Falls',
      priceTag: 'Free Access',
      footerTag: 'Roadside Waterfall Vista',
      imageUrl: SriLankaImages.ravanaFalls,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'little_adams_peak',
      name: 'Little Adam\'s Peak',

      subtitle: '360° Panoramic Ella Valley View & Tea Slopes',
      region: 'Ella Highlands',
      rating: '4.8 • Viewpoint',
      badge: 'Easy Hike',
      priceTag: 'Free Access',
      footerTag: 'Sunset Panoramic Vista',
      imageUrl: SriLankaImages.littleAdamsPeak,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'liptons_seat',
      name: 'Lipton\'s Seat',

      subtitle: 'Sir Thomas Lipton\'s Historic Lookout',

      region: 'Haputale • Uva',
      rating: '4.9 • Panoramic',
      badge: 'Tea Heritage',
      priceTag: '\$2 entry',
      footerTag: 'Lookout over 7 Provinces',
      imageUrl: SriLankaImages.liptonsSeat,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'pidurangala',
      name: 'Pidurangala Rock',
      subtitle: 'Facing Sigiriya with 360° Sunrise Vistas',
      region: 'Central Province',
      rating: '4.9 • Sunrise Peak',
      badge: '360° View',
      priceTag: '\$3 entry',
      footerTag: 'Sacred Cave & Vista',
      imageUrl: SriLankaImages.pidurangala,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'ramboda_falls',
      name: 'Ramboda Falls',
      subtitle: '109m Giant Twin Cascades in Highland Pass',
      region: 'Pussellawa Pass',
      rating: '4.7 • Waterfalls',
      badge: 'Highland Pass',
      priceTag: 'Free Access',
      footerTag: 'Emerald Gorge Vista',
      imageUrl: SriLankaImages.rambodaFalls,
      category: 'Nature',
    ),

    // ═══════════════════════════════════════════════════════════
    // CULTURE & HERITAGE
    // ═══════════════════════════════════════════════════════════
    ExploreDestination(
      id: 'sigiriya',
      name: 'Sigiriya Rock Fortress',
      subtitle: 'Ancient Sky Palace, Water Gardens & Frescoes',
      region: 'Central Province',
      rating: '5.0 • UNESCO',
      badge: '8th Wonder',
      priceTag: '\$36 entry',
      footerTag: '1,200 Steps Climb',
      imageUrl: SriLankaImages.sigiriya,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'nuwara_eliya',
      name: 'Nuwara Eliya',
      subtitle: 'Tea Factory Estates & Gregory Lake',
      region: 'Cool Highlands',
      rating: '4.8 • Highlands',
      badge: 'Little England',
      priceTag: '16°C Fresh Climate',
      footerTag: 'Tea Trails & Gardens',
      imageUrl: SriLankaImages.nuwaraEliya,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'horton_plains',
      name: "Horton Plains & World's End",
      subtitle: "880m Sheer Cliff Drop & Baker's Falls",
      region: 'Central Plateau',
      rating: '4.9 • Plateau',
      badge: 'UNESCO Plateau',
      priceTag: '\$25 entry',
      footerTag: '9 km Circular Trek',
      imageUrl: SriLankaImages.hortonPlains,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'adams_peak',
      name: "Adam's Peak (Sri Pada)",
      subtitle: 'Sacred Mountain Summit & Sunrise Shadow',
      region: 'Sabaragamuwa Ridge',
      rating: '4.9 • Sacred',
      badge: 'Pilgrimage Peak',
      priceTag: 'Free Access',
      footerTag: '5,500 Steps Sunrise Climb',
      imageUrl: SriLankaImages.adamsPeak,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'knuckles',
      name: 'Knuckles Mountain Range',
      subtitle: '34 Mist-Shrouded Wilderness Peaks',
      region: 'Matale & Kandy',
      rating: '4.8 • Wilderness',
      badge: 'Cloud Forest',
      priceTag: 'Free / Guide',
      footerTag: 'Biodiversity Trekking',
      imageUrl: SriLankaImages.knucklesRange,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'sinharaja',
      name: 'Sinharaja Rainforest',
      subtitle: 'Primary Lowland Tropical Rainforest',
      region: 'Southern Province',
      rating: '4.9 • UNESCO',
      badge: 'Biosphere Reserve',
      priceTag: '\$10 entry',
      footerTag: 'Endemic Birds & Canopy',
      imageUrl: SriLankaImages.sinharaja,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'diyaluma',
      name: 'Diyaluma Falls',
      subtitle: "Sri Lanka's 2nd Highest Waterfall & Pools",
      region: 'Koslanda • Badulla',
      rating: '4.8 • Cascades',
      badge: 'Natural Pools',
      priceTag: 'Free Access',
      footerTag: 'Cliffside Infinity Pools',
      imageUrl: SriLankaImages.diyaluma,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'ravana_falls',
      name: 'Ravana Falls',
      subtitle: 'Mythological 25m Cascading Multi-Tier Falls',
      region: 'Ella Gap',
      rating: '4.7 • Scenic',
      badge: 'Legendary Falls',
      priceTag: 'Free Access',
      footerTag: 'Roadside Waterfall Vista',
      imageUrl: SriLankaImages.ravanaFalls,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'little_adams_peak',
      name: "Little Adam's Peak",
      subtitle: '360° Panoramic Ella Valley View & Tea Slopes',
      region: 'Ella Highlands',
      rating: '4.8 • Viewpoint',
      badge: 'Easy Hike',
      priceTag: 'Free Access',
      footerTag: 'Sunset Panoramic Vista',
      imageUrl: SriLankaImages.littleAdamsPeak,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'liptons_seat',
      name: "Lipton's Seat",
      subtitle: "Sir Thomas Lipton's Historic Lookout",
      region: 'Haputale • Uva',
      rating: '4.9 • Panoramic',
      badge: 'Tea Heritage',
      priceTag: '\$2 entry',
      footerTag: 'Lookout over 7 Provinces',
      imageUrl: SriLankaImages.liptonsSeat,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'pidurangala',
      name: 'Pidurangala Rock',
      subtitle: 'Facing Sigiriya with 360° Sunrise Vistas',
      region: 'Central Province',
      rating: '4.9 • Sunrise Peak',
      badge: '360° View',
      priceTag: '\$3 entry',
      footerTag: 'Sacred Cave & Vista',
      imageUrl: SriLankaImages.pidurangala,
      category: 'Nature',
    ),
    ExploreDestination(
      id: 'ramboda_falls',
      name: 'Ramboda Falls',
      subtitle: '109m Giant Twin Cascades in Highland Pass',
      region: 'Pussellawa Pass',
      rating: '4.7 • Waterfalls',
      badge: 'Highland Pass',
      priceTag: 'Free Access',
      footerTag: 'Emerald Gorge Vista',
      imageUrl: SriLankaImages.rambodaFalls,
      category: 'Nature',
    ),

    // ═══════════════════════════════════════════════════════════
    // CULTURE & HERITAGE
    // ═══════════════════════════════════════════════════════════
    ExploreDestination(
      id: 'sigiriya',
      name: 'Sigiriya Rock Fortress',
      subtitle: 'Ancient Sky Palace, Water Gardens & Frescoes',
      region: 'Central Province',
      rating: '5.0 • UNESCO',
      badge: '8th Wonder',
      priceTag: '\$36 entry',
      footerTag: '1,200 Steps Climb',
      imageUrl: SriLankaImages.sigiriya,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'kandy',
      name: 'Kandy Temple of Tooth',
      subtitle: 'Golden-Roofed Sanctuary of the Sacred Relic',
      region: 'Central Highlands',
      rating: '4.9 • UNESCO',
      badge: 'Sacred Relic',
      priceTag: '\$6 entry',
      footerTag: 'Daily Thevava Rituals',
      imageUrl: SriLankaImages.templeOfTheTooth,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'dambulla',
      name: 'Dambulla Cave Temple',
      subtitle: '5 Monastery Caves with 153 Buddha Statues',
      region: 'Central Province',
      rating: '4.8 • UNESCO',
      badge: 'Cave Frescoes',
      priceTag: '\$7 entry',
      footerTag: '2,100-Year History',
      imageUrl: SriLankaImages.dambulla,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'galle',
      name: 'Galle Dutch Fort',
      subtitle: 'Living 17th-Century Ramparts & Lighthouse',
      region: 'Southern Coast',
      rating: '4.9 • Colonial',
      badge: 'Colonial Fort',
      priceTag: 'Open Ramparts',
      footerTag: 'Coastal History Walk',
      imageUrl: SriLankaImages.galleFort,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'anuradhapura',
      name: 'Anuradhapura Sacred City',
      subtitle: '2,500-Year Ancient Capital & Sacred Stupas',
      region: 'North Central',
      rating: '4.9 • UNESCO',
      badge: 'Ancient Kingdom',
      priceTag: '\$25 entry',
      footerTag: 'Ruwanwelisaya & Bodhi',
      imageUrl: SriLankaImages.anuradhapura,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'polonnaruwa',
      name: 'Polonnaruwa Ancient City',
      subtitle: 'Gal Vihara Granite Sculptures & Royal Citadel',
      region: 'North Central',
      rating: '4.8 • UNESCO',
      badge: 'Medieval City',
      priceTag: '\$25 entry',
      footerTag: 'Royal Citadel Ruins',
      imageUrl: SriLankaImages.polonnaruwa,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'mihintale',
      name: 'Mihintale Sacred Mountain',
      subtitle: 'Cradle of Buddhism with 1,840 Granite Steps',
      region: 'Anuradhapura District',
      rating: '4.8 • Sacred Hill',
      badge: 'Cradle of Faith',
      priceTag: '\$3 entry',
      footerTag: 'Aradhana Gala Sunset',
      imageUrl: SriLankaImages.mihintale,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'yapahuwa',
      name: 'Yapahuwa Rock Fortress',
      subtitle: '13th-Century Fortress with Ornamental Staircase',
      region: 'Kurunegala District',
      rating: '4.7 • Citadel',
      badge: 'Royal Fortress',
      priceTag: '\$4 entry',
      footerTag: 'Lion Carvings & Steps',
      imageUrl: SriLankaImages.yapahuwa,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'gangaramaya',
      name: 'Gangaramaya Temple',
      subtitle: 'Vibrant Temple, Relic Museum & Lake Shrine',
      region: 'Colombo 02',
      rating: '4.8 • Eclectic',
      badge: 'Island Shrine',
      priceTag: '\$2 entry',
      footerTag: 'Architectural Gem',
      imageUrl: SriLankaImages.gangaramayaTemple,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'nallur_kovil',
      name: 'Nallur Kandaswamy Kovil',
      subtitle: 'Magnificent Golden Dravidian Temple & Gopuram',
      region: 'Jaffna Peninsula',
      rating: '4.9 • Dravidian',
      badge: 'Northern Crown',
      priceTag: 'Free Entry',
      footerTag: 'Sacred Chariot Festival',
      imageUrl: SriLankaImages.nallurKovil,
      category: 'Culture',
    ),
    ExploreDestination(
      id: 'kataragama',
      name: 'Kataragama Sacred Shrine',
      subtitle: 'Multi-Faith Sanctuary Dedicated to God Skanda',
      region: 'Deep South • Uva',
      rating: '4.8 • Multi-Faith',
      badge: 'Sacred Precinct',
      priceTag: 'Free Entry',
      footerTag: 'Evening Pooja Ceremony',
      imageUrl: SriLankaImages.kataragama,
      category: 'Culture',
    ),

    // ═══════════════════════════════════════════════════════════
    // WILDLIFE & SAFARI
    // ═══════════════════════════════════════════════════════════
    ExploreDestination(
      id: 'yala',
      name: 'Yala National Park',
      subtitle: 'Highest Leopard Density & Elephant Herds',
      region: 'Southern & Uva',
      rating: '4.9 • Safari',
      badge: 'Leopard Capital',
      priceTag: '\$30 safari',
      footerTag: 'Big Four Wildlife Safari',
      imageUrl: SriLankaImages.yala,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'udawalawe',
      name: 'Udawalawe National Park',
      subtitle: 'Guaranteed Wild Elephant Herds & Transit Home',
      region: 'Sabaragamuwa',
      rating: '4.9 • Elephants',
      badge: 'Elephant Haven',
      priceTag: '\$25 safari',
      footerTag: '400+ Free Elephants',
      imageUrl: SriLankaImages.udawalawe,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'wilpattu',
      name: 'Wilpattu National Park',
      subtitle: 'Natural Sand-Rimmed Villu Lakes & Leopards',
      region: 'North Western',
      rating: '4.8 • Wilderness',
      badge: 'Natural Villus',
      priceTag: '\$30 safari',
      footerTag: 'Leopards, Bears & Villus',
      imageUrl: SriLankaImages.wilpattu,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'minneriya',
      name: 'Minneriya National Park',
      subtitle: 'The Great Elephant Gathering of 300+ Elephants',
      region: 'North Central',
      rating: '4.9 • The Gathering',
      badge: 'World Wonder',
      priceTag: '\$25 safari',
      footerTag: 'Dry Season Gathering',
      imageUrl: SriLankaImages.minneriya,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'mirissa_whales',
      name: 'Mirissa Marine Sanctuary',
      subtitle: 'Open Ocean Trench Whale Watching Safari',
      region: 'South Coast',
      rating: '4.9 • Marine Giants',
      badge: 'Blue Whale Hub',
      priceTag: '\$45 cruise',
      footerTag: 'Earth\'s Largest Mammals',

      imageUrl: SriLankaImages.blueWhale,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'kumana',
      name: 'Kumana National Park',
      subtitle: 'Renowned Wetland Haven for 255 Migratory Birds',
      region: 'Ampara District',
      rating: '4.8 • Bird Paradise',
      badge: 'Wetland Sanctuary',
      priceTag: '\$20 safari',
      footerTag: 'Pelican & Stork Colonies',
      imageUrl: SriLankaImages.kumana,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'pigeon_island',
      name: 'Pigeon Island National Park',
      subtitle: 'Live Coral Reef, Blacktip Reef Sharks & Turtles',
      region: 'Trincomalee Coast',
      rating: '4.9 • Marine Park',
      badge: 'Coral Haven',
      priceTag: '\$18 boat & entry',
      footerTag: 'Snorkel with Reef Sharks',
      imageUrl: SriLankaImages.pigeonIsland,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'bundala',
      name: 'Bundala National Park',
      subtitle: 'Ramsar Wetland Sanctuary for Greater Flamingos',
      region: 'Hambantota Coast',
      rating: '4.8 • Ramsar Site',
      badge: 'Flamingo Haven',
      priceTag: '\$20 safari',
      footerTag: 'Coastal Lagoons & Dunes',
      imageUrl: SriLankaImages.bundala,
      category: 'Wildlife',
    ),
    ExploreDestination(
      id: 'wasgamuwa',
      name: 'Wasgamuwa National Park',
      subtitle: 'Untamed Wilderness with Sloth Bears & Tuskers',
      region: 'Matale & Polonnaruwa',
      rating: '4.7 • Sloth Bear',
      badge: 'Untamed River',
      priceTag: '\$22 safari',
      footerTag: 'Sloth Bears & Canals',
      imageUrl: SriLankaImages.wasgamuwa,
      category: 'Wildlife',
    ),

    // ═══════════════════════════════════════════════════════════
    // OUTDOOR & ADVENTURE
    // ═══════════════════════════════════════════════════════════
    ExploreDestination(
      id: 'kitulgala',
      name: 'Kitulgala White Water',
      subtitle: 'Grade 2-4 Kelani River Rapids & Canyoning',
      region: 'Kegalle District',
      rating: '4.9 • Extreme',
      badge: 'Rapid River',
      priceTag: '\$20 session',
      footerTag: 'Rapids, Jumps & Ziplines',
      imageUrl: SriLankaImages.kitulgala,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'flying_ravana',
      name: 'Ella Flying Ravana Zipline',
      subtitle: 'South Asia\'s Longest Dual Mega Zipline',

      region: 'Ella Highlands',
      rating: '4.9 • Thrills',
      badge: 'Mega Zipline',
      priceTag: '\$25 ride',
      footerTag: '82 km/h Flight Over Valleys',
      imageUrl: SriLankaImages.flyingRavana,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'arugam_surf',
      name: 'Arugam Bay Surf Expedition',
      subtitle: 'World-Renowned Right Hand Point Breaks',
      region: 'East Coast',
      rating: '4.9 • World Surf',
      badge: 'Pro Surf Hub',
      priceTag: 'Board Rent \$10',
      footerTag: 'May - Sept Wave Season',
      imageUrl: SriLankaImages.arugamBay,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'kalpitiya_kitesurf',
      name: 'Kalpitiya Kitesurfing',
      subtitle: '25-Knot Trade Winds & Flat Lagoon Waters',
      region: 'Puttalam Lagoon',
      rating: '4.8 • Wind Capital',
      badge: 'Premier Kitesurf',
      priceTag: '\$40 lesson',
      footerTag: 'Flat Lagoon & Ocean Waves',
      imageUrl: SriLankaImages.kalpitiya,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'knuckles_trek',
      name: 'Knuckles Cloud Forest Trek',
      subtitle: 'Corbett\'s Gap, Nitro Caves & Mini World\'s End',

      region: 'Central Highlands',
      rating: '4.8 • Hard Trek',
      badge: 'Cloud Forest',
      priceTag: 'Guide \$25/day',
      footerTag: 'Waterfalls, Caves & Peaks',
      imageUrl: SriLankaImages.knucklesRange,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'meemure_expedition',
      name: 'Meemure Wilderness Village',
      subtitle: 'Isolated Valley beneath Lakegala Pyramid Rock',
      region: 'Knuckles Wilderness',
      rating: '4.9 • Off-Grid',
      badge: 'Wilderness Camp',
      priceTag: 'Tour \$30',
      footerTag: 'Lakegala Ascent & Streams',
      imageUrl: SriLankaImages.meemure,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'hikkaduwa_diving',
      name: 'Hikkaduwa Scuba & Shipwrecks',
      subtitle: 'SS Conch Historic British Wreck & Deep Reefs',
      region: 'South-West Coast',
      rating: '4.8 • Scuba Hub',
      badge: 'Wreck Diving',
      priceTag: '\$35 per dive',
      footerTag: 'SS Conch Wreck & Reef',
      imageUrl: SriLankaImages.hikkaduwa,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'adams_peak_climb',
      name: 'Adam\'s Peak Night Pilgrimage',

      subtitle: '5,500 Steps Lantern Ascent for Solar Halo',
      region: 'Central Ridge',
      rating: '4.9 • Endurance',
      badge: 'Sacred Ascent',
      priceTag: 'Free Entry',
      footerTag: 'Sunrise Shadow Phenomenon',
      imageUrl: SriLankaImages.adamsPeak,
      category: 'Adventure',
    ),
    ExploreDestination(
      id: 'dambulla_balloon',
      name: 'Dambulla Hot Air Ballooning',
      subtitle: 'Floating over Ancient Lakes & Jungle Canopies',
      region: 'Cultural Triangle',
      rating: '4.9 • Sky High',
      badge: 'Sunrise Flight',
      priceTag: '\$210 flight',
      footerTag: 'Sunrise Aerial Views',
      imageUrl: SriLankaImages.hotAirBalloon,
      category: 'Adventure',
    ),
  ];

  final List<HiddenGemItem> _hiddenGems = const [
    // Beaches
    HiddenGemItem(
      id: 'tangalle_silent_gem',
      title: 'Tangalle Silent Beach',
      subtitle: 'Pristine secluded turquoise cove lined with wild coconut palms and crashing azure surf.',
      badge: 'UNTOUCHED HAVEN',
      distance: '2 hrs from Galle',
      rating: '4.9',
      imageUrl: SriLankaImages.tangalle,
      category: 'Beaches',
    ),
    HiddenGemItem(
      id: 'hiriketiya_gem',
      title: 'Hiriketiya Horseshoe Cove',
      subtitle: 'Secluded crescent cove with bohemian cafes and sheltered beginner-to-pro waves.',
      badge: 'SECRET COVE',
      distance: '1.5 hrs from Galle',
      rating: '4.9',
      imageUrl: SriLankaImages.hiriketiya,
      category: 'Beaches',
    ),
    HiddenGemItem(
      id: 'goyambokka_gem',
      title: 'Goyambokka Secret Bay',
      subtitle: 'Sheltered golden sand cove framed by giant smooth granite boulders and calm waters.',
      badge: 'HIDDEN BAY',
      distance: '2.5 hrs from Galle',
      rating: '4.8',
      imageUrl: SriLankaImages.tangalle,
      category: 'Beaches',
    ),

    // Nature
    HiddenGemItem(
      id: 'ritigala',
      title: 'Ritigala Strict Nature Reserve',
      subtitle: 'Ancient ruined forest monastery wrapped in giant jungle vines and medicinal groves.',
      badge: 'OFFBEAT SANCTUARY',
      distance: '3.5 hrs from Colombo',
      rating: '4.9',
      imageUrl: SriLankaImages.ritigala,
      category: 'Nature',
    ),
    HiddenGemItem(
      id: 'riverston_gem',
      title: 'Riverston & Knuckles Cloud Forest',
      subtitle: 'The mini World\'s End cloud forest trek featuring windswept plains and mountain streams.',

      badge: 'CLOUD FOREST TREK',
      distance: '1.5 hrs from Kandy',
      rating: '4.8',
      imageUrl: SriLankaImages.knucklesRange,
      category: 'Nature',
    ),
    HiddenGemItem(
      id: 'diyaluma_gem',
      title: 'Upper Diyaluma Natural Pools',
      subtitle: 'Secret series of natural rock plunge pools perched at the precipice of Sri Lanka\'s 2nd highest cascade.',

      badge: 'INFINITY POOLS',
      distance: '1 hr from Ella',
      rating: '4.9',
      imageUrl: SriLankaImages.diyaluma,
      category: 'Nature',
    ),

    // Culture
    HiddenGemItem(
      id: 'yapahuwa_gem',
      title: 'Yapahuwa Citadel Fortress',
      subtitle: 'Breathtaking 13th-century rock palace with steep granite steps and intricately carved lion guardians.',
      badge: 'ROCK CITADEL',
      distance: '2.5 hrs from Kandy',
      rating: '4.8',
      imageUrl: SriLankaImages.yapahuwa,
      category: 'Culture',
    ),
    HiddenGemItem(
      id: 'mihintale_gem',
      title: 'Mihintale Sacred Mountain',
      subtitle: 'The historic cradle of Sri Lankan Buddhism with 1,840 shaded stone steps leading to Aradhana Gala.',
      badge: 'BIRTHPLACE OF FAITH',
      distance: '20 mins from Anuradhapura',
      rating: '4.8',
      imageUrl: SriLankaImages.mihintale,
      category: 'Culture',
    ),

    // Wildlife
    HiddenGemItem(
      id: 'kumana_gem',
      title: 'Kumana Mangrove Bird Sanctuary',
      subtitle: 'Pristine mangrove swamp and lagoon sanctuary harboring thousands of rare nesting waterbirds.',
      badge: 'BIRD SANCTUARY',
      distance: '1 hr from Arugam Bay',
      rating: '4.8',
      imageUrl: SriLankaImages.kumana,
      category: 'Wildlife',
    ),
    HiddenGemItem(
      id: 'bundala_gem',
      title: 'Bundala Ramsar Wetlands',
      subtitle: 'Shallow coastal lagoons teeming with winter flocks of greater flamingos and saltwater crocodiles.',
      badge: 'RAMSAR WETLAND',
      distance: '45 mins from Yala',
      rating: '4.8',
      imageUrl: SriLankaImages.bundala,
      category: 'Wildlife',
    ),

    // Adventure
    HiddenGemItem(
      id: 'meemure_gem',
      title: 'Meemure Isolated Jungle Valley',
      subtitle: 'Ancient off-grid mountain hamlet completely insulated inside the Knuckles wilderness beneath Lakegala.',
      badge: 'OFF-GRID EXPEDITION',
      distance: '3 hrs from Kandy',
      rating: '4.9',
      imageUrl: SriLankaImages.meemure,
      category: 'Adventure',
    ),
    HiddenGemItem(
      id: 'kalpitiya_lagoon_gem',
      title: 'Kalpitiya Flat-Water Lagoon',
      subtitle: 'Butter-smooth secret sandbar channels offering world-class downwind kitesurfing expeditions.',
      badge: 'KITESURF LAGOON',
      distance: '3 hrs from Colombo',
      rating: '4.8',
      imageUrl: SriLankaImages.kalpitiya,
      category: 'Adventure',
    ),
  ];

  final List<CulturalExperienceItem> _culturalExperiences = const [
    // Beaches
    CulturalExperienceItem(
      id: 'mirissa_whale_exp',
      title: 'Mirissa Blue Whale & Dolphin Yacht Safari',
      subtitle: 'Open-ocean expedition into the deep Dondra trench to witness the world\'s largest living blue whales in their natural habitat.',

      duration: '3-4 hrs',
      price: '\$45 per person',
      tag: 'Marine Safari',
      verifiedNote: 'Marine Naturalist on board',
      ctaText: 'Book Safari',
      imageUrl: SriLankaImages.blueWhale,
      category: 'Beaches',
    ),
    CulturalExperienceItem(
      id: 'weligama_surf_clinic',
      title: 'Weligama Bay Beginner Surfing Clinic',
      subtitle: 'Professional 1-on-1 coaching, board rental and beach safety drills on the gentlest sandy-bottom surf breaks in Asia.',
      duration: '2 hrs Session',
      price: '\$20 per person',
      tag: 'Surf School',
      verifiedNote: 'ISA Certified Coaches',
      ctaText: 'Reserve Slot',
      imageUrl: SriLankaImages.weligama,
      category: 'Beaches',
    ),
    CulturalExperienceItem(
      id: 'bentota_lagoon_safari',
      title: 'Bentota Mangrove River Boat Safari',
      subtitle: 'Gliding silently through ancient mangrove tunnels, cinnamon peeling islands and open-air natural fish therapy pools.',
      duration: '2 hrs Cruise',
      price: '\$15 per boat',
      tag: 'River Safari',
      verifiedNote: 'Local Boatman & Lifejackets',
      ctaText: 'Book Cruise',
      imageUrl: SriLankaImages.bentota,
      category: 'Beaches',
    ),

    // Nature
    CulturalExperienceItem(
      id: 'ella_train_exp',
      title: 'Scenic Ella to Kandy Blue Train Journey',
      subtitle: 'South Asia\'s most scenic highland rail odyssey passing misty pine forests, tea estates, tunnels and cascading waterfalls.',

      duration: '3.5 hrs Ride',
      price: '\$12 Reserved Ticket',
      tag: 'Scenic Rail',
      verifiedNote: 'Reserved 1st Class Window',
      ctaText: 'Check Schedule',
      imageUrl: SriLankaImages.nineArchBridge,
      category: 'Nature',
    ),
    CulturalExperienceItem(
      id: 'ceylon_tea_masterclass',
      title: 'Pedro Estate Ceylon Tea Masterclass',
      subtitle: 'Walk among emerald bushes, hand-pick two leaves and a bud with local pickers, and taste artisanal Orange Pekoe.',
      duration: '2 hrs Tour',
      price: '\$8 Tasting',
      tag: 'Tea Tasting',
      verifiedNote: 'Factory Master Guide',
      ctaText: 'Join Masterclass',
      imageUrl: SriLankaImages.ceylonTea,
      category: 'Nature',
    ),
    CulturalExperienceItem(
      id: 'horton_plains_exp',
      title: 'Horton Plains & World\'s End Guided Hike',

      subtitle: 'Dawn crossing across cloud forest plateau, Baker\'s Falls cascade, and peering into the 880m sheer mountain abyss.',

      duration: '4 hrs Trek',
      price: '\$35 per person',
      tag: 'Trekking',
      verifiedNote: 'Wilderness Naturalist',
      ctaText: 'Book Expedition',
      imageUrl: SriLankaImages.hortonPlains,
      category: 'Nature',
    ),

    // Culture
    CulturalExperienceItem(
      id: 'dambulla',
      title: 'Dambulla Cave Temple Sanctuary',
      subtitle: 'Five ancient sacred sanctuaries adorned with 150+ gilded Buddha statues and 2,000-year-old rock frescoes.',
      duration: '2-3 hrs',
      price: '\$7 per person',
      tag: 'Audio Guide',
      verifiedNote: 'Licensed Guide available',
      ctaText: 'Book Experience',
      imageUrl: SriLankaImages.dambulla,
      category: 'Culture',
    ),
    CulturalExperienceItem(
      id: 'galle_trail',
      title: 'Galle Fort Historic Ramparts Trail',
      subtitle: '17th-century bastion ramparts, Dutch colonial architecture, maritime spice trading lore, and sunset lighthouse walk.',
      duration: '1.5-2 hrs',
      price: 'Free / Guided \$15',
      tag: 'Walking Tour',
      verifiedNote: 'Local Historian',
      ctaText: 'Explore Trail',
      imageUrl: SriLankaImages.galleLighthouse,
      category: 'Culture',
    ),
    CulturalExperienceItem(
      id: 'kandy_dance',
      title: 'Kandyan Cultural & Fire Dance Show',
      subtitle: 'Vibrant low-country drum ceremonies, ceremonial peacock dances, and thrilling barefoot fire-walking rituals.',
      duration: '1 hr Show',
      price: '\$10 Ticket',
      tag: 'Live Theatre',
      verifiedNote: 'Reserve Seat',
      ctaText: 'View Schedule',
      imageUrl: SriLankaImages.kandyanDance,
      category: 'Culture',
    ),

    // Wildlife
    CulturalExperienceItem(
      id: 'yala_jeep_safari',
      title: 'Yala Dawn 4x4 Leopard Tracker Safari',
      subtitle: 'Early morning game drive through Block 1 & 2 tracking the elusive Sri Lankan leopard, sloth bears and tuskers.',
      duration: '4-5 hrs',
      price: '\$55 per jeep',
      tag: '4x4 Game Drive',
      verifiedNote: 'Expert Wildlife Tracker',
      ctaText: 'Book Jeep',
      imageUrl: SriLankaImages.yala,
      category: 'Wildlife',
    ),
    CulturalExperienceItem(
      id: 'udawalawe_safari_exp',
      title: 'Udawalawe Wild Elephant Reserve Safari',
      subtitle: 'Open-top safari through scrub jungles observing 400+ free-roaming wild elephants and visiting the Elephant Transit Home.',
      duration: '3 hrs Safari',
      price: '\$40 per jeep',
      tag: 'Elephant Safari',
      verifiedNote: 'Certified Wildlife Ranger',
      ctaText: 'Reserve Jeep',
      imageUrl: SriLankaImages.udawalawe,
      category: 'Wildlife',
    ),
    CulturalExperienceItem(
      id: 'pigeon_island_snork_exp',
      title: 'Pigeon Island Reef Shark Snorkeling',
      subtitle: 'Boat expedition to live coral reefs to snorkel alongside peaceful blacktip reef sharks, green sea turtles and clownfish.',
      duration: '3 hrs Snorkel',
      price: '\$25 per person',
      tag: 'Marine Snorkel',
      verifiedNote: 'Snorkel Gear Included',
      ctaText: 'Book Snorkel',
      imageUrl: SriLankaImages.pigeonIsland,
      category: 'Wildlife',
    ),

    // Adventure
    CulturalExperienceItem(
      id: 'kitulgala_rafting_exp',
      title: 'Kitulgala White Water Rafting & Canyoning',
      subtitle: 'Pounding through Grade 3-4 rapids on the scenic Kelani River with certified guides, cliff jumps and river boarding.',
      duration: '2.5 hrs Rapids',
      price: '\$22 per person',
      tag: 'Whitewater',
      verifiedNote: 'River Safety Certified',
      ctaText: 'Book Rafting',
      imageUrl: SriLankaImages.kitulgala,
      category: 'Adventure',
    ),
    CulturalExperienceItem(
      id: 'flying_ravana_zipline_exp',
      title: 'Ella Flying Ravana Mega Zipline Ride',
      subtitle: 'South Asia\'s premier double mega zipline cruising at 82 km/h across lush green tea valleys and mountain chasms.',

      duration: '45 mins Flight',
      price: '\$25 per ride',
      tag: 'Mega Zipline',
      verifiedNote: 'European Safety Certified',
      ctaText: 'Book Flight',
      imageUrl: SriLankaImages.flyingRavana,
      category: 'Adventure',
    ),
    CulturalExperienceItem(
      id: 'dambulla_balloon_exp',
      title: 'Hot Air Ballooning Over Ancient Kingdoms',
      subtitle: 'Silently floating at sunrise over Kandalama Lake, Sigiriya Rock Fortress and waking jungle canopy.',
      duration: '1 hr Flight',
      price: '\$210 per person',
      tag: 'Sunrise Flight',
      verifiedNote: 'Licensed Commercial Pilot',
      ctaText: 'Reserve Basket',
      imageUrl: SriLankaImages.hotAirBalloon,
      category: 'Adventure',
    ),
  ];

  final List<NearbyPlaceItem> _nearbyPlaces = const [
    // Beaches
    NearbyPlaceItem(
      title: 'Mount Lavinia Shore',
      subtitle: 'Colonial beachside sunset promenade and seafood cafes',
      distance: '9.5 km',
      status: 'Open 24 hrs • Best at sunset',
      imageUrl: SriLankaImages.mountLavinia,
      category: 'Beaches',
    ),
    NearbyPlaceItem(
      title: 'Negombo Golden Beach & Lagoon',
      subtitle: 'Vibrant golden sands and coastal traditional catamarans',
      distance: '18 km',
      status: 'Open 24 hrs • Scenic shore',
      imageUrl: SriLankaImages.bentota,
      category: 'Beaches',
    ),

    // Nature
    NearbyPlaceItem(
      title: 'Seethawaka Botanical Gardens',
      subtitle: 'Lush rainforest flora, lotus lakes and mountain streams',
      distance: '35 km',
      status: 'Open 8 AM - 5 PM',
      imageUrl: SriLankaImages.sinharaja,
      category: 'Nature',
    ),
    NearbyPlaceItem(
      title: 'Labookellie Tea Estate',
      subtitle: 'Scenic mist-covered tea slopes and waterfall streams',
      distance: '45 km',
      status: 'Open 8 AM - 6 PM',
      imageUrl: SriLankaImages.ceylonTea,
      category: 'Nature',
    ),

    // Culture
    NearbyPlaceItem(
      title: 'Gangaramaya Temple',
      subtitle: 'Eclectic Buddhist temple by Beira Lake',
      distance: '2.4 km',
      status: 'Open now • Closes 6 PM',
      imageUrl: SriLankaImages.gangaramayaTemple,
      category: 'Culture',
    ),
    NearbyPlaceItem(
      title: 'Pettah & Red Mosque',
      subtitle: 'Historic vibrant spice bazaar & candy-striped mosque',
      distance: '3.8 km',
      status: 'Open now • Closes 8 PM',
      imageUrl: SriLankaImages.redMosque,
      category: 'Culture',
    ),
    NearbyPlaceItem(
      title: 'Kelaniya Raja Maha Vihara',
      subtitle: 'Ancient riverside temple sanctified by the Buddha',
      distance: '9.2 km',
      status: 'Open now • Closes 8 PM',
      imageUrl: SriLankaImages.anuradhapura,
      category: 'Culture',
    ),

    // Wildlife
    NearbyPlaceItem(
      title: 'Attidiya Bird Sanctuary',
      subtitle: 'Biodiverse urban marshland for rare migratory waterfowl',
      distance: '12 km',
      status: 'Best at Dawn',
      imageUrl: SriLankaImages.bundala,
      category: 'Wildlife',
    ),
    NearbyPlaceItem(
      title: 'Pinnawala Elephant Orphanage',
      subtitle: 'Daily river bathing of 70+ rescued gentle giants',
      distance: '78 km',
      status: 'Open 8:30 AM - 5:30 PM',
      imageUrl: SriLankaImages.elephant,
      category: 'Wildlife',
    ),

    // Adventure
    NearbyPlaceItem(
      title: 'Kelani Valley Kayak & Canopy',
      subtitle: 'River kayaking and jungle forest canopy flying',
      distance: '55 km',
      status: 'Booking Required',
      imageUrl: SriLankaImages.kitulgala,
      category: 'Adventure',
    ),
  ];

  void _openPlaceDetails(String title, {String? subtitle, String? rating, String? imageUrl}) {
    final details = PlaceDetailCatalog.resolveByIdOrTitle(
      title,
      fallbackSubtitle: subtitle,
      fallbackRating: rating,
      fallbackImageUrl: imageUrl,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailsPage(place: details)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSaveDestination(ExploreDestination d) {
    final appState = HelaAppStateProvider.of(context);
    final isSaved = appState.isHavenSaved(d.name) || _savedIds.contains(d.id);

    final haven = HavenItem(
      id: d.id,
      title: d.name,
      location: d.region,
      category: d.category,
      price: d.priceTag,
      rating: double.tryParse(d.rating.split(' ').first) ?? 4.8,
      badgeText: d.badge,
      imageUrl: d.imageUrl,
      filterCategory: d.category,
    );

    setState(() {
      if (isSaved) {
        _savedIds.remove(d.id);
        if (appState.isHavenSaved(d.name)) {
          appState.removeSavedHaven(d.name);
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${d.name}" from Saved Sanctuary'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _savedIds.add(d.id);
        if (!appState.isHavenSaved(d.name)) {
          appState.toggleSaveHaven(haven);
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved "${d.name}" to Wishlist'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Widget _buildNetworkImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFF0B5D56).withValues(alpha: 0.12),
        child: const Center(
          child: Icon(Icons.landscape_rounded, color: Color(0xFF0B5D56), size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);

    final selectedCat = _categories[_selectedCategoryIndex]['label'] as String;
    final query = _searchQuery.trim().toLowerCase();

    // Filter Popular Destinations
    final filteredDestinations = _popularDestinations.where((d) {
      final matchesCat = selectedCat == 'All' || d.category == selectedCat;
      final matchesQuery = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.subtitle.toLowerCase().contains(query) ||
          d.region.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    // Filter Hidden Gems
    final filteredGems = _hiddenGems.where((g) {
      final matchesCat = selectedCat == 'All' || g.category == selectedCat;
      final matchesQuery = query.isEmpty ||
          g.title.toLowerCase().contains(query) ||
          g.subtitle.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    // Filter Cultural Experiences
    final filteredExperiences = _culturalExperiences.where((e) {
      final matchesCat = selectedCat == 'All' || e.category == selectedCat;
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          e.subtitle.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    // Filter Nearby Discoveries
    final filteredNearby = _nearbyPlaces.where((n) {
      final matchesCat = selectedCat == 'All' || n.category == selectedCat;
      final matchesQuery = query.isEmpty ||
          n.title.toLowerCase().contains(query) ||
          n.subtitle.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HelaNavigationDrawer(),
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Title & View Switcher Row
                        _buildTitleAndViewSwitcher(colors),
                        const SizedBox(height: 14),

                        // Search Bar
                        _buildSearchBar(colors),
                        const SizedBox(height: 14),

                        // Category Filter Pills
                        _buildCategoryFilterPills(colors),
                        const SizedBox(height: 20),

                        // SECTION 1: Popular Destinations
                        if (filteredDestinations.isNotEmpty) ...[
                          _buildPopularDestinationsSection(colors, filteredDestinations, selectedCat),
                          const SizedBox(height: 26),
                        ],

                        // SECTION 2: Hidden Gems
                        if (filteredGems.isNotEmpty) ...[
                          _buildHiddenGemsSection(colors, filteredGems, selectedCat),
                          const SizedBox(height: 26),
                        ],

                        // SECTION 3: Curated Category Experiences
                        if (filteredExperiences.isNotEmpty) ...[
                          _buildCulturalExperiencesSection(colors, filteredExperiences, selectedCat),
                          const SizedBox(height: 26),
                        ],

                        // SECTION 4: Nearby Discoveries
                        if (filteredNearby.isNotEmpty) ...[
                          _buildNearbyDiscoveriesSection(colors, filteredNearby, selectedCat),
                          const SizedBox(height: 20),
                        ],

                        // Delight Banner: HELA Smart Local Assistant
                        _buildDelightAiBanner(colors),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating "Smart Guide • Ask HELA" Action Button in Bottom Right
            Positioned(
              bottom: 20,
              right: 16,
              child: HelaBottomNavBar.buildFloatingAskHelaButton(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HelaBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTitleAndViewSwitcher(HelaColorPalette colors) {
    return Text(
      'Explore',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: colors.onSurface,
        fontFamily: 'Inter',
        letterSpacing: -0.8,
      ),
    );
  }

  Widget _buildSearchBar(HelaColorPalette colors) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.architecturalBorder.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: colors.onSurface,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(
                fontSize: 14.5,
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Places to go, things to do, hotels...',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            const SizedBox(width: 18),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterPills(HelaColorPalette colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (idx) {
          final isSelected = _selectedCategoryIndex == idx;
          final cat = _categories[idx];
          final icon = cat['icon'] as IconData?;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.architecturalBorder,
                  ),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: isSelected ? Colors.white : colors.secondary),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      _translatedCategoryLabel(context, cat['label'] as String),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _translatedCategoryLabel(BuildContext context, String rawLabel) {
    final appState = HelaAppStateProvider.of(context);
    switch (rawLabel) {
      case 'All':
        return appState.tr('cat_all');
      case 'Nature':
        return appState.tr('cat_nature');
      case 'Beaches':
        return appState.tr('cat_beaches');
      case 'Culture':
        return appState.tr('cat_culture');
      case 'Wildlife':
        return appState.tr('cat_wildlife');
      case 'Adventure':
        return appState.tr('cat_adventure');
      default:
        return rawLabel;
    }
  }

  Widget _buildPopularDestinationsSection(HelaColorPalette colors, List<ExploreDestination> items, String category) {
    String sectionTitle;
    if (category == 'All') {
      sectionTitle = HelaAppStateProvider.of(context).tr('popular_destinations');
    } else if (category == 'Beaches') {
      sectionTitle = 'All Beaches in Sri Lanka';
    } else if (category == 'Nature') {
      sectionTitle = 'Nature & Mountain Wonders';
    } else if (category == 'Culture') {
      sectionTitle = 'Heritage & Ancient Citadels';
    } else if (category == 'Wildlife') {
      sectionTitle = 'Wildlife & National Parks';
    } else if (category == 'Adventure') {
      sectionTitle = 'Adventure & Outdoor Expeditions';
    } else {
      sectionTitle = '$category Destinations';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() => _selectedCategoryIndex = 0);
              },
              child: Row(
                children: [
                  Text(
                    'See All (${items.length})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 16, color: colors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Carousel
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final d = items[index];
              final isSaved = HelaAppStateProvider.of(context).isHavenSaved(d.name) || _savedIds.contains(d.id);
              return GestureDetector(
                onTap: () => _openPlaceDetails(d.name, subtitle: d.subtitle, rating: d.rating, imageUrl: d.imageUrl),
                child: Container(
                width: 235,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.architecturalBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with badges and save button
                      Stack(
                        children: [
                          SizedBox(
                            height: 135,
                            width: double.infinity,
                            child: _buildNetworkImage(d.imageUrl),
                          ),
                          // Rating Badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star_rounded, size: 12, color: colors.goldenAmber),
                                  const SizedBox(width: 2),
                                  Text(
                                    d.rating,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Bookmark Heart Icon
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _toggleSaveDestination(d),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isSaved ? const Color(0xFFDC2626) : const Color(0xFF4A5D5A),
                                ),
                              ),
                            ),
                          ),
                          // Location & Fee Strip at Bottom of Image
                          Positioned(
                            bottom: 6,
                            left: 8,
                            right: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 10, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        d.region,
                                        style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d.priceTag,
                                    style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Destination Text
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              d.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.explore_outlined, size: 13, color: colors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      d.footerTag,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: colors.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHiddenGemsSection(HelaColorPalette colors, List<HiddenGemItem> items, String category) {
    String sectionTitle;
    if (category == 'All') {
      sectionTitle = HelaAppStateProvider.of(context).tr('hidden_gems');
    } else if (category == 'Beaches') {
      sectionTitle = 'Hidden Beaches & Secret Coves';
    } else if (category == 'Nature') {
      sectionTitle = 'Offbeat Mountain Sanctuaries';
    } else if (category == 'Culture') {
      sectionTitle = 'Hidden Citadels & Sacred Ruins';
    } else if (category == 'Wildlife') {
      sectionTitle = 'Undiscovered Wildlife Havens';
    } else if (category == 'Adventure') {
      sectionTitle = 'Off-Grid Wilderness Expeditions';
    } else {
      sectionTitle = 'Hidden Gems';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.goldenAmber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Text(
              'Off the beaten track',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Vertical List
        ...items.map((gem) {
          return GestureDetector(
            onTap: () => _openPlaceDetails(gem.title, subtitle: gem.subtitle, rating: gem.rating, imageUrl: gem.imageUrl),
            child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.architecturalBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            gem.badge,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${gem.distance}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 13, color: colors.goldenAmber),
                        const SizedBox(width: 2),
                        Text(
                          gem.rating,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Body: Image + Text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: _buildNetworkImage(gem.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gem.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            gem.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          );
        }),
      ],
    );
  }

  Widget _buildCulturalExperiencesSection(HelaColorPalette colors, List<CulturalExperienceItem> items, String category) {
    String sectionTitle;
    String subtitle;
    if (category == 'All') {
      sectionTitle = HelaAppStateProvider.of(context).tr('cultural_experiences');
      subtitle = 'Authentic Heritage';
    } else if (category == 'Beaches') {
      sectionTitle = 'Ocean & Beach Activities';
      subtitle = 'Surf, Whales & Reefs';
    } else if (category == 'Nature') {
      sectionTitle = 'Highland Tea & Mountain Treks';
      subtitle = 'Cloud Forest Trails';
    } else if (category == 'Culture') {
      sectionTitle = 'Cultural & Heritage Tours';
      subtitle = 'Sacred Traditions';
    } else if (category == 'Wildlife') {
      sectionTitle = 'Safaris & Wildlife Expeditions';
      subtitle = 'Big Four Animals';
    } else if (category == 'Adventure') {
      sectionTitle = 'Adrenaline & Extreme Thrills';
      subtitle = 'Outdoor Action';
    } else {
      sectionTitle = '$category Experiences';
      subtitle = 'Curated Activities';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rich Experience Cards
        ...items.map((exp) {
          return GestureDetector(
            onTap: () => _openPlaceDetails(exp.title, subtitle: exp.subtitle, imageUrl: exp.imageUrl),
            child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.architecturalBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Duration and Price Badges
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: _buildNetworkImage(exp.imageUrl),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              exp.duration,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          exp.price,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF132220),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title + Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exp.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exp.tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  exp.subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                // Verified Note & CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: colors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          exp.verifiedNote,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.secondary,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CulturalGuidePage()));
                      },
                      child: Row(
                        children: [
                          Text(
                            exp.ctaText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 16, color: colors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          );
        }),
      ],
    );
  }

  Widget _buildNearbyDiscoveriesSection(HelaColorPalette colors, List<NearbyPlaceItem> items, String category) {
    String sectionTitle;
    String regionBadge;
    if (category == 'All') {
      sectionTitle = HelaAppStateProvider.of(context).tr('nearby_discoveries');
      regionBadge = 'Sri Lanka Highlights';
    } else if (category == 'Beaches') {
      sectionTitle = 'Nearby Coastal Discoveries';
      regionBadge = 'Coastal & Marine';
    } else if (category == 'Nature') {
      sectionTitle = 'Nearby Botanical & Forest Spots';
      regionBadge = 'Highland & Gardens';
    } else if (category == 'Culture') {
      sectionTitle = 'Nearby Historic Sanctuaries';
      regionBadge = 'Living Heritage';
    } else if (category == 'Wildlife') {
      sectionTitle = 'Nearby Wildlife & Bird Havens';
      regionBadge = 'Sanctuaries & Habitats';
    } else if (category == 'Adventure') {
      sectionTitle = 'Nearby Action & Trail Spots';
      regionBadge = 'Outdoor Trails';
    } else {
      sectionTitle = 'Nearby Discoveries';
      regionBadge = '$category Spots';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 3.5,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 12, color: colors.primary),
                  const SizedBox(width: 3),
                  Text(
                    regionBadge,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nearby List Tiles
        ...items.map((place) {
          return GestureDetector(
            onTap: () => _openPlaceDetails(place.title, subtitle: place.subtitle, imageUrl: place.imageUrl),
            child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.architecturalBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: _buildNetworkImage(place.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            place.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            place.distance,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF15803D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            place.status,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 20, color: colors.outlineVariant),
              ],
            ),
          ),
          );
        }),
      ],
    );
  }

  Widget _buildDelightAiBanner(HelaColorPalette colors) {
    return InkWell(
      onTap: () {
        HelaBottomNavBar.openAskHelaSheet(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.auto_awesome_rounded, size: 20, color: colors.goldenAmber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unsure what to see next?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Ask HELA to build a custom day trip',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
