import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/widgets/t_sport_button.dart';
import '../../venues/data/venue_repository.dart';
import '../../bookings/data/booking_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String time;
  final String venueId;
  final int pitchIndex;

  const CheckoutScreen({
    super.key,
    required this.time,
    this.venueId = '1',
    this.pitchIndex = 0,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late Timer _timer;
  int _secondsRemaining = 292; // ~04:52 matching Screen 9
  String _paymentMethod = 'card'; // 'card' or 'cash'

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer.cancel();
        if (mounted) context.pop();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final s = S(locale);
    final venue = VenueRepository.getById(widget.venueId);

    final venueName = s.isAr ? venue.nameAr : venue.name;
    final pitchType = s.isAr ? venue.pitchTypeAr : venue.pitchType;
    final courtName = s.isAr
        ? (widget.pitchIndex < venue.pitchesAr.length
            ? venue.pitchesAr[widget.pitchIndex]
            : venue.pitchesAr.first)
        : (widget.pitchIndex < venue.pitches.length
            ? venue.pitches[widget.pitchIndex]
            : venue.pitches.first);
    final dateDisplay = s.isAr ? 'الأحد، 28 أبريل' : 'Sun, Apr 28';
    final totalCost = s.isAr ? '${venue.price} د.ل' : '${venue.price} LYD';

    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      appBar: AppBar(
        title: Text(
          s.checkoutTitle,
          style: TextStyle(
            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TSportColors.charcoal,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TSportColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      venue.primaryPhoto,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 50,
                        height: 50,
                        color: TSportColors.vantablack,
                        child: const Icon(Icons.sports,
                            color: TSportColors.textDim, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName,
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(pitchType,
                          style: const TextStyle(
                              color: TSportColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date / Pitch Tag Row
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TSportColors.charcoal,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TSportColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: TSportColors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '$dateDisplay  •  ${widget.time} - ${(int.parse(widget.time.split(':')[0]) + 1).toString()}:00',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        venue.sport == 'PADEL'
                            ? Icons.sports_tennis
                            : Icons.sports_soccer,
                        size: 16,
                        color: TSportColors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(courtName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5-Minute Hold Pill
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: TSportColors.charcoal,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: TSportColors.limeGreen.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      s.slotReservedTitle,
                      style: TextStyle(
                        fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                        color: TSportColors.limeGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.timeLeftBooking,
                      style: TextStyle(
                        fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                        color: TSportColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.totalAmount,
                  style: TextStyle(
                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                    color: TSportColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                Text(
                  totalCost,
                  style: TextStyle(
                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Methods
            Text(
              s.paymentMethod,
              style: TextStyle(
                fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            _buildPaymentMethodTile(
              id: 'card',
              title: s.payWithCard,
              subtitle: s.payCardSubtitle,
              icon: Icons.credit_card,
              s: s,
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodTile(
              id: 'cash',
              title: s.payCashOnArrival,
              subtitle: s.payCashSubtitle,
              icon: Icons.payments_outlined,
              s: s,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TSportColors.charcoal,
          border: const Border(top: BorderSide(color: TSportColors.border)),
        ),
        child: SafeArea(
          child: TSportButton(
            label: s.continueBtn,
            onPressed: () {
              if (_paymentMethod == 'card') {
                _showStripePaymentSheet(context, s);
              } else {
                _processBookingConfirmation(context, s, 'cash');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required S s,
  }) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TSportColors.charcoal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? TSportColors.orange : TSportColors.border,
              width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? TSportColors.orange : TSportColors.textDim,
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: TSportColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Secure Payment Sheet
  void _showStripePaymentSheet(BuildContext context, S s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TSportColors.vantablack,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock,
                          size: 16, color: TSportColors.orange),
                      const SizedBox(width: 6),
                      Text(
                        s.isAr ? 'دفع إلكتروني آمن' : 'Secure Payment',
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                s.isAr ? 'رقم البطاقة' : 'Card number',
                style: const TextStyle(
                    color: TSportColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                    color: TSportColors.charcoal,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TSportColors.border)),
                child: const Text('1234 5678 9012 3456',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.isAr ? 'تاريخ الانتهاء' : 'MM/YY',
                          style: const TextStyle(
                              color: TSportColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                              color: TSportColors.charcoal,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: TSportColors.border)),
                          child: const Text('04/28',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CVC',
                            style: TextStyle(
                                color: TSportColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                              color: TSportColors.charcoal,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: TSportColors.border)),
                          child: const Text('•••',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Apple Pay pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.apple, color: Colors.black, size: 20),
                    SizedBox(width: 6),
                    Text('Pay',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TSportButton(
                label: s.isAr
                    ? 'دفع ${VenueRepository.getById(widget.venueId).price} د.ل'
                    : 'PAY ${VenueRepository.getById(widget.venueId).price} LYD',
                onPressed: () {
                  Navigator.pop(context);
                  _processBookingConfirmation(context, s, 'card');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _processBookingConfirmation(BuildContext context, S s, String method) {
    final venue = VenueRepository.getById(widget.venueId);
    final courtName = widget.pitchIndex < venue.pitches.length
        ? venue.pitches[widget.pitchIndex]
        : venue.pitches.first;
    final courtNameAr = widget.pitchIndex < venue.pitchesAr.length
        ? venue.pitchesAr[widget.pitchIndex]
        : venue.pitchesAr.first;

    try {
      final confirmed =
          ref.read(bookingRepositoryProvider.notifier).confirmBooking(
                venueId: venue.id,
                courtIndex: widget.pitchIndex,
                scheduleDate: '2026-10-13',
                slotStart: widget.time,
                userId: 'user_player_1',
                paymentMethod: method,
                amount: venue.price,
                venueName: venue.name,
                venueNameAr: venue.nameAr,
                courtName: courtName,
                courtNameAr: courtNameAr,
                imageUrl: venue.primaryPhoto,
              );
      _showConfirmation(context, s, confirmed);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.isAr
                ? 'فشل تأكيد الحجز: انتهت صلاحية القفل أو تم الحجز'
                : 'Failed to confirm booking: lock expired or slot taken',
          ),
          backgroundColor: TSportColors.orange,
        ),
      );
    }
  }

  // Booking Confirmed Screen
  void _showConfirmation(
      BuildContext context, S s, BookingItem confirmedBooking) {
    final venueName =
        s.isAr ? confirmedBooking.venueNameAr : confirmedBooking.venueName;
    final courtName =
        s.isAr ? confirmedBooking.courtNameAr : confirmedBooking.courtName;
    final totalCost = s.isAr
        ? '${confirmedBooking.amount} د.ل'
        : '${confirmedBooking.amount} LYD';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TSportColors.vantablack,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: TSportColors.limeGreen.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.check,
                    color: TSportColors.limeGreen, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                s.bookingConfirmed,
                style: TextStyle(
                  fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.bookingConfirmedSubtitle,
                style: TextStyle(
                  fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                  color: TSportColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: TSportColors.charcoal,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TSportColors.border)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            venueName,
                            style: TextStyle(
                              fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          courtName,
                          style: const TextStyle(
                              color: TSportColors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(color: TSportColors.border, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.bookingIdLabel,
                            style: const TextStyle(
                                color: TSportColors.textMuted, fontSize: 12)),
                        Text(confirmedBooking.id,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.totalAmount,
                            style: const TextStyle(
                                color: TSportColors.textMuted, fontSize: 12)),
                        Text(
                          totalCost,
                          style: const TextStyle(
                              color: TSportColors.orange,
                              fontWeight: FontWeight.w900,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TSportButton(
                  label: s.viewInBookings,
                  onPressed: () => context.go('/bookings')),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  s.backToHome,
                  style: TextStyle(
                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                    color: TSportColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
