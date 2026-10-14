import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../venues/data/venue_repository.dart';

class ExploreMapScreen extends ConsumerStatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  String _selectedSport = 'ALL'; // ALL, FOOTBALL, PADEL
  String _selectedArea = 'ALL'; // ALL, Ain Zara, Janzour, Hay Al-Andalus, Gargaresh, Souq Al Jumaa
  bool _isMapView = true; // Toggle between Map and List
  VenueModel? _selectedVenue;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _selectedVenue = VenueRepository.venues.first;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _openGoogleMaps(VenueModel venue) {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${venue.lat},${venue.lng}';
    try {
      launchWebUrl(url);
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TSportColors.charcoal,
        content: Text(
          '🗺️ Opening ${venue.name} on Google Maps...',
          style: const TextStyle(
              color: TSportColors.orange, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final s = S(locale);

    final filteredVenues = VenueRepository.venues.where((v) {
      final matchesSport = _selectedSport == 'ALL' || v.sport == _selectedSport;
      final matchesArea = _selectedArea == 'ALL' ||
          v.location.contains(_selectedArea) ||
          v.locationAr.contains(_selectedArea);
      return matchesSport && matchesArea;
    }).toList();

    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Controls (Title, View Switcher, Filter Bars)
            _buildTopControls(filteredVenues, s),

            // Content: Interactive Map OR List View
            Expanded(
              child: _isMapView
                  ? _buildMapContent(filteredVenues, s)
                  : _buildListContent(filteredVenues, s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(List<VenueModel> filteredVenues, S s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: TSportColors.vantablack,
        border: const Border(
          bottom: BorderSide(color: TSportColors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Title & View Switcher (Map vs List)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TSportColors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.explore,
                        color: TSportColors.orange, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.exploreTripoliTitle,
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${filteredVenues.length} ${s.availableVenuesTag}',
                        style: const TextStyle(
                          color: TSportColors.limeGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Segmented Toggle: [ Map | List ]
              Container(
                decoration: BoxDecoration(
                  color: TSportColors.charcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TSportColors.border),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildViewToggleButton(
                      icon: Icons.map,
                      label: s.isAr ? 'خريطة' : 'Map',
                      isSelected: _isMapView,
                      onTap: () => setState(() => _isMapView = true),
                    ),
                    _buildViewToggleButton(
                      icon: Icons.format_list_bulleted,
                      label: s.isAr ? 'قائمة' : 'List',
                      isSelected: !_isMapView,
                      onTap: () => setState(() => _isMapView = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Sport Selector Pills (ALL, FOOTBALL, PADEL)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSportPill('ALL', s.isAr ? 'الكل' : 'All Sports', Icons.sports),
                const SizedBox(width: 8),
                _buildSportPill('FOOTBALL', s.football, Icons.sports_soccer),
                const SizedBox(width: 8),
                _buildSportPill('PADEL', s.padel, Icons.sports_tennis),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Row 3: Neighborhood Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAreaChip('ALL', s.allNeighborhoods),
                const SizedBox(width: 6),
                _buildAreaChip('Ain Zara', s.isAr ? 'عين زارة' : 'Ain Zara'),
                const SizedBox(width: 6),
                _buildAreaChip('Janzour', s.isAr ? 'جنزور' : 'Janzour'),
                const SizedBox(width: 6),
                _buildAreaChip('Hay Al-Andalus', s.isAr ? 'حي الأندلس' : 'Hay Al-Andalus'),
                const SizedBox(width: 6),
                _buildAreaChip('Gargaresh', s.isAr ? 'قرقارش' : 'Gargaresh'),
                const SizedBox(width: 6),
                _buildAreaChip('Souq Al Jumaa', s.isAr ? 'سوق الجمعة' : 'Souq Al Jumaa'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? TSportColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : TSportColors.textDim),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : TSportColors.textDim,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportPill(String key, String label, IconData icon) {
    final isSelected = _selectedSport == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedSport = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? TSportColors.orange : TSportColors.charcoal,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TSportColors.orange : TSportColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaChip(String key, String label) {
    final isSelected = _selectedArea == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedArea = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? TSportColors.limeGreen.withOpacity(0.18)
              : TSportColors.charcoal.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? TSportColors.limeGreen : TSportColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? TSportColors.limeGreen : TSportColors.textMuted,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // --- MAP CONTENT (Interactive, Zoomable, Fully Padded) ---
  Widget _buildMapContent(List<VenueModel> venues, S s) {
    return Stack(
      children: [
        // Interactive Zoomable Map Canvas
        InteractiveViewer(
          transformationController: _transformController,
          boundaryMargin: const EdgeInsets.all(80),
          minScale: 0.8,
          maxScale: 2.5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              // Lat: 32.8000 to 32.9000
              // Lng: 13.0400 to 13.2700
              const minLat = 32.8000;
              const maxLat = 32.9000;
              const minLng = 13.0400;
              const maxLng = 13.2700;

              return SizedBox(
                width: w,
                height: h,
                child: Stack(
                  children: [
                    // Tripoli Canvas Grid & Geography
                    CustomPaint(
                      size: Size(w, h),
                      painter: _TripoliDetailedMapPainter(),
                    ),

                    // Map Pins
                    ...venues.map((venue) {
                      final double normX =
                          (venue.lng - minLng) / (maxLng - minLng);
                      final double normY =
                          1.0 - ((venue.lat - minLat) / (maxLat - minLat));

                      // Distribute pins across the viewport with safe margins
                      final double posX = (normX * (w - 120)) + 30;
                      final double posY = (normY * (h - 220)) + 30;

                      final isSelected = _selectedVenue?.id == venue.id;

                      return Positioned(
                        left: posX,
                        top: posY,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedVenue = venue);
                          },
                          child: AnimatedScale(
                            scale: isSelected ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Price Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? TSportColors.orange
                                        : TSportColors.charcoal,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : (venue.sport == 'PADEL'
                                              ? TSportColors.limeGreen
                                              : TSportColors.orange),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.6),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        venue.sport == 'PADEL'
                                            ? Icons.sports_tennis
                                            : Icons.sports_soccer,
                                        color: isSelected
                                            ? Colors.white
                                            : (venue.sport == 'PADEL'
                                                ? TSportColors.limeGreen
                                                : TSportColors.orange),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${venue.price} ${s.isAr ? "د.ل" : "LYD"}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Marker Pin
                                Icon(
                                  Icons.location_on,
                                  color: isSelected
                                      ? TSportColors.orange
                                      : (venue.sport == 'PADEL'
                                          ? TSportColors.limeGreen
                                          : TSportColors.orange),
                                  size: isSelected ? 34 : 26,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),

        // Hint: Pinch to Zoom
        Positioned(
          top: 12,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TSportColors.charcoal.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TSportColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pinch, size: 14, color: TSportColors.textDim),
                const SizedBox(width: 4),
                Text(
                  s.isAr ? 'اسحب للتكبير والتنقل' : 'Pinch to zoom & pan',
                  style: const TextStyle(color: TSportColors.textDim, fontSize: 10),
                ),
              ],
            ),
          ),
        ),

        // Floating Bottom Preview Card (Anchored gracefully above bottom nav)
        if (_selectedVenue != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildVenuePreviewCard(_selectedVenue!, s),
          ),
      ],
    );
  }

  // --- LIST CONTENT (Clean, High-Res Scrollable Cards) ---
  Widget _buildListContent(List<VenueModel> venues, S s) {
    if (venues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: TSportColors.textDim),
            const SizedBox(height: 12),
            Text(
              s.isAr ? 'لا توجد ملاعب مطابقة' : 'No venues found',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        final venueName = s.isAr ? venue.nameAr : venue.name;
        final venueLocation = s.isAr ? venue.locationAr : venue.location;
        final venuePitchType = s.isAr ? venue.pitchTypeAr : venue.pitchType;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: TSportColors.charcoal,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TSportColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/venue/${venue.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue Image with Tags
                Stack(
                  children: [
                    Image.network(
                      venue.primaryPhoto,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 160,
                        color: TSportColors.vantablack,
                        child: const Center(
                          child: Icon(Icons.sports, color: TSportColors.textDim, size: 36),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Sport Tag (Top Left)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: venue.sport == 'PADEL'
                              ? TSportColors.limeGreen
                              : TSportColors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          venue.sport == 'PADEL' ? s.padel : s.football,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    // Rating Tag (Top Right)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${venue.rating} (${venue.reviews})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Price on Bottom of Photo
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: TSportColors.vantablack.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: TSportColors.orange),
                        ),
                        child: Text(
                          '${venue.price} ${s.perHour}',
                          style: const TextStyle(
                            color: TSportColors.orange,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Card Body
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName,
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: TSportColors.textDim, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            venueLocation,
                            style: const TextStyle(
                              color: TSportColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            venuePitchType,
                            style: const TextStyle(
                              color: TSportColors.limeGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _openGoogleMaps(venue),
                            icon: const Icon(Icons.directions, size: 16, color: TSportColors.orange),
                            label: Text(
                              s.openInGoogleMaps,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: TSportColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.push('/venue/${venue.id}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TSportColors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                s.viewCourtAndSlots,
                                style: TextStyle(
                                  fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- FLOATING PREVIEW CARD (COMPACT & ROBUST) ---
  Widget _buildVenuePreviewCard(VenueModel venue, S s) {
    final venueName = s.isAr ? venue.nameAr : venue.name;
    final venueLocation = s.isAr ? venue.locationAr : venue.location;

    return Container(
      decoration: BoxDecoration(
        color: TSportColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TSportColors.orange.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    venue.primaryPhoto,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 75,
                      height: 75,
                      color: TSportColors.vantablack,
                      child: const Icon(Icons.sports, color: TSportColors.textDim),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              venueName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '${venue.rating}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        venueLocation,
                        style: const TextStyle(
                          color: TSportColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${venue.price} ${s.perHour}',
                        style: const TextStyle(
                          color: TSportColors.orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: TSportColors.vantablack,
              border: Border(top: BorderSide(color: TSportColors.border)),
            ),
            child: Row(
              children: [
                // Directions Button
                IconButton(
                  icon: const Icon(Icons.directions, color: TSportColors.orange, size: 20),
                  onPressed: () => _openGoogleMaps(venue),
                  tooltip: s.openInGoogleMaps,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => context.push('/venue/${venue.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TSportColors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        s.viewCourtAndSlots,
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Tripoli Detailed Dark Map
class _TripoliDetailedMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Land Background
    final landPaint = Paint()..color = const Color(0xFF11141A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    // 2. Subtle Map Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1F29).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Mediterranean Sea (Top Coastline)
    final seaPaint = Paint()..color = const Color(0xFF091624);
    final seaPath = Path();
    seaPath.moveTo(0, 0);
    seaPath.lineTo(size.width, 0);
    seaPath.lineTo(size.width, size.height * 0.22);
    // Smooth coastline
    seaPath.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.16,
      0,
      size.height * 0.24,
    );
    seaPath.close();
    canvas.drawPath(seaPath, seaPaint);

    // Coastline Border Glow
    final coastBorder = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final coastLine = Path();
    coastLine.moveTo(0, size.height * 0.24);
    coastLine.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.16,
      size.width,
      size.height * 0.22,
    );
    canvas.drawPath(coastLine, coastBorder);

    // 4. Primary Arteries (Highways & Main Roads)
    final highwayPaint = Paint()
      ..color = const Color(0xFF262D3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFF1C222D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Coastal Highway (Janzour -> Gargaresh -> City Center)
    final coastalPath = Path();
    coastalPath.moveTo(0, size.height * 0.32);
    coastalPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.24,
      size.width,
      size.height * 0.28,
    );
    canvas.drawPath(coastalPath, highwayPaint);

    // Highway 20 / Ring Road (طريق السريع)
    final ringRoadPath = Path();
    ringRoadPath.moveTo(0, size.height * 0.50);
    ringRoadPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.44,
      size.width,
      size.height * 0.46,
    );
    canvas.drawPath(ringRoadPath, highwayPaint);

    // Airport Road Artery
    final airportPath = Path();
    airportPath.moveTo(size.width * 0.65, size.height * 0.26);
    airportPath.lineTo(size.width * 0.58, size.height);
    canvas.drawPath(airportPath, secondaryRoadPaint);

    // Janzour Crossroad
    final janzourPath = Path();
    janzourPath.moveTo(size.width * 0.18, size.height * 0.30);
    janzourPath.lineTo(size.width * 0.25, size.height);
    canvas.drawPath(janzourPath, secondaryRoadPaint);

    // 5. Neighborhood District Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawDistrict(String name, double x, double y) {
      textPainter.text = TextSpan(
        text: name,
        style: const TextStyle(
          color: Color(0xFF4A5568),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }

    drawDistrict('🌊 MEDITERRANEAN SEA', size.width * 0.28, size.height * 0.08);
    drawDistrict('JANZOUR', size.width * 0.08, size.height * 0.38);
    drawDistrict('GARGARESH', size.width * 0.30, size.height * 0.30);
    drawDistrict('HAY AL-ANDALUS', size.width * 0.45, size.height * 0.26);
    drawDistrict('SOUQ AL JUMAA', size.width * 0.72, size.height * 0.32);
    drawDistrict('AIN ZARA', size.width * 0.64, size.height * 0.62);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
