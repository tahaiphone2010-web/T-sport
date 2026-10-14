import 'package:go_router/go_router.dart';
import '../widgets/main_shell.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/venues/presentation/venue_detail_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/manager/presentation/manager_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(initialIndex: 0),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const MainShell(initialIndex: 2),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainShell(initialIndex: 3),
    ),
    GoRoute(
      path: '/venue/:id',
      builder: (context, state) => VenueDetailScreen(
        venueId: state.pathParameters['id'] ?? '1',
      ),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => CheckoutScreen(
        time: state.uri.queryParameters['time'] ?? '18:00',
        venueId: state.uri.queryParameters['venueId'] ?? '1',
        pitchIndex:
            int.tryParse(state.uri.queryParameters['pitch'] ?? '0') ?? 0,
      ),
    ),
    GoRoute(
      path: '/manager',
      builder: (context, state) => const ManagerDashboardScreen(),
    ),
  ],
);
