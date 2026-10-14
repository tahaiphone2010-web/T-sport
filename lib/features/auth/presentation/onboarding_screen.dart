import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/t_sport_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      body: Stack(
        children: [
          // Background Pitch Image with Dark Gradient
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.85),
                    TSportColors.vantablack,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TSportColors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.flash_on,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'T-SPORT',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: const Text('SKIP',
                            style: TextStyle(
                                color: TSportColors.textMuted,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Athletic Headline
                  const Text(
                    'FIND A PITCH.\nBOOK YOUR HOUR.\nPLAY.',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Football & Padel courts in Tripoli.\nSimple. Fast. Reliable.',
                    style: TextStyle(
                      color: TSportColors.textMuted,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Step Indicator Bar
                  Row(
                    children: [
                      Container(
                        height: 4,
                        width: 48,
                        decoration: BoxDecoration(
                          color: TSportColors.orange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 4,
                        width: 20,
                        decoration: BoxDecoration(
                          color: TSportColors.darkGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 4,
                        width: 20,
                        decoration: BoxDecoration(
                          color: TSportColors.darkGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Next / Get Started Action
                  TSportButton(
                    label: 'GET STARTED',
                    onPressed: () => context.go('/auth'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
