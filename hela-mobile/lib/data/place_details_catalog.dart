import 'package:flutter/material.dart';
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
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  String get formattedCoordinates {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lonDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(4)}° $latDir, ${longitude.abs().toStringAsFixed(4)}° $lonDir';
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
      'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      ),
      PlaceHighlightCardData(
        tag: 'ANCIENT ARTISTRY',
        title: 'The Celestial Maidens (Frescoes)',
        description:
            'Painted in a high sheltered rock pocket 100 metres above ground. These ethereal 5th-century tempera masterpieces showcase graceful cloud maidens carrying delicate water lilies and cascading blossom petals.',
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      ),
      NearbyDiscoveryItem(
        id: 'dambulla',
        distanceLabel: '18 KM AWAY',
        title: 'Dambulla Cave Temple',
        subtitle: 'UNESCO Golden Rock Shrine',
        metaLabel: 'Ancient sacred caves',
        metaIcon: Icons.temple_buddhist_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$36 / person',
    categoryLabel: 'UNESCO Heritage',
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
      'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=800&auto=format&fit=crop&q=80',
      ),
      PlaceHighlightCardData(
        tag: 'APEX PREDATOR',
        title: 'Yala Leopard & Lagoon Coast',
        description:
            'Granite outcrops, coastal lagoons, and monsoon forests harbour Panthera pardus kotiya alongside mugger crocodiles, painted storks, and wild water buffalo.',
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      ),
      NearbyDiscoveryItem(
        id: 'pidurangala',
        distanceLabel: '22 KM AWAY',
        title: 'Pidurangala Rock',
        subtitle: 'Sunrise view over Sigiriya',
        metaLabel: '1.5 hr scenic climb',
        metaIcon: Icons.terrain_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$55 / person',
    categoryLabel: 'Nature & Wildlife',
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
      'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
      ),
      NearbyDiscoveryItem(
        id: 'dambulla',
        distanceLabel: '45 KM AWAY',
        title: 'Dambulla Cave Temple',
        subtitle: 'UNESCO Golden Rock Shrine',
        metaLabel: '2,000-yr murals',
        metaIcon: Icons.account_balance_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$24 / person',
    categoryLabel: 'Food & Culture',
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
      'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      ),
      PlaceHighlightCardData(
        tag: 'HIDDEN LAGOONS',
        title: 'Goyambokka & Silent Beach, Tangalle',
        description:
            'Tucked behind swaying coconut groves, Tangalle\'s coves offer calm crystal shallows, glowing sunsets, and night turtle-conservation walks at Rekawa.',
        imageUrl:
            'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      ),
      NearbyDiscoveryItem(
        id: 'galle',
        distanceLabel: '28 KM AWAY',
        title: 'Galle Dutch Fort',
        subtitle: '17th-century coastal ramparts',
        metaLabel: 'UNESCO heritage fort',
        metaIcon: Icons.fort_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$25 / person',
    categoryLabel: 'Beaches & Ocean',
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
      'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      ),
      NearbyDiscoveryItem(
        id: 'kandy',
        distanceLabel: '135 KM AWAY',
        title: 'Kandy Sacred City',
        subtitle: 'Start of the scenic tea rail',
        metaLabel: 'UNESCO hill capital',
        metaIcon: Icons.temple_buddhist_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$15 / person',
    categoryLabel: 'Hill Country',
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
      'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$20 / person',
    categoryLabel: 'Cultural Heritage',
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
      'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'Free entry',
    categoryLabel: 'Coastal Heritage',
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
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$35 / person',
    categoryLabel: 'Ocean & Whales',
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
      'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$4 / person',
    categoryLabel: 'Hikes & Adventure',
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
      'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
      ),
    ],
    priceEstimate: r'$7 / person',
    categoryLabel: 'UNESCO Heritage',
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
  };

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
          photos: [
            fallbackImageUrl ??
                'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
          ],
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
              imageUrl: fallbackImageUrl ??
                  'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
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
              imageUrl:
                  'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
            ),
          ],
        );
  }

  static PlaceDetailData resolveForFeaturedDestination(
    FeaturedDestinationItem item,
  ) {
    return resolveByIdOrTitle(
      item.title,
      fallbackSubtitle: item.subtitle,
      fallbackRating: item.rating,
      fallbackImageUrl: item.imageUrl,
      fallbackCategory: item.badge,
    );
  }
}
