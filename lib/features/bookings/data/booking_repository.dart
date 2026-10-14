import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Representation of a verified booking in T-Sport
class BookingItem {
  final String id; // e.g. "TSP-20261013-8472"
  final String venueId;
  final String venueName;
  final String venueNameAr;
  final int courtIndex;
  final String courtName;
  final String courtNameAr;
  final String scheduleDate; // "YYYY-MM-DD"
  final String slotStart; // "20:00"
  final String slotEnd; // "21:00"
  final num amount;
  final String currency;
  final String status; // 'confirmed', 'completed', 'blocked_cash', 'cancelled'
  final String paymentMethod; // 'cash', 'card'
  final DateTime createdAt;
  final String imageUrl;

  const BookingItem({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.venueNameAr,
    required this.courtIndex,
    required this.courtName,
    required this.courtNameAr,
    required this.scheduleDate,
    required this.slotStart,
    required this.slotEnd,
    required this.amount,
    this.currency = 'LYD',
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.imageUrl,
  });

  bool get isUpcoming => status == 'confirmed';
}

/// Authoritative 5-Minute Slot Lock
class SlotLock {
  final String lockId;
  final String userId;
  final DateTime expiresAt;

  const SlotLock({
    required this.lockId,
    required this.userId,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get remainingSeconds =>
      max(0, expiresAt.difference(DateTime.now()).inSeconds);
}

/// Reactive State for Bookings, Locks, and Manager Cash Blocks
class BookingState {
  final List<BookingItem> bookings;
  final Map<String, SlotLock> locks;
  final Set<String> cashBlocks;

  const BookingState({
    required this.bookings,
    required this.locks,
    required this.cashBlocks,
  });

  BookingState copyWith({
    List<BookingItem>? bookings,
    Map<String, SlotLock>? locks,
    Set<String>? cashBlocks,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      locks: locks ?? this.locks,
      cashBlocks: cashBlocks ?? this.cashBlocks,
    );
  }

  /// Calculates canonical slot ID
  static String slotKey(
      String venueId, int courtIndex, String scheduleDate, String slotStart) {
    return '${venueId}_${courtIndex}_${scheduleDate}_$slotStart';
  }

  /// Authoritative status query for matrix cell
  String getSlotStatus({
    required String venueId,
    required int courtIndex,
    required String scheduleDate,
    required String slotStart,
    String? currentUserId,
  }) {
    final key = slotKey(venueId, courtIndex, scheduleDate, slotStart);

    // 1. Confirmed bookings check
    final isBooked = bookings.any(
      (b) =>
          b.venueId == venueId &&
          b.courtIndex == courtIndex &&
          b.scheduleDate == scheduleDate &&
          b.slotStart == slotStart &&
          (b.status == 'confirmed' || b.status == 'completed'),
    );
    if (isBooked) return 'booked';

    // 2. Manager cash block check
    if (cashBlocks.contains(key)) return 'cash';

    // 3. Active lock check
    final lock = locks[key];
    if (lock != null && !lock.isExpired) {
      if (currentUserId != null && lock.userId == currentUserId) {
        return 'selected';
      }
      return 'booked';
    }

    return 'available';
  }
}

/// StateNotifier handling atomic booking operations, locks, and cash blocks
class BookingRepositoryNotifier extends StateNotifier<BookingState> {
  BookingRepositoryNotifier()
      : super(
          BookingState(
            bookings: [
              // Initial verified historical & upcoming seed data
              BookingItem(
                id: 'TSP-20260428-1094',
                venueId: '1',
                venueName: 'AL-NASR FOOTBALL CENTER',
                venueNameAr: 'مركز النصر لكرة القدم',
                courtIndex: 0,
                courtName: 'Pitch 1 (5v5)',
                courtNameAr: 'ملعب 1 (خماسي)',
                scheduleDate: '2026-04-28',
                slotStart: '20:00',
                slotEnd: '21:00',
                amount: 70,
                status: 'confirmed',
                paymentMethod: 'card',
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
                imageUrl:
                    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=300&q=80',
              ),
              BookingItem(
                id: 'TSP-20260424-9921',
                venueId: '2',
                venueName: 'TRIPOLI PADEL CLUB',
                venueNameAr: 'نادي طرابلس للبادل',
                courtIndex: 1,
                courtName: 'Padel Court 2',
                courtNameAr: 'ملعب بادل 2',
                scheduleDate: '2026-04-24',
                slotStart: '19:00',
                slotEnd: '20:00',
                amount: 85,
                status: 'confirmed',
                paymentMethod: 'cash',
                createdAt: DateTime.now().subtract(const Duration(days: 5)),
                imageUrl:
                    'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=300&q=80',
              ),
              BookingItem(
                id: 'TSP-20260421-4819',
                venueId: '3',
                venueName: 'GREEN FIELD SPORTS',
                venueNameAr: 'ملاعب الحقل الأخضر',
                courtIndex: 1,
                courtName: 'Pitch 2',
                courtNameAr: 'ملعب 2',
                scheduleDate: '2026-04-21',
                slotStart: '18:00',
                slotEnd: '19:00',
                amount: 60,
                status: 'completed',
                paymentMethod: 'cash',
                createdAt: DateTime.now().subtract(const Duration(days: 8)),
                imageUrl:
                    'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?auto=format&fit=crop&w=300&q=80',
              ),
            ],
            locks: {},
            cashBlocks: {
              '1_0_2026-10-13_21:00',
              '1_0_2026-10-13_22:00',
              '1_1_2026-10-13_19:00',
              '1_2_2026-10-13_21:00',
            },
          ),
        );

  /// Acquires an authoritative 5-minute slot lock
  SlotLock acquireLock({
    required String venueId,
    required int courtIndex,
    required String scheduleDate,
    required String slotStart,
    required String userId,
  }) {
    final key =
        BookingState.slotKey(venueId, courtIndex, scheduleDate, slotStart);

    // 1. Conflict Check: already confirmed
    final isBooked = state.bookings.any(
      (b) =>
          b.venueId == venueId &&
          b.courtIndex == courtIndex &&
          b.scheduleDate == scheduleDate &&
          b.slotStart == slotStart &&
          (b.status == 'confirmed' || b.status == 'completed'),
    );
    if (isBooked) {
      throw Exception('SLOT_ALREADY_BOOKED');
    }

    // 2. Conflict Check: cash blocked by venue
    if (state.cashBlocks.contains(key)) {
      throw Exception('SLOT_BLOCKED_BY_VENUE');
    }

    // 3. Conflict Check: active lock owned by another user
    final existingLock = state.locks[key];
    if (existingLock != null &&
        !existingLock.isExpired &&
        existingLock.userId != userId) {
      throw Exception('SLOT_LOCKED');
    }

    // 4. Create authoritative 5-minute lock
    final newLock = SlotLock(
      lockId: key,
      userId: userId,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    final updatedLocks = Map<String, SlotLock>.from(state.locks);
    updatedLocks[key] = newLock;

    state = state.copyWith(locks: updatedLocks);
    return newLock;
  }

  /// Releases a lock early if checkout is cancelled
  void releaseLock({
    required String venueId,
    required int courtIndex,
    required String scheduleDate,
    required String slotStart,
  }) {
    final key =
        BookingState.slotKey(venueId, courtIndex, scheduleDate, slotStart);
    final updatedLocks = Map<String, SlotLock>.from(state.locks);
    updatedLocks.remove(key);
    state = state.copyWith(locks: updatedLocks);
  }

  /// Authoritatively confirms a booking
  BookingItem confirmBooking({
    required String venueId,
    required int courtIndex,
    required String scheduleDate,
    required String slotStart,
    required String userId,
    required String paymentMethod,
    required num amount,
    required String venueName,
    required String venueNameAr,
    required String courtName,
    required String courtNameAr,
    required String imageUrl,
  }) {
    final key =
        BookingState.slotKey(venueId, courtIndex, scheduleDate, slotStart);

    // 1. Verify unexpired lock
    final lock = state.locks[key];
    if (lock == null || lock.isExpired) {
      // Re-validate that slot isn't booked
      final isBooked = state.bookings.any(
        (b) =>
            b.venueId == venueId &&
            b.courtIndex == courtIndex &&
            b.scheduleDate == scheduleDate &&
            b.slotStart == slotStart &&
            (b.status == 'confirmed' || b.status == 'completed'),
      );
      if (isBooked) throw Exception('SLOT_ALREADY_BOOKED');
    }

    // 2. Calculate slotEnd
    final startHour = int.parse(slotStart.split(':')[0]);
    final endHour = (startHour + 1) % 24;
    final slotEnd = '${endHour.toString().padLeft(2, '0')}:00';

    // 3. Generate unique reference e.g. TSP-20261013-8821
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randSuffix = (1000 + Random().nextInt(9000)).toString();
    final referenceId = 'TSP-$dateStr-$randSuffix';

    final newBooking = BookingItem(
      id: referenceId,
      venueId: venueId,
      venueName: venueName,
      venueNameAr: venueNameAr,
      courtIndex: courtIndex,
      courtName: courtName,
      courtNameAr: courtNameAr,
      scheduleDate: scheduleDate,
      slotStart: slotStart,
      slotEnd: slotEnd,
      amount: amount,
      status: 'confirmed',
      paymentMethod: paymentMethod,
      createdAt: now,
      imageUrl: imageUrl,
    );

    // 4. Remove active lock and commit new booking
    final updatedLocks = Map<String, SlotLock>.from(state.locks);
    updatedLocks.remove(key);

    state = state.copyWith(
      bookings: [newBooking, ...state.bookings],
      locks: updatedLocks,
    );

    return newBooking;
  }

  /// Manager Cash Walk-In Toggle (Authoritative block / unblock)
  bool toggleManagerCashBlock({
    required String venueId,
    required int courtIndex,
    required String scheduleDate,
    required String slotStart,
  }) {
    final key =
        BookingState.slotKey(venueId, courtIndex, scheduleDate, slotStart);

    // 1. Conflict Check: confirmed booking cannot be overwritten
    final isBooked = state.bookings.any(
      (b) =>
          b.venueId == venueId &&
          b.courtIndex == courtIndex &&
          b.scheduleDate == scheduleDate &&
          b.slotStart == slotStart &&
          (b.status == 'confirmed' || b.status == 'completed'),
    );
    if (isBooked) {
      throw Exception('CANNOT_OVERWRITE_CONFIRMED_BOOKING');
    }

    // 2. Conflict Check: active player lock cannot be overwritten
    final lock = state.locks[key];
    if (lock != null && !lock.isExpired) {
      throw Exception('SLOT_CURRENTLY_LOCKED_BY_PLAYER');
    }

    final updatedBlocks = Set<String>.from(state.cashBlocks);
    bool isNowBlocked;
    if (updatedBlocks.contains(key)) {
      updatedBlocks.remove(key);
      isNowBlocked = false;
    } else {
      updatedBlocks.add(key);
      isNowBlocked = true;
    }

    state = state.copyWith(cashBlocks: updatedBlocks);
    return isNowBlocked;
  }
}

/// Global provider for booking state
final bookingRepositoryProvider =
    StateNotifierProvider<BookingRepositoryNotifier, BookingState>((ref) {
  return BookingRepositoryNotifier();
});
