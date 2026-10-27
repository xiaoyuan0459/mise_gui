import 'package:flutter/material.dart';
import 'package:mise_gui/app/theme/app_theme.dart';
import 'package:mise_gui/models/app_models.dart';

/// 状态徽标：LED 指示灯 + 等宽标签，替代圆润的胶囊标签。
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.level});

  final String label;
  final HealthLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = switch (level) {
      HealthLevel.healthy => colors.accent,
      HealthLevel.info => colors.info,
      HealthLevel.warning => colors.warning,
      HealthLevel.critical => colors.danger,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.10 : 0.09),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.7 : 0.35),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppTypography.eyebrow(
              context,
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ).copyWith(letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}
