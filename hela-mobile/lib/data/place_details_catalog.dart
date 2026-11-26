import 'package:flutter/material.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/models/featured_destination_item.dart';
import 'package:latlong2/latlong.dart';

class PlaceSpecItem {
  final IconData icon;
  final String label;
  final String value;

  const PlaceSpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class PlaceHighlightCardData {
  final String tag;
  final String title;
  final String description;
  final String imageUrl;

  const PlaceHighlightCardData({
    required this.tag,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class PlaceFeatureCallout {
  final IconData icon;
  final bool isAmber;
  final String title;
  final String description;

  const PlaceFeatureCallout({
    required this.icon,
    this.isAmber = false,
    required this.title,
    required this.description,
  });
}

class PlaceHistoryEntry {
  final String era;
  final String title;
  final String description;

  const PlaceHistoryEntry({
    required this.era,
    required this.title,
    required this.description,
  });
}

class PlaceVisitTip {
  final IconData icon;
  final String title;
  final String description;

  const PlaceVisitTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class NearbyDiscoveryItem {
  final String id;
  final String distanceLabel;
  final String title;
  final String subtitle;
  final String metaLabel;
  final IconData metaIcon;
  final String imageUrl;

  const NearbyDiscoveryItem({
    required this.id,
    required this.distanceLabel,
    required this.title,
    required this.subtitle,
    required this.metaLabel,
    required this.metaIcon,
    required this.imageUrl,
  });
}

class PlaceTouristGuide {
  final String openingHours;
  final String entryFee;
  final String bestSeason;
  final String howToGetThere;
  final String dressCodeAndRules;
  final String facilitiesAndSafety;

  const PlaceTouristGuide({
    required this.openingHours,
    required this.entryFee,
    required this.bestSeason,
    required this.howToGetThere,
    required this.dressCodeAndRules,
    required this.facilitiesAndSafety,
  });
}

class PlaceDetailData {
  final String id;
  final String title;
  final String subtitle;
  final String localScriptName;
  final String categoryBadge;
  final String eraBadge;
  final String loreGuideLabel;
  final String loreScript;
  final String rating;
  final String ratingCaption;
  final String locationLine;
  final String prestigeBadge;
  final String description;
  final List<String> photos;
  final List<PlaceSpecItem> quickSpecs;
  final List<PlaceHighlightCardData> highlightCards;
  final List<PlaceFeatureCallout> featureCallouts;
  final List<PlaceHistoryEntry> historyEntries;
  final List<PlaceVisitTip> visitTips;
  final double latitude;
  final double longitude;
  final String mapMarkerLabel;
  final String routeOrigin;
  final String routeSummaryLine;
  final String nearbyRegionLabel;
  final List<NearbyDiscoveryItem> nearbyDiscoveries;
  final String priceEstimate;
  final String categoryLabel;
  final PlaceTouristGuide? touristGuide;

  const PlaceDetailData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.localScriptName,
    required this.categoryBadge,
    required this.eraBadge,
    required this.loreGuideLabel,
    required this.loreScript,
    required this.rating,
    required this.ratingCaption,
    required this.locationLine,
    required this.prestigeBadge,
    required this.description,
    required this.photos,
    required this.quickSpecs,
    required this.highlightCards,
    required this.featureCallouts,
    required this.historyEntries,
    required this.visitTips,
    required this.latitude,
    required this.longitude,
    required this.mapMarkerLabel,
    required this.routeOrigin,
    required this.routeSummaryLine,
    required this.nearbyRegionLabel,
    required this.nearbyDiscoveries,
    this.priceEstimate = r'$30 / person',
    this.categoryLabel = 'Heritage & Nature',
    this.touristGuide,
  });

  PlaceTouristGuide get effectiveTouristGuide =>
      touristGuide ??
      PlaceTouristGuide(
        openingHours: 'Daily, 6:00 AM – 6:00 PM (Peak light: early morning & late afternoon)',
        entryFee: '$priceEstimate (Carry LKR cash for local tickets, parking & guides)',
        bestSeason: 'Dec – Apr (West/South/Hills dry) • May – Sep (East Coast dry)',
        howToGetThere: '$routeSummaryLine from $routeOrigin via private car, train or tuk-tuk',
        dressCodeAndRules: 'Respect local heritage etiquette; cover shoulders & knees at sacred sites; no littering',
        facilitiesAndSafety: 'Local guides & refreshments available; carry 1.5L water, sun protection & cash',
      );

  LatLng get coordinates => LatLng(latitude, longitude);

  String get formattedCoordinates {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lonDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(4)}° $latDir, ${longitude.abs().toStringAsFixed(4)}° $lonDir';
  }

  PlaceDetailData copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? localScriptName,
    String? categoryBadge,
    String? eraBadge,
    String? loreGuideLabel,
    String? loreScript,
    String? rating,
    String? ratingCaption,
    String? locationLine,
    String? prestigeBadge,
    String? description,
    List<String>? photos,
    List<PlaceSpecItem>? quickSpecs,
    List<PlaceHighlightCardData>? highlightCards,
    List<PlaceFeatureCallout>? featureCallouts,
    List<PlaceHistoryEntry>? historyEntries,
    List<PlaceVisitTip>? visitTips,
    double? latitude,
    double? longitude,
    String? mapMarkerLabel,
    String? routeOrigin,
    String? routeSummaryLine,
    String? nearbyRegionLabel,
    List<NearbyDiscoveryItem>? nearbyDiscoveries,
    String? priceEstimate,
    String? categoryLabel,
    PlaceTouristGuide? touristGuide,
  }) {
    return PlaceDetailData(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      localScriptName: localScriptName ?? this.localScriptName,
      categoryBadge: categoryBadge ?? this.categoryBadge,
      eraBadge: eraBadge ?? this.eraBadge,
      loreGuideLabel: loreGuideLabel ?? this.loreGuideLabel,
      loreScript: loreScript ?? this.loreScript,
      rating: rating ?? this.rating,
      ratingCaption: ratingCaption ?? this.ratingCaption,
      locationLine: locationLine ?? this.locationLine,
      prestigeBadge: prestigeBadge ?? this.prestigeBadge,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      quickSpecs: quickSpecs ?? this.quickSpecs,
      highlightCards: highlightCards ?? this.highlightCards,
      featureCallouts: featureCallouts ?? this.featureCallouts,
      historyEntries: historyEntries ?? this.historyEntries,
      visitTips: visitTips ?? this.visitTips,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapMarkerLabel: mapMarkerLabel ?? this.mapMarkerLabel,
      routeOrigin: routeOrigin ?? this.routeOrigin,
      routeSummaryLine: routeSummaryLine ?? this.routeSummaryLine,
      nearbyRegionLabel: nearbyRegionLabel ?? this.nearbyRegionLabel,
      nearbyDiscoveries: nearbyDiscoveries ?? this.nearbyDiscoveries,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      touristGuide: touristGuide ?? this.touristGuide,
    );
  }
}

/// Curated constant catalog of Sri Lankan destinations & home experiences.
class PlaceDetailCatalog {
  PlaceDetailCatalog._();

  static const PlaceDetailData sigiriya = PlaceDetailData(
    id: 'sigiriya',
    title: 'Sigiriya',
    subtitle: 'The Lion Rock Citadel •',
    localScriptName: 'සීගිරිය',
    categoryBadge: 'UNESCO HERITAGE',
    eraBadge: '5th Century CE',
    loreGuideLabel: 'Local Lore Guide (8m)',
    loreScript:
        'In 477 CE, King Kashyapa moved Sri Lanka\'s capital from Anuradhapura to this 180-metre granite citadel. Walk through symmetrical monsoon water gardens before ascending past the mirror wall and celestial frescoes.',
    rating: '4.9',
    ratingCaption: 'Verified Rating • 12.4k',
    locationLine: 'Central Province, Matale District, Sri Lanka',
    prestigeBadge: 'Top 1% Global Heritage • Wonder of South Asia',
    description:
        'An extraordinary 5th-century palace fortress perched atop a towering 180-metre sheer granite monolith, boasting celestial frescoes, mirror-polished parapets, and colossal stone lion paws guarding the clouds.',
    photos: [
      SriLankaImages.sigiriya,
      SriLankaImages.sigiriyaFrescoes,
      SriLankaImages.pidurangala,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'SUGGESTED TIME',
        value: '3 – 4 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.hiking_rounded,
        label: 'CLIMB GRADE',
        value: '1,200 Steps (Mod)',
      ),
      PlaceSpecItem(
        icon: Icons.workspace_premium_rounded,
        label: 'REGAL ERA',
        value: 'King Kashyapa',
      ),
      PlaceSpecItem(
        icon: Icons.eco_outlined,
        label: 'ECOSYSTEM',
        value: 'Nature Reserve',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'HYDRAULIC FEAT',
        title: 'The Water & Boulder Gardens',
        description:
            'One of the oldest surviving landscaped gardens in the world. Symmetrical canals, subterranean terracotta conduits, and gravity-powered fountains that still surge with water during the seasonal monsoon rains.',
        imageUrl: SriLankaImages.sigiriya,
      ),
      PlaceHighlightCardData(
        tag: 'ANCIENT ARTISTRY',
        title: 'The Celestial Maidens (Frescoes)',
        description:
            'Painted in a high sheltered rock pocket 100 metres above ground. These ethereal 5th-century tempera masterpieces showcase graceful cloud maidens carrying delicate water lilies and cascading blossom petals.',
        imageUrl: SriLankaImages.sigiriyaFrescoes,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.menu_book_rounded,
        title: 'The Mirror Wall & Ancient Graffiti',
        description:
            'Polished with porcelain-like lime, egg white, and wild honey so the king could admire his reflection. Inscribed with lyrical Sinhala poetry left by visitors between the 7th and 14th centuries.',
      ),
      PlaceFeatureCallout(
        icon: Icons.pets_rounded,
        isAmber: true,
        title: 'The Colossal Lion Gate',
        description:
            'The grand entrance to the summit plateau. Gigantic paws carved directly into the bedrock flank a limestone stairwell—originally leading into the jaws of a gargantuan sculpted brick beast.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '3rd Century BCE',
        title: 'Forest Monastery Sanctuary',
        description:
            'Drip-ledge rock shelters around the base housed Buddhist monks long before royal fortification, with Brahmi inscriptions still visible on boulder caves.',
      ),
      PlaceHistoryEntry(
        era: '477 – 495 CE',
        title: 'King Kashyapa\'s Sky Palace',
        description:
            'Kashyapa I engineered a fortified palace city atop the magma plug with an urban grid of moats, ramparts, and gravity-fed hydraulic pools.',
      ),
      PlaceHistoryEntry(
        era: '1982',
        title: 'UNESCO World Heritage Inscription',
        description:
            'Recognized globally for its unmatched fusion of 5th-century urban planning, landscape hydraulics, and classical South Asian fresco art.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.wb_sunny_outlined,
        title: 'Best Climbing Window',
        description:
            'Enter right at 6:30 AM or after 3:30 PM to avoid midday heat and large coach queues on the spiral staircase.',
      ),
      PlaceVisitTip(
        icon: Icons.water_drop_outlined,
        title: 'Hydration & Footwear',
        description:
            'Carry at least 1 litre of water and wear grippy walking shoes; there are no water stalls once you pass the Lion Terrace.',
      ),
      PlaceVisitTip(
        icon: Icons.camera_alt_outlined,
        title: 'Fresco Photography Rule',
        description:
            'Flash and photography are restricted inside the fresco pocket to preserve the original 5th-century pigments.',
      ),
    ],
    latitude: 7.9570,
    longitude: 80.7603,
    mapMarkerLabel: 'Sigiriya Citadel',
    routeOrigin: 'Dambulla',
    routeSummaryLine: '17.8 km • ~28 min via Tuk-Tuk',
    nearbyRegionLabel: 'Cultural Triangle',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'pidurangala',
        distanceLabel: '2.1 KM AWAY',
        title: 'Pidurangala Rock',
        subtitle: 'Epic panorama facing Lion Rock',
        metaLabel: '1.5 hr sunrise hike',
        metaIcon: Icons.schedule_rounded,
        imageUrl: SriLankaImages.pidurangala,
      ),
      NearbyDiscoveryItem(
        id: 'dambulla',
        distanceLabel: '18 KM AWAY',
        title: 'Dambulla Cave Temple',
        subtitle: 'UNESCO Golden Rock Shrine',
        metaLabel: 'Ancient sacred caves',
        metaIcon: Icons.temple_buddhist_rounded,
        imageUrl: SriLankaImages.dambulla,
      ),
    ],
    priceEstimate: r'$36 / person',
    categoryLabel: 'UNESCO Heritage',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 7:00 AM – 5:30 PM (Ticket counter closes 5:00 PM)',
      entryFee: r'~$35 USD Foreign Adult • ~$18 USD SAARC • Half price ages 6–12',
      bestSeason: 'Jan – Apr & Jul – Sep • Climb at 7:00 AM or 4:00 PM to avoid midday heat',
      howToGetThere: '~170 km (3.5–4h) from Colombo or 2.5h from Kandy via Dambulla/Habarana',
      dressCodeAndRules: 'Modest breathable wear & grippy shoes (1,200 steps); no flash on frescoes; drone permit needed',
      facilitiesAndSafety: 'Ticket museum, restrooms & certified guides; carry 1.5L water, hat & heed hornet signs',
    ),
  );

  static const PlaceDetailData minneriyaYala = PlaceDetailData(
    id: 'minneriya_yala',
    title: 'Minneriya & Yala Safaris',
    subtitle: 'Wild Elephant Gathering & Leopard Trails •',
    localScriptName: 'මින්නේරිය සහ යාල',
    categoryBadge: 'WILDLIFE SAFARI',
    eraBadge: 'Peak Jun–Oct',
    loreGuideLabel: 'Ranger Audio Brief (6m)',
    loreScript:
        'During the dry season, hundreds of wild Asian elephants converge along the ancient Minneriya tank bed crafted by King Mahasena in the 3rd century, while Yala Block 1 holds one of the highest leopard densities on Earth.',
    rating: '4.9',
    ratingCaption: 'Verified Rating • 9.8k',
    locationLine: 'North Central & Southern Wildlife Corridors, Sri Lanka',
    prestigeBadge: 'World-Famous Elephant Gathering • Big Five of Sri Lanka',
    description:
        'Witness monumental herds of wild Asian elephants grazing along ancient emerald reservoir shores in Minneriya, paired with thrilling dawn 4x4 jeep tracks through Yala\'s dry-zone scrub in search of elusive Sri Lankan leopards and sloth bears.',
    photos: [
      SriLankaImages.elephant,
      SriLankaImages.leopard,
      SriLankaImages.yala,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'SAFARI DURATION',
        value: '3.5 – 5 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.directions_car_rounded,
        label: 'VEHICLE',
        value: 'Open 4x4 Jeep',
      ),
      PlaceSpecItem(
        icon: Icons.wb_twilight_rounded,
        label: 'PRIME WINDOW',
        value: 'Dawn / 3 PM',
      ),
      PlaceSpecItem(
        icon: Icons.eco_outlined,
        label: 'HABITAT',
        value: 'Tank & Scrub',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'GREAT GATHERING',
        title: 'Minneriya Tank Bed Herds',
        description:
            'Up to 300 wild elephants—including playful calves and majestic tuskers—assemble across the receding lush grasslands of King Mahasena\'s 3rd-century reservoir.',
        imageUrl: SriLankaImages.minneriya,
      ),
      PlaceHighlightCardData(
        tag: 'APEX PREDATOR',
        title: 'Yala Leopard & Lagoon Coast',
        description:
            'Granite outcrops, coastal lagoons, and monsoon forests harbour Panthera pardus kotiya alongside mugger crocodiles, painted storks, and wild water buffalo.',
        imageUrl: SriLankaImages.leopard,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.verified_user_rounded,
        title: 'Ethical Jeep Spacing Protocol',
        description:
            'HELA partners strictly with certified wildlife trackers who maintain respectful viewing distances and keep engine noise low around elephant matriarchs.',
      ),
      PlaceFeatureCallout(
        icon: Icons.camera_enhance_rounded,
        isAmber: true,
        title: 'Golden Hour Safari Optics',
        description:
            'Bring a 70–300mm zoom lens or binoculars; afternoon light from 3:45 PM illuminates herds drinking at the water\'s edge.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '276 – 303 CE',
        title: 'Minneriya Reservoir Engineered',
        description:
            'King Mahasena built the massive 4,670-acre Minneriya Tank, creating the seasonal wetland ecosystem elephants still follow every year.',
      ),
      PlaceHistoryEntry(
        era: '1938',
        title: 'Yala Designated National Park',
        description:
            'Established as one of Sri Lanka\'s earliest protected sanctuaries, preserving ancient Ruhuna Kingdom ruins inside the jungle.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.palette_outlined,
        title: 'Neutral Safari Attire',
        description:
            'Wear earthy greens, khaki, or beige clothing with a dust scarf and sun hat for open-jeep tracks.',
      ),
      PlaceVisitTip(
        icon: Icons.schedule_rounded,
        title: 'Gate Entry Timing',
        description:
            'Arrive at Habarana/Minneriya gate by 2:30 PM or Yala Palatupana gate by 5:45 AM for quietest wildlife sightings.',
      ),
    ],
    latitude: 8.0190,
    longitude: 80.8400,
    mapMarkerLabel: 'Minneriya Park',
    routeOrigin: 'Habarana',
    routeSummaryLine: '11.4 km • ~20 min via Safari Jeep',
    nearbyRegionLabel: 'North Central Wilds',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'sigiriya',
        distanceLabel: '24 KM AWAY',
        title: 'Sigiriya Rock Fortress',
        subtitle: '5th-century sky citadel',
        metaLabel: 'UNESCO World Heritage',
        metaIcon: Icons.fort_rounded,
        imageUrl: SriLankaImages.sigiriya,
      ),
      NearbyDiscoveryItem(
        id: 'pidurangala',
        distanceLabel: '22 KM AWAY',
        title: 'Pidurangala Rock',
        subtitle: 'Sunrise view over Sigiriya',
        metaLabel: '1.5 hr scenic climb',
        metaIcon: Icons.terrain_rounded,
        imageUrl: SriLankaImages.pidurangala,
      ),
    ],
    priceEstimate: r'$55 / person',
    categoryLabel: 'Nature & Wildlife',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 6:00 AM – 6:00 PM (Morning 6–10 AM & Afternoon 2–6 PM safaris)',
      entryFee: r'~$35–$42 USD gate entry (incl. taxes & VAT) + private 4WD jeep hire',
      bestSeason: 'Minneriya Gathering: Jul – Oct • Yala Leopards: Feb – Jul (Block 1 closes Sep/Oct)',
      howToGetThere: 'Minneriya: 30 min from Sigiriya • Yala: ~3.5h from Colombo via Southern Expressway',
      dressCodeAndRules: 'Neutral earthy clothing; stay inside 4WD jeep; single-use plastics banned at gates',
      facilitiesAndSafety: 'Licensed 4WD jeeps & park trackers required; carry LKR cash, binoculars & dust scarf',
    ),
  );

  static const PlaceDetailData ceylonSpiceTrail = PlaceDetailData(
    id: 'ceylon_spice_trail',
    title: 'Ceylon Spice Trail',
    subtitle: 'Heirloom Curries & Hopper Feast •',
    localScriptName: 'සිලෝන් කුළුබඩු සහ ආප්ප',
    categoryBadge: 'CULINARY HERITAGE',
    eraBadge: 'Living Tradition',
    loreGuideLabel: 'Chef Story Guide (5m)',
    loreScript:
        'From wild-harvested Alba cinnamon and Matale black pepper to wood-fired clay-pot curries and lacy coconut-milk egg hoppers, discover how Sri Lanka\'s spice trade shaped world cuisine.',
    rating: '4.8',
    ratingCaption: 'Verified Rating • 6.2k',
    locationLine: 'Matale Spice Belt & Colombo Heritage Kitchens, Sri Lanka',
    prestigeBadge: 'True Ceylon Cinnamon Origin • Slow-Food Experience',
    description:
        'Embark on an aromatic journey through shaded spice gardens and bustling village kitchens. Grind fresh curry blends on a traditional miris gala granite stone, learn crisp hopper swirling over woodfire, and savour an eight-curry banana-leaf feast.',
    photos: [
      SriLankaImages.riceAndCurry,
      SriLankaImages.ceylonSpices,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'EXPERIENCE TIME',
        value: '2.5 – 3 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.restaurant_rounded,
        label: 'TASTINGS',
        value: '8+ Local Dishes',
      ),
      PlaceSpecItem(
        icon: Icons.spa_rounded,
        label: 'SPICE ORIGINS',
        value: 'Cinnamon & Pepper',
      ),
      PlaceSpecItem(
        icon: Icons.local_cafe_rounded,
        label: 'PAIRING',
        value: 'King Coconut & Tea',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'CLAY-POT CRAFT',
        title: 'Woodfire Hopper & Sambol Workshop',
        description:
            'Swirl fermented rice-flour and coconut-milk batter inside a seasoned curved thachchi pan until lacy golden edges form, served hot with spicy katta sambol and seeni sambol.',
        imageUrl: SriLankaImages.hopper,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.eco_rounded,
        title: 'True Ceylon Cinnamon (Kurundu)',
        description:
            'Learn why Sri Lankan Cinnamomum verum—delicate, sweet, and ultra-low in coumarin—is prized over cassia by master chefs worldwide.',
      ),
      PlaceFeatureCallout(
        icon: Icons.local_dining_rounded,
        isAmber: true,
        title: 'Dietary & Spice Customizations',
        description:
            '100% plant-based, vegan, gluten-free, and mild-spice adaptations are freshly prepared on request.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: 'Ancient Maritime Era',
        title: 'Taprobane\'s Spice Routes',
        description:
            'Arab, Chinese, and Mediterranean merchants sailed to Sri Lankan ports specifically for cinnamon, cardamom, cloves, and black pepper.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.restaurant_menu_rounded,
        title: 'Arrive Hungry',
        description:
            'Skip heavy snacks beforehand—tastings include crispy hoppers, kottu, jackfruit curry, and buffalo curd with kithul treacle.',
      ),
    ],
    latitude: 7.4675,
    longitude: 80.6234,
    mapMarkerLabel: 'Matale Spice Valley',
    routeOrigin: 'Kandy',
    routeSummaryLine: '26.2 km • ~45 min scenic drive',
    nearbyRegionLabel: 'Central Highlands',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'kandy',
        distanceLabel: '26 KM AWAY',
        title: 'Kandy Sacred City',
        subtitle: 'Temple of the Tooth & lake walk',
        metaLabel: 'Cultural capital',
        metaIcon: Icons.temple_buddhist_rounded,
        imageUrl: SriLankaImages.templeOfTheTooth,
      ),
      NearbyDiscoveryItem(
        id: 'dambulla',
        distanceLabel: '45 KM AWAY',
        title: 'Dambulla Cave Temple',
        subtitle: 'UNESCO Golden Rock Shrine',
        metaLabel: '2,000-yr murals',
        metaIcon: Icons.account_balance_rounded,
        imageUrl: SriLankaImages.dambulla,
      ),
    ],
    priceEstimate: r'$24 / person',
    categoryLabel: 'Food & Culture',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 8:30 AM – 5:30 PM (Hands-on cooking classes ~10:00 AM & 4:00 PM)',
      entryFee: r'Garden walks often free; curated tastings & cooking classes ~$15 – $30 USD',
      bestSeason: 'Year-round • Dec – Apr offers driest hill weather in Matale & Kandy',
      howToGetThere: '25 km north of Kandy (~45 min) along A9 highway toward Dambulla via car or tuk-tuk',
      dressCodeAndRules: 'Casual comfortable attire; share food allergies or spice preferences before tasting',
      facilitiesAndSafety: 'Shaded outdoor kitchens, restrooms & filtered water; zero obligation to buy shop spices',
    ),
  );

  static const PlaceDetailData weligamaTangalle = PlaceDetailData(
    id: 'weligama_tangalle',
    title: 'Weligama & Tangalle Bays',
    subtitle: 'Surfing Reefs & Secret Coves •',
    localScriptName: 'වැලිගම සහ තංගල්ල',
    categoryBadge: 'BEACHES & OCEAN',
    eraBadge: 'Best Nov–Apr',
    loreGuideLabel: 'Coastal Surf Guide (6m)',
    loreScript:
        'Weligama\'s sandy-bottom crescent bay welcomes first-time surfers and longboarders alike, while an hour east, Tangalle unfolds into quiet palm-framed coves and sea turtle nesting sands.',
    rating: '4.9',
    ratingCaption: 'Verified Rating • 10.1k',
    locationLine: 'Southern Coast, Matara & Hambantota Districts, Sri Lanka',
    prestigeBadge: 'Asia\'s Friendliest Surf Bay • Marine Turtle Coast',
    description:
        'Ride gentle turquoise rollers along Weligama\'s forgiving sandy crescent in the morning, then cruise the southern coastal road to Tangalle\'s secluded golden bays, mangrove lagoons, and tranquil sunset cliffs.',
    photos: [
      SriLankaImages.weligama,
      SriLankaImages.tangalle,
      SriLankaImages.unawatuna,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'SUGGESTED TIME',
        value: 'Half / Full Day',
      ),
      PlaceSpecItem(
        icon: Icons.surfing_rounded,
        label: 'SURF GRADE',
        value: 'Beginner – Interm.',
      ),
      PlaceSpecItem(
        icon: Icons.waves_rounded,
        label: 'WATER TEMP',
        value: '28°C Year-Round',
      ),
      PlaceSpecItem(
        icon: Icons.beach_access_rounded,
        label: 'COASTLINE',
        value: 'Sandy & Coral',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'SURF PARADISE',
        title: 'Weligama Crescent & Taprobane Island',
        description:
            'Soft sandbar waves make Weligama ideal for sunrise surf coaching, framed by iconic stilt fishermen poles and tiny offshore Taprobane Island.',
        imageUrl: SriLankaImages.weligama,
      ),
      PlaceHighlightCardData(
        tag: 'HIDDEN LAGOONS',
        title: 'Goyambokka & Silent Beach, Tangalle',
        description:
            'Tucked behind swaying coconut groves, Tangalle\'s coves offer calm crystal shallows, glowing sunsets, and night turtle-conservation walks at Rekawa.',
        imageUrl: SriLankaImages.tangalle,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.kayaking_rounded,
        title: 'Kalametiya & Tangalle Lagoon Kayaking',
        description:
            'Glide quietly at sunrise beneath kingfishers and purple herons in coastal mangrove lagoons just minutes from the ocean.',
      ),
      PlaceFeatureCallout(
        icon: Icons.wb_sunny_rounded,
        isAmber: true,
        title: 'Cleanest Glassy Swells',
        description:
            'Early morning sessions (6:30 AM – 9:30 AM) offer the cleanest offshore winds before afternoon sea breezes arrive.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1920s',
        title: 'Taprobane Island Villa Legacy',
        description:
            'Built by Count de Mauny-Talvande on a private rocky islet in Weligama Bay, inspiring writers and travelers for a century.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.sunny_snowing,
        title: 'Reef-Safe Sunscreen & Rashguard',
        description:
            'Tropical UV peaks quickly on the water—wear a long-sleeve rashguard and reef-safe zinc sunscreen when surfing.',
      ),
    ],
    latitude: 5.9739,
    longitude: 80.4297,
    mapMarkerLabel: 'Weligama Surf Bay',
    routeOrigin: 'Galle',
    routeSummaryLine: '28.5 km • ~38 min coastal drive',
    nearbyRegionLabel: 'Southern Coast',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'mirissa',
        distanceLabel: '6.5 KM AWAY',
        title: 'Mirissa & Coconut Tree Hill',
        subtitle: 'Sunset palm cliff & blue whales',
        metaLabel: '12 min by Tuk-Tuk',
        metaIcon: Icons.beach_access_rounded,
        imageUrl: SriLankaImages.mirissa,
      ),
      NearbyDiscoveryItem(
        id: 'galle',
        distanceLabel: '28 KM AWAY',
        title: 'Galle Dutch Fort',
        subtitle: '17th-century coastal ramparts',
        metaLabel: 'UNESCO heritage fort',
        metaIcon: Icons.fort_rounded,
        imageUrl: SriLankaImages.galleFort,
      ),
    ],
    priceEstimate: r'$25 / person',
    categoryLabel: 'Beaches & Ocean',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Open 24 Hours (Surf schools & lagoon tours operate 6:30 AM – 6:00 PM)',
      entryFee: r'Free Public Beaches • Surfboard rental ~$8–$12 USD • Surf lesson ~$20–$30 USD',
      bestSeason: 'November – April (Calm turquoise seas, gentle swells & sunny weather)',
      howToGetThere: '~2h 15m from Colombo via Southern Expressway (E01) or Coastal Train to Weligama',
      dressCodeAndRules: 'Beachwear on shore; cover up in town; respect local stilt fishermen & reef habitats',
      facilitiesAndSafety: 'Surf schools, showers & cafes in Weligama; check local flags for currents in Tangalle',
    ),
  );

  static const PlaceDetailData ellaNineArch = PlaceDetailData(
    id: 'ella_nine_arch',
    title: 'Ella & Nine Arch Bridge',
    subtitle: 'Demodara Tea Valley •',
    localScriptName: 'ඇල්ල සහ ආරුක්කු නවයේ පාලම',
    categoryBadge: 'HILL COUNTRY',
    eraBadge: '1921 Colonial Rail',
    loreGuideLabel: 'Highland Rail Lore (7m)',
    loreScript:
        'Built in 1921 purely of brick, stone, and cement without a single steel girder, the Nine Arch Bridge curves 30 metres above a lush jungle valley where emerald tea pluckers still greet passing blue trains.',
    rating: '4.9',
    ratingCaption: 'Verified Rating • 15.2k',
    locationLine: 'Uva Province, Badulla District, Sri Lanka',
    prestigeBadge: 'World\'s Most Scenic Train Corridor • Misty Tea Country',
    description:
        'Perched amidst emerald mountain ridges and cascading waterfalls, Ella blends iconic colonial railway architecture at the Nine Arch Bridge with ridge-top hikes up Little Adam\'s Peak and Ella Rock.',
    photos: [
      SriLankaImages.nineArchBridge,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'SUGGESTED TIME',
        value: '2.5 – 4 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.hiking_rounded,
        label: 'TRAIL GRADE',
        value: 'Easy – Moderate',
      ),
      PlaceSpecItem(
        icon: Icons.train_rounded,
        label: 'RAILWAY ERA',
        value: 'Built 1921',
      ),
      PlaceSpecItem(
        icon: Icons.terrain_rounded,
        label: 'ELEVATION',
        value: '1,041 m ASL',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'ARCHITECTURAL ICON',
        title: 'The Nine Arch Stone Viaduct',
        description:
            'Known locally as Ahas Namaye Palama ("Bridge in the Nine Skies"), this graceful 91-metre curved bridge spans a mist-filled gorge flanked by Demodara tea estates.',
        imageUrl: SriLankaImages.nineArchBridge,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.train_rounded,
        title: 'Daily Train Crossing Schedule',
        description:
            'Catch the iconic blue highland trains crossing the bridge around 9:30 AM, 11:30 AM, 3:30 PM, and 5:30 PM.',
      ),
      PlaceFeatureCallout(
        icon: Icons.local_florist_rounded,
        isAmber: true,
        title: 'Artisan Tea Factory Tasting',
        description:
            'Pair your walk with a visit to Halpewatte Tea Estate to taste single-origin Uva high-grown orange pekoe.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1921',
        title: 'Masterwork Without Steel',
        description:
            'When World War I disrupted steel shipments, local master builder P. K. Appuhamy completed the entire 30-metre-tall bridge using solid granite and cement.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.directions_walk_rounded,
        title: 'Forest Path Shortcut',
        description:
            'Walk down the shaded footpath from Gotuwala Junction (15 mins) rather than riding a steep tuk-tuk trail right to the tracks.',
      ),
    ],
    latitude: 6.8768,
    longitude: 81.0608,
    mapMarkerLabel: 'Nine Arch Bridge',
    routeOrigin: 'Ella Town',
    routeSummaryLine: '2.9 km • ~12 min via Tuk-Tuk',
    nearbyRegionLabel: 'Uva Highlands',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'little_adams_peak',
        distanceLabel: '2.4 KM AWAY',
        title: 'Little Adam\'s Peak',
        subtitle: 'Panoramic sunrise ridge walk',
        metaLabel: '1 hr easy hike',
        metaIcon: Icons.terrain_rounded,
        imageUrl: SriLankaImages.ella,
      ),
      NearbyDiscoveryItem(
        id: 'kandy',
        distanceLabel: '135 KM AWAY',
        title: 'Kandy Sacred City',
        subtitle: 'Start of the scenic tea rail',
        metaLabel: 'UNESCO hill capital',
        metaIcon: Icons.temple_buddhist_rounded,
        imageUrl: SriLankaImages.templeOfTheTooth,
      ),
    ],
    priceEstimate: r'$15 / person',
    categoryLabel: 'Hill Country',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Open 24/7 • Trains cross ~9:30 AM, 11:30 AM, 3:30 PM & 5:30 PM daily',
      entryFee: r'Free Entry (Tuk-tuk drop-off ~300–500 LKR; Flying Ravana zipline ~$25–$30 USD)',
      bestSeason: 'January – May (Clear misty mornings, dry trails & sunny highland vistas)',
      howToGetThere: 'Scenic Kandy–Ella Blue Train (~6–7h) or 30 min walk / 10 min tuk-tuk from Ella town',
      dressCodeAndRules: 'Sturdy sneakers for forest path; step well clear of railway tracks when trains approach',
      facilitiesAndSafety: 'Viewpoint tea cafes & zipline park nearby; verify daily train times; pack light rain shell',
    ),
  );

  static const PlaceDetailData kandy = PlaceDetailData(
    id: 'kandy',
    title: 'Kandy',
    subtitle: 'Temple of the Sacred Tooth Relic •',
    localScriptName: 'මහනුවර',
    categoryBadge: 'CULTURAL HERITAGE',
    eraBadge: '1595 CE Kingdom',
    loreGuideLabel: 'Royal City Guide (7m)',
    loreScript:
        'Sri Lanka\'s last royal capital cradles the golden-roofed Sri Dalada Maligawa beside tranquil Kandy Lake, surrounded by misty hills and the Royal Botanic Gardens of Peradeniya.',
    rating: '4.8',
    ratingCaption: 'Verified Rating • 11.3k',
    locationLine: 'Central Province, Kandy District, Sri Lanka',
    prestigeBadge: 'UNESCO Sacred City • Last Royal Capital',
    description:
        'Nestled in a bowl of emerald mountains around a tranquil man-made lake, Kandy is the spiritual heart of Sri Lanka—home to the Temple of the Sacred Tooth Relic, vibrant Kandyan dance traditions, and 147 acres of royal botanical gardens.',
    photos: [
      SriLankaImages.templeOfTheTooth,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'SUGGESTED TIME',
        value: 'Half / Full Day',
      ),
      PlaceSpecItem(
        icon: Icons.temple_buddhist_rounded,
        label: 'DRESS CODE',
        value: 'Modest / Covered',
      ),
      PlaceSpecItem(
        icon: Icons.music_note_rounded,
        label: 'EVENING POOJA',
        value: '6:30 PM Drums',
      ),
      PlaceSpecItem(
        icon: Icons.eco_outlined,
        label: 'CLIMATE',
        value: 'Breezy 24°C',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'SACRED SANCTUARY',
        title: 'Sri Dalada Maligawa',
        description:
            'Hear traditional hewisi ceremonial drumming during the dawn and evening Thevava offerings at Sri Lanka\'s most revered Buddhist shrine.',
        imageUrl: SriLankaImages.kandyLake,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.park_rounded,
        title: 'Peradeniya Royal Botanical Gardens',
        description:
            'Stroll beneath avenues of towering royal palms, giant Javan fig trees, and over 300 orchid species beside the Mahaweli River.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1595 – 1815 CE',
        title: 'Kingdom of Senkadagala',
        description:
            'Protected by dense mountain passes, Kandy remained an independent sovereign kingdom for over two centuries.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.checkroom_rounded,
        title: 'Temple Attire Checklist',
        description:
            'Ensure shoulders and knees are covered and remove footwear at the temple entrance gate.',
      ),
    ],
    latitude: 7.2936,
    longitude: 80.6413,
    mapMarkerLabel: 'Sri Dalada Maligawa',
    routeOrigin: 'Peradeniya',
    routeSummaryLine: '6.2 km • ~18 min via Tuk-Tuk',
    nearbyRegionLabel: 'Hill Capital',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'ceylon_spice_trail',
        distanceLabel: '26 KM AWAY',
        title: 'Matale Spice Gardens',
        subtitle: 'Cinnamon & heirloom curry tour',
        metaLabel: '2.5 hr culinary walk',
        metaIcon: Icons.restaurant_rounded,
        imageUrl: SriLankaImages.ceylonSpices,
      ),
    ],
    priceEstimate: r'$20 / person',
    categoryLabel: 'Cultural Heritage',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 5:30 AM – 8:00 PM • Sacred Puja rituals at 5:30 AM, 9:30 AM & 6:30 PM',
      entryFee: r'LKR 3,000 (~$10 USD) Foreign Adult (Locals free; SAARC discounts apply)',
      bestSeason: 'December – April (Mild highland weather) & July/August for Esala Perahera',
      howToGetThere: '2.5–3.5h scenic train or highway drive from Colombo; short walk from central Kandy',
      dressCodeAndRules: 'Strict temple dress code: shoulders & knees covered; remove shoes & hats at entrance',
      facilitiesAndSafety: 'Official shoe storage (~100–200 LKR), lockers & ATMs nearby; beware touts outside gates',
    ),
  );

  static const PlaceDetailData galle = PlaceDetailData(
    id: 'galle',
    title: 'Galle Dutch Fort',
    subtitle: '17th-Century Ocean Ramparts •',
    localScriptName: 'ගාල්ල කොටුව',
    categoryBadge: 'COLONIAL FORT',
    eraBadge: '1663 CE Ramparts',
    loreGuideLabel: 'Fort Walk Guide (6m)',
    loreScript:
        'Constructed initially by the Portuguese in 1588 and fortified in coral and granite by the Dutch in 1663, Galle Fort is a living UNESCO city of cobbled lanes, cafes, and sunset ocean bastions.',
    rating: '4.9',
    ratingCaption: 'Verified Rating • 13.7k',
    locationLine: 'Southern Province, Galle District, Sri Lanka',
    prestigeBadge: 'UNESCO Living Heritage Fort • Indian Ocean Bastions',
    description:
        'Wander lantern-lit cobblestone streets lined with Dutch-period villas, boutique galleries, spice merchants, and the iconic white Galle Lighthouse overlooking turquoise surf breaks along the ramparts.',
    photos: [
      SriLankaImages.galleFort,
      SriLankaImages.galleLighthouse,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'SUGGESTED TIME',
        value: '2.5 – 4 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.directions_walk_rounded,
        label: 'WALK GRADE',
        value: 'Flat Cobblestone',
      ),
      PlaceSpecItem(
        icon: Icons.fort_rounded,
        label: 'FORTIFIED',
        value: '1663 CE',
      ),
      PlaceSpecItem(
        icon: Icons.wb_twilight_rounded,
        label: 'SUNSET SPOT',
        value: 'Flag Rock Bastion',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'COASTAL BASTION',
        title: 'Galle Lighthouse & Utrecht Bastion',
        description:
            'Sri Lanka\'s oldest light station stands at the southeastern rampart corner, framed by coconut palms and ocean breezes.',
        imageUrl: SriLankaImages.galleLighthouse,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.storefront_rounded,
        title: 'Pedlar Street Boutiques & Gelato',
        description:
            'Browse handloom textiles, Ceylon sapphires, and tropical passionfruit sorbet tucked inside restored courtyard mansions.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1663 CE',
        title: 'Dutch VOC Maritime Stronghold',
        description:
            'Granite walls and 14 bastions protected the harbour, complete with an ingenious tidal underground sewer network.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.wb_twilight_rounded,
        title: 'Golden Hour Rampart Stroll',
        description:
            'Begin walking the walls at 4:45 PM from Moon Bastion to Flag Rock to watch the sunset dip into the Indian Ocean.',
      ),
    ],
    latitude: 6.0270,
    longitude: 80.2170,
    mapMarkerLabel: 'Galle Fort',
    routeOrigin: 'Galle Station',
    routeSummaryLine: '1.4 km • ~6 min via Tuk-Tuk',
    nearbyRegionLabel: 'Southern Coast',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'weligama_tangalle',
        distanceLabel: '28 KM AWAY',
        title: 'Weligama Surf Bay',
        subtitle: 'Gentle beginner surf & beaches',
        metaLabel: '35 min coastal ride',
        metaIcon: Icons.surfing_rounded,
        imageUrl: SriLankaImages.weligama,
      ),
    ],
    priceEstimate: r'Free entry',
    categoryLabel: 'Coastal Heritage',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Ramparts open 24/7 • Boutiques, cafes & museums operate ~9:00 AM – 7:00 PM',
      entryFee: r'Free entry to Fort & ramparts (Maritime & Dutch Museums ~$3–$5 USD optional)',
      bestSeason: 'November – April (Dry coastal sunshine; iconic sunset rampart walk 5:00–6:15 PM)',
      howToGetThere: '~1h 45m from Colombo via Southern Expressway (E01) or Coastal Train to Galle Station',
      dressCodeAndRules: 'Casual resort wear; modest attire when entering Fort mosques, churches or Buddhist temple',
      facilitiesAndSafety: 'Boutique stays, cafes, ATMs & pharmacies inside Fort; watch footing on unrailed walls',
    ),
  );

  static const PlaceDetailData mirissa = PlaceDetailData(
    id: 'mirissa',
    title: 'Mirissa',
    subtitle: 'Coconut Tree Hill & Blue Whales •',
    localScriptName: 'මිරිස්ස',
    categoryBadge: 'SOUTH COAST',
    eraBadge: 'Whale Season Nov–Apr',
    loreGuideLabel: 'Marine Coast Guide (5m)',
    loreScript:
        'Just off Mirissa\'s continental shelf drop-off, deep-ocean currents attract the planet\'s largest mammal—the blue whale—while Coconut Tree Hill offers Sri Lanka\'s most photographed sunset headland.',
    rating: '4.9',
    ratingCaption: 'Verified Rating • 9.4k',
    locationLine: 'Southern Province, Matara District, Sri Lanka',
    prestigeBadge: 'Blue Whale Sanctuary • Iconic Palm Headland',
    description:
        'A laid-back crescent cove famed for responsible dawn whale-watching expeditions, red-laterite Coconut Tree Hill panoramas, beginner-friendly surf swells, and candlelit beachside grilled seafood.',
    photos: [
      SriLankaImages.mirissa,
      SriLankaImages.blueWhale,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'SUGGESTED TIME',
        value: 'Half / Full Day',
      ),
      PlaceSpecItem(
        icon: Icons.sailing_rounded,
        label: 'WHALE TOURS',
        value: '6:30 AM Depart',
      ),
      PlaceSpecItem(
        icon: Icons.photo_camera_rounded,
        label: 'TOP VIEWPOINT',
        value: 'Coconut Tree Hill',
      ),
      PlaceSpecItem(
        icon: Icons.beach_access_rounded,
        label: 'VIBE',
        value: 'Tropical Sunset',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'OCEAN HORIZON',
        title: 'Coconut Tree Hill Headland',
        description:
            'A dramatic red-cliff peninsula crowned by tall ocean palms overlooking rolling swells toward Parrot Rock.',
        imageUrl: SriLankaImages.mirissa,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.water_rounded,
        title: 'Responsible Whale Watching',
        description:
            'Choose eco-certified vessels adhering to the 100-metre passive approach guideline for blue whales and spinner dolphins.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: 'Maritime Heritage',
        title: 'From Fishing Cove to Marine Haven',
        description:
            'Traditional outrigger oruwa fishermen still launch from Mirissa Harbour alongside marine researchers studying Indian Ocean blue whales.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.wb_sunny_outlined,
        title: 'Sunrise Over Sunset at Coconut Hill',
        description:
            'Visit at 6:15 AM for serene empty photos, or at 5:30 PM for warm golden sunset light.',
      ),
    ],
    latitude: 5.9483,
    longitude: 80.4578,
    mapMarkerLabel: 'Mirissa Beach',
    routeOrigin: 'Weligama',
    routeSummaryLine: '6.5 km • ~12 min coastal ride',
    nearbyRegionLabel: 'Southern Coast',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'weligama_tangalle',
        distanceLabel: '6.5 KM AWAY',
        title: 'Weligama Surf Bay',
        subtitle: 'Warm beginner surf swells',
        metaLabel: '12 min by Tuk-Tuk',
        metaIcon: Icons.surfing_rounded,
        imageUrl: SriLankaImages.weligama,
      ),
    ],
    priceEstimate: r'$35 / person',
    categoryLabel: 'Ocean & Whales',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Beach open 24/7 • Whale watching boats depart 6:00 AM – 6:30 AM daily',
      entryFee: r'Free Public Beach • Whale Watching Tours ~$40 – $80 USD (incl. breakfast)',
      bestSeason: 'November – April (Peak Blue Whale & calm sea window: December – March)',
      howToGetThere: '~2.5h via Southern Expressway from Colombo or scenic Coastal Train to Weligama/Mirissa',
      dressCodeAndRules: 'Beachwear on sand; cover up in town; book ethical boats keeping safe distance from whales',
      facilitiesAndSafety: 'Beachfront dining, guesthouses & ATMs; take seasickness meds prior; watch rip currents',
    ),
  );

  static const PlaceDetailData pidurangala = PlaceDetailData(
    id: 'pidurangala',
    title: 'Pidurangala Rock',
    subtitle: 'Volcanic Sunrise Lookout •',
    localScriptName: 'පිදුරංගල',
    categoryBadge: 'SCENIC HIKE',
    eraBadge: '1st Century BCE',
    loreGuideLabel: 'Summit Audio Guide (5m)',
    loreScript:
        'Standing directly north of Sigiriya, Pidurangala\'s flat granite summit offers the finest uninterrupted 360-degree view of Lion Rock emerging above morning forest mist.',
    rating: '4.9',
    ratingCaption: 'Verified Rating • 7.1k',
    locationLine: 'Central Province, Matale District, Sri Lanka',
    prestigeBadge: 'Best View of Sigiriya Rock • Ancient Cave Temple',
    description:
        'A rewarding 40-minute forest and boulder scramble passing an ancient brick reclining Buddha statue to reach a sweeping summit plateau framing Sigiriya Lion Rock at sunrise.',
    photos: [
      SriLankaImages.pidurangala,
      SriLankaImages.sigiriya,
    ],
    quickSpecs: [
      PlaceSpecItem(icon: Icons.schedule_rounded, label: 'HIKE TIME', value: '1.5 Hours'),
      PlaceSpecItem(icon: Icons.hiking_rounded, label: 'GRADE', value: 'Boulder Scramble'),
      PlaceSpecItem(icon: Icons.wb_twilight_rounded, label: 'BEST TIME', value: '5:30 AM Sunrise'),
      PlaceSpecItem(icon: Icons.eco_outlined, label: 'SETTING', value: 'Forest Temple'),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'PANORAMA',
        title: 'Lion Rock Horizon Summit',
        description:
            'Look straight across the jungle canopy at Sigiriya illuminated by early morning sunlight.',
        imageUrl: SriLankaImages.sigiriya,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.temple_buddhist_rounded,
        title: 'Reclining Brick Buddha',
        description:
            'Halfway up the climb lies a massive restored brick-and-stucco reclining Buddha beneath a prehistoric cave overhang.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '5th Century CE',
        title: 'Monks Relocated by Kashyapa',
        description:
            'When King Kashyapa fortified Sigiriya, he expanded Pidurangala Monastery as a sanctuary for the displaced monks.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.flashlight_on_rounded,
        title: 'Carry a Headlamp for Sunrise',
        description:
            'Bring a small torch for the final boulder section before dawn and wear modest clothing through the temple gate.',
      ),
    ],
    latitude: 7.9665,
    longitude: 80.7617,
    mapMarkerLabel: 'Pidurangala Summit',
    routeOrigin: 'Sigiriya',
    routeSummaryLine: '2.1 km • ~8 min via Tuk-Tuk',
    nearbyRegionLabel: 'Cultural Triangle',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'sigiriya',
        distanceLabel: '2.1 KM AWAY',
        title: 'Sigiriya Rock Fortress',
        subtitle: '5th-century Lion Rock citadel',
        metaLabel: 'UNESCO World Heritage',
        metaIcon: Icons.fort_rounded,
        imageUrl: SriLankaImages.sigiriya,
      ),
    ],
    priceEstimate: r'$4 / person',
    categoryLabel: 'Hikes & Adventure',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 5:00 AM – 6:00 PM (Best for 5:15 AM sunrise & 5:00 PM sunset hikes)',
      entryFee: r'LKR 1,000 (~$3.30 USD) per person • Cash only at temple base counter',
      bestSeason: 'January – April & July – September (Clear dawn panoramas over Lion Rock)',
      howToGetThere: '1–2 km north of Sigiriya Rock (~10 min tuk-tuk ride from Sigiriya village)',
      dressCodeAndRules: 'Cover shoulders & knees passing temple gate (sarongs rented); sneakers for boulder scramble',
      facilitiesAndSafety: 'Basic temple restrooms & kiosk at base; carry headlamp/phone torch for pre-dawn climb',
    ),
  );

  static const PlaceDetailData dambulla = PlaceDetailData(
    id: 'dambulla',
    title: 'Dambulla Cave Temple',
    subtitle: 'Golden Rock Sanctuary •',
    localScriptName: 'දඹුල්ල රජමහා විහාරය',
    categoryBadge: 'UNESCO HERITAGE',
    eraBadge: '1st Century BCE',
    loreGuideLabel: 'Sacred Caves Guide (7m)',
    loreScript:
        'Five natural rock caverns carved high on a granite whaleback hold 153 Buddha statues and 2,100 square metres of radiant Kandyan-era murals.',
    rating: '4.8',
    ratingCaption: 'Verified Rating • 8.9k',
    locationLine: 'Central Province, Matale District, Sri Lanka',
    prestigeBadge: 'UNESCO World Heritage • 2,100m² Ancient Murals',
    description:
        'Sri Lanka\'s largest and best-preserved cave-temple complex, ascending granite steps to five serene caverns filled with gilded statues, painted ceilings, and sweeping Cultural Triangle views.',
    photos: [
      SriLankaImages.dambulla,
      SriLankaImages.sigiriya,
    ],
    quickSpecs: [
      PlaceSpecItem(icon: Icons.schedule_rounded, label: 'SUGGESTED TIME', value: '1.5 – 2 Hours'),
      PlaceSpecItem(icon: Icons.temple_buddhist_rounded, label: 'CAVES', value: '5 Sanctuaries'),
      PlaceSpecItem(icon: Icons.history_edu_rounded, label: 'FOUNDED', value: '1st Century BCE'),
      PlaceSpecItem(icon: Icons.checkroom_rounded, label: 'ATTIRE', value: 'Shoulders Covered'),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'SACRED ART',
        title: 'Maharaja Vihara (Cave 2)',
        description:
            'The grandest cave houses 56 statues beneath intricate lotus ceiling frescoes and a sacred rock spring that drips upward in defiance of gravity.',
        imageUrl: SriLankaImages.dambulla,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.confirmation_number_rounded,
        title: 'Ticket Counter at Hill Base',
        description:
            'Purchase entry tickets at the lower museum desk before climbing the 160-metre granite stairway.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '89 BCE',
        title: 'King Valagamba\'s Refuge',
        description:
            'Protected here during 14 years of exile, King Valagamba transformed the caves into gilded shrines upon reclaiming Anuradhapura.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.wb_sunny_outlined,
        title: 'Cooler Morning Steps',
        description:
            'Climb before 9:30 AM or carry thick socks, as the bare stone courtyard gets warm under midday sun.',
      ),
    ],
    latitude: 7.8567,
    longitude: 80.6492,
    mapMarkerLabel: 'Dambulla Caves',
    routeOrigin: 'Dambulla Town',
    routeSummaryLine: '2.5 km • ~8 min via Tuk-Tuk',
    nearbyRegionLabel: 'Cultural Triangle',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'sigiriya',
        distanceLabel: '18 KM AWAY',
        title: 'Sigiriya Rock Fortress',
        subtitle: '5th-century Lion Rock citadel',
        metaLabel: '28 min drive',
        metaIcon: Icons.fort_rounded,
        imageUrl: SriLankaImages.sigiriya,
      ),
    ],
    priceEstimate: r'$7 / person',
    categoryLabel: 'UNESCO Heritage',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 7:00 AM – 7:00 PM (Ticket counter closes ~6:30 PM; quieter before 9:30 AM)',
      entryFee: r'LKR 3,000 (~$10 USD) Foreign Adult • Cash only at lower ticket booth',
      bestSeason: 'Year-round • Jan – Apr & Jul – Sep offer mildest climbing conditions',
      howToGetThere: '20 min bus or tuk-tuk from Sigiriya; direct highway stop between Kandy & Habarana',
      dressCodeAndRules: 'Strict temple dress code: shoulders & knees covered; remove shoes/hats on upper terrace',
      facilitiesAndSafety: 'Shoe storage (~100–200 LKR) & water stalls; carry socks for hot stone; guard snacks from monkeys',
    ),
  );

  static const PlaceDetailData arugamBay = PlaceDetailData(
    id: 'arugam_bay',
    title: 'Arugam Bay',
    subtitle: 'East Coast Surf Capital •',
    localScriptName: 'ආරුගම්බේ',
    categoryBadge: 'BEACHES',
    eraBadge: 'World Surf Mecca',
    loreGuideLabel: 'East Coast Surf Guide (5m)',
    loreScript:
        'Renowned globally for long right-hand point breaks like Main Point and Whiskey Point, Arugam Bay blends laid-back beach cabanas with rugged east-coast wildlife lagoons.',
    rating: '4.6',
    ratingCaption: 'Google Rating • 8.4k',
    locationLine: 'Ampara District, Eastern Province, Sri Lanka',
    prestigeBadge: 'Sri Lanka\'s Premier International Surf Bay • May – Oct Peak',
    description:
        'A laid-back crescent bay on Sri Lanka\'s southeastern coast famed for world-class surf point breaks, sunset lagoon safaris, and bohemian beachfront cafés.',
    photos: [
      SriLankaImages.arugamBay,
      SriLankaImages.tropicalPalmBeach,
      SriLankaImages.weligamaSurfCoast,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.surfing_rounded,
        label: 'BEST ACTIVITY',
        value: 'Point-Break Surfing',
      ),
      PlaceSpecItem(
        icon: Icons.wb_sunny_outlined,
        label: 'PEAK SEASON',
        value: 'May – October',
      ),
      PlaceSpecItem(
        icon: Icons.directions_car_rounded,
        label: 'NEARBY PARK',
        value: 'Kumana (45 mins)',
      ),
      PlaceSpecItem(
        icon: Icons.waves_rounded,
        label: 'SWELL',
        value: 'Right-Hand Point',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'SURF ICON',
        title: 'Main Point & Peanut Farm',
        description:
            'Consistent right-hand swells drawing international surfers from May through October, plus gentle inside sections for learners at Baby Point.',
        imageUrl: SriLankaImages.arugamBay,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.kayaking_rounded,
        title: 'Pottuvil Lagoon Mangrove Safari',
        description:
            'Glide past wild elephants and vibrant kingfishers along tranquil east-coast waterways at dawn.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1960s – Present',
        title: 'From Fishing Bay to Global Surf Legend',
        description:
            'Discovered by travelling surfers in the late 1960s, Arugam Bay grew into Sri Lanka\'s premier international WSL surfing destination.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.calendar_month_rounded,
        title: 'East Coast Dry Window',
        description:
            'Visit between May and September for sunny skies, glassy morning winds, and peak surf conditions.',
      ),
    ],
    latitude: 6.8589,
    longitude: 81.8304,
    mapMarkerLabel: 'Arugam Bay',
    routeOrigin: 'Ella / Yala',
    routeSummaryLine: '132 km from Ella • Scenic Eastern Descent',
    nearbyRegionLabel: 'East Coast',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'minneriya_yala',
        distanceLabel: '45 MIN DRIVE',
        title: 'Kumana & Yala Safari',
        subtitle: 'Leopards, elephants & bird lagoons',
        metaLabel: 'Wildlife Reserve',
        metaIcon: Icons.pets_rounded,
        imageUrl: SriLankaImages.kumana,
      ),
    ],
    priceEstimate: r'$15 / board rental',
    categoryLabel: 'Beaches',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Open 24 Hours (Surf schools, rentals & beach clubs operate 6:00 AM – 10:00 PM)',
      entryFee: r'Free Public Beaches • Board rental ~$10–$15 USD/day • Lagoon safari ~$25–$40 USD',
      bestSeason: 'May – October (East coast dry season & peak right-hand surf swells)',
      howToGetThere: '~6–7h drive from Colombo or ~2.5–3h scenic descent from Ella via Pottuvil',
      dressCodeAndRules: 'Relaxed surf & beach wear; assess Main Point reef breaks before paddling out',
      facilitiesAndSafety: 'Surf camps, cafes & ATMs in Pottuvil; carry reef-safe sunscreen & check seasonal currents',
    ),
  );

  static const PlaceDetailData unawatuna = PlaceDetailData(
    id: 'unawatuna',
    title: 'Unawatuna Beach',
    subtitle: 'Coral-Protected Golden Bay •',
    localScriptName: 'උණවටුන වෙරළ',
    categoryBadge: 'BEACHES',
    eraBadge: 'Coral Reef Haven',
    loreGuideLabel: 'Coastal Bay Guide (4m)',
    loreScript:
        'Sheltered by an offshore double coral reef, Unawatuna offers calm turquoise waters ideal for year-round swimming just minutes from historic Galle Fort.',
    rating: '4.5',
    ratingCaption: 'Google Rating • 11.2k',
    locationLine: 'Galle District, Southern Province, Sri Lanka',
    prestigeBadge: 'Reef-Sheltered Swimming Bay • Minutes from Galle Fort',
    description:
        'A vibrant semi-circular golden beach protected by an offshore reef, renowned for calm turquoise swimming, snorkeling near Jungle Beach, and seaside dining.',
    photos: [
      SriLankaImages.unawatuna,
      SriLankaImages.seaTurtleCoast,
      SriLankaImages.tropicalPalmBeach,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.pool_rounded,
        label: 'WATER SAFETY',
        value: 'Reef-Calm Swims',
      ),
      PlaceSpecItem(
        icon: Icons.scuba_diving_rounded,
        label: 'MARINE LIFE',
        value: 'Reefs & Turtles',
      ),
      PlaceSpecItem(
        icon: Icons.wb_sunny_outlined,
        label: 'BEST SEASON',
        value: 'Nov – April',
      ),
      PlaceSpecItem(
        icon: Icons.fort_rounded,
        label: 'NEARBY UNESCO',
        value: 'Galle Fort (6 km)',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'TURQUOISE COVE',
        title: 'Jungle Beach & Peace Pagoda Trail',
        description:
            'Walk through lush coastal forest past the Japanese Peace Pagoda to reach the secluded snorkeling cove of Jungle Beach.',
        imageUrl: SriLankaImages.unawatuna,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.beach_access_rounded,
        title: 'Safe Coral-Protected Lagoon',
        description:
            'Natural offshore coral formations break heavy ocean swells, making it one of Sri Lanka\'s safest swimming beaches.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: 'Ancient Legend',
        title: 'Rumassala & The Ramayana',
        description:
            'Local legend ties neighbouring Rumassala headland to the Ramayana epic, famous for rare medicinal plants and jungle trails.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.wb_twilight_rounded,
        title: 'Combine with Galle Fort Sunset',
        description:
            'Enjoy morning snorkeling at Unawatuna and head 15 minutes west to Galle Fort ramparts by 5:00 PM.',
      ),
    ],
    latitude: 6.0183,
    longitude: 80.2525,
    mapMarkerLabel: 'Unawatuna Beach',
    routeOrigin: 'Galle Fort',
    routeSummaryLine: '6.2 km • ~15 min coastal tuk-tuk',
    nearbyRegionLabel: 'Southern Coast',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'galle',
        distanceLabel: '6 KM AWAY',
        title: 'Galle Dutch Fort',
        subtitle: '17th-century UNESCO fortress',
        metaLabel: '15 min drive',
        metaIcon: Icons.fort_rounded,
        imageUrl: SriLankaImages.galleFort,
      ),
    ],
    priceEstimate: 'Free Public Beach',
    categoryLabel: 'Beaches',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Open 24 Hours (Dive shops & beach restaurants operate 8:00 AM – 11:00 PM)',
      entryFee: r'Free Public Beach • Snorkel gear rental ~$5–$10 USD • Sunbeds often free with order',
      bestSeason: 'November – April (Calm, crystal-clear bay sheltered by offshore coral reef)',
      howToGetThere: '15 min (6 km) tuk-tuk south of Galle Fort or ~2h via Southern Expressway from Colombo',
      dressCodeAndRules: 'Swimwear on shore; carry sarong if hiking up to Japanese Peace Pagoda or temples',
      facilitiesAndSafety: 'Reef-calm water ideal for families; restaurants, showers & dive schools along the crescent',
    ),
  );

  static const PlaceDetailData polonnaruwa = PlaceDetailData(
    id: 'polonnaruwa',
    title: 'Ancient City of Polonnaruwa',
    subtitle: 'Medieval Royal Capital •',
    localScriptName: 'පොළොන්නරුව',
    categoryBadge: 'CULTURAL HERITAGE',
    eraBadge: '12th Century UNESCO',
    loreGuideLabel: 'Royal Kingdom Lore (8m)',
    loreScript:
        'Capital of Sri Lanka\'s golden Chola and Parakramabahu era, Polonnaruwa preserves colossal granite Buddha statues at Gal Vihara alongside soaring brick palace ruins.',
    rating: '4.6',
    ratingCaption: 'Google Rating • 9.6k',
    locationLine: 'North Central Province, Sri Lanka',
    prestigeBadge: 'UNESCO World Heritage Archaeological Park • Cycling Ruins',
    description:
        'Sri Lanka\'s remarkably preserved 11th–13th century medieval royal capital featuring the Quadrangle, the circular Vatadage, Royal Palace, and the granite carvings of Gal Vihara.',
    photos: [
      SriLankaImages.polonnaruwa,
      SriLankaImages.ancientBuddhaStatue,
      SriLankaImages.sigiriyaRockAerial,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.pedal_bike_rounded,
        label: 'BEST EXPLORED',
        value: 'By Bicycle (3–4h)',
      ),
      PlaceSpecItem(
        icon: Icons.account_balance_rounded,
        label: 'ENTRY FEE',
        value: r'~$25 Foreign',
      ),
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'OPEN HOURS',
        value: '7:30 AM – 6:00 PM',
      ),
      PlaceSpecItem(
        icon: Icons.history_edu_rounded,
        label: 'GOLDEN ERA',
        value: '1153 – 1186 AD',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'ROCK SCULPTURE',
        title: 'Gal Vihara Granite Masterpieces',
        description:
            'Four monumental Buddha figures carved from a single living granite cliff face in the 12th century under King Parakramabahu I.',
        imageUrl: SriLankaImages.polonnaruwa,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.pedal_bike_rounded,
        title: 'Tree-Lined Heritage Cycling Loop',
        description:
            'Flat, shaded archaeological roads make renting a bicycle the most joyful way to explore between monuments.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1153 – 1186 AD',
        title: 'Reign of King Parakramabahu the Great',
        description:
            'Engineered the vast Parakrama Samudra reservoir ("Sea of Parakrama") and elevated Polonnaruwa into a hydraulic civilization.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.checkroom_rounded,
        title: 'Temple Dress & Footwear',
        description:
            'Carry socks for hot stone courtyards at the Quadrangle and keep shoulders and knees covered.',
      ),
    ],
    latitude: 7.9403,
    longitude: 81.0188,
    mapMarkerLabel: 'Polonnaruwa Ancient City',
    routeOrigin: 'Sigiriya',
    routeSummaryLine: '56 km • ~1 hr 15 min drive',
    nearbyRegionLabel: 'Cultural Triangle',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'minneriya_yala',
        distanceLabel: '22 KM AWAY',
        title: 'Minneriya National Park',
        subtitle: 'Wild elephant gathering tank',
        metaLabel: '30 min drive',
        metaIcon: Icons.pets_rounded,
        imageUrl: SriLankaImages.elephant,
      ),
    ],
    priceEstimate: r'$25 / person',
    categoryLabel: 'Cultural Heritage',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 7:00 AM – 5:30 PM (Ticket counters close around 5:00 PM)',
      entryFee: r'$30 USD Foreign Adult • $15 USD Children (6–12) • 50% off for SAARC nationals',
      bestSeason: 'Jan – Apr & Jul – Sep (Best cycled 7:30 – 11:00 AM before afternoon heat)',
      howToGetThere: '~55 km (1–1.5h) east of Sigiriya by car or bus; rent bicycles (~300–500 LKR) at gate',
      dressCodeAndRules: 'Modest clothing covering shoulders & knees at sacred ruins; remove shoes at stone shrines',
      facilitiesAndSafety: 'Archaeological museum, cycle rentals & drink stalls; wear thick socks on sun-heated stone',
    ),
  );

  static const PlaceDetailData udawalawe = PlaceDetailData(
    id: 'udawalawe',
    title: 'Udawalawe National Park',
    subtitle: 'Open Savannah Elephant Sanctuary •',
    localScriptName: 'උඩවලව ජාතික උද්‍යානය',
    categoryBadge: 'NATURE & WILDLIFE',
    eraBadge: 'Guaranteed Elephants',
    loreGuideLabel: 'Safari Tracker Briefing (5m)',
    loreScript:
        'Set around the shimmering Udawalawe Reservoir, wide savannah grasslands offer unobstructed views of over 600 resident Asian elephants roaming with their calves.',
    rating: '4.8',
    ratingCaption: 'Google Rating • 10.5k',
    locationLine: 'Sabaragamuwa & Uva Border, Sri Lanka',
    prestigeBadge: 'Best Park for Wild Elephant Sightings • Less Crowded Trails',
    description:
        'Renowned for open savannah landscapes and guaranteed wild elephant herds around the Udawalawe Reservoir, plus the nearby Elephant Transit Home orphanage.',
    photos: [
      SriLankaImages.udawalawe,
      SriLankaImages.wildElephants,
      SriLankaImages.elephant,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.pets_rounded,
        label: 'WILDLIFE STAR',
        value: '600+ Elephants',
      ),
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'BEST SAFARI',
        value: '6:00 AM / 3:00 PM',
      ),
      PlaceSpecItem(
        icon: Icons.landscape_rounded,
        label: 'TERRAIN',
        value: 'Open Savannah',
      ),
      PlaceSpecItem(
        icon: Icons.favorite_rounded,
        label: 'TRANSIT HOME',
        value: 'Daily Feeding Times',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'ETHICAL CONSERVATION',
        title: 'Udawalawe Elephant Transit Home',
        description:
            'Watch orphaned elephant calves receive milk feedings before eventual rewilding—strictly zero riding or direct tourist contact.',
        imageUrl: SriLankaImages.udawalawe,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.visibility_rounded,
        title: 'High Sighting Reliability Year-Round',
        description:
            'Because Udawalawe is open grassland rather than dense scrub, herds are easily spotted in every month.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1972',
        title: 'Created to Protect Displaced Wildlife',
        description:
            'Designated as a national park following construction of the Walawe Ganga reservoir to safeguard wild elephant habitats.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.wb_sunny_outlined,
        title: 'Pair Morning Safari with Transit Home',
        description:
            'Start your 3-hour jeep drive at 6:00 AM and visit the Elephant Transit Home viewing platform for the 10:30 AM feeding.',
      ),
    ],
    latitude: 6.5122,
    longitude: 80.8876,
    mapMarkerLabel: 'Udawalawe National Park',
    routeOrigin: 'Ella / Tangalle',
    routeSummaryLine: '90 km from Ella • Smooth Highway Transfer',
    nearbyRegionLabel: 'Southern Wilderness',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'weligama_tangalle',
        distanceLabel: '75 KM SOUTH',
        title: 'Tangalle Coastline',
        subtitle: 'Secluded golden beach coves',
        metaLabel: '1.5 hr drive',
        metaIcon: Icons.beach_access_rounded,
        imageUrl: SriLankaImages.tangalle,
      ),
    ],
    priceEstimate: r'$35 / person + jeep',
    categoryLabel: 'Nature & Wildlife',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 6:00 AM – 6:00 PM (Best safaris depart 6:00 AM & 2:30 PM)',
      entryFee: r'~$35–$42 USD total gate fee (incl. taxes & VAT) + private 4WD jeep hire',
      bestSeason: 'Year-round guaranteed elephant sightings • Transit Home feeds at 10:30 AM & 2:30 PM',
      howToGetThere: '~90 km (2h) south of Ella or ~3h from Colombo/Galle via Southern Expressway',
      dressCodeAndRules: 'Neutral casual wear; stay inside safari jeep; zero single-use plastics allowed in park',
      facilitiesAndSafety: 'Park restrooms & Transit Home viewing deck; carry LKR cash, binoculars & sunscreen',
    ),
  );

  static const PlaceDetailData hortonPlains = PlaceDetailData(
    id: 'horton_plains',
    title: 'Horton Plains & World\'s End',
    subtitle: '2,100m Misty Cloud Plateau •',
    localScriptName: 'හෝර්ටන් තැන්න',
    categoryBadge: 'NATURE & WILDLIFE',
    eraBadge: 'UNESCO Highland Reserve',
    loreGuideLabel: 'Highland Trail Guide (6m)',
    loreScript:
        'At over 2,100 metres altitude, Horton Plains unfolds across windswept patana grasslands and stunted cloud forest before plunging 870 metres straight down at World\'s End.',
    rating: '4.7',
    ratingCaption: 'Google Rating • 8.9k',
    locationLine: 'Nuwara Eliya District, Central Highlands, Sri Lanka',
    prestigeBadge: 'UNESCO Central Highlands • Dramatic 870m Sheer Cliff Drop',
    description:
        'A highland UNESCO plateau of misty grasslands, sambar deer, Baker\'s Falls, and the famous World\'s End escarpment dropping 870 metres toward the southern plains.',
    photos: [
      SriLankaImages.hortonPlains,
      SriLankaImages.cloudForestTrek,
      SriLankaImages.cascadeWaterfall,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.directions_walk_rounded,
        label: 'LOOP TRAIL',
        value: '9.5 km (3.5 Hours)',
      ),
      PlaceSpecItem(
        icon: Icons.terrain_rounded,
        label: 'ELEVATION',
        value: '2,100 m ASL',
      ),
      PlaceSpecItem(
        icon: Icons.wb_sunny_outlined,
        label: 'CLEAR VIEW',
        value: 'Before 9:30 AM',
      ),
      PlaceSpecItem(
        icon: Icons.thermostat_rounded,
        label: 'MORNING TEMP',
        value: '8°C – 15°C',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'SHEER PRECIPICE',
        title: 'World\'s End & Baker\'s Falls',
        description:
            'Look down 870 metres over tea valleys all the way to the distant Indian Ocean on clear dawns, then loop past roaring Baker\'s Falls.',
        imageUrl: SriLankaImages.hortonPlains,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.alarm_rounded,
        isAmber: true,
        title: 'Arrive at Gate Opening (6:00 AM)',
        description:
            'Dense highland mist rolls across World\'s End by mid-morning; entering at 6:00 AM gives the clearest panoramic vista.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '2010 UNESCO',
        title: 'Protected Central Highlands Heritage',
        description:
            'Inscribed for extraordinary endemic cloud-forest flora and watershed headstreams feeding Sri Lanka\'s major rivers.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.checkroom_rounded,
        title: 'Pack a Warm Jacket & Zero Plastics',
        description:
            'Park rangers inspect bags at entry to ban single-use plastic wrappers; bring reusable flasks and morning fleece.',
      ),
    ],
    latitude: 6.8031,
    longitude: 80.7915,
    mapMarkerLabel: 'Horton Plains National Park',
    routeOrigin: 'Nuwara Eliya / Ohiya',
    routeSummaryLine: '32 km from Nuwara Eliya • ~1 hr scenic ascent',
    nearbyRegionLabel: 'Central Highlands',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'ella_nine_arch',
        distanceLabel: 'SCENIC RAIL',
        title: 'Ohiya to Ella Train',
        subtitle: 'One of the world\'s finest rail rides',
        metaLabel: '1.5 hr train',
        metaIcon: Icons.train_rounded,
        imageUrl: SriLankaImages.nineArchBridge,
      ),
    ],
    priceEstimate: r'$30 / person',
    categoryLabel: 'Nature & Wildlife',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 6:00 AM – 6:00 PM (Enter right at 6:00 AM to see World\'s End before 9:30 AM fog)',
      entryFee: r'~$35–$45 USD total foreign gate charge (incl. taxes, service fees & vehicle levy)',
      bestSeason: 'January – March (Driest weather & clearest cliff views; avoid heavy Jun–Sep rains)',
      howToGetThere: '~1h drive (32 km) from Nuwara Eliya or tuk-tuk uphill from Ohiya Railway Station',
      dressCodeAndRules: 'Walking trail only (no jeeps inside); plastic bags & wrappers strictly confiscated at gate',
      facilitiesAndSafety: 'Visitor center & restrooms at trailhead; pack warm fleece, 2L water & sturdy hiking shoes',
    ),
  );

  static const PlaceDetailData sinharaja = PlaceDetailData(
    id: 'sinharaja',
    title: 'Sinharaja Rainforest Reserve',
    subtitle: 'UNESCO Virgin Tropical Rainforest •',
    localScriptName: 'සිංහරාජ වනාන්තරය',
    categoryBadge: 'NATURE & WILDLIFE',
    eraBadge: '1988 UNESCO Sanctuary',
    loreGuideLabel: 'Rainforest Naturalist Lore (6m)',
    loreScript:
        'Sri Lanka\'s last viable primary lowland rainforest shelters over 60% of the island\'s endemic trees and mixed-species bird flocks beneath towering emerald canopies.',
    rating: '4.8',
    ratingCaption: 'Google Rating • 5.4k',
    locationLine: 'Sabaragamuwa & Southern Borders, Sri Lanka',
    prestigeBadge: 'Biodiversity Hotspot • Endemic Birds, Frogs & Jungle Waterfalls',
    description:
        'A living prehistoric tropical rainforest and UNESCO World Heritage Reserve teeming with endemic birds, purple-faced langurs, vibrant reptiles, and crystalline jungle waterfalls.',
    photos: [
      SriLankaImages.sinharaja,
      SriLankaImages.cloudForestTrek,
      SriLankaImages.cascadeWaterfall,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.forest_rounded,
        label: 'FOREST TYPE',
        value: 'Primary Rainforest',
      ),
      PlaceSpecItem(
        icon: Icons.directions_walk_rounded,
        label: 'GUIDED TREK',
        value: '3 – 5 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.water_drop_rounded,
        label: 'HIGHLIGHT',
        value: 'Jungle Waterfalls',
      ),
      PlaceSpecItem(
        icon: Icons.verified_rounded,
        label: 'GUIDE RULE',
        value: 'Naturalist Required',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'ENDEMIC WILDLIFE',
        title: 'Mixed-Species Bird Flocks & Canopy',
        description:
            'Spot the striking Sri Lanka Blue Magpie, Green Pit Viper, and colourful tree frogs alongside expert local rainforest trackers.',
        imageUrl: SriLankaImages.sinharaja,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.hiking_rounded,
        title: 'Leech Socks Provided at Entrances',
        description:
            'Kudawa and Deniyaya gates supply canvas leech socks and certified naturalists to navigate damp jungle trails comfortably.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1988 UNESCO',
        title: 'Lion King Forest Preserved',
        description:
            'Protected from commercial logging in 1978 and inscribed by UNESCO a decade later for irreplaceable island endemism.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.wb_sunny_outlined,
        title: 'Start Trek by 7:00 AM',
        description:
            'Early morning forest walks bring peak bird activity before afternoon tropical rain showers.',
      ),
    ],
    latitude: 6.4011,
    longitude: 80.5026,
    mapMarkerLabel: 'Sinharaja Forest Reserve',
    routeOrigin: 'Galle / Ratnapura',
    routeSummaryLine: '78 km from Galle via Deniyaya Gate',
    nearbyRegionLabel: 'Wet Zone Rainforest',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'udawalawe',
        distanceLabel: '85 KM EAST',
        title: 'Udawalawe National Park',
        subtitle: 'Open-grassland elephant safaris',
        metaLabel: '2 hr drive',
        metaIcon: Icons.pets_rounded,
        imageUrl: SriLankaImages.udawalawe,
      ),
    ],
    priceEstimate: r'$15 – $25 / person',
    categoryLabel: 'Nature & Wildlife',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily, 6:00 AM – 4:30 PM (Morning treks start 6:30–8:30 AM)',
      entryFee: r'LKR 2,700–4,500 (~$10–$15 USD) gate fee • Guided packages ~$30–$40 USD',
      bestSeason: 'December – April & August – September (Relatively drier rainforest conditions)',
      howToGetThere: 'Enter via Deniyaya Gate (~2h from Galle) or Kudawa Gate (Ratnapura side)',
      dressCodeAndRules: 'Certified Forest Dept guide strictly mandatory; zero single-use plastics in UNESCO forest',
      facilitiesAndSafety: 'Leech socks available at gates; carry waterproof shell, insect repellent & LKR cash',
    ),
  );

  static const PlaceDetailData adamsPeak = PlaceDetailData(
    id: 'adams_peak',
    title: 'Adam\'s Peak (Sri Pada)',
    subtitle: '2,243m Sacred Sunrise Mountain •',
    localScriptName: 'ශ්‍රී පාදය',
    categoryBadge: 'ADVENTURE',
    eraBadge: 'Millennia Pilgrimage',
    loreGuideLabel: 'Pilgrim Ascent Lore (7m)',
    loreScript:
        'Ascending over 5,500 stone steps by starlight from Nallathanniya, pilgrims of four faiths climb together to witness sunrise cast a perfect triangular mountain shadow across the clouds.',
    rating: '4.8',
    ratingCaption: 'Google Rating • 13.1k',
    locationLine: 'Ratnapura / Nuwara Eliya Border, Sri Lanka',
    prestigeBadge: 'Iconic Night Ascent • Triangular Sunrise Shadow Phenomenon',
    description:
        'Sri Lanka\'s towering 2,243-metre conical summit sacred to Buddhists, Hindus, Christians, and Muslims, famous for its magical candle-lit night climb and dramatic dawn views.',
    photos: [
      SriLankaImages.adamsPeak,
      SriLankaImages.adamsPeakSunrisePeak,
      SriLankaImages.cloudForestTrek,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.stairs_rounded,
        label: 'ASCENT',
        value: '~5,500 Steps',
      ),
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'START TIME',
        value: '2:00 AM Climb',
      ),
      PlaceSpecItem(
        icon: Icons.wb_sunny_outlined,
        label: 'PEAK SEASON',
        value: 'Dec – May (Poya)',
      ),
      PlaceSpecItem(
        icon: Icons.terrain_rounded,
        label: 'SUMMIT',
        value: '2,243 m ASL',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'DAWN PHENOMENON',
        title: 'The Floating Triangular Shadow',
        description:
            'As the sun rises behind Sri Pada, the conical peak projects a crisp geometric pyramid shadow across the mist-blanketed valley.',
        imageUrl: SriLankaImages.adamsPeak,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.nights_stay_rounded,
        title: 'Illuminated Trail & Tea Stalls',
        description:
            'During December–May pilgrimage season, thousands of lights guide the entire path alongside welcoming warm roti & tea stalls.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: 'Ancient – Present',
        title: 'Four-Faith Sacred Mountain',
        description:
            'Chronicled by Marco Polo and Ibn Battuta, Sri Pada has drawn pilgrims for over a thousand years.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.checkroom_rounded,
        title: 'Warm Layers for Summit Dawn',
        description:
            'While climbing keeps you warm, summit temperatures drop sharply before sunrise—carry windproof layers and gloves.',
      ),
    ],
    latitude: 6.8094,
    longitude: 80.4994,
    mapMarkerLabel: 'Adam\'s Peak (Sri Pada)',
    routeOrigin: 'Hatton / Nallathanniya',
    routeSummaryLine: '32 km from Hatton Station • ~1 hr drive',
    nearbyRegionLabel: 'Peak Wilderness',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'kitulgala',
        distanceLabel: '45 KM WEST',
        title: 'Kitulgala Rafting',
        subtitle: 'Kelani River white-water rapids',
        metaLabel: '1.5 hr drive',
        metaIcon: Icons.kayaking_rounded,
        imageUrl: SriLankaImages.kitulgala,
      ),
    ],
    priceEstimate: 'Free Public Trail',
    categoryLabel: 'Adventure',
    touristGuide: PlaceTouristGuide(
      openingHours: '24/7 illuminated trail in season (Dec–May); start climb 1:00–2:00 AM for sunrise',
      entryFee: r'Free Entry (Small voluntary offerings welcome at base/summit shrines)',
      bestSeason: 'December Poya – May Vesak Poya (Clearest weather: Jan – Mar; avoid Poya weekend crowds)',
      howToGetThere: 'Scenic train to Hatton, then 1–1.5h bus or taxi to Dalhousie (Nallathanniya) trailhead',
      dressCodeAndRules: 'Modest pilgrimage wear; remove shoes at summit shrine (bring thick socks for cold stone)',
      facilitiesAndSafety: 'Tea & roti stalls lit all night in season; bring warm fleece, gloves, water & headlamp',
    ),
  );

  static const PlaceDetailData kitulgala = PlaceDetailData(
    id: 'kitulgala',
    title: 'Kitulgala White-Water Rafting',
    subtitle: 'Kelani River Adventure Capital •',
    localScriptName: 'කිතුල්ගල',
    categoryBadge: 'ADVENTURE',
    eraBadge: 'Grade 2–3 Rapids',
    loreGuideLabel: 'River Adventure Briefing (4m)',
    loreScript:
        'Carving through lush wet-zone jungle along the Kelani River—famous filming site of The Bridge on the River Kwai—Kitulgala delivers Sri Lanka\'s top white-water rafting and canyoning.',
    rating: '4.7',
    ratingCaption: 'Google Rating • 4.6k',
    locationLine: 'Kegalle District, Sabaragamuwa, Sri Lanka',
    prestigeBadge: 'Sri Lanka\'s Adrenaline Hub • Rafting, Canyoning & Cliff Jumps',
    description:
        'A vibrant rainforest river gorge along the Kelani Ganga offering 5 km Grade 2–3 white-water rafting runs, natural waterfall rock-sliding, canyoning, and confidence jumps.',
    photos: [
      SriLankaImages.kitulgala,
      SriLankaImages.cascadeWaterfall,
      SriLankaImages.cloudForestTrek,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.kayaking_rounded,
        label: 'RAPIDS',
        value: 'Grade 2 – 3 (5 km)',
      ),
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'DURATION',
        value: '2.5 – 4 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.wb_sunny_outlined,
        label: 'BEST MONTHS',
        value: 'Jan–Apr, Jul–Sep',
      ),
      PlaceSpecItem(
        icon: Icons.security_rounded,
        label: 'GEAR',
        value: 'Certified Guides',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'KELANI GANGA',
        title: '7 Named Rapids & Canyon Waterfall Slide',
        description:
            'Paddle past Virgin\'s Breast and Butter Crunch rapids before hiking into hidden rainforest streams for waterfall abseiling.',
        imageUrl: SriLankaImages.kitulgala,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.movie_rounded,
        title: 'Cinema History on the Riverbank',
        description:
            'David Lean built and exploded the iconic wooden railway bridge right along these Kelani waters in 1956.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: '1957 & Prehistory',
        title: 'Belilena Cave & Film Legacy',
        description:
            'Beyond adventure sports, Kitulgala\'s Belilena Cave yielded prehistoric human fossils dating back over 12,000 years.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.checkroom_rounded,
        title: 'Quick-Dry Swimwear & Water Shoes',
        description:
            'Wear secure strap sandals or river shoes and leave phones in waterproof drybags with your raft captain.',
      ),
    ],
    latitude: 6.9898,
    longitude: 80.4271,
    mapMarkerLabel: 'Kitulgala Rafting Base',
    routeOrigin: 'Colombo / Kandy',
    routeSummaryLine: '88 km from Colombo • 2 hr drive toward Highlands',
    nearbyRegionLabel: 'Kelani Valley',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'adams_peak',
        distanceLabel: '45 KM EAST',
        title: 'Adam\'s Peak (Sri Pada)',
        subtitle: 'Sacred highland sunrise climb',
        metaLabel: '1.5 hr drive',
        metaIcon: Icons.terrain_rounded,
        imageUrl: SriLankaImages.adamsPeak,
      ),
    ],
    priceEstimate: r'$25 – $40 / person',
    categoryLabel: 'Adventure',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daily rafting 10:00 AM – 3:00 PM (Aligned with upstream dam water releases)',
      entryFee: r'~$20–$35 USD standard 5 km rafting • ~$50–$80 USD bundled with canyoning & lunch',
      bestSeason: 'Year-round • Jan – Apr (Family-friendly flows) • May – Sep (Stronger Grade 3 rapids)',
      howToGetThere: '~2.5–3h (90 km) east of Colombo or ~1.5–2h from Kandy along A7 highway',
      dressCodeAndRules: 'Helmet & life jacket mandatory (provided); minimum age ~10–14 yrs per SLTDA safety rules',
      facilitiesAndSafety: 'Base camp showers & changing rooms; wear secure strap water sandals & quick-dry clothes',
    ),
  );

  static const PlaceDetailData knucklesRange = PlaceDetailData(
    id: 'knuckles_range',
    title: 'Knuckles Mountain Range',
    subtitle: 'Remote UNESCO Cloud-Forest Peaks •',
    localScriptName: 'දුම්බර කඳු වැටිය',
    categoryBadge: 'ADVENTURE',
    eraBadge: '2010 UNESCO Wilderness',
    loreGuideLabel: 'Mountain Trek Briefing (5m)',
    loreScript:
        'Named for peaks resembling a clenched fist, the Dumbara/Knuckles range guards untouched cloud forests, tiered waterfalls, and timeless highland villages like Meemure.',
    rating: '4.8',
    ratingCaption: 'Google Rating • 3.9k',
    locationLine: 'Matale & Kandy Districts, Central Province, Sri Lanka',
    prestigeBadge: 'Off-the-Beaten-Path Wilderness • Multi-Peak Trails & Waterfalls',
    description:
        'A rugged, mist-draped UNESCO conservation massif famed for full-day summit treks, remote village homestays in Meemure, hidden cascades, and rich endemic biodiversity.',
    photos: [
      SriLankaImages.knucklesRange,
      SriLankaImages.meemure,
      SriLankaImages.cloudForestTrek,
    ],
    quickSpecs: [
      PlaceSpecItem(
        icon: Icons.hiking_rounded,
        label: 'TRAIL GRADE',
        value: 'Moderate – Challenging',
      ),
      PlaceSpecItem(
        icon: Icons.schedule_rounded,
        label: 'TREK LENGTH',
        value: '4 – 8 Hours',
      ),
      PlaceSpecItem(
        icon: Icons.wb_sunny_outlined,
        label: 'DRY WINDOW',
        value: 'Jan–Feb, May–Sep',
      ),
      PlaceSpecItem(
        icon: Icons.landscape_rounded,
        label: 'PEAK HEIGHT',
        value: 'Up to 1,906 m',
      ),
    ],
    highlightCards: [
      PlaceHighlightCardData(
        tag: 'WILDERNESS TREK',
        title: 'Mini World\'s End & Sera Ella Falls',
        description:
            'Trek across windy patana ridges overlooking terraced rice fields before cooling off beneath cascading mountain streams.',
        imageUrl: SriLankaImages.knucklesRange,
      ),
    ],
    featureCallouts: [
      PlaceFeatureCallout(
        icon: Icons.explore_rounded,
        title: 'Certified Local Trekking Guides',
        description:
            'Because remote mist trails are unmarked, local conservation guides share safe navigation and highland spice lore.',
      ),
    ],
    historyEntries: [
      PlaceHistoryEntry(
        era: 'Ancient Dumbara',
        title: 'Kingdom\'s Mountain Fortress',
        description:
            'Historically known as Dumbara ("Misty Mountains"), these ridges sheltered Kandyan kings and ancient terraced agriculture.',
      ),
    ],
    visitTips: [
      PlaceVisitTip(
        icon: Icons.hiking_rounded,
        title: 'Grippy Trail Shoes & Light Rain Shell',
        description:
            'Mountain weather shifts quickly between sunshine and mist—pack grip footwear, 2L water, and leech socks.',
      ),
    ],
    latitude: 7.4500,
    longitude: 80.8000,
    mapMarkerLabel: 'Knuckles Mountain Range',
    routeOrigin: 'Kandy City',
    routeSummaryLine: '42 km northeast of Kandy • ~1.5 hr drive',
    nearbyRegionLabel: 'Dumbara Highlands',
    nearbyDiscoveries: [
      NearbyDiscoveryItem(
        id: 'kandy',
        distanceLabel: '42 KM SOUTHWEST',
        title: 'Kandy Sacred City',
        subtitle: 'Temple of the Tooth & lake walk',
        metaLabel: '1.5 hr drive',
        metaIcon: Icons.temple_buddhist_rounded,
        imageUrl: SriLankaImages.templeOfTheTooth,
      ),
    ],
    priceEstimate: r'$30 / guided trek',
    categoryLabel: 'Adventure',
    touristGuide: PlaceTouristGuide(
      openingHours: 'Daylight trekking 6:00 AM – 5:30 PM (Early morning departure recommended)',
      entryFee: r'Conservation permit ~LKR 2,000–3,000 (~$7–$10 USD) + local guide ~$25–$40 USD',
      bestSeason: 'January – February & May – September (Driest windows for cloud-forest ridge trails)',
      howToGetThere: '~1.5–2h (42 km) northeast of Kandy via Hunnasgiriya, Bambarella or Meemure',
      dressCodeAndRules: 'Certified local guide strongly advised for unmarked trails; strict carry-in, carry-out rule',
      facilitiesAndSafety: 'Remote wilderness with few shops; carry 2L water, leech socks, trail shoes & rain jacket',
    ),
  );

  static const Map<String, PlaceDetailData> _byId = {
    'sigiriya': sigiriya,
    'minneriya_yala': minneriyaYala,
    'ceylon_spice_trail': ceylonSpiceTrail,
    'weligama_tangalle': weligamaTangalle,
    'ella_nine_arch': ellaNineArch,
    'ella': ellaNineArch,
    'little_adams_peak': ellaNineArch,
    'kandy': kandy,
    'galle': galle,
    'mirissa': mirissa,
    'pidurangala': pidurangala,
    'dambulla': dambulla,
    'arugam_bay': arugamBay,
    'unawatuna': unawatuna,
    'polonnaruwa': polonnaruwa,
    'udawalawe': udawalawe,
    'horton_plains': hortonPlains,
    'sinharaja': sinharaja,
    'adams_peak': adamsPeak,
    'kitulgala': kitulgala,
    'knuckles_range': knucklesRange,
  };

  static List<String> _getCategoryPhotos(
    String query,
    String? fallbackCategory,
    String? fallbackImageUrl,
  ) {
    final lower = query.toLowerCase();
    final cat = (fallbackCategory ?? '').toLowerCase();

    final List<String> list = [];
    if (fallbackImageUrl != null && fallbackImageUrl.trim().isNotEmpty) {
      list.add(fallbackImageUrl);
    }

    if (cat.contains('beach') ||
        lower.contains('beach') ||
        lower.contains('bay') ||
        lower.contains('surf') ||
        lower.contains('mirissa') ||
        lower.contains('weligama') ||
        lower.contains('unawatuna') ||
        lower.contains('bentota') ||
        lower.contains('tangalle') ||
        lower.contains('nilaveli') ||
        lower.contains('hikkaduwa') ||
        lower.contains('pasikudah')) {
      list.addAll([
        SriLankaImages.tropicalPalmBeach,
        SriLankaImages.weligamaSurfCoast,
        SriLankaImages.seaTurtleCoast,
        SriLankaImages.mirissa,
      ]);
    } else if (cat.contains('wildlife') ||
        lower.contains('wildlife') ||
        lower.contains('safari') ||
        lower.contains('elephant') ||
        lower.contains('leopard') ||
        lower.contains('yala') ||
        lower.contains('minneriya') ||
        lower.contains('udawalawe') ||
        lower.contains('wilpattu') ||
        lower.contains('park')) {
      list.addAll([
        SriLankaImages.wildElephants,
        SriLankaImages.leopardSanctuary,
        SriLankaImages.elephant,
        SriLankaImages.yala,
      ]);
    } else if (cat.contains('nature') ||
        lower.contains('nature') ||
        lower.contains('waterfall') ||
        lower.contains('falls') ||
        lower.contains('hike') ||
        lower.contains('trek') ||
        lower.contains('peak') ||
        lower.contains('tea') ||
        lower.contains('nuwara eliya') ||
        lower.contains('ella') ||
        lower.contains('horton') ||
        lower.contains('knuckles') ||
        lower.contains('sinharaja') ||
        lower.contains('diyaluma')) {
      list.addAll([
        SriLankaImages.teaPlantationHills,
        SriLankaImages.cascadeWaterfall,
        SriLankaImages.ellaNineArchValley,
        SriLankaImages.cloudForestTrek,
        SriLankaImages.ceylonTeaMist,
      ]);
    } else {
      list.addAll([
        SriLankaImages.sigiriyaRockAerial,
        SriLankaImages.galleFortLighthouse,
        SriLankaImages.kandyLakePalace,
        SriLankaImages.ancientBuddhaStatue,
        SriLankaImages.sigiriyaMonolith,
      ]);
    }

    final seen = <String>{};
    return list.where((url) => seen.add(url)).take(5).toList();
  }

  static PlaceDetailData resolveByIdOrTitle(
    String query, {
    String? fallbackSubtitle,
    String? fallbackRating,
    String? fallbackImageUrl,
    String? fallbackCategory,
  }) {
    final lower = query.toLowerCase();
    if (lower.contains('minneriya') || lower.contains('yala')) {
      return minneriyaYala;
    }
    if (lower.contains('spice') || lower.contains('hopper')) {
      return ceylonSpiceTrail;
    }
    if (lower.contains('weligama') || lower.contains('tangalle')) {
      return weligamaTangalle;
    }
    if (lower.contains('arugam')) {
      return arugamBay;
    }
    if (lower.contains('unawatuna')) {
      return unawatuna;
    }
    if (lower.contains('polonnaruwa')) {
      return polonnaruwa;
    }
    if (lower.contains('udawalawe')) {
      return udawalawe;
    }
    if (lower.contains('horton') || lower.contains('world\'s end')) {
      return hortonPlains;
    }
    if (lower.contains('sinharaja')) {
      return sinharaja;
    }
    if (lower.contains('adam\'s peak') || lower.contains('sri pada')) {
      return adamsPeak;
    }
    if (lower.contains('kitulgala')) {
      return kitulgala;
    }
    if (lower.contains('knuckles')) {
      return knucklesRange;
    }
    if (lower.contains('nine arch') ||
        lower.contains('demodara') ||
        lower == 'ella' ||
        lower.contains('little adam')) {
      return ellaNineArch;
    }
    if (lower.contains('pidurangala')) {
      return pidurangala;
    }
    if (lower.contains('dambulla')) {
      return dambulla;
    }
    if (lower.contains('sigiriya')) {
      return sigiriya;
    }
    if (lower.contains('kandy')) {
      return kandy;
    }
    if (lower.contains('galle')) {
      return galle;
    }
    if (lower.contains('mirissa')) {
      return mirissa;
    }

    return _byId[lower] ??
        PlaceDetailData(
          id: lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
          title: query,
          subtitle: fallbackSubtitle ?? 'Curated Sri Lanka Discovery •',
          localScriptName: 'ශ්‍රී ලංකා',
          categoryBadge: (fallbackCategory ?? 'EXPLORE SRI LANKA').toUpperCase(),
          eraBadge: 'Island Highlight',
          loreGuideLabel: 'Local Lore Guide (5m)',
          loreScript:
              'Discover $query—one of Sri Lanka\'s cherished cultural and natural experiences curated by HELA local specialists.',
          rating: fallbackRating ?? '4.8',
          ratingCaption: 'Verified Rating • 4.2k',
          locationLine: 'Sri Lanka',
          prestigeBadge: 'HELA Curated Island Highlight',
          description: fallbackSubtitle ??
              'An authentic Sri Lankan destination featuring rich local heritage, scenic landscapes, and guided cultural immersion.',
          photos: _getCategoryPhotos(query, fallbackCategory, fallbackImageUrl),
          quickSpecs: const [
            PlaceSpecItem(
              icon: Icons.schedule_rounded,
              label: 'SUGGESTED TIME',
              value: '2 – 4 Hours',
            ),
            PlaceSpecItem(
              icon: Icons.explore_rounded,
              label: 'EXPERIENCE',
              value: 'Curated Local',
            ),
            PlaceSpecItem(
              icon: Icons.wb_sunny_outlined,
              label: 'BEST WINDOW',
              value: 'Morning / Sunset',
            ),
            PlaceSpecItem(
              icon: Icons.eco_outlined,
              label: 'SETTING',
              value: 'Scenic Sri Lanka',
            ),
          ],
          highlightCards: [
            PlaceHighlightCardData(
              tag: 'CURATED HIGHLIGHT',
              title: query,
              description: fallbackSubtitle ??
                  'Handpicked local experiences, scenic viewpoints, and authentic cultural heritage.',
              imageUrl: fallbackImageUrl ?? SriLankaImages.ella,
            ),
          ],
          featureCallouts: const [
            PlaceFeatureCallout(
              icon: Icons.verified_rounded,
              title: 'Certified Local Guides Available',
              description:
                  'Explore with SLTDA-registered chauffeurs and insider cultural storytellers.',
            ),
          ],
          historyEntries: const [
            PlaceHistoryEntry(
              era: 'Island Heritage',
              title: 'Living Sri Lankan Tradition',
              description:
                  'Part of Sri Lanka\'s centuries-old network of cultural, spiritual, and natural sanctuaries.',
            ),
          ],
          visitTips: const [
            PlaceVisitTip(
              icon: Icons.wb_sunny_outlined,
              title: 'Arrive Early',
              description:
                  'Morning hours offer the mildest tropical breeze and softest light for photography.',
            ),
          ],
          latitude: 7.8731,
          longitude: 80.7718,
          mapMarkerLabel: query,
          routeOrigin: 'Nearest Hub',
          routeSummaryLine: 'Live route available via HELA GPS',
          nearbyRegionLabel: 'Sri Lanka',
          nearbyDiscoveries: const [
            NearbyDiscoveryItem(
              id: 'sigiriya',
              distanceLabel: 'FEATURED',
              title: 'Sigiriya',
              subtitle: 'Ancient Lion Rock fortress',
              metaLabel: 'UNESCO World Heritage',
              metaIcon: Icons.fort_rounded,
              imageUrl: SriLankaImages.sigiriya,
            ),
          ],
        );
  }

  static PlaceDetailData resolveForFeaturedDestination(
    FeaturedDestinationItem item,
  ) {
    final base = resolveByIdOrTitle(
      item.title,
      fallbackSubtitle: item.subtitle,
      fallbackRating: item.rating,
      fallbackImageUrl: item.imageUrl,
      fallbackCategory: item.badge,
    );

    if (item.latitude != null && item.longitude != null) {
      return base.copyWith(
        latitude: item.latitude,
        longitude: item.longitude,
        locationLine: item.locationLine ?? base.locationLine,
        mapMarkerLabel: item.title,
      );
    }
    return base;
  }
}
