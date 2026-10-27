import 'package:flutter/material.dart';
import 'package:mise_gui/app/theme/app_theme.dart';
import 'package:mise_gui/models/app_models.dart';
import 'package:mise_gui/shared/ui/app_panel.dart';
import 'package:mise_gui/shared/ui/status_badge.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.metric});

  final SummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(label: metric.label, level: metric.level),
          const SizedBox(height: 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              maxLines: 1,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            width: 28,
            color: colors.border.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            metric.caption,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
