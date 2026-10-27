import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mise_gui/app/theme/app_theme.dart';
import 'package:mise_gui/shared/ui/app_panel.dart';
import 'package:mise_gui/services/mise_process_service.dart';

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({super.key, required this.value, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const _LoadingReadout(),
      error: (error, stackTrace) {
        final colors = AppTheme.colorsOf(context);
        final isMissingMise = isMiseCommandUnavailable(error);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AppPanel(
              child: isMissingMise
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOADING FAILED',
                          style: AppTypography.eyebrow(
                            context,
                            color: colors.warning,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '还没有检测到 mise',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '当前页面需要可用的 mise CLI 才能继续读取环境信息。先完成安装，再回到应用里刷新即可。',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.backgroundDeep.withValues(
                              alpha: 0.55,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadius.control,
                            ),
                            border: Border.all(color: colors.border),
                          ),
                          child: SelectableText(
                            recommendedMiseInstallCommand(),
                            style: AppTypography.mono(
                              color: colors.textPrimary,
                              fontSize: 12.5,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text('页面加载失败: $error'),
            ),
          ),
        );
      },
    );
  }
}

/// 统一的加载态：一个细环 + 等宽 "READING" 提示，避免页面突然空白。
class _LoadingReadout extends StatelessWidget {
  const _LoadingReadout();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.accent,
              backgroundColor: colors.panelMuted,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'READING ENVIRONMENT',
            style: AppTypography.eyebrow(context, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
