import 'package:flutter/material.dart';
import 'package:mise_gui/app/theme/app_theme.dart';

/// 统一的"仪表盘面板"：石墨底、发丝级描边、右上角定位括号。
///
/// 比原先的大圆角玻璃卡更克制，也更容易承载高密度信息。
class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.showShadow = true,
    this.radius = AppRadius.panel,
    this.backgroundAlpha,
    this.borderAlpha,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showShadow;
  final double radius;
  final double? backgroundAlpha;
  final double? borderAlpha;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedRadius = BorderRadius.circular(radius);

    return CustomPaint(
      foregroundPainter: _PanelBracketPainter(
        color: colors.borderStrong.withValues(alpha: isDark ? 0.6 : 0.48),
        inset: 7,
        arm: 7,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: padding,
        foregroundDecoration: BoxDecoration(
          borderRadius: resolvedRadius,
          // 顶部一条极细高光，让平面看起来像有厚度的金属面板。
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.borderStrong.withValues(alpha: isDark ? 0.22 : 0.16),
              Colors.transparent,
            ],
            stops: const [0, 0.06],
          ),
        ),
        decoration: BoxDecoration(
          // 面板底色略实，文字落在稳定背景上，观感更清晰。
          color: colors.panel.withValues(
            alpha: backgroundAlpha ?? (isDark ? 0.92 : 0.96),
          ),
          borderRadius: resolvedRadius,
          border: Border.all(
            color: colors.border.withValues(alpha: borderAlpha ?? 0.72),
          ),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: isDark
                        ? const Color(0x40000000)
                        : const Color(0x14181C12),
                    blurRadius: isDark ? 26 : 18,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

class _PanelBracketPainter extends CustomPainter {
  const _PanelBracketPainter({
    required this.color,
    required this.inset,
    required this.arm,
  });

  final Color color;
  final double inset;
  final double arm;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < inset * 2 + arm || size.height < inset * 2 + arm) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final right = size.width - inset;
    final top = inset;

    // 右上角定位括号。
    canvas.drawLine(Offset(right - arm, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + arm), paint);

    // 左下角对称括号，保持构图平衡。
    final left = inset;
    final bottom = size.height - inset;
    canvas.drawLine(Offset(left, bottom), Offset(left + arm, bottom), paint);
    canvas.drawLine(Offset(left, bottom - arm), Offset(left, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant _PanelBracketPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.inset != inset ||
        oldDelegate.arm != arm;
  }
}
