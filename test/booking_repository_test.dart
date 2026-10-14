import 'package:flutter_test/flutter_test.dart';
import 'package:t_sport/features/bookings/data/booking_repository.dart';

void main() {
  group('BookingRepository Unit & Concurrency Tests', () {
    late BookingRepositoryNotifier repository;

    setUp(() {
      repository = BookingRepositoryNotifier();
    });

    test(
        'Initial repository state contains seed bookings and default cash blocks',
        () {
      final state = repository.state;
      expect(state.bookings.isNotEmpty, true);
      expect(state.cashBlocks.isNotEmpty, true);

      // Verify seed Tripoli venues
      final hasAlNasr = state.bookings.any((b) => b.venueId == '1');
      expect(hasAlNasr, true);
    });

    test(
        'Authoritative 5-minute slot lock is created with correct duration and key',
        () {
      const venueId = '1';
      const courtIndex = 0;
      const scheduleDate = '2026-10-13';
      const slotStart = '17:00';
      const userId = 'player_A';

      final lock = repository.acquireLock(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
        userId: userId,
      );

      expect(lock.userId, userId);
      expect(lock.isExpired, false);
      expect(lock.remainingSeconds, inInclusiveRange(295, 300));

      final status = repository.state.getSlotStatus(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
        currentUserId: userId,
      );
      expect(status, 'selected');

      // Another user querying status sees it as booked/locked
      final statusForB = repository.state.getSlotStatus(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
        currentUserId: 'player_B',
      );
      expect(statusForB, 'booked');
    });

    test('Lock contention: Second player cannot lock already locked slot', () {
      const venueId = '1';
      const courtIndex = 0;
      const scheduleDate = '2026-10-13';
      const slotStart = '17:00';

      repository.acquireLock(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
        userId: 'player_A',
      );

      expect(
        () => repository.acquireLock(
          venueId: venueId,
          courtIndex: courtIndex,
          scheduleDate: scheduleDate,
          slotStart: slotStart,
          userId: 'player_B',
        ),
        throwsA(predicate((e) => e.toString().contains('SLOT_LOCKED'))),
      );
    });

    test('Lock contention: Player cannot lock manager cash-blocked slot', () {
      // '1_0_2026-10-13_21:00' is in default cashBlocks
      expect(
        () => repository.acquireLock(
          venueId: '1',
          courtIndex: 0,
          scheduleDate: '2026-10-13',
          slotStart: '21:00',
          userId: 'player_A',
        ),
        throwsA(
            predicate((e) => e.toString().contains('SLOT_BLOCKED_BY_VENUE'))),
      );
    });

    test('Confirm booking commits unique reference and releases lock', () {
      const venueId = '1';
      const courtIndex = 1;
      const scheduleDate = '2026-10-13';
      const slotStart = '18:00';
      const userId = 'player_A';

      repository.acquireLock(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
        userId: userId,
      );

      final booking = repository.confirmBooking(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
        userId: userId,
        paymentMethod: 'card',
        amount: 70,
        venueName: 'AL-NASR FOOTBALL CENTER',
        venueNameAr: 'مركز النصر لكرة القدم',
        courtName: 'Pitch 2 (5v5)',
        courtNameAr: 'ملعب 2 (خماسي)',
        imageUrl: 'https://example.com/photo.jpg',
      );

      expect(booking.id.startsWith('TSP-'), true);
      expect(booking.status, 'confirmed');
      expect(booking.slotEnd, '19:00');
      expect(booking.isUpcoming, true);

      // Lock should be released and booking present at index 0
      final key =
          BookingState.slotKey(venueId, courtIndex, scheduleDate, slotStart);
      expect(repository.state.locks.containsKey(key), false);
      expect(repository.state.bookings.first.id, booking.id);

      // Status in matrix is now booked
      final status = repository.state.getSlotStatus(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
      );
      expect(status, 'booked');
    });

    test('Manager cash-block toggle cycles between blocked and available', () {
      const venueId = '1';
      const courtIndex = 2;
      const scheduleDate = '2026-10-13';
      const slotStart = '17:00';

      // 1. Initial status is available
      expect(
        repository.state.getSlotStatus(
          venueId: venueId,
          courtIndex: courtIndex,
          scheduleDate: scheduleDate,
          slotStart: slotStart,
        ),
        'available',
      );

      // 2. Manager blocks for cash
      final blocked = repository.toggleManagerCashBlock(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
      );
      expect(blocked, true);
      expect(
        repository.state.getSlotStatus(
          venueId: venueId,
          courtIndex: courtIndex,
          scheduleDate: scheduleDate,
          slotStart: slotStart,
        ),
        'cash',
      );

      // 3. Manager unblocks
      final unblocked = repository.toggleManagerCashBlock(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
      );
      expect(unblocked, false);
      expect(
        repository.state.getSlotStatus(
          venueId: venueId,
          courtIndex: courtIndex,
          scheduleDate: scheduleDate,
          slotStart: slotStart,
        ),
        'available',
      );
    });

    test('Manager cannot overwrite active player lock with cash block', () {
      const venueId = '1';
      const courtIndex = 2;
      const scheduleDate = '2026-10-13';
      const slotStart = '18:00';

      repository.acquireLock(
        venueId: venueId,
        courtIndex: courtIndex,
        scheduleDate: scheduleDate,
        slotStart: slotStart,
        userId: 'player_A',
      );

      expect(
        () => repository.toggleManagerCashBlock(
          venueId: venueId,
          courtIndex: courtIndex,
          scheduleDate: scheduleDate,
          slotStart: slotStart,
        ),
        throwsA(predicate(
            (e) => e.toString().contains('SLOT_CURRENTLY_LOCKED_BY_PLAYER'))),
      );
    });
  });
}
