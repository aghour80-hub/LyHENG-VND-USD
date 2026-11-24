import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class CustomKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final bool showDecimal;
  final double buttonHeight;

  const CustomKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    this.showDecimal = true,
    this.buttonHeight = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 8),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _KeypadButton(
                text: showDecimal ? '.' : '00',
                buttonHeight: buttonHeight,
                onTap: () => onKeyPress(showDecimal ? '.' : '00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KeypadButton(
                text: '0',
                buttonHeight: buttonHeight,
                onTap: () => onKeyPress('0'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KeypadButton(
                icon: Icons.backspace_outlined,
                buttonHeight: buttonHeight,
                onTap: onDelete,
                onLongPress: onClear,
                backgroundColor: AppColors.sellRateRedLight.withValues(alpha: 0.5),
                iconColor: AppColors.sellRateRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              text: key,
              buttonHeight: buttonHeight,
              onTap: () => onKeyPress(key),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? iconColor;
  final double buttonHeight;

  const _KeypadButton({
    this.text,
    this.icon,
    required this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.iconColor,
    this.buttonHeight = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy;

    return Material(
      color: backgroundColor ?? defaultBg,
      borderRadius: BorderRadius.circular(14),
      elevation: isDark ? 0 : 0.5,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                onLongPress!();
              }
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: buttonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 24, color: iconColor ?? textColor)
              : Text(
                  text ?? '',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
