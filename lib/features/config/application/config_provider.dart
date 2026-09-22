import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mise_gui/app/bootstrap/dependencies.dart';
import 'package:mise_gui/features/projects/application/projects_provider.dart';
import 'package:mise_gui/models/app_models.dart';

/// 配置页左侧子菜单对应的分区。
enum ConfigSection {
  global('全局配置', '配置文件与项目覆盖'),
  tools('默认工具与版本', '选择全局默认管理的工具及其版本'),
  runtime('运行时 / 代理 / 其它', '运行时设置、网络代理与其它区段');

  const ConfigSection(this.label, this.description);

  final String label;
  final String description;
}

final selectedConfigSectionProvider = StateProvider<ConfigSection>(
  (ref) => ConfigSection.global,
);

final selectedConfigProjectPathProvider = StateProvider<String?>((ref) => null);

final selectedConfigProjectProvider = Provider<ProjectRecord?>((ref) {
  final requestedPath = ref.watch(selectedConfigProjectPathProvider);
  final projects = ref
      .watch(projectsProvider)
      .maybeWhen(data: (items) => items, orElse: () => const <ProjectRecord>[]);

  if (projects.isEmpty) {
    return null;
  }

  ProjectRecord? findByPath(String path) {
    for (final project in projects) {
      if (project.path == path) {
        return project;
      }
    }
    return null;
  }

  if (requestedPath case final path?) {
    final selected = findByPath(path);
    if (selected != null) {
      return selected;
    }
  }

  final currentProject = findByPath(Directory.current.path);
  return currentProject ?? projects.first;
});

final configProvider = FutureProvider<ConfigWorkspaceData>((ref) {
  final project = ref.watch(selectedConfigProjectProvider);
  final hasTrackedProject = project != null;
  return ref
      .watch(configRepositoryProvider)
      .loadWorkspace(
        projectPath: project?.path,
        projectConfigPath: project?.configPath,
        projectName: project?.name,
        includeProjectConfig: hasTrackedProject,
      );
});
