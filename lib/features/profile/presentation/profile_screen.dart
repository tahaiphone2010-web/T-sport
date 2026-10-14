import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_locale.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final s = S(locale);

    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      appBar: AppBar(
        title: Text(
          s.profileTitle,
          style: TextStyle(
            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TSportColors.charcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TSportColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: TSportColors.orange,
                    child: Text(
                      s.isAr ? 'ط' : 'T',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.isAr ? 'طه محمد' : 'Taha Mohamed',
                        style: TextStyle(
                          fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text('+218 91 234 5678',
                          style: TextStyle(
                              color: TSportColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Nav List
            _buildProfileTile(
                icon: Icons.confirmation_number_outlined,
                title: s.myBookingsTitle,
                onTap: () => context.go('/bookings'),
                s: s),
            _buildProfileTile(
                icon: Icons.payment_outlined,
                title: s.paymentMethodsOption,
                s: s),
            _buildProfileTile(
                icon: Icons.notifications_none, title: s.settingsOption, s: s),
            _buildProfileTile(
                icon: Icons.help_outline, title: s.helpSupportOption, s: s),

            // Language Switch Tile
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: TSportColors.charcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TSportColors.orange.withOpacity(0.4)),
              ),
              child: ListTile(
                leading: const Icon(Icons.language,
                    color: TSportColors.orange, size: 20),
                title: Text(
                  s.languageOption,
                  style: TextStyle(
                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TSportColors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TSportColors.orange),
                  ),
                  child: Text(
                    s.isAr ? 'العربية 🇱🇾' : 'English 🇬🇧',
                    style: TextStyle(
                      fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                      color: TSportColors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
              ),
            ),

            const SizedBox(height: 12),
            // Venue Manager Switch
            Container(
              decoration: BoxDecoration(
                color: TSportColors.charcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TSportColors.orange.withOpacity(0.4)),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.storefront, color: TSportColors.orange),
                title: Text(
                  s.venueManagerOption,
                  style: TextStyle(
                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: TSportColors.orange),
                onTap: () => context.push('/manager'),
              ),
            ),

            const SizedBox(height: 24),
            // Log Out Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: TSportColors.charcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TSportColors.border),
              ),
              child: Center(
                child: Text(
                  s.logOut,
                  style: TextStyle(
                    fontFamily: s.isAr ? 'Cairo' : 'Outfit',
                    color: TSportColors.errorRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
      {required IconData icon,
      required String title,
      VoidCallback? onTap,
      required S s}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TSportColors.charcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TSportColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: s.isAr ? 'Cairo' : 'Outfit',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: TSportColors.textDim, size: 18),
        onTap: onTap,
      ),
    );
  }
}
