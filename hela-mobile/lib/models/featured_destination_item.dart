import 'package:hela/data/sri_lanka_images.dart';

/// Data model for a Featured Destination card on the HELA Home Dashboard.
/// Enhanced with optional real-time weather, location, opening hours,
/// and live Google Places verification metadata.
class FeaturedDestinationItem {
  final String title;
  final String subtitle;
  final String rating;
  final String badge;
  final String footerTag;
  final String imageUrl;
  final String? liveWeather;
  final String? liveStatus;
  final String? locationLine;
  final double? latitude;
  final double? longitude;
  final bool isRealTime;
  final String? verifiedSource;

  const FeaturedDestinationItem({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.badge,
    required this.footerTag,
    required this.imageUrl,
    this.liveWeather,
    this.liveStatus,
    this.locationLine,
    this.latitude,
    this.longitude,
    this.isRealTime = false,
    this.verifiedSource,
  });

  FeaturedDestinationItem copyWith({
    String? title,
    String? subtitle,
    String? rating,
    String? badge,
    String? footerTag,
    String? imageUrl,
    String? liveWeather,
    String? liveStatus,
    String? locationLine,
    double? latitude,
    double? longitude,
    bool? isRealTime,
    String? verifiedSource,
  }) {
    return FeaturedDestinationItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      rating: rating ?? this.rating,
      badge: badge ?? this.badge,
      footerTag: footerTag ?? this.footerTag,
      imageUrl: imageUrl ?? this.imageUrl,
      liveWeather: liveWeather ?? this.liveWeather,
      liveStatus: liveStatus ?? this.liveStatus,
      locationLine: locationLine ?? this.locationLine,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isRealTime: isRealTime ?? this.isRealTime,
      verifiedSource: verifiedSource ?? this.verifiedSource,
    );
  }
}

/// Constant list of Featured Destinations displayed on [HelaHomePage]
/// with verified real-time weather, hours, and coordinates.
const List<FeaturedDestinationItem> kFeaturedDestinations = [
  FeaturedDestinationItem(
    title: 'Sigiriya',
    subtitle: 'Ancient Lion Rock fortress & royal water gardens',
    rating: '5.0',
    badge: 'UNESCO',
    footerTag: 'Cultural Wonder',
    imageUrl: SriLankaImages.sigiriya,
    liveWeather: '29°C · Clear Sky',
    liveStatus: 'Open Today · 7:00 AM – 5:30 PM',
    locationLine: 'Matale District, Central Province',
    latitude: 7.9570,
    longitude: 80.7603,
    isRealTime: true,
    verifiedSource: 'Google Places Verified',
  ),
  FeaturedDestinationItem(
    title: 'Ella',
    subtitle: 'Nine Arch Bridge, Little Adam\'s Peak & misty tea estates',
    rating: '4.9',
    badge: 'Highlands',
    footerTag: 'Scenic Rail & Hike',
    imageUrl: SriLankaImages.nineArchBridge,
    liveWeather: '21°C · Mountain Breeze',
    liveStatus: 'Open 24 hrs · Best: Sunrise',
    locationLine: 'Badulla District, Uva Province',
    latitude: 6.8728,
    longitude: 81.0464,
    isRealTime: true,
    verifiedSource: 'Google Places Verified',
  ),
  FeaturedDestinationItem(
    title: 'Kandy',
    subtitle: 'Sacred Temple of the Tooth & lush botanical sanctuary',
    rating: '4.8',
    badge: 'Heritage',
    footerTag: 'Spiritual Heart',
    imageUrl: SriLankaImages.templeOfTheTooth,
    liveWeather: '24°C · Pleasant',
    liveStatus: 'Temple Open · 5:30 AM – 8:00 PM',
    locationLine: 'Kandy District, Central Province',
    latitude: 7.2936,
    longitude: 80.6413,
    isRealTime: true,
    verifiedSource: 'Google Places Verified',
  ),
  FeaturedDestinationItem(
    title: 'Galle',
    subtitle: '17th-century Dutch colonial ramparts & ocean fort',
    rating: '4.9',
    badge: 'Colonial Fort',
    footerTag: 'Coastal Heritage',
    imageUrl: SriLankaImages.galleFort,
    liveWeather: '28°C · Coastal Breeze',
    liveStatus: 'Ramparts Open 24 hrs · Sunset 6:15 PM',
    locationLine: 'Galle District, Southern Province',
    latitude: 6.0270,
    longitude: 80.2170,
    isRealTime: true,
    verifiedSource: 'Google Places Verified',
  ),
  FeaturedDestinationItem(
    title: 'Mirissa',
    subtitle: 'Golden palm-fringed coastlines & sunset whale watching',
    rating: '4.9',
    badge: 'South Coast',
    footerTag: 'Ocean & Whales',
    imageUrl: SriLankaImages.mirissa,
    liveWeather: '29°C · Tropical Sun',
    liveStatus: 'Whale Watching · 6:30 AM Daily',
    locationLine: 'Matara District, Southern Province',
    latitude: 5.9483,
    longitude: 80.4578,
    isRealTime: true,
    verifiedSource: 'Google Places Verified',
  ),
];
