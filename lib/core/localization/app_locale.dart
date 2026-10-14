import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void toggleLocale() {
    if (state.languageCode == 'en') {
      state = const Locale('ar');
    } else {
      state = const Locale('en');
    }
  }

  bool get isArabic => state.languageCode == 'ar';
}

class S {
  final Locale locale;
  S(this.locale);

  bool get isAr => locale.languageCode == 'ar';

  // Header & Branding
  String get appTitle => 'T-SPORT';
  String get greeting => isAr ? 'صباح الخير،' : 'GOOD MORNING,';
  String get playerName => isAr ? 'طه 👋' : 'Taha 👋';
  String get cityTripoli => isAr ? 'طرابلس' : 'Tripoli';
  String get countryLibya => isAr ? 'طرابلس، ليبيا' : 'TRIPOLI, LIBYA';

  // Navigation Items
  String get navHome => isAr ? 'الرئيسية' : 'Home';
  String get navExplore => isAr ? 'استكشف' : 'Explore';
  String get navBookings => isAr ? 'حجوزاتي' : 'Bookings';
  String get navProfile => isAr ? 'حسابي' : 'Profile';

  // Sports
  String get football => isAr ? 'كرة قدم' : 'FOOTBALL';
  String get padel => isAr ? 'بادل' : 'PADEL';

  // Search & Filters
  String get searchPlaceholder =>
      isAr ? 'ابحث عن المنطقة أو الملعب...' : 'Search by neighborhood...';
  String get nearbyVenues => isAr ? 'الملاعب القريبة' : 'Nearby Venues';
  String get seeAll => isAr ? 'عرض الكل' : 'See All';
  String get availableVenuesTag => isAr ? 'ملاعب متاحة' : 'Available';
  String get exploreVenues => isAr ? 'استكشف الملاعب' : 'EXPLORE VENUES';

  // Venue Cards
  String get perHour => isAr ? 'د.ل / ساعة' : 'LYD / hour';
  String get startingFrom => isAr ? 'ابتداءً من' : 'Starting from';
  String get bookPitch => isAr ? 'حجز ملعب' : 'BOOK PITCH';
  String get popularTag => isAr ? 'شائع' : 'POPULAR';
  String get discountTag => isAr ? 'خصم 15% اليوم' : '15% OFF TODAY';
  String get premiumTag => isAr ? 'مميز' : 'PREMIUM';

  // Matrix & Pitch Selection
  String get pitch1 => isAr ? 'ملعب 1' : 'Pitch 1';
  String get pitch2 => isAr ? 'ملعب 2' : 'Pitch 2';
  String get pitch3 => isAr ? 'ملعب 3' : 'Pitch 3';
  String get timeColumn => isAr ? 'الوقت' : 'TIME';
  String get statusAvailable => isAr ? 'متاح' : 'Open';
  String get statusBooked => isAr ? 'محجوز' : 'Booked';
  String get statusHold => isAr ? 'حجز نقدي' : 'Hold';
  String get statusSelected => isAr ? 'محدد' : 'Selected';
  String get legendAvailable => isAr ? 'متاح' : 'Available';
  String get legendSelected => isAr ? 'محدد' : 'Selected';
  String get legendBooked => isAr ? 'محجوز' : 'Booked';
  String get legendCashHold => isAr ? 'حجز نقدي' : 'Cash Hold';
  String get oneHourTotal => isAr ? 'المجموع لساعة' : '1 HOUR TOTAL';
  String get viewAvailability =>
      isAr ? 'عرض المواعيد والدفع' : 'VIEW AVAILABILITY';
  String get selectMatchDate =>
      isAr ? 'اختر تاريخ المباراة' : 'SELECT MATCH DATE';

  // Checkout
  String get checkoutTitle => isAr ? 'الدفع وتأكيد الحجز' : 'Checkout';
  String get slotReservedTitle =>
      isAr ? 'تم حجز موعدك مؤقتاً' : 'YOUR SLOT IS RESERVED';
  String get timeLeftBooking => isAr
      ? 'الوقت المتبقي لإتمام الحجز'
      : 'Time left to complete your booking';
  String get totalAmount => isAr ? 'المجموع الإجمالي' : 'Total';
  String get paymentMethod => isAr ? 'طريقة الدفع' : 'Payment Method';
  String get payWithCard => isAr ? 'الدفع بالبطاقة المصرفية' : 'Pay with Card';
  String get payCardSubtitle =>
      isAr ? 'فيزا / ماستركارد / آبل باي' : 'Visa / Mastercard / Apple Pay';
  String get payCashOnArrival =>
      isAr ? 'الدفع نقداً عند الوصول' : 'Pay Cash on Arrival';
  String get payCashSubtitle =>
      isAr ? 'الدفع مباشرة في مكتب الملعب' : 'Pay directly at the venue desk';
  String get continueBtn => isAr ? 'متابعة الدفع' : 'CONTINUE';

  // Confirmation
  String get bookingConfirmed =>
      isAr ? 'تم تأكيد الحجز بنجاح!' : 'BOOKING CONFIRMED!';
  String get bookingConfirmedSubtitle => isAr
      ? 'تم تثبيت موعدك في جدول الملعب.'
      : 'Your slot has been successfully booked.';
  String get bookingIdLabel => isAr ? 'رقم الحجز' : 'Booking ID';
  String get viewInBookings => isAr ? 'عرض في حجوزاتي' : 'VIEW IN BOOKINGS';
  String get backToHome => isAr ? 'العودة للرئيسية' : 'BACK TO HOME';

  // Bookings Tab
  String get myBookingsTitle => isAr ? 'حجوزاتي' : 'My Bookings';
  String get upcomingTab => isAr ? 'القادمة' : 'Upcoming';
  String get pastTab => isAr ? 'السابقة' : 'Past';
  String get paidOnline => isAr ? 'مدفوع إلكترونياً' : 'Paid Online';
  String get confirmedStatus => isAr ? 'مؤكد' : 'Confirmed';

  // Profile
  String get profileTitle => isAr ? 'الملف الشخصي' : 'Profile';
  String get paymentMethodsOption => isAr ? 'طرق الدفع' : 'Payment Methods';
  String get settingsOption => isAr ? 'الإعدادات' : 'Settings';
  String get helpSupportOption => isAr ? 'المساعدة والدعم' : 'Help & Support';
  String get venueManagerOption =>
      isAr ? 'لوحة تحكم مدير الملعب' : 'Venue Manager Console';
  String get languageOption => isAr ? 'اللغة / Language' : 'Language / اللغة';
  String get switchLanguageAction => isAr ? 'English' : 'العربية';
  String get logOut => isAr ? 'تسجيل الخروج' : 'Log Out';

  // Venue Manager Console
  String get managerConsoleTitle => isAr ? 'لوحة تحكم الملعب' : 'Venue Manager';
  String get scheduleTab => isAr ? 'الجدول' : 'Schedule';
  String get venuesTab => isAr ? 'الملاعب' : 'Venues';
  String get blockCashSlotBtn => isAr ? '+ حجز نقدي فوري' : '+ BLOCK CASH SLOT';

  // Tripoli Map & Gallery
  String get openInGoogleMaps =>
      isAr ? 'فتح في خرائط جوجل' : 'Open in Google Maps';
  String get amenitiesTitle =>
      isAr ? 'المرافق والخدمات' : 'Amenities & Features';
  String get photosGallery => isAr ? 'معرض الصور' : 'Photos';
  String get courtSelection => isAr ? 'اختر الملعب' : 'Select Court';
  String get exploreTripoliTitle =>
      isAr ? 'استكشف ملاعب طرابلس' : 'Explore Tripoli Pitches';
  String get mapView => isAr ? 'خريطة طرابلس' : 'Tripoli Map';
  String get allNeighborhoods => isAr ? 'كل المناطق' : 'All Areas';
  String get viewCourtAndSlots =>
      isAr ? 'عرض الملعب والمواعيد' : 'VIEW VENUE & SLOTS';
  String get directions => isAr ? 'الاتجاهات' : 'Directions';
  String get photoCounter => isAr ? 'صورة' : 'Photo';
}
