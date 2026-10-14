import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_locale.dart';
import '../../venues/data/venue_repository.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedSport = 'FOOTBALL';
  String _searchQuery = '';

  final List<VenueModel> _venues = VenueRepository.venues;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final s = S(locale);

    final filteredVenues = _venues.where((v) {
      final matchesSport = v.sport == _selectedSport;
      final nameSearch = s.isAr ? v.nameAr : v.name;
      final locSearch = s.isAr ? v.locationAr : v.location;

      final matchesQuery = _searchQuery.isEmpty ||
          nameSearch.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          locSearch.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSport && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Athletic Bar: "GOOD MORNING, Taha" + Location & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: TSportColors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.flash_on,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'T-SPORT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Language switcher pill
                            InkWell(
                              onTap: () => ref
                                  .read(localeProvider.notifier)
                                  .toggleLocale(),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: TSportColors.charcoal,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          TSportColors.orange.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Text(s.isAr ? '🇱🇾' : '🇬🇧',
                                        style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      s.isAr ? 'EN' : 'العربية',
                                      style: const TextStyle(
                                        color: TSportColors.orange,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on,
                                size: 14, color: TSportColors.orange),
                            const SizedBox(width: 4),
                            Text(s.cityTripoli,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: TSportColors.charcoal,
                                shape: BoxShape.circle,
                                border: Border.all(color: TSportColors.border),
                              ),
                              child: const Icon(Icons.notifications_none,
                                  size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Greeting
                    Text(
                      s.greeting,
                      style: const TextStyle(
                          color: TSportColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.playerName,
                      style: TextStyle(
                        fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Sport Pill Selector (Orange Football / Dark Padel)
                    Row(
                      children: [
                        _buildSportPill(
                            'FOOTBALL', s.football, Icons.sports_soccer),
                        const SizedBox(width: 10),
                        _buildSportPill('PADEL', s.padel, Icons.sports_tennis),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search by neighborhood
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: TSportColors.charcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TSportColors.border),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          icon: const Icon(Icons.search,
                              color: TSportColors.textMuted, size: 20),
                          hintText: s.searchPlaceholder,
                          hintStyle: const TextStyle(
                              color: TSportColors.textDim, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby Venues Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.nearbyVenues,
                      style: TextStyle(
                        fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${filteredVenues.length} ${s.availableVenuesTag}',
                      style: const TextStyle(
                        color: TSportColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Venues List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final venue = filteredVenues[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildVenueCard(context, venue, s),
                    );
                  },
                  childCount: filteredVenues.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildSportPill(String sportKey, String displayLabel, IconData icon) {
    final isSelected = _selectedSport == sportKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSport = sportKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? TSportColors.orange : TSportColors.charcoal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? TSportColors.orange : TSportColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                displayLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context, VenueModel venue, S s) {
    final venueName = s.isAr ? venue.nameAr : venue.name;
    final venueLocation = s.isAr ? venue.locationAr : venue.location;
    final venuePitchType = s.isAr ? venue.pitchTypeAr : venue.pitchType;
    final tagText = s.isAr ? venue.discountTagAr : venue.discountTag;

    return GestureDetector(
      onTap: () => context.push('/venue/${venue.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: TSportColors.charcoal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TSportColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Tag & Heart
            Stack(
              children: [
                Image.network(
                  venue.primaryPhoto,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 170,
                    color: TSportColors.charcoal,
                    child: const Center(
                        child: Icon(Icons.sports,
                            color: TSportColors.textDim, size: 40)),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Discount / Tag Badge
                Positioned(
                  bottom: 12,
                  left: s.isAr ? null : 12,
                  right: s.isAr ? 12 : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: venue.hasDiscount
                          ? TSportColors.orange
                          : TSportColors.darkGrey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          tagText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                // Heart favorite
                Positioned(
                  top: 12,
                  right: s.isAr ? null : 12,
                  left: s.isAr ? 12 : null,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),

            // Info Body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venueName,
                    style: TextStyle(
                      fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$venuePitchType • $venueLocation',
                    style: const TextStyle(
                        color: TSportColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: TSportColors.border, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 15),
                          const SizedBox(width: 4),
                          Text(
                            '${venue.rating} (${venue.reviews})',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${venue.price} ${s.perHour}',
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: TSportColors.orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
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
  }
}
