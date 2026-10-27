import 'package:flutter/material.dart';

/// 界面正文使用的字体栈。
///
/// 应用不内置 CJK 字体，中文由系统字体渲染；拉丁字符与数字优先使用随包
/// 分发的 JetBrains Mono，形成"仪表盘 / 终端"式的技术感。
const List<String> kUiFontFamilies = <String>[
  'Segoe UI Variable Text',
  'Segoe UI',
  'Microsoft YaHei UI',
  'Microsoft YaHei',
  'PingFang SC',
  'Hiragino Sans GB',
  'Noto Sans CJK SC',
  'Noto Sans SC',
  'Helvetica Neue',
  'Arial',
];

/// 随应用打包的等宽字体，用于版本号、路径、指标数值与眉标。
const String kMonoFontFamily = 'JetBrainsMono';
const List<String> kMonoFontFallback = <String>[
  'Cascadia Mono',
  'Consolas',
  'SF Mono',
  'Menlo',
  'DejaVu Sans Mono',
  'Liberation Mono',
  'Courier New',
];

/// 统一的圆角尺度：面板偏硬朗，控件更紧凑，强调精密仪器感而非气泡感。
abstract final class AppRadius {
  static const double panel = 14;
  static const double control = 9;
  static const double chip = 6;
  static const double pill = 999;
}

@immutable
class AppPalette {
  const AppPalette({
    required this.background,
    required this.backgroundSoft,
    required this.backgroundDeep,
    required this.panel,
    required this.panelRaised,
    required this.panelMuted,
    required this.border,
    required this.borderStrong,
    required this.accent,
    required this.info,
    required this.warning,
    required this.danger,
    required this.textPrimary,
    required this.textMuted,
    required this.hover,
    required this.heroGradient,
    required this.backdropGradient,
  });

  final Color background;
  final Color backgroundSoft;
  final Color backgroundDeep;
  final Color panel;
  final Color panelRaised;
  final Color panelMuted;
  final Color border;
  final Color borderStrong;
  final Color accent;
  final Color info;
  final Color warning;
  final Color danger;
  final Color textPrimary;
  final Color textMuted;
  final Color hover;
  final LinearGradient heroGradient;
  final LinearGradient backdropGradient;
}

class AppTheme {
  /// 石墨底 + 荧光柠檬绿。整体偏"校准仪器"，只用一种高饱和信号色。
  static const AppPalette darkPalette = AppPalette(
    background: Color(0xFF0B0D0B),
    backgroundSoft: Color(0xFF10130F),
    backgroundDeep: Color(0xFF060806),
    panel: Color(0xFF121612),
    panelRaised: Color(0xFF181D17),
    panelMuted: Color(0xFF1D231C),
    border: Color(0xFF2A322A),
    borderStrong: Color(0xFF455044),
    accent: Color(0xFFC8F24E),
    info: Color(0xFF8FD3E8),
    warning: Color(0xFFF0B44B),
    danger: Color(0xFFF2634A),
    textPrimary: Color(0xFFEDEFE4),
    textMuted: Color(0xFF98A093),
    hover: Color(0x14C8F24E),
    heroGradient: LinearGradient(
      colors: [Color(0xFF1B2117), Color(0xFF10140F), Color(0xFF242C15)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backdropGradient: LinearGradient(
      colors: [Color(0xFF090B09), Color(0xFF0C100C), Color(0xFF070907)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// 石灰纸 + 橄榄绿。浅色主题更像工程蓝图与纸质手册。
  static const AppPalette lightPalette = AppPalette(
    background: Color(0xFFF1F0E6),
    backgroundSoft: Color(0xFFFAF9F2),
    backgroundDeep: Color(0xFFE4E3D7),
    panel: Color(0xFFF8F7EF),
    panelRaised: Color(0xFFFFFEF8),
    panelMuted: Color(0xFFE9E8DB),
    border: Color(0xFFD5D4C5),
    borderStrong: Color(0xFFB0B1A0),
    accent: Color(0xFF4E6414),
    info: Color(0xFF116B72),
    warning: Color(0xFF96620A),
    danger: Color(0xFFAE3B25),
    textPrimary: Color(0xFF161A10),
    textMuted: Color(0xFF636A58),
    hover: Color(0x144E6414),
    heroGradient: LinearGradient(
      colors: [Color(0xFFFFFEF8), Color(0xFFF3F3E7), Color(0xFFEBF2D6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backdropGradient: LinearGradient(
      colors: [Color(0xFFF6F5EC), Color(0xFFF0EFE4), Color(0xFFE6E6D8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static AppPalette colorsOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPalette
        : lightPalette;
  }

  static ThemeData dark() => _buildTheme(darkPalette, Brightness.dark);

  static ThemeData light() => _buildTheme(lightPalette, Brightness.light);

  static ThemeData _buildTheme(AppPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.accent,
      onPrimary: isDark ? palette.backgroundDeep : palette.backgroundSoft,
      secondary: palette.info,
      onSecondary: isDark ? palette.backgroundDeep : palette.backgroundSoft,
      error: palette.danger,
      onError: palette.backgroundSoft,
      surface: palette.panel,
      onSurface: palette.textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = base.textTheme.copyWith(
      // 大号数值：等宽 + 紧字距，像仪表读数。
      displaySmall: _monoStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.02,
        letterSpacing: -1.2,
      ),
      headlineLarge: _uiStyle(
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.12,
        letterSpacing: -0.3,
      ),
      headlineMedium: _uiStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleLarge: _uiStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        height: 1.25,
      ),
      titleMedium: _uiStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
        height: 1.3,
      ),
      bodyLarge: _uiStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: palette.textPrimary,
        height: 1.5,
      ),
      bodyMedium: _uiStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
        height: 1.5,
      ),
      bodySmall: _uiStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: palette.textMuted,
        height: 1.45,
      ),
      labelLarge: _monoStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
        letterSpacing: 0.2,
      ),
      labelMedium: _monoStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.textMuted,
        letterSpacing: 0.4,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      iconTheme: IconThemeData(color: palette.textPrimary, size: 19),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background.withValues(alpha: 0.9),
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.panelRaised,
        contentTextStyle: _uiStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: palette.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          side: BorderSide(color: palette.borderStrong.withValues(alpha: 0.7)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.panel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.panel),
          side: BorderSide(color: palette.border),
        ),
        titleTextStyle: textTheme.headlineMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      cardTheme: CardThemeData(
        color: palette.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.panel),
          side: BorderSide(color: palette.border),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: palette.border,
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: palette.panelRaised,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: palette.borderStrong.withValues(alpha: 0.6),
          ),
        ),
        textStyle: _monoStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: palette.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(AppRadius.pill),
        thumbColor: WidgetStatePropertyAll(
          palette.borderStrong.withValues(alpha: isDark ? 0.7 : 0.55),
        ),
        trackColor: WidgetStatePropertyAll(
          palette.panel.withValues(alpha: 0.3),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
        linearTrackColor: palette.panelMuted,
        circularTrackColor: palette.panelMuted,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.panelMuted.withValues(alpha: isDark ? 0.55 : 0.7),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: _uiStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: palette.textMuted,
        ),
        border: _inputBorder(palette.border),
        enabledBorder: _inputBorder(palette.border),
        focusedBorder: _inputBorder(palette.accent, width: 1.4),
        errorBorder: _inputBorder(palette.danger),
        focusedErrorBorder: _inputBorder(palette.danger, width: 1.4),
        labelStyle: _monoStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: palette.textMuted,
          letterSpacing: 0.4,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          // 主操作使用实色信号色，是界面上唯一的"通电"元素。
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.panelMuted.withValues(alpha: isDark ? 0.6 : 0.8);
            }
            if (states.contains(WidgetState.pressed)) {
              return palette.accent.withValues(alpha: 0.82);
            }
            if (states.contains(WidgetState.hovered)) {
              return palette.accent.withValues(alpha: 0.92);
            }
            return palette.accent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.textMuted.withValues(alpha: 0.8);
            }
            return isDark ? palette.backgroundDeep : palette.backgroundSoft;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return palette.backgroundDeep.withValues(alpha: 0.12);
            }
            return null;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: palette.accent.withValues(alpha: 0.9)),
          ),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.3),
          ),
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.textMuted.withValues(alpha: 0.8);
            }
            return isDark ? palette.backgroundDeep : palette.backgroundSoft;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.transparent;
            }
            if (states.contains(WidgetState.pressed)) {
              return palette.panelMuted.withValues(alpha: isDark ? 0.9 : 0.9);
            }
            if (states.contains(WidgetState.hovered)) {
              return palette.panelMuted.withValues(alpha: isDark ? 0.7 : 0.7);
            }
            return palette.panelRaised.withValues(alpha: isDark ? 0.36 : 0.6);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.textMuted.withValues(alpha: 0.7);
            }
            return palette.textPrimary;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: palette.border.withValues(alpha: 0.5));
            }
            if (states.contains(WidgetState.hovered)) {
              return BorderSide(
                color: palette.accent.withValues(alpha: isDark ? 0.55 : 0.4),
              );
            }
            return BorderSide(
              color: palette.borderStrong.withValues(
                alpha: isDark ? 0.7 : 0.55,
              ),
            );
          }),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.3),
          ),
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.textMuted.withValues(alpha: 0.7);
            }
            return palette.textPrimary;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.textMuted.withValues(alpha: 0.7);
            }
            return palette.accent;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return palette.accent.withValues(alpha: 0.14);
            }
            if (states.contains(WidgetState.hovered)) {
              return palette.accent.withValues(alpha: 0.08);
            }
            return null;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(letterSpacing: 0.3),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.accent.withValues(alpha: isDark ? 0.16 : 0.14);
            }
            if (states.contains(WidgetState.hovered)) {
              return palette.panelMuted.withValues(alpha: isDark ? 0.8 : 0.7);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.accent;
            }
            return palette.textMuted;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: palette.borderStrong.withValues(
                alpha: isDark ? 0.55 : 0.4,
              ),
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          ),
          textStyle: WidgetStatePropertyAll(
            _monoStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return palette.accent;
            }
            return palette.textMuted;
          }),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: palette.panelMuted.withValues(alpha: 0.6),
        selectedColor: palette.accent.withValues(alpha: 0.16),
        side: BorderSide(color: palette.border.withValues(alpha: 0.9)),
        labelStyle: _monoStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
          letterSpacing: 0.3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textMuted,
        textColor: palette.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.panelRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          side: BorderSide(color: palette.border),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accent,
        selectionColor: palette.accent.withValues(alpha: 0.28),
        selectionHandleColor: palette.accent,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextStyle _uiStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: kUiFontFamilies.first,
      fontFamilyFallback: kUiFontFamilies.sublist(1),
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _monoStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: kMonoFontFamily,
      fontFamilyFallback: kMonoFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height ?? 1.25,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

/// 复用的排版工具：眉标、等宽元数据与仪表数值。
abstract final class AppTypography {
  /// 小节眉标：等宽、全大写、字距放宽，像设备铭牌上的编号。
  static TextStyle eyebrow(
    BuildContext context, {
    Color? color,
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final colors = AppTheme.colorsOf(context);
    return TextStyle(
      fontFamily: kMonoFontFamily,
      fontFamilyFallback: kMonoFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 1.6,
      height: 1.2,
      color: color ?? colors.textMuted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// 等宽正文：路径、命令、版本号、时间戳。
  static TextStyle mono({
    Color? color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.45,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: kMonoFontFamily,
      fontFamilyFallback: kMonoFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// 仪表读数：大号、紧字距、等宽对齐。
  static TextStyle readout({
    required Color color,
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: kMonoFontFamily,
      fontFamilyFallback: kMonoFontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1,
      letterSpacing: -1.0,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
