class VenueModel {
  final String id;
  final String name;
  final String nameAr;
  final String location;
  final String locationAr;
  final String address;
  final String addressAr;
  final String sport; // 'FOOTBALL' or 'PADEL'
  final int price;
  final double rating;
  final int reviews;
  final String pitchType;
  final String pitchTypeAr;
  final bool hasDiscount;
  final String discountTag;
  final String discountTagAr;
  final double lat;
  final double lng;
  final List<String> photos;
  final List<String> pitches;
  final List<String> pitchesAr;
  final List<String> amenities;
  final List<String> amenitiesAr;

  const VenueModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.location,
    required this.locationAr,
    required this.address,
    required this.addressAr,
    required this.sport,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.pitchType,
    required this.pitchTypeAr,
    required this.hasDiscount,
    required this.discountTag,
    required this.discountTagAr,
    required this.lat,
    required this.lng,
    required this.photos,
    required this.pitches,
    required this.pitchesAr,
    required this.amenities,
    required this.amenitiesAr,
  });

  String get primaryPhoto => photos.isNotEmpty ? photos.first : '';
}

class VenueRepository {
  static final List<VenueModel> venues = [
    const VenueModel(
      id: '1',
      name: 'AL-NASR FOOTBALL CENTER',
      nameAr: 'مركز النصر لكرة القدم',
      location: 'Ain Zara • 1.2 km',
      locationAr: 'عين زارة • 1.2 كم',
      address: 'Ain Zara, Near Airport Road, Tripoli',
      addressAr: 'عين زارة، بالقرب من طريق المطار، طرابلس',
      sport: 'FOOTBALL',
      price: 70,
      rating: 4.8,
      reviews: 94,
      pitchType: '5-a-Side & 7-a-Side • Outdoor Turf',
      pitchTypeAr: 'خماسي وسباعي • عشب صناعي خارجي',
      hasDiscount: true,
      discountTag: '15% OFF TODAY',
      discountTagAr: 'خصم 15% اليوم',
      lat: 32.8450,
      lng: 13.2350,
      photos: [
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1551958219-acbc608c6377?auto=format&fit=crop&w=800&q=80',
      ],
      pitches: ['Pitch 1 (5v5)', 'Pitch 2 (5v5)', 'Pitch 3 (7v7)'],
      pitchesAr: ['ملعب 1 (خماسي)', 'ملعب 2 (خماسي)', 'ملعب 3 (سباعي)'],
      amenities: [
        '💡 Night Floodlights',
        '🚿 Changing Rooms',
        '🅿️ Free Parking',
        '☕ Cafeteria',
        '🦺 Match Bibs'
      ],
      amenitiesAr: [
        '💡 إضاءة ليلية',
        '🚿 غرف تبديل ودش',
        '🅿️ موقف سيارات مجاني',
        '☕ كافتيريا ومشروبات',
        '🦺 سترات المباراة'
      ],
    ),
    const VenueModel(
      id: '2',
      name: 'TRIPOLI PADEL CLUB',
      nameAr: 'نادي طرابلس للبادل',
      location: 'Janzour • 2.8 km',
      locationAr: 'جنزور • 2.8 كم',
      address: 'Janzour Coastal Road, Near Palm City, Tripoli',
      addressAr: 'طريق الشاطئ جنزور، بالقرب من بالم سيتي، طرابلس',
      sport: 'PADEL',
      price: 85,
      rating: 4.9,
      reviews: 128,
      pitchType: 'Panoramic Glass Courts • WPT Mondo Turf',
      pitchTypeAr: 'ملاعب زجاجية بانورامية • أرضية موندو',
      hasDiscount: false,
      discountTag: 'POPULAR',
      discountTagAr: 'شائع',
      lat: 32.8180,
      lng: 13.0640,
      photos: [
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=800&q=80',
      ],
      pitches: [
        'Court 1 (Panoramic)',
        'Court 2 (Center Court)',
        'Court 3 (Outdoor)'
      ],
      pitchesAr: ['ملعب 1 (بانورامي)', 'ملعب 2 (الرئيسي)', 'ملعب 3 (خارجي)'],
      amenities: [
        '🎾 Racket Rental',
        '💡 LED Competition Lights',
        '❄️ AC Player Lounge',
        '🅿️ Valet & Parking',
        '☕ Specialty Coffee'
      ],
      amenitiesAr: [
        '🎾 تأجير مضارب وكرات',
        '💡 إضاءة LED دولية',
        '❄️ صالة مكيفة للاعبين',
        '🅿️ موقف سيارات واسع',
        '☕ قهوة مختصة'
      ],
    ),
    const VenueModel(
      id: '4',
      name: 'ELITE PADEL ARENA',
      nameAr: 'أرينا إيليت للبادل',
      location: 'Hay Al-Andalus • 3.4 km',
      locationAr: 'حي الأندلس • 3.4 كم',
      address: 'Hay Al-Andalus Diplomatic Area, Tripoli',
      addressAr: 'حي الأندلس، المنطقة الدبلوماسية، طرابلس',
      sport: 'PADEL',
      price: 90,
      rating: 5.0,
      reviews: 86,
      pitchType: 'Indoor Air-Conditioned Glass Courts',
      pitchTypeAr: 'ملاعب داخلية زجاجية مكيفة بالكامل',
      hasDiscount: true,
      discountTag: 'PREMIUM',
      discountTagAr: 'مميز',
      lat: 32.8800,
      lng: 13.1300,
      photos: [
        'https://images.unsplash.com/photo-1622163642998-1ea32b0bbc67?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80',
      ],
      pitches: [
        'Arena 1 (Indoor AC)',
        'Arena 2 (Indoor AC)',
        'Arena 3 (VIP Center)'
      ],
      pitchesAr: [
        'ملعب 1 (مكيف داخلي)',
        'ملعب 2 (مكيف داخلي)',
        'ملعب 3 (VIP مركزي)'
      ],
      amenities: [
        '❄️ 100% Indoor Climate Control',
        '🎾 Bullpadel Pro Gear',
        '🚿 Luxury Showers',
        '🅿️ Covered Parking'
      ],
      amenitiesAr: [
        '❄️ تكييف مركزي متكامل',
        '🎾 معدات Bullpadel احترافية',
        '🚿 غرف استحمام فندقية',
        '🅿️ موقف مظلل'
      ],
    ),
    const VenueModel(
      id: '5',
      name: 'AL-SHATTA PADEL COURTS',
      nameAr: 'ملاعب الشط للبادل',
      location: 'Gargaresh • 4.1 km',
      locationAr: 'قرقارش • 4.1 كم',
      address: 'Gargaresh Seaside Road, Tripoli',
      addressAr: 'طريق الشط قرقارش، طرابلس',
      sport: 'PADEL',
      price: 80,
      rating: 4.8,
      reviews: 64,
      pitchType: 'Outdoor Sea-Breeze Glass Courts',
      pitchTypeAr: 'ملاعب زجاجية بإطلالة بحرية',
      hasDiscount: false,
      discountTag: 'POPULAR',
      discountTagAr: 'شائع',
      lat: 32.8680,
      lng: 13.1150,
      photos: [
        'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?auto=format&fit=crop&w=800&q=80',
      ],
      pitches: ['Sea Court 1', 'Sea Court 2', 'Glass Court 3'],
      pitchesAr: ['ملعب الشاطئ 1', 'ملعب الشاطئ 2', 'ملعب زجاجي 3'],
      amenities: [
        '🌊 Sea Breeze Atmosphere',
        '💡 High Mast Lights',
        '🎾 Ball & Racket Hire',
        '🥤 Fresh Juice Bar'
      ],
      amenitiesAr: [
        '🌊 إطلالة نسيم البحر',
        '💡 إضاءة ليلية عالية',
        '🎾 تأجير مضارب وكرات',
        '🥤 بوفيه عصائر طازجة'
      ],
    ),
    const VenueModel(
      id: '3',
      name: 'GREEN FIELD SPORTS',
      nameAr: 'ملاعب الحقل الأخضر',
      location: 'Souq Al Jumaa • 3.1 km',
      locationAr: 'سوق الجمعة • 3.1 كم',
      address: 'Souq Al Jumaa, Highway 20, Tripoli',
      addressAr: 'سوق الجمعة، طريق السريع، طرابلس',
      sport: 'FOOTBALL',
      price: 60,
      rating: 4.6,
      reviews: 52,
      pitchType: '7-a-Side • FIFA Quality Pro Turf',
      pitchTypeAr: 'سباعي • عشب صناعي معتمد من الفيفا',
      hasDiscount: false,
      discountTag: 'POPULAR',
      discountTagAr: 'شائع',
      lat: 32.8750,
      lng: 13.2400,
      photos: [
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?auto=format&fit=crop&w=800&q=80',
      ],
      pitches: ['Pitch A (7v7)', 'Pitch B (7v7)', 'Pitch C (5v5)'],
      pitchesAr: ['ملعب أ (سباعي)', 'ملعب ب (سباعي)', 'ملعب ج (خماسي)'],
      amenities: [
        '⚽ FIFA Quality Turf',
        '💡 Floodlights',
        '🅿️ Large Parking Area',
        '☕ Sports Cafe'
      ],
      amenitiesAr: [
        '⚽ عشب معتمد دولياً',
        '💡 إضاءة كاشفة',
        '🅿️ ساحة مواقف كبيرة',
        '☕ مقهى رياضي'
      ],
    ),
  ];

  static VenueModel getById(String id) {
    return venues.firstWhere(
      (v) => v.id == id,
      orElse: () => venues.first,
    );
  }
}
