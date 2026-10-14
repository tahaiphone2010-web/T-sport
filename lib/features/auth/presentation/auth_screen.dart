import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/t_sport_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  void _sendOtp() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _isLoading = false;
      _otpSent = true;
    });
  }

  void _verifyOtp() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoading = false);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TSportColors.vantablack,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_otpSent) {
              setState(() => _otpSent = false);
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
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
              const SizedBox(height: 36),

              if (!_otpSent) ...[
                // Screen 3: Welcome back - Phone Login
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your phone number to continue',
                  style: TextStyle(color: TSportColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Libyan Flag & Phone Input Card
                Container(
                  decoration: BoxDecoration(
                    color: TSportColors.charcoal,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TSportColors.border),
                  ),
                  child: Row(
                    children: [
                      // Libya Flag & Code prefix
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                              right: BorderSide(color: TSportColors.border)),
                        ),
                        child: Row(
                          children: const [
                            Text('🇱🇾', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text(
                              '+218',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Phone Number Field
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'Phone number',
                              hintStyle: TextStyle(color: TSportColors.textDim),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                TSportButton(
                  label: 'SEND OTP',
                  isLoading: _isLoading,
                  onPressed: _sendOtp,
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'By continuing you agree to our\nTerms & Conditions and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TSportColors.textDim, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Screen 4: Enter the code - OTP Verification
                const Text(
                  'Enter the code',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ve sent a 6-digit code to\n+218 ${_phoneController.text.isEmpty ? "91 234 5678" : _phoneController.text}',
                  style: const TextStyle(
                      color: TSportColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // 6 Boxes OTP input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 48,
                      height: 56,
                      decoration: BoxDecoration(
                        color: TSportColors.charcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: index == 0
                              ? TSportColors.orange
                              : TSportColors.border,
                          width: index == 0 ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          index == 0 ? '7' : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Resend code in 00:45',
                    style: TextStyle(
                        color: TSportColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),

                // Custom Technical Number Keypad matching Mockup 4
                _buildKeypad(),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildKeypadRow(['', '0', '⌫']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox(width: 60);
        return InkWell(
          onTap: () {
            if (key == '⌫') {
              // Delete
            } else {
              _verifyOtp();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 72,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TSportColors.charcoal,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TSportColors.border),
            ),
            child: Text(
              key,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
