import 'package:flutter/material.dart';
import 'package:mise_gui/app/theme/app_theme.dart';

/// 页面骨架：眉标 + 大标题 + 技术分隔线 + 内容区。
///
/// 页头刻意保留大量留白，并把编号眉标放在标题上方，形成"工程手册"式的
/// 阅读顺序；内容区进入时做一次轻微的上浮淡入。
class AppPageScaffold extends StatefulWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.actions = const [],
    this.eyebrow,
  });

  final String title;
  final String description;
  final Widget child;
  final List<Widget> actions;

  /// 例：`01 / OVERVIEW`。缺省时不显示编号行。
  final String? eyebrow;

  @override
  State<AppPageScaffold> createState() => _AppPageScaffoldState();
}

class _AppPageScaffoldState extends State<AppPageScaffold> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final scrollBehavior = ScrollConfiguration.of(
      context,
    ).copyWith(scrollbars: false);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return ScrollConfiguration(
      behavior: scrollBehavior,
      child: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: false,
        thickness: 6,
        radius: const Radius.circular(AppRadius.pill),
        crossAxisMargin: 8,
        mainAxisMargin: 20,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(30, 30, 38, 32),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) => Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - progress)),
                child: child,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(
                  eyebrow: widget.eyebrow,
                  title: widget.title,
                  description: widget.description,
                  actions: widget.actions,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 26),
                  child: _TechRule(color: colors.border),
                ),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actions,
  });

  final String? eyebrow;
  final String title;
  final String description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final eyebrowText = eyebrow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrowText != null && eyebrowText.trim().isNotEmpty) ...[
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                eyebrowText.toUpperCase(),
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
                  color: colors.border.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 20,
          runSpacing: 18,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                  if (description.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actions.isNotEmpty)
              Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ),
      ],
    );
  }
}

/// 带刻度端点的分隔线，替代普通的 Divider。
class _TechRule extends StatelessWidget {
  const _TechRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.55)),
        ),
        const SizedBox(width: 10),
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 1,
              height: i == 1 ? 8 : 5,
              color: color.withValues(alpha: 0.8),
            ),
          ),
      ],
    );
  }
}
