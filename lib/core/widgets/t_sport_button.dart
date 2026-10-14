import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TSportButtonType { primary, secondary, outline }

class TSportButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TSportButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const TSportButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = TSportButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 14,
                ),
              ),
            ],
          );

    Widget button;

    switch (type) {
      case TSportButtonType.primary:
        button = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: TSportColors.orange.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: TSportColors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              elevation: 0,
            ),
            child: buttonContent,
          ),
        );
        break;
      case TSportButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: TSportColors.darkGrey,
            foregroundColor: Colors.white,
            side: const BorderSide(color: TSportColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 0,
          ),
          child: buttonContent,
        );
        break;
      case TSportButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: TSportColors.orange,
            side: const BorderSide(color: TSportColors.orange, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: buttonContent,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
