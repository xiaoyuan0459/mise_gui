import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mise_gui/app/bootstrap/dependencies.dart';
import 'package:mise_gui/app/router/app_destination.dart';
import 'package:mise_gui/app/theme/app_theme.dart';
import 'package:mise_gui/features/config/application/config_provider.dart';
import 'package:mise_gui/shared/ui/app_backdrop.dart';
import 'package:mise_gui/shared/ui/app_panel.dart';
import 'package:mise_gui/services/mise_process_service.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = AppDestination.values[navigationShell.currentIndex];
    final colors = AppTheme.colorsOf(context);
    final miseAvailableValue = ref.watch(miseAvailableProvider);
    final isMissingMise = miseAvailableValue.maybeWhen(
      data: (value) => !value,
      orElse: () => false,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        final expandedSidebar = constraints.maxWidth >= 1280;
        final immersiveMacDesktop =
            !compact &&
            !kIsWeb &&
            defaultTargetPlatform == TargetPlatform.macOS;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: compact
              ? AppBar(
                  title: _WindowChromeDoubleTapRegion(
                    child: Text(isMissingMise ? '安装 mise' : destination.label),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Center(child: _TopMetaRow(compact: true)),
                    ),
                  ],
                )
              : null,
          drawer: compact
              ? Drawer(
                  backgroundColor: colors.panel,
                  child: SafeArea(
                    child: _Sidebar(
                      currentIndex: navigationShell.currentIndex,
                      expanded: true,
                      locked: isMissingMise,
                      onSelect: (index) {
                        if (isMissingMise) {
                          return;
                        }
                        Navigator.of(context).pop();
                        navigationShell.goBranch(index);
                      },
                    ),
                  ),
                )
              : null,
          body: Stack(
            children: [
              const AppBackdrop(),
              SafeArea(
                top: !immersiveMacDesktop,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 14 : 20,
                    compact ? 14 : (immersiveMacDesktop ? 10 : 20),
                    compact ? 14 : 20,
                    compact ? 14 : 20,
                  ),
                  child: compact
                      ? _ContentPanel(
                          child: miseAvailableValue.when(
                            data: (available) => available
                                ? navigationShell
                                : const _MissingMiseExperience(),
                            loading: () => const _ShellLoadingView(),
                            error: (error, stackTrace) => navigationShell,
                          ),
                        )
                      : Column(
                          children: [
                            if (immersiveMacDesktop)
                              const _DesktopChromeBar()
                            else
                              const _TopBar(),
                            SizedBox(height: immersiveMacDesktop ? 8 : 12),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Sidebar(
                                    currentIndex: navigationShell.currentIndex,
                                    expanded: expandedSidebar,
                                    locked: isMissingMise,
                                    onSelect: isMissingMise
                                        ? (_) {}
                                        : navigationShell.goBranch,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _ContentPanel(
                                      child: miseAvailableValue.when(
                                        data: (available) => available
                                            ? navigationShell
                                            : const _MissingMiseExperience(),
                                        loading: () =>
                                            const _ShellLoadingView(),
                                        error: (error, stackTrace) =>
                                            navigationShell,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopChromeBar extends StatelessWidget {
  const _DesktopChromeBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 44,
      child: Stack(
        children: [
          Positioned.fill(left: 92, child: _WindowChromeDoubleTapRegion()),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 96),
              child: _StatusReadout(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(left: 92),
              child: _TopMetaRow(compact: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.currentIndex,
    required this.expanded,
    required this.locked,
    required this.onSelect,
  });

  final int currentIndex;
  final bool expanded;
  final bool locked;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.colorsOf(context);
    final appVersion = ref.watch(appVersionInfoProvider);
    final sidebarWidth = expanded ? 268.0 : 92.0;
    final sidebarPadding = expanded ? 14.0 : 10.0;

    return SizedBox(
      width: sidebarWidth,
      child: AppPanel(
        padding: EdgeInsets.fromLTRB(
          sidebarPadding,
          expanded ? 18 : 16,
          sidebarPadding,
          expanded ? 14 : 12,
        ),
        radius: AppRadius.panel,
        backgroundAlpha: 0.88,
        borderAlpha: 0.62,
        child: Column(
          crossAxisAlignment: expanded
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: expanded
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    if (expanded)
                      const _BrandLockup()
                    else
                      const Center(child: _BrandBadge(size: 40)),
                    SizedBox(height: expanded ? 20 : 16),
                    Container(
                      height: 1,
                      color: colors.border.withValues(alpha: 0.7),
                    ),
                    SizedBox(height: expanded ? 16 : 14),
                    if (expanded) ...[
                      Row(
                        children: [
                          Text(
                            'NAVIGATION',
                            style: AppTypography.eyebrow(context, fontSize: 9),
                          ),
                          const Spacer(),
                          Text(
                            '04',
                            style: AppTypography.mono(
                              color: colors.textMuted.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    for (final destination in AppDestination.values)
                      _SidebarDestinationBlock(
                        destination: destination,
                        currentIndex: currentIndex,
                        expanded: expanded,
                        locked: locked,
                        onSelect: onSelect,
                      ),
                    if (expanded) ...[
                      const SizedBox(height: 18),
                      _SidebarRuntimeStrip(locked: locked),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SidebarFooter(
              expanded: expanded,
              locked: locked,
              versionLabel: appVersion.maybeWhen(
                data: (value) => value.shortLabel,
                orElse: () => 'v1.0.0',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Row(
      children: [
        const _BrandBadge(size: 38),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MISE GUI',
                style: AppTypography.mono(
                  color: colors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'LOCAL ENV CONSOLE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.eyebrow(
                  context,
                  fontSize: 8,
                ).copyWith(letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarRuntimeStrip extends StatelessWidget {
  const _SidebarRuntimeStrip({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MANAGED RUNTIMES',
          style: AppTypography.eyebrow(context, fontSize: 8.5),
        ),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _RuntimePill(label: 'JAVA'),
            _RuntimePill(label: 'PYTHON'),
            _RuntimePill(label: 'GO'),
            _RuntimePill(label: 'NODE'),
            _RuntimePill(label: 'FLUTTER'),
            _RuntimePill(label: '+'),
          ],
        ),
        if (locked) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: colors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '先安装 mise，导航会自动解锁。',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.expanded,
    required this.locked,
    required this.versionLabel,
  });

  final bool expanded;
  final bool locked;
  final String versionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final stateColor = locked ? colors.warning : colors.accent;
    final stateLabel = locked ? 'MISE OFFLINE' : 'MISE LINKED';
    final versionStyle = AppTypography.mono(
      color: colors.textMuted.withValues(alpha: 0.8),
      fontSize: 9.5,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.8,
    );

    final dot = Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: stateColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: stateColor.withValues(alpha: 0.6), blurRadius: 6),
        ],
      ),
    );

    if (!expanded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(height: 8),
          Text(
            versionLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: versionStyle.copyWith(fontSize: 8.5),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            dot,
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                stateLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.eyebrow(
                  context,
                  color: stateColor,
                  fontSize: 8.5,
                ).copyWith(letterSpacing: 1.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('BUILD $versionLabel', style: versionStyle),
      ],
    );
  }
}

class _SidebarDestinationBlock extends ConsumerWidget {
  const _SidebarDestinationBlock({
    required this.destination,
    required this.currentIndex,
    required this.expanded,
    required this.locked,
    required this.onSelect,
  });

  final AppDestination destination;
  final int currentIndex;
  final bool expanded;
  final bool locked;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = !locked && currentIndex == destination.index;
    final isConfig = destination == AppDestination.config;
    final activeSection = ref.watch(selectedConfigSectionProvider);

    final main = Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: _SidebarDestination(
        destination: destination,
        expanded: expanded,
        selected: selected,
        locked: locked,
        onTap: () => onSelect(destination.index),
      ),
    );

    if (!isConfig || !expanded || locked) {
      return main;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        main,
        Padding(
          padding: const EdgeInsets.only(left: 26, bottom: 8, top: 2),
          child: _SidebarConfigChildren(
            currentIndex: currentIndex,
            activeSection: activeSection,
            onSelect: onSelect,
          ),
        ),
      ],
    );
  }
}

class _SidebarConfigChildren extends ConsumerWidget {
  const _SidebarConfigChildren({
    required this.currentIndex,
    required this.activeSection,
    required this.onSelect,
  });

  final int currentIndex;
  final ConfigSection activeSection;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.colorsOf(context);
    final active = currentIndex == AppDestination.config.index;

    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: colors.border.withValues(alpha: 0.75)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, section) in ConfigSection.values.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Material(
                color: active && section == activeSection
                    ? colors.accent.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                child: InkWell(
                  onTap: () {
                    ref.read(selectedConfigSectionProvider.notifier).state =
                        section;
                    onSelect(AppDestination.config.index);
                  },
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  hoverColor: active ? colors.hover : Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '0${index + 1}',
                          style: AppTypography.mono(
                            color: active && section == activeSection
                                ? colors.accent
                                : colors.textMuted.withValues(alpha: 0.6),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            section.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: active && section == activeSection
                                  ? colors.textPrimary
                                  : colors.textMuted,
                              fontSize: 12,
                              fontWeight: active && section == activeSection
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.destination,
    required this.expanded,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final AppDestination destination;
  final bool expanded;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? destination.selectedIcon : destination.icon;
    final colors = AppTheme.colorsOf(context);

    final indexLabel = '0${destination.index + 1}';
    final iconColor = locked
        ? colors.textMuted.withValues(alpha: 0.65)
        : selected
        ? colors.accent
        : colors.textMuted;

    return Tooltip(
      message: destination.label,
      child: Material(
        color: selected
            ? colors.accent.withValues(alpha: 0.09)
            : locked
            ? colors.panelMuted.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          hoverColor: locked ? Colors.transparent : colors.hover,
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(width: 2, color: colors.accent),
                ),
              Padding(
                padding: expanded
                    ? const EdgeInsets.fromLTRB(12, 10, 10, 10)
                    : const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  mainAxisAlignment: expanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 19, color: iconColor),
                    if (expanded) ...[
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: locked
                                    ? colors.textMuted
                                    : selected
                                    ? colors.textPrimary
                                    : colors.textPrimary.withValues(
                                        alpha: 0.86,
                                      ),
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              destination.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textMuted.withValues(alpha: 0.85),
                                fontSize: 10.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        indexLabel,
                        style: AppTypography.mono(
                          color: selected
                              ? colors.accent
                              : colors.textMuted.withValues(alpha: 0.55),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      if (locked) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: colors.textMuted,
                        ),
                      ],
                    ],
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

class _ContentPanel extends StatelessWidget {
  const _ContentPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.panel),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.panel.withValues(alpha: 0.26),
          borderRadius: BorderRadius.circular(AppRadius.panel),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: child,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 42,
      child: Stack(
        children: [
          Positioned.fill(child: _WindowChromeDoubleTapRegion()),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: _StatusReadout(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _TopMetaRow(compact: false),
          ),
        ],
      ),
    );
  }
}

/// 顶栏左侧的 CLI 连接状态读数。
class _StatusReadout extends ConsumerWidget {
  const _StatusReadout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.colorsOf(context);
    final miseAvailable = ref.watch(miseAvailableProvider);
    final loading = miseAvailable.isLoading;
    final linked = miseAvailable.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    final signalColor = loading
        ? colors.textMuted
        : linked
        ? colors.accent
        : colors.warning;
    final label = loading
        ? 'CHECKING'
        : linked
        ? 'LINKED'
        : 'MISSING';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: signalColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: signalColor.withValues(alpha: 0.7),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('MISE CLI', style: AppTypography.eyebrow(context, fontSize: 9)),
        const SizedBox(width: 8),
        Container(
          width: 1,
          height: 10,
          color: colors.border.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.mono(
            color: signalColor,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _WindowChromeDoubleTapRegion extends ConsumerWidget {
  const _WindowChromeDoubleTapRegion({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: () {
        unawaited(ref.read(desktopWindowServiceProvider).toggleMaximize());
      },
      child: child,
    );
  }
}

class _TopMetaRow extends ConsumerWidget {
  const _TopMetaRow({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = compact ? 8.0 : 12.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: const [_ToolbarGroup()],
    );
  }
}

class _ToolbarGroup extends ConsumerWidget {
  const _ToolbarGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.colorsOf(context);
    final themePreference = ref.watch(themePreferenceProvider);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.panelRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.control + 1),
        border: Border.all(color: colors.border.withValues(alpha: 0.9)),
      ),
      child: SegmentedButton<AppThemePreference>(
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity(horizontal: -2, vertical: -3),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        segments: const [
          ButtonSegment<AppThemePreference>(
            value: AppThemePreference.system,
            icon: Icon(Icons.brightness_auto_rounded, size: 16),
            label: Text('系统'),
          ),
          ButtonSegment<AppThemePreference>(
            value: AppThemePreference.light,
            icon: Icon(Icons.light_mode_rounded, size: 16),
            label: Text('浅色'),
          ),
          ButtonSegment<AppThemePreference>(
            value: AppThemePreference.dark,
            icon: Icon(Icons.dark_mode_rounded, size: 16),
            label: Text('深色'),
          ),
        ],
        selected: {themePreference},
        onSelectionChanged: (selection) {
          final nextPreference = selection.first;
          ref.read(themePreferenceProvider.notifier).state = nextPreference;
        },
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SvgPicture.asset(
        'assets/branding/mise_gui_logo.svg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _RuntimePill extends StatelessWidget {
  const _RuntimePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: colors.panelMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.borderStrong.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.mono(
          color: colors.textMuted,
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _ShellLoadingView extends StatelessWidget {
  const _ShellLoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 18),
          Text('正在检查 mise 是否可用', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '稍等一下，我们先确认当前设备能否直接调用 mise CLI。',
            style: TextStyle(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MissingMiseExperience extends ConsumerStatefulWidget {
  const _MissingMiseExperience();

  @override
  ConsumerState<_MissingMiseExperience> createState() =>
      _MissingMiseExperienceState();
}

class _MissingMiseExperienceState
    extends ConsumerState<_MissingMiseExperience> {
  static const _retryDebounce = Duration(seconds: 1);

  DateTime? _lastRetryAt;
  var _retrying = false;

  Future<void> _handleRetry() async {
    if (_retrying) {
      _showFeedback('正在重新检测，请稍候。');
      return;
    }

    final now = DateTime.now();
    if (_lastRetryAt != null &&
        now.difference(_lastRetryAt!) < _retryDebounce) {
      _showFeedback('点击过于频繁，请 1 秒后再试。');
      return;
    }

    _lastRetryAt = now;
    setState(() => _retrying = true);

    try {
      final available = await ref.refresh(miseAvailableProvider.future);
      _showFeedback(available ? '已检测到 mise CLI。' : '还没有检测到 mise CLI。');
    } catch (_) {
      _showFeedback('重新检测失败，请稍后重试。');
    } finally {
      if (mounted) {
        setState(() => _retrying = false);
      }
    }
  }

  void _showFeedback(String message) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final installCommand = recommendedMiseInstallCommand();
    final platformLabel = _currentPlatformLabel();

    return LayoutBuilder(
      builder: (context, viewport) {
        final targetHeight = viewport.maxHeight.isFinite
            ? (viewport.maxHeight - 56).clamp(720.0, 1600.0)
            : 760.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 34, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: targetHeight),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.panelRaised.withValues(alpha: 0.98),
                    colors.backgroundSoft.withValues(alpha: 0.92),
                    colors.accent.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.panel),
                border: Border.all(
                  color: colors.borderStrong.withValues(alpha: 0.75),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 1040;
                  final showFooterBand =
                      viewport.maxHeight >= 820 && constraints.maxWidth >= 760;
                  final hero = _MissingHeroText(platformLabel: platformLabel);
                  final commandCard = _InstallCommandCard(
                    installCommand: installCommand,
                    onCopy: () async {
                      await Clipboard.setData(
                        ClipboardData(text: installCommand),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('安装命令已复制到剪贴板。')),
                      );
                    },
                    onRetry: _handleRetry,
                    retrying: _retrying,
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        hero,
                        const SizedBox(height: 24),
                        commandCard,
                        if (showFooterBand) ...[
                          const SizedBox(height: 24),
                          const _MissingMiseFooterBand(),
                        ],
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: hero),
                          const SizedBox(width: 22),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 34),
                              child: commandCard,
                            ),
                          ),
                        ],
                      ),
                      if (showFooterBand) ...[
                        const SizedBox(height: 28),
                        const _MissingMiseFooterBand(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MissingHeroText extends StatelessWidget {
  const _MissingHeroText({required this.platformLabel});

  final String platformLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.warning,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'SETUP REQUIRED',
              style: AppTypography.eyebrow(
                context,
                color: colors.textMuted,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 1,
                color: colors.border.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('这台电脑还没有安装 mise', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 14),
        Text(
          'Mise GUI 依赖可用的 mise CLI 才能读取工具版本、项目覆盖关系和全局配置。先完成安装，右侧这些功能就会自动解锁。',
          style: TextStyle(color: colors.textMuted, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.panel.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Icon(Icons.terminal_rounded, color: colors.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$platformLabel 推荐安装方式',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '先安装，再点击右侧“重新检测”，应用就会进入正常视图。',
                          style: TextStyle(
                            color: colors.textMuted,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _StepRow(
                index: '01',
                title: '执行安装命令',
                description: '使用右侧命令在当前系统安装 mise。',
              ),
              const SizedBox(height: 12),
              const _StepRow(
                index: '02',
                title: '确认 CLI 可用',
                description: '安装完成后，先运行 `mise --version` 验证命令是否生效。',
              ),
              const SizedBox(height: 12),
              const _StepRow(
                index: '03',
                title: '回到应用重新检测',
                description: '安装完成后点击“重新检测”，左侧导航和完整页面会自动恢复。',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstallCommandCard extends StatelessWidget {
  const _InstallCommandCard({
    required this.installCommand,
    required this.onCopy,
    required this.onRetry,
    required this.retrying,
  });

  final String installCommand;
  final VoidCallback onCopy;
  final VoidCallback onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return AppPanel(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('安装命令', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '复制后在终端执行。安装完成后，不需要重新配置这个页面。',
                      style: TextStyle(color: colors.textMuted, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: colors.backgroundDeep.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.54
                    : 0.82,
              ),
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: colors.borderStrong),
            ),
            child: SelectableText(
              installCommand,
              style: TextStyle(
                fontFamily: kMonoFontFamily,
                fontFamilyFallback: kMonoFontFallback,
                fontSize: 14,
                height: 1.55,
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '安装完成后建议再执行一次：`mise --version`',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.content_copy_rounded),
                label: const Text('复制安装命令'),
              ),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: retrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(retrying ? '检测中...' : '重新检测'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissingMiseFooterBand extends StatelessWidget {
  const _MissingMiseFooterBand();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.panel.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('安装完成后你会立刻看到', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '环境总览、工具版本和全局配置都会自动接入，不需要再额外配置页面。',
            style: TextStyle(color: colors.textMuted, height: 1.55),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              SizedBox(
                width: 280,
                child: _FooterFeatureTile(
                  icon: Icons.space_dashboard_rounded,
                  title: '环境总览',
                  description: '活跃工具、PATH 导出和整体健康评分会直接显示。',
                ),
              ),
              SizedBox(
                width: 280,
                child: _FooterFeatureTile(
                  icon: Icons.handyman_rounded,
                  title: '工具版本',
                  description: '已安装版本、当前生效版本和来源关系会自动读出。',
                ),
              ),
              SizedBox(
                width: 320,
                child: _FooterFeatureTile(
                  icon: Icons.tune_rounded,
                  title: '全局配置',
                  description: '当前默认版本和配置文件内容会直接读出。',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterFeatureTile extends StatelessWidget {
  const _FooterFeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundSoft.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: colors.border.withValues(alpha: 0.9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: colors.info.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, color: colors.info, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(color: colors.textMuted, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.title,
    required this.description,
  });

  final String index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: colors.accent.withValues(alpha: 0.28)),
          ),
          alignment: Alignment.center,
          child: Text(
            index,
            style: TextStyle(
              color: colors.accent,
              fontFamily: kMonoFontFamily,
              fontFamilyFallback: kMonoFontFallback,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: colors.textMuted, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _currentPlatformLabel() {
  if (Platform.isMacOS) {
    return 'macOS';
  }
  if (Platform.isWindows) {
    return 'Windows';
  }
  if (Platform.isLinux) {
    return 'Linux';
  }
  return '当前系统';
}
