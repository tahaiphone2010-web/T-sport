import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_locale.dart';
import '../data/booking_repository.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  bool _isUpcoming = true;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final bookingState = ref.watch(bookingRepositoryProvider);
    final s = S(locale);

    final displayedBookings = bookingState.bookings.where((b) {
      return _isUpcoming ? b.isUpcoming : !b.isUpcoming;
    }).toList();

    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      appBar: AppBar(
        title: Text(
          s.myBookingsTitle,
          style: TextStyle(
            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Upcoming vs Past Pill Bar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TSportColors.charcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TSportColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isUpcoming = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isUpcoming
                              ? TSportColors.orange
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            s.upcomingTab,
                            style: TextStyle(
                              fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                              color: _isUpcoming
                                  ? Colors.white
                                  : TSportColors.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isUpcoming = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isUpcoming
                              ? TSportColors.orange
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            s.pastTab,
                            style: TextStyle(
                              fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                              color: !_isUpcoming
                                  ? Colors.white
                                  : TSportColors.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (displayedBookings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TSportColors.charcoal,
                          shape: BoxShape.circle,
                          border: Border.all(color: TSportColors.border),
                        ),
                        child: const Icon(Icons.confirmation_number_outlined,
                            color: TSportColors.textDim, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isUpcoming
                            ? (s.isAr
                                ? 'لا توجد حجوزات قادمة بعد'
                                : 'No upcoming bookings yet')
                            : (s.isAr
                                ? 'لا توجد حجوزات سابقة'
                                : 'No past bookings found'),
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.isAr
                            ? 'اكتشف الملاعب واحجز الآن في ثوانٍ'
                            : 'Discover courts and book in seconds',
                        style: const TextStyle(
                            color: TSportColors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TSportColors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.go('/'),
                        child: Text(s.exploreVenues,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedBookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = displayedBookings[index];
                  final title = s.isAr ? item.venueNameAr : item.venueName;
                  final pitch = s.isAr ? item.courtNameAr : item.courtName;
                  final date =
                      '${item.scheduleDate} • ${item.slotStart} - ${item.slotEnd}';
                  final statusText = item.status == 'confirmed'
                      ? s.confirmedStatus
                      : (s.isAr ? 'مكتمل' : 'Completed');
                  final statusColor = item.status == 'confirmed'
                      ? TSportColors.limeGreen
                      : TSportColors.textMuted;
                  final paymentText = item.paymentMethod == 'card'
                      ? s.paidOnline
                      : s.payCashOnArrival;

                  return _buildBookingCard(
                    title: title,
                    date: date,
                    pitch: pitch,
                    status: statusText,
                    statusColor: statusColor,
                    payment: paymentText,
                    imageUrl: item.imageUrl,
                    reference: item.id,
                    amount: item.amount,
                    s: s,
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required String title,
    required String date,
    required String pitch,
    required String status,
    required Color statusColor,
    required String payment,
    required String imageUrl,
    required String reference,
    required num amount,
    required S s,
  }) {
    return Container(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl,
                    width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(pitch,
                        style: const TextStyle(
                            color: TSportColors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(date,
                        style: const TextStyle(
                            color: TSportColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: TSportColors.textDim, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: TSportColors.border, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    payment,
                    style: TextStyle(
                      fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                      color: TSportColors.textDim,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    reference,
                    style: const TextStyle(
                      color: TSportColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$amount ${s.isAr ? "د.ل" : "LYD"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
