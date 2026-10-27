import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mise_gui/app/theme/app_theme.dart';

/// 全局底纹：石墨渐层 + 细网格 + 定位十字与颗粒噪点。
///
/// 目标不是"漂亮的渐变"，而是让人一眼联想到校准仪器、示波器和工程图纸。
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: colors.backdropGradient),
        child: CustomPaint(
          painter: _BackdropPainter(colors: colors, isDark: isDark),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({required this.colors, required this.isDark});

  final AppPalette colors;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // 细网格：每 11 条画一条更实的"主刻度"，形成测绘纸的节奏。
    const gap = 44.0;
    final minorPaint = Paint()
      ..color = colors.border.withValues(alpha: isDark ? 0.16 : 0.30)
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = colors.border.withValues(alpha: isDark ? 0.34 : 0.42)
      ..strokeWidth = 1;

    var index = 0;
    for (double x = 0; x <= size.width; x += gap, index++) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        index % 11 == 0 ? majorPaint : minorPaint,
      );
    }
    index = 0;
    for (double y = 0; y <= size.height; y += gap, index++) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        index % 11 == 0 ? majorPaint : minorPaint,
      );
    }

    // 两处低饱和光晕：右上偏信号色，左下偏冷色，避免背景死平。
    _paintGlow(
      canvas,
      rect: Rect.fromCircle(
        center: Offset(size.width * 0.86, size.height * 0.06),
        radius: math.max(size.width, size.height) * 0.42,
      ),
      color: colors.accent.withValues(alpha: isDark ? 0.10 : 0.09),
    );
    _paintGlow(
      canvas,
      rect: Rect.fromCircle(
        center: Offset(size.width * 0.08, size.height * 0.92),
        radius: math.max(size.width, size.height) * 0.38,
      ),
      color: colors.info.withValues(alpha: isDark ? 0.06 : 0.07),
    );

    // 四角定位十字：像设备面板上的对位标记。
    final markPaint = Paint()
      ..color = colors.textMuted.withValues(alpha: isDark ? 0.26 : 0.34)
      ..strokeWidth = 1;
    const inset = 22.0;
    const arm = 9.0;
    for (final point in <Offset>[
      const Offset(inset, inset),
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      Offset(size.width - inset, size.height - inset),
    ]) {
      canvas.drawLine(
        Offset(point.dx - arm, point.dy),
        Offset(point.dx + arm, point.dy),
        markPaint,
      );
      canvas.drawLine(
        Offset(point.dx, point.dy - arm),
        Offset(point.dx, point.dy + arm),
        markPaint,
      );
    }

    // 颗粒：固定种子的伪随机噪点，营造磨砂屏的触感。
    final noisePaint = Paint()
      ..color = colors.textMuted.withValues(alpha: isDark ? 0.09 : 0.07);
    final random = math.Random(20261027);
    final count = (size.width * size.height / 2600).clamp(240, 1600).toInt();
    for (var i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() < 0.82 ? 0.6 : 1.1;
      canvas.drawCircle(Offset(dx, dy), radius, noisePaint);
    }
  }

  void _paintGlow(Canvas canvas, {required Rect rect, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0, 1],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.colors != colors;
  }
}
