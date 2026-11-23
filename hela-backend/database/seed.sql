-- ============================================================================
-- HELA Backend Seed Data (Sri Lanka Tourism Attractions & Stays)
-- ============================================================================

-- Seed Curated Sri Lanka Destinations
INSERT INTO public.destinations (
    source_id, name, description, region, latitude, longitude, categories, image_url, entrance_fee_usd, rating, relevance_score
) VALUES
(
    'sigiriya-01',
    'Sigiriya Rock Fortress',
    'Ancient palace and fortress complex featuring breathtaking 5th-century frescoes and landscaped water gardens atop a sheer 200m granite peak.',
    'Matale / Central Province',
    7.9570, 80.7603,
    ARRAY['Culture', 'Archaeology', 'Hiking', 'Photography'],
    'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800',
    30.00, 4.9, 0.98
),
(
    'ella-nine-arch-02',
    'Nine Arch Bridge, Ella',
    'Iconic colonial viaduct bridge surrounded by misty tea plantations and verdant hills in the scenic mountain village of Ella.',
    'Badulla / Uva Province',
    6.8768, 81.0608,
    ARRAY['Nature', 'Photography', 'Trekking', 'Relaxation'],
    'https://images.unsplash.com/photo-1546708973-b339540b5162?w=800',
    0.00, 4.8, 0.95
),
(
    'kandy-temple-03',
    'Temple of the Sacred Tooth Relic',
    'Sri Lanka’s most revered Buddhist shrine housing the sacred tooth relic of the Buddha located in the royal palace complex of Kandy.',
    'Kandy / Central Province',
    7.2936, 80.6413,
    ARRAY['Culture', 'Religious', 'Photography'],
    'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800',
    15.00, 4.8, 0.93
),
(
    'galle-fort-04',
    'Galle Dutch Fort',
    'UNESCO World Heritage 17th-century rampart fortress where European colonial architecture blends with South Asian traditions by the ocean.',
    'Galle / Southern Province',
    6.0328, 80.2170,
    ARRAY['Culture', 'History', 'Beaches', 'Romantic'],
    'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800',
    0.00, 4.7, 0.94
),
(
    'yala-safari-05',
    'Yala National Park',
    'World-renowned wildlife sanctuary with the highest density of leopards in the world, plus wild elephants, sloth bears, and crocodiles.',
    'Hambantota / Southern Province',
    6.3725, 81.5173,
    ARRAY['Wildlife', 'Adventure', 'Photography', 'Nature'],
    'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800',
    40.00, 4.9, 0.96
),
(
    'mirissa-beach-06',
    'Mirissa Coconut Tree Hill & Bay',
    'Picturesque palm-fringed dome cliff overlooking the turquoise Indian Ocean, celebrated for surfing, whale watching, and sunsets.',
    'Matara / Southern Province',
    5.9482, 80.4594,
    ARRAY['Beaches', 'Photography', 'Romantic', 'Relaxation'],
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    0.00, 4.7, 0.91
)
ON CONFLICT (source_id) DO NOTHING;

-- Seed Haven Stays & Accommodations
INSERT INTO public.haven_stays (
    title, location, category, price, price_per_night_usd, rating, badge_text, image_url, filter_category, amenities
) VALUES
(
    'Heritance Kandalama',
    'Dambulla / Sigiriya',
    'Eco-Luxury Resort',
    '\$180 / night',
    180.00, 4.9, 'Top Rated',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
    'Resort',
    ARRAY['Infinity Pool', 'Spa', 'Jungle View', 'Free Breakfast', 'Wi-Fi']
),
(
    '98 Acres Resort & Spa',
    'Ella',
    'Mountain Chalet',
    '\$220 / night',
    220.00, 4.9, 'Scenic View',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
    'Chalet',
    ARRAY['Tea Plantation View', 'Helipad', 'Ayurvedic Spa', 'Restaurant']
),
(
    'The Fort Printers',
    'Galle Fort',
    'Heritage Boutique Hotel',
    '\$140 / night',
    140.00, 4.7, 'Historic',
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
    'Hotel',
    ARRAY['Private Dining', 'Historic Architecture', 'Beach Access Nearby']
)
ON CONFLICT DO NOTHING;
