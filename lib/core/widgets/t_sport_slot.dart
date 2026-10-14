import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SlotState {
  available,
  selected,
  lockedByMe,
  lockedByOther,
  booked,
  cashBlocked,
  expired,
  disabled,
}

class TSportSlot extends StatelessWidget {
  final String timeLabel; // e.g. "17:00"
  final SlotState state;
  final VoidCallback? onTap;

  const TSportSlot({
    super.key,
    required this.timeLabel,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    String statusText;
    IconData statusIcon;
    Color iconColor;

    switch (state) {
      case SlotState.available:
        backgroundColor = TSportColors.slateCard;
        textColor = TSportColors.textPrimary;
        borderColor = TSportColors.electricVolt.withOpacity(0.5);
        statusText = 'AVAILABLE';
        statusIcon = Icons.check_circle_outline;
        iconColor = TSportColors.electricVolt;
        break;
      case SlotState.selected:
        backgroundColor = TSportColors.electricVolt;
        textColor = const Color(0xFF021008);
        borderColor = TSportColors.electricVolt;
        statusText = 'SELECTED';
        statusIcon = Icons.check_circle;
        iconColor = const Color(0xFF021008);
        break;
      case SlotState.lockedByMe:
        backgroundColor = TSportColors.electricVolt.withOpacity(0.15);
        textColor = TSportColors.electricVolt;
        borderColor = TSportColors.electricVolt;
        statusText = 'LOCKED (5 MIN)';
        statusIcon = Icons.lock_clock;
        iconColor = TSportColors.electricVolt;
        break;
      case SlotState.lockedByOther:
      case SlotState.booked:
        backgroundColor = TSportColors.slateCard.withOpacity(0.5);
        textColor = TSportColors.textTertiary;
        borderColor = TSportColors.slateBorder;
        statusText = 'BOOKED';
        statusIcon = Icons.lock_outline;
        iconColor = TSportColors.textTertiary;
        break;
      case SlotState.cashBlocked:
        backgroundColor = TSportColors.amberWarning.withOpacity(0.1);
        textColor = TSportColors.amberWarning;
        borderColor = TSportColors.amberWarning.withOpacity(0.4);
        statusText = 'CASH RESERVED';
        statusIcon = Icons.payments_outlined;
        iconColor = TSportColors.amberWarning;
        break;
      case SlotState.expired:
      case SlotState.disabled:
        backgroundColor = TSportColors.midnightBg;
        textColor = TSportColors.textTertiary;
        borderColor = TSportColors.slateBorder;
        statusText = 'PASSED';
        statusIcon = Icons.block;
        iconColor = TSportColors.textTertiary;
        break;
    }

    final isTappable = onTap != null &&
        (state == SlotState.available || state == SlotState.selected);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isTappable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
                color: borderColor,
                width: state == SlotState.selected ? 2 : 1.2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: state == SlotState.selected
                ? [
                    BoxShadow(
                      color: TSportColors.electricVolt.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled,
                    size: 18,
                    color: state == SlotState.selected
                        ? const Color(0xFF021008)
                        : TSportColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: state == SlotState.selected
                      ? Colors.black.withOpacity(0.12)
                      : (state == SlotState.available
                          ? TSportColors.electricVolt.withOpacity(0.12)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: iconColor),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
