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
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB470bfrsJ34_Zfz3mF8BpQZOUum-fhawKh51cm1K8-0n16IJnyIRDWCDo-p-4LKlIJL7eWRS6fSHiQ7Y076dniwfTg2-uSNGP-Y1fU4rUt8gQCz0RWM_EspICB8L-E9uu3ZguLz8MSZG0MZai01QaMRbw9u7NFJ6XRoYIDFwFMifvWSsy_XhyQ2UkxBFBJVs0TNFtCkUr-O7xCS0cyKCNy4TCnZZq8uzJM0M3dU9c',
  ),
  FeaturedDestinationItem(
    title: 'Ella',
    subtitle: 'Nine Arch Bridge, Little Adam\'s Peak & misty tea estates',
    rating: '4.9',
    badge: 'Highlands',
    footerTag: 'Scenic Rail & Hike',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC1-w7059r6Tx8JOuHhGLLm6spMsWw09E48ApBmOWTEe-p-IbOyd8GBmFh3Zvn60CK2ZR0YsjHx75NDRUWyT2eYsmsMBsoNsO380YPX-8NkCVlAl9L84IrpVcJskPmn7bby1SLlQNDsytKDChKgPdcmfeIa6V14oUmNsO-WDDWQZJlHl_dJvco52RzpSUA0AS2JlopPWLNhvwsNiRGcKN4YqXKlwv5GpBLlmhs9TRI',
  ),
  FeaturedDestinationItem(
    title: 'Kandy',
    subtitle: 'Sacred Temple of the Tooth & lush botanical sanctuary',
    rating: '4.8',
    badge: 'Heritage',
    footerTag: 'Spiritual Heart',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAf_ZHki056g4HPCYefzjMlcb2RDYtvjthd-ddHXXVe627O2eS1UoDIgiQ_L-HKdkLD9fKmpLz29XjJCzAX-uHg68hnR6w8d8wJJJasNuOqCFl3pVUmgcPmjQzd1eEzWMovtcNQjv5uQV-wGNks7fK8WOBUFpNVKYzvyjP0oOxlEXwSUQgjWHLC-mO86yMwUkMCo4fc0t_xHB8t1iRNYNQe3OQwojumYbhjBuANTUk',
  ),
  FeaturedDestinationItem(
    title: 'Galle',
    subtitle: '17th-century Dutch colonial ramparts & ocean fort',
    rating: '4.9',
    badge: 'Colonial Fort',
    footerTag: 'Coastal Heritage',
    imageUrl:
        'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800&auto=format&fit=crop&q=80',
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
