import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/config_model.dart';

class FolderGenerator {
  final String libPath;
  final CleanForgeConfig config;

  FolderGenerator(this.libPath, this.config);

  Future<void> generateCoreStructure() async {
    final corePaths = [
      'core/error',
      'core/usecases',
      'core/utils',
      'core/network',
      'core/constants',
      'features',
    ];

    // Add DI folder if using get_it or injectable
    if (config.defaultDi == DependencyInjection.getIt ||
        config.defaultDi == DependencyInjection.injectable) {
      corePaths.add('injection');
    }

    for (final corePath in corePaths) {
      await _createDirectory(path.join(libPath, corePath));
    }
  }

  Future<void> generateFeatureStructure(
    String featureName,
    StateManagement stateManagement,
  ) async {
    final basePath = 'features/$featureName';

    final featurePaths = [
      '$basePath/data/datasources/local',
      '$basePath/data/datasources/remote',
      '$basePath/data/models',
      '$basePath/data/repositories',
      '$basePath/domain/entities',
      '$basePath/domain/repositories',
      '$basePath/domain/usecases',
      '$basePath/presentation/pages',
      '$basePath/presentation/widgets',
    ];

    // Add state management specific folders
    switch (stateManagement) {
      case StateManagement.bloc:
        featurePaths.add('$basePath/presentation/bloc');
        break;
      case StateManagement.cubit:
        featurePaths.add('$basePath/presentation/cubit');
        break;
      case StateManagement.riverpod:
      case StateManagement.provider:
        featurePaths.add('$basePath/presentation/providers');
        break;
      case StateManagement.getx:
        featurePaths.add('$basePath/presentation/controllers');
        break;
      case StateManagement.mobx:
        featurePaths.add('$basePath/presentation/stores');
        break;
      case StateManagement.none:
        break;
    }

    for (final featurePath in featurePaths) {
      await _createDirectory(path.join(libPath, featurePath));
    }
  }

  Future<void> _createDirectory(String dirPath) async {
    await Directory(dirPath).create(recursive: true);
  }
}