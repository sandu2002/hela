/// Data model for a Featured Destination card on the HELA Home Dashboard.
class FeaturedDestinationItem {
  final String title;
  final String subtitle;
  final String rating;
  final String badge;
  final String footerTag;
  final String imageUrl;

  const FeaturedDestinationItem({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.badge,
    required this.footerTag,
    required this.imageUrl,
  });
}

/// Constant list of Featured Destinations displayed on [HelaHomePage].
const List<FeaturedDestinationItem> kFeaturedDestinations = [
  FeaturedDestinationItem(
    title: 'Sigiriya',
    subtitle: 'Ancient Lion Rock fortress & royal water gardens',
    rating: '5.0',
    badge: 'UNESCO',
    footerTag: 'Cultural Wonder',
    imageUrl:
        'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
  ),
  FeaturedDestinationItem(
    title: 'Ella',
    subtitle: 'Nine Arch Bridge, Little Adam\'s Peak & misty tea estates',
    rating: '4.9',
    badge: 'Highlands',
    footerTag: 'Scenic Rail & Hike',
    imageUrl:
        'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
  ),
  FeaturedDestinationItem(
    title: 'Kandy',
    subtitle: 'Sacred Temple of the Tooth & lush botanical sanctuary',
    rating: '4.8',
    badge: 'Heritage',
    footerTag: 'Spiritual Heart',
    imageUrl:
        'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
  ),
  FeaturedDestinationItem(
    title: 'Galle',
    subtitle: '17th-century Dutch colonial ramparts & ocean fort',
    rating: '4.9',
    badge: 'Colonial Fort',
    footerTag: 'Coastal Heritage',
    imageUrl:
        'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800&auto=format&fit=crop&q=80',
  ),
  FeaturedDestinationItem(
    title: 'Mirissa',
    subtitle: 'Golden palm-fringed coastlines & sunset whale watching',
    rating: '4.9',
    badge: 'South Coast',
    footerTag: 'Ocean & Whales',
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
  ),
];
