import 'package:flutter/material.dart';
import 'package:mise_gui/app/theme/app_theme.dart';

/// 面板统一的区段头：图标(可选) + 标题 + 一句简短说明(可选) + 右侧操作(可选)。
///
/// 替代各页面里反复手写的 `Row(Expanded(Column(Text(title), Text(desc))), action)`
/// 样板，收敛垂直堆叠，让每个区段的信息密度更一致。
class PanelHeader extends StatelessWidget {
  const PanelHeader({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.accent,
    this.action,
    this.trailing,
    this.titleStyle,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final Color? accent;
  final Widget? action;
  final Widget? trailing;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final accentColor = accent ?? colors.info;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: accentColor.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    titleStyle ??
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (description != null && description!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: 16), action!],
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}