import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/config_model.dart';
import '../templates/test_templates.dart';

class TestGenerator {
  final CleanForgeConfig config;

  TestGenerator(this.config);

  Future<void> generateFeatureTests(String featureName) async {
    final testDir = path.join('test', 'features', featureName);
    final className = _toPascalCase(featureName);

    final testTemplates = TestTemplates(config, featureName, className);

    // Generate data layer tests
    await _writeTestFile(
      path.join(testDir, 'data', 'datasources', '${featureName}_remote_data_source_test.dart'),
      testTemplates.remoteDataSourceTest,
    );

    await _writeTestFile(
      path.join(testDir, 'data', 'datasources', '${featureName}_local_data_source_test.dart'),
      testTemplates.localDataSourceTest,
    );

    await _writeTestFile(
      path.join(testDir, 'data', 'models', '${featureName}_model_test.dart'),
      testTemplates.modelTest,
    );

    await _writeTestFile(
      path.join(testDir, 'data', 'repositories', '${featureName}_repository_impl_test.dart'),
      testTemplates.repositoryImplTest,
    );

    // Generate domain layer tests
    await _writeTestFile(
      path.join(testDir, 'domain', 'usecases', 'get_${featureName}_test.dart'),
      testTemplates.getUseCaseTest,
    );

    // Generate presentation layer tests based on state management
    switch (config.defaultStateManagement) {
      case StateManagement.bloc:
        await _writeTestFile(
          path.join(testDir, 'presentation', 'bloc', '${featureName}_bloc_test.dart'),
          testTemplates.blocTest,
        );
        break;
      case StateManagement.cubit:
        await _writeTestFile(
          path.join(testDir, 'presentation', 'cubit', '${featureName}_cubit_test.dart'),
          testTemplates.cubitTest,
        );
        break;
      case StateManagement.riverpod:
        await _writeTestFile(
          path.join(testDir, 'presentation', 'providers', '${featureName}_provider_test.dart'),
          testTemplates.riverpodTest,
        );
        break;
      case StateManagement.provider:
        await _writeTestFile(
          path.join(testDir, 'presentation', 'providers', '${featureName}_provider_test.dart'),
          testTemplates.providerTest,
        );
        break;
      case StateManagement.getx:
        await _writeTestFile(
          path.join(testDir, 'presentation', 'controllers', '${featureName}_controller_test.dart'),
          testTemplates.getxTest,
        );
        break;
      case StateManagement.mobx:
        await _writeTestFile(
          path.join(testDir, 'presentation', 'stores', '${featureName}_store_test.dart'),
          testTemplates.mobxTest,
        );
        break;
      case StateManagement.none:
        break;
    }
  }

  Future<void> _writeTestFile(String filePath, String content) async {
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  String _toPascalCase(String text) {
    return text.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join('');
  }
}