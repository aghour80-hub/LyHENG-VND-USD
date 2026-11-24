import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CustomKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final bool showDecimal;

  const CustomKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    this.showDecimal = true,
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
                onTap: () => onKeyPress(showDecimal ? '.' : '00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KeypadButton(
                text: '0',
                onTap: () => onKeyPress('0'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KeypadButton(
                icon: Icons.backspace_outlined,
                onTap: onDelete,
                onLongPress: onClear,
                backgroundColor: AppColors.sellRateRedLight.withValues(alpha: 0.4),
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

  const _KeypadButton({
    this.text,
    this.icon,
    required this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.primaryNavy;

    return Material(
      color: backgroundColor ?? defaultBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 22, color: iconColor ?? textColor)
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
