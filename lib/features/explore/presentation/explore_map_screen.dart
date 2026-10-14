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
  String _selectedArea =
      'ALL'; // ALL, Ain Zara, Janzour, Hay Al-Andalus, Gargaresh, Souq Al Jumaa
  VenueModel? _selectedVenue;

  @override
  void initState() {
    super.initState();
    _selectedVenue = VenueRepository.venues.first;
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
      body: Stack(
        children: [
          // 1. Stylized Tripoli Vector Map Canvas
          Positioned.fill(
            child: _buildTripoliMapCanvas(filteredVenues, s),
          ),

          // 2. Top Header & Filter Controls
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Bar & Language Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: TSportColors.charcoal.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: TSportColors.border),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.explore,
                                color: TSportColors.orange, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              s.exploreTripoliTitle,
                              style: TextStyle(
                                fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: TSportColors.charcoal.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: TSportColors.border),
                        ),
                        child: Text(
                          '${filteredVenues.length} ${s.availableVenuesTag}',
                          style: const TextStyle(
                              color: TSportColors.limeGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Sport Filter Row (ALL, FOOTBALL, PADEL)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSportPill(
                            'ALL', s.isAr ? 'الكل' : 'ALL', Icons.sports),
                        const SizedBox(width: 8),
                        _buildSportPill(
                            'FOOTBALL', s.football, Icons.sports_soccer),
                        const SizedBox(width: 8),
                        _buildSportPill('PADEL', s.padel, Icons.sports_tennis),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Neighborhood Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAreaChip('ALL', s.allNeighborhoods),
                        const SizedBox(width: 6),
                        _buildAreaChip(
                            'Ain Zara', s.isAr ? 'عين زارة' : 'Ain Zara'),
                        const SizedBox(width: 6),
                        _buildAreaChip('Janzour', s.isAr ? 'جنزور' : 'Janzour'),
                        const SizedBox(width: 6),
                        _buildAreaChip('Hay Al-Andalus',
                            s.isAr ? 'حي الأندلس' : 'Hay Al-Andalus'),
                        const SizedBox(width: 6),
                        _buildAreaChip(
                            'Gargaresh', s.isAr ? 'قرقارش' : 'Gargaresh'),
                        const SizedBox(width: 6),
                        _buildAreaChip('Souq Al Jumaa',
                            s.isAr ? 'سوق الجمعة' : 'Souq Al Jumaa'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Bottom Venue Preview Card
          if (_selectedVenue != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: _buildVenuePreviewCard(_selectedVenue!, s),
            ),
        ],
      ),
    );
  }

  Widget _buildSportPill(String key, String label, IconData icon) {
    final isSelected = _selectedSport == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedSport = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? TSportColors.orange
              : TSportColors.charcoal.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? TSportColors.orange : TSportColors.border),
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
                  fontSize: 11),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? TSportColors.limeGreen.withOpacity(0.2)
              : TSportColors.vantablack.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
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
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildTripoliMapCanvas(List<VenueModel> venues, S s) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Bounding box for Tripoli venues
        // Lat: 32.8100 to 32.9000
        // Lng: 13.0400 to 13.2600
        const minLat = 32.8000;
        const maxLat = 32.9000;
        const minLng = 13.0400;
        const maxLng = 13.2700;

        return Stack(
          children: [
            // Dark Vector Map Background with Coastline
            CustomPaint(
              size: Size(w, h),
              painter: _TripoliMapPainter(),
            ),

            // Venue Pins on Map
            ...venues.map((venue) {
              // Convert lat/lng to screen offset
              final double normalizedX =
                  (venue.lng - minLng) / (maxLng - minLng);
              final double normalizedY =
                  1.0 - ((venue.lat - minLat) / (maxLat - minLat));

              // Map bounds inside screen with safe margins
              final double posX = (normalizedX * (w - 80)) + 20;
              final double posY = (normalizedY * (h - 260)) + 140;

              final isSelected = _selectedVenue?.id == venue.id;

              return Positioned(
                left: posX,
                top: posY,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedVenue = venue),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Price tag / Name tag bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TSportColors.orange
                                : TSportColors.charcoal,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : TSportColors.orange.withOpacity(0.7),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected
                                        ? TSportColors.orange
                                        : Colors.black)
                                    .withOpacity(0.4),
                                blurRadius: isSelected ? 12 : 4,
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
                                color: Colors.white,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${venue.price} ${s.isAr ? "د.ل" : "LYD"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Pin Icon & Pulse
                        Icon(
                          Icons.location_on,
                          color: isSelected
                              ? TSportColors.orange
                              : (venue.sport == 'PADEL'
                                  ? TSportColors.limeGreen
                                  : TSportColors.orange),
                          size: isSelected ? 32 : 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildVenuePreviewCard(VenueModel venue, S s) {
    final venueName = s.isAr ? venue.nameAr : venue.name;
    final venueLocation = s.isAr ? venue.locationAr : venue.location;

    return Container(
      decoration: BoxDecoration(
        color: TSportColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: TSportColors.orange.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Thumbnail Photo
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
                child: Image.network(
                  venue.primaryPhoto,
                  width: 100,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 100,
                    height: 96,
                    color: TSportColors.vantablack,
                    child:
                        const Icon(Icons.sports, color: TSportColors.textDim),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Venue Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TSportColors.vantablack,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  '${venue.rating}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        venueLocation,
                        style: const TextStyle(
                            color: TSportColors.textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
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
              ),
              const SizedBox(width: 12),
            ],
          ),

          // Actions Row (Directions & View Slots)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: TSportColors.vantablack,
              border: Border(top: BorderSide(color: TSportColors.border)),
            ),
            child: Row(
              children: [
                // Google Maps Directions Button
                IconButton(
                  icon: const Icon(Icons.directions,
                      color: TSportColors.orange, size: 20),
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
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        s.viewCourtAndSlots,
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
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

// Custom Painter for Tripoli Vector Map (Coastline + Major Roads + Districts)
class _TripoliMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0F1115);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Mediterranean Sea at top
    final seaPaint = Paint()..color = const Color(0xFF071926);
    final seaPath = Path();
    seaPath.moveTo(0, 0);
    seaPath.lineTo(size.width, 0);
    seaPath.lineTo(size.width, size.height * 0.28);
    // Natural coastline curve
    seaPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.22,
      0,
      size.height * 0.32,
    );
    seaPath.close();
    canvas.drawPath(seaPath, seaPaint);

    // Coastline Glow line
    final coastBorder = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final coastLine = Path();
    coastLine.moveTo(0, size.height * 0.32);
    coastLine.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.22,
      size.width,
      size.height * 0.28,
    );
    canvas.drawPath(coastLine, coastBorder);

    // Roads (Coastal Road, Ring Road Highway 20, Airport Road)
    final mainRoad = Paint()
      ..color = const Color(0xFF22262E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Coastal Road (Gargaresh - Janzour)
    final coastalRoadPath = Path();
    coastalRoadPath.moveTo(0, size.height * 0.38);
    coastalRoadPath.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.30,
      size.width,
      size.height * 0.35,
    );
    canvas.drawPath(coastalRoadPath, mainRoad);

    // Highway 20 (Ring Road / طريق السريع)
    final ringRoadPath = Path();
    ringRoadPath.moveTo(0, size.height * 0.55);
    ringRoadPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.48,
      size.width,
      size.height * 0.52,
    );
    canvas.drawPath(ringRoadPath, mainRoad);

    // Airport Road (Ain Zara artery)
    final airportRoad = Paint()
      ..color = const Color(0xFF1D222A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final airportRoadPath = Path();
    airportRoadPath.moveTo(size.width * 0.70, size.height * 0.33);
    airportRoadPath.lineTo(size.width * 0.62, size.height);
    canvas.drawPath(airportRoadPath, airportRoad);

    // Neighborhood District Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawDistrict(String name, double x, double y) {
      textPainter.text = TextSpan(
        text: name,
        style: const TextStyle(
          color: Color(0xFF38404E),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }

    drawDistrict('JANZOUR', size.width * 0.08, size.height * 0.44);
    drawDistrict('GARGARESH', size.width * 0.25, size.height * 0.36);
    drawDistrict('HAY AL-ANDALUS', size.width * 0.40, size.height * 0.32);
    drawDistrict('SOUQ AL JUMAA', size.width * 0.72, size.height * 0.36);
    drawDistrict('AIN ZARA', size.width * 0.65, size.height * 0.68);
    drawDistrict('MEDITERRANEAN SEA', size.width * 0.30, size.height * 0.12);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
