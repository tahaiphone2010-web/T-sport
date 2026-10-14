import 'package:cloud_firestore/cloud_firestore.dart';

class Venue {
  final String id;
  final String name;
  final String sport;
  final String neighborhoodId;
  final num pricePerHour;
  final String currency;
  final String openingTime; // e.g. "17:00"
  final String closingTime; // e.g. "02:00"
  final String? coverImageUrl;
  final bool isActive;

  Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.neighborhoodId,
    required this.pricePerHour,
    this.currency = 'LYD',
    required this.openingTime,
    required this.closingTime,
    this.coverImageUrl,
    this.isActive = true,
  });

  factory Venue.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Venue(
      id: doc.id,
      name: data['name'] ?? '',
      sport: data['sport'] ?? 'Football',
      neighborhoodId: data['neighborhoodId'] ?? '',
      pricePerHour: data['pricePerHour'] ?? 0,
      currency: data['currency'] ?? 'LYD',
      openingTime: data['openingTime'] ?? '17:00',
      closingTime: data['closingTime'] ?? '02:00',
      coverImageUrl: data['coverImageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }
}

class Booking {
  final String id;
  final String userId;
  final String venueId;
  final String courtId;
  final String
      scheduleDate; // "YYYY-MM-DD" representing the operational session
  final Timestamp startAt;
  final Timestamp endAt;
  final String
      status; // 'locked', 'confirmed', 'cancelled', 'completed', 'blocked_cash'
  final String? paymentMethod; // 'stripe', 'cash'
  final num amount;

  Booking({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.courtId,
    required this.scheduleDate,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.paymentMethod,
    required this.amount,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      venueId: data['venueId'] ?? '',
      courtId: data['courtId'] ?? '',
      scheduleDate: data['scheduleDate'] ?? '',
      startAt: data['startAt'],
      endAt: data['endAt'],
      status: data['status'] ?? 'locked',
      paymentMethod: data['paymentMethod'],
      amount: data['amount'] ?? 0,
    );
  }
}
