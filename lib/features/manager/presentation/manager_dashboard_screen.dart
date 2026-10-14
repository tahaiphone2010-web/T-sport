import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_locale.dart';
import '../../bookings/data/booking_repository.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState
    extends ConsumerState<ManagerDashboardScreen> {
  String _activeTab = 'Schedule';

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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final bookingState = ref.watch(bookingRepositoryProvider);
    final s = S(locale);

    final venueName =
        s.isAr ? 'مركز النصر لكرة القدم' : 'Al-Nasr Football Center';
    final locationName = s.isAr ? 'طرابلس • عين زارة' : 'Tripoli • Ain Zara';
    final dateDisplay = s.isAr ? 'الأحد، 28 أبريل' : 'Sun, Apr 28';

    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: TSportColors.orange,
                  borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('T-SPORT',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.white)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                s.managerConsoleTitle,
                style: TextStyle(
                  fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                  color: TSportColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Operations Sidebar matching Screen 14
          Container(
            width: 90,
            decoration: const BoxDecoration(
              color: TSportColors.charcoal,
              border: Border(right: BorderSide(color: TSportColors.border)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSidebarItem(
                    'Schedule', s.scheduleTab, Icons.calendar_month, s),
                _buildSidebarItem('Bookings', s.navBookings,
                    Icons.confirmation_number_outlined, s),
                _buildSidebarItem(
                    'Venues', s.venuesTab, Icons.stadium_outlined, s),
                _buildSidebarItem(
                    'Settings', s.settingsOption, Icons.settings_outlined, s),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout,
                      color: TSportColors.textDim, size: 20),
                  onPressed: () => context.go('/'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Main Operations Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venueName,
                            style: TextStyle(
                              fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(locationName,
                              style: const TextStyle(
                                  color: TSportColors.textMuted, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: TSportColors.charcoal,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TSportColors.border)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 12, color: TSportColors.orange),
                            const SizedBox(width: 6),
                            Text(dateDisplay,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Operations Grid Header
                  Row(
                    children: [
                      SizedBox(
                          width: 44,
                          child: Text(s.timeColumn,
                              style: const TextStyle(
                                  color: TSportColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          child: Center(
                              child: Text(s.pitch1,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)))),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Center(
                              child: Text(s.pitch2,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)))),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Center(
                              child: Text(s.pitch3,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Operations Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _times.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final time = _times[index];
                      return Row(
                        children: [
                          SizedBox(
                              width: 44,
                              child: Text(time,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: _buildManagerCell(
                                  time, 'Pitch 1', 0, bookingState, s)),
                          const SizedBox(width: 6),
                          Expanded(
                              child: _buildManagerCell(
                                  time, 'Pitch 2', 1, bookingState, s)),
                          const SizedBox(width: 6),
                          Expanded(
                              child: _buildManagerCell(
                                  time, 'Pitch 3', 2, bookingState, s)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            s.isAr
                                ? 'المس أي وقت متاح بالجدول لقفله كحجز نقدي أو لإلغاء القفل'
                                : 'Tap any slot in the matrix to block or unblock cash walk-ins',
                          ),
                          backgroundColor: TSportColors.charcoal,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: TSportColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          s.blockCashSlotBtn,
                          style: TextStyle(
                            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String tabKey, String label, IconData icon, S s) {
    final isSelected = _activeTab == tabKey;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tabKey),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TSportColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : TSportColors.textMuted,
                  size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                  color: isSelected ? Colors.white : TSportColors.textDim,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagerCell(
      String time, String pitch, int courtIdx, BookingState bookingState, S s) {
    final status = bookingState.getSlotStatus(
      venueId: '1',
      courtIndex: courtIdx,
      scheduleDate: _scheduleDate,
      slotStart: time,
    );

    Color bg;
    Color text;
    String label;

    if (status == 'available') {
      bg = TSportColors.limeGreen.withOpacity(0.85);
      text = Colors.black;
      label = s.statusAvailable;
    } else if (status == 'cash') {
      bg = TSportColors.amber.withOpacity(0.3);
      text = TSportColors.amber;
      label = s.statusHold;
    } else {
      bg = TSportColors.charcoal;
      text = TSportColors.textDim;
      label = s.statusBooked;
    }

    return GestureDetector(
      onTap: () {
        try {
          ref.read(bookingRepositoryProvider.notifier).toggleManagerCashBlock(
                venueId: '1',
                courtIndex: courtIdx,
                scheduleDate: _scheduleDate,
                slotStart: time,
              );
        } catch (e) {
          final isBooked =
              e.toString().contains('CANNOT_OVERWRITE_CONFIRMED_BOOKING');
          final isLocked =
              e.toString().contains('SLOT_CURRENTLY_LOCKED_BY_PLAYER');
          final msg = isBooked
              ? (s.isAr
                  ? 'لا يمكن حجب وقت محجوز بالفعل'
                  : 'Cannot block confirmed booking')
              : (isLocked
                  ? (s.isAr
                      ? 'الوقت محجوز مؤقتاً بواسطة لاعب نشط'
                      : 'Slot locked by active player')
                  : e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: TSportColors.orange),
          );
        }
      },
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color:
                  status == 'cash' ? TSportColors.amber : Colors.transparent),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: s.isAr ? 'Cairo' : 'Outfit',
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
