import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/widgets/t_sport_button.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../data/venue_repository.dart';
import '../../bookings/data/booking_repository.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;

  const VenueDetailScreen({
    super.key,
    this.venueId = '1',
  });

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  int _selectedPitchIndex = 0;
  String _selectedSlot = '18:00';
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  final List<String> _times = [
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
    '00:00',
    '01:00'
  ];
  final String _scheduleDate = '2026-10-13';

  void _openGoogleMaps(double lat, double lng, String venueName) {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    try {
      launchWebUrl(url);
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TSportColors.charcoal,
        content: Text(
          '🗺️ Opening $venueName on Google Maps...',
          style: const TextStyle(
              color: TSportColors.orange, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final bookingState = ref.watch(bookingRepositoryProvider);
    final s = S(locale);
    final venue = VenueRepository.getById(widget.venueId);

    final venueName = s.isAr ? venue.nameAr : venue.name;
    final venueLocation = s.isAr ? venue.locationAr : venue.location;
    final venueAddress = s.isAr ? venue.addressAr : venue.address;
    final pitchType = s.isAr ? venue.pitchTypeAr : venue.pitchType;
    final pitchesList = s.isAr ? venue.pitchesAr : venue.pitches;
    final amenitiesList = s.isAr ? venue.amenitiesAr : venue.amenities;
    final tagText = s.isAr ? venue.discountTagAr : venue.discountTag;

    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          venueName,
          style: TextStyle(
            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border,
                color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Swipeable Venue Photo Carousel
            Stack(
              children: [
                SizedBox(
                  height: 230,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: venue.photos.length,
                    onPageChanged: (idx) =>
                        setState(() => _currentPhotoIndex = idx),
                    itemBuilder: (context, index) {
                      return Image.network(
                        venue.photos[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: TSportColors.charcoal,
                          child: const Center(
                            child: Icon(Icons.sports,
                                color: TSportColors.textDim, size: 48),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Gradient scrim
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Tag badge
                Positioned(
                  top: 14,
                  left: s.isAr ? null : 14,
                  right: s.isAr ? 14 : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: venue.hasDiscount
                          ? TSportColors.orange
                          : TSportColors.charcoal,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: venue.hasDiscount
                              ? TSportColors.orange
                              : TSportColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          venue.sport == 'PADEL'
                              ? Icons.sports_tennis
                              : Icons.sports_soccer,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tagText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),

                // Photo Indicators (Orange dots) & Counter
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          venue.photos.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPhotoIndex == dotIndex ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == dotIndex
                                  ? TSportColors.orange
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      // Photo count pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_currentPhotoIndex + 1} / ${venue.photos.length} ${s.photosGallery}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title & Pitch Specs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venueName,
                              style: TextStyle(
                                fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pitchType,
                              style: const TextStyle(
                                  color: TSportColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Rating Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: TSportColors.charcoal,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: TSportColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${venue.rating}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Pitch / Court Selection Tabs (Court 1, Court 2, Court 3) - FRONT & CENTER
                  Text(
                    s.courtSelection,
                    style: TextStyle(
                      fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(pitchesList.length, (idx) {
                      final isSelected = _selectedPitchIndex == idx;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPitchIndex = idx),
                          child: Container(
                            margin: EdgeInsets.only(
                                right: idx < pitchesList.length - 1 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TSportColors.orange
                                  : TSportColors.charcoal,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isSelected
                                      ? TSportColors.orange
                                      : TSportColors.border),
                            ),
                            child: Center(
                              child: Text(
                                pitchesList[idx],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // 4. Time Slot Matrix Header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: TSportColors.charcoal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            s.timeColumn,
                            style: TextStyle(
                              fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                              color: TSportColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...List.generate(pitchesList.length, (pIdx) {
                          final isSelected = _selectedPitchIndex == pIdx;
                          return Expanded(
                            child: Center(
                              child: Text(
                                pitchesList[pIdx].split(' ').first,
                                style: TextStyle(
                                  fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                                  color: isSelected
                                      ? TSportColors.orange
                                      : TSportColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 5. Matrix Grid Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _times.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final time = _times[index];
                      return _buildMatrixRow(time, pitchesList.length,
                          venue.price, s, bookingState, venue.id);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 6. Legend Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(
                          TSportColors.limeGreen, s.legendAvailable, s),
                      _buildLegendItem(
                          TSportColors.orange, s.legendSelected, s),
                      _buildLegendItem(TSportColors.border, s.legendBooked, s),
                      _buildLegendItem(TSportColors.amber, s.legendCashHold, s),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 7. Tripoli Location & Google Maps Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TSportColors.charcoal,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TSportColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: TSportColors.orange.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on,
                                  color: TSportColors.orange, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    venueLocation,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    venueAddress,
                                    style: const TextStyle(
                                        color: TSportColors.textMuted,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: TSportColors.border, height: 1),
                        const SizedBox(height: 10),
                        // Directions Button
                        InkWell(
                          onTap: () =>
                              _openGoogleMaps(venue.lat, venue.lng, venueName),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: TSportColors.vantablack,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: TSportColors.orange.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map_outlined,
                                    color: TSportColors.orange, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  s.openInGoogleMaps,
                                  style: TextStyle(
                                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                                    color: TSportColors.orange,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 8. Amenities Chips
                  Text(
                    s.amenitiesTitle,
                    style: TextStyle(
                      fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: amenitiesList.map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: TSportColors.charcoal,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: TSportColors.border),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(
                            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 120),
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TSportColors.charcoal,
          border: const Border(top: BorderSide(color: TSportColors.border)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.oneHourTotal,
                    style: TextStyle(
                      fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                      color: TSportColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${venue.price} ${s.isAr ? "د.ل" : "LYD"}',
                    style: TextStyle(
                      fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TSportButton(
                  label: s.viewAvailability,
                  onPressed: () {
                    try {
                      ref.read(bookingRepositoryProvider.notifier).acquireLock(
                            venueId: venue.id,
                            courtIndex: _selectedPitchIndex,
                            scheduleDate: _scheduleDate,
                            slotStart: _selectedSlot,
                            userId: 'user_player_1',
                          );
                      context.push(
                          '/checkout?venueId=${venue.id}&time=$_selectedSlot&pitch=$_selectedPitchIndex');
                    } catch (e) {
                      final isLocked = e.toString().contains('SLOT_LOCKED');
                      final isCash =
                          e.toString().contains('SLOT_BLOCKED_BY_VENUE');
                      final isBooked =
                          e.toString().contains('SLOT_ALREADY_BOOKED');
                      String msg = s.isAr
                          ? 'عذراً، هذا الوقت غير متاح'
                          : 'Selected slot is not available';
                      if (isLocked) {
                        msg = s.isAr
                            ? 'هذا الوقت محجوز مؤقتاً لمستخدم آخر'
                            : 'Slot is currently locked by another player';
                      } else if (isCash) {
                        msg = s.isAr
                            ? 'هذا الوقت محجوز نقداً بالموقع'
                            : 'This slot is held for walk-in cash';
                      } else if (isBooked) {
                        msg = s.isAr
                            ? 'هذا الوقت محجوز بالفعل'
                            : 'This slot is already booked';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: TSportColors.orange,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixRow(String time, int courtCount, int price, S s,
      BookingState bookingState, String venueId) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            time,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        ...List.generate(courtCount, (courtIdx) {
          final authoritativeStatus = bookingState.getSlotStatus(
            venueId: venueId,
            courtIndex: courtIdx,
            scheduleDate: _scheduleDate,
            slotStart: time,
          );
          final status = (_selectedSlot == time &&
                  _selectedPitchIndex == courtIdx &&
                  authoritativeStatus == 'available')
              ? 'selected'
              : authoritativeStatus;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: courtIdx > 0 ? 6.0 : 0.0),
              child: _buildSlotCell(time, courtIdx, status, price, s),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSlotCell(
      String time, int courtIdx, String status, int price, S s) {
    Color bg;
    Color text;
    String label = '';

    if (status == 'selected') {
      bg = TSportColors.orange;
      text = Colors.white;
      label = s.isAr ? '$price د.ل' : '$price LYD';
    } else if (status == 'available') {
      bg = TSportColors.limeGreen.withOpacity(0.9);
      text = Colors.black;
      label = s.statusAvailable;
    } else if (status == 'cash') {
      bg = TSportColors.amber.withOpacity(0.25);
      text = TSportColors.amber;
      label = s.statusHold;
    } else {
      bg = TSportColors.charcoal;
      text = TSportColors.textDim;
      label = s.statusBooked;
    }

    return GestureDetector(
      onTap: (status == 'available' || status == 'selected')
          ? () {
              setState(() {
                _selectedSlot = time;
                _selectedPitchIndex = courtIdx;
              });
            }
          : () {
              final msg = status == 'cash'
                  ? (s.isAr
                      ? 'هذا الوقت محجوز نقداً بالموقع'
                      : 'This slot is held for walk-in cash')
                  : (s.isAr
                      ? 'هذا الوقت محجوز بالفعل'
                      : 'This slot is already booked');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: status == 'cash' ? TSportColors.amber : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: s.isAr ? 'Cairo' : 'Outfit',
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, S s) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
            color: TSportColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
