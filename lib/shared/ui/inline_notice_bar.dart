import 'package:flutter/material.dart';
import 'package:mise_gui/app/theme/app_theme.dart';
import 'package:mise_gui/models/app_models.dart';

class InlineNoticeBar extends StatelessWidget {
  const InlineNoticeBar({
    super.key,
    required this.notice,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final InlineNotice notice;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final accent = switch (notice.level) {
      HealthLevel.healthy => colors.accent,
      HealthLevel.info => colors.info,
      HealthLevel.warning => colors.warning,
      HealthLevel.critical => colors.danger,
    };

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.panelRaised.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(width: 2, child: ColoredBox(color: accent)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notice.message,
                        style: TextStyle(color: colors.textMuted, height: 1.45),
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onAction,
                    icon: Icon(actionIcon ?? Icons.open_in_new_rounded),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
