import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/config_model.dart';
import '../templates/base_templates.dart';
import '../templates/bloc_templates.dart';
import '../templates/cubit_templates.dart';
import '../templates/riverpod_templates.dart';
import '../templates/provider_templates.dart';
import '../templates/getx_templates.dart';
import '../templates/mobx_templates.dart';

class FileGenerator {
  final CleanForgeConfig config;

  FileGenerator(this.config);

  Future<void> generateCoreFiles(String libPath) async {
    // Generate base files
    final baseTemplates = BaseTemplates(config);

    await _writeFile(
      path.join(libPath, 'core/error/exceptions.dart'),
      baseTemplates.exceptionsTemplate,
    );

    await _writeFile(
      path.join(libPath, 'core/error/failures.dart'),
      baseTemplates.failuresTemplate,
    );

    await _writeFile(
      path.join(libPath, 'core/usecases/usecase.dart'),
      baseTemplates.useCaseTemplate,
    );

    await _writeFile(
      path.join(libPath, 'core/network/network_info.dart'),
      baseTemplates.networkInfoTemplate(config.defaultDi == DependencyInjection.injectable),
    );

    // Generate DI container if needed
    if (config.defaultDi == DependencyInjection.getIt) {
      await _writeFile(
        path.join(libPath, 'injection_container.dart'),
        baseTemplates.getItContainerTemplate,
      );
    } else if (config.defaultDi == DependencyInjection.injectable) {
      await _writeFile(
        path.join(libPath, 'injection_container.dart'),
        baseTemplates.injectableContainerTemplate,
      );
    }
  }

  Future<void> generateFeatureFiles(
    String featureDir,
    String featureName,
    StateManagement stateManagement, {
    bool generateCrud = false,
  }) async {
    // Generate data layer
    await _generateDataLayer(featureDir, featureName);

    // Generate domain layer
    await _generateDomainLayer(featureDir, featureName, generateCrud);

    // Generate presentation layer
    await _generatePresentationLayer(
      featureDir,
      featureName,
      stateManagement,
      generateCrud,
    );
  }

  Future<void> _generateDataLayer(String featureDir, String featureName) async {
    final baseTemplates = BaseTemplates(config);
    final className = _toPascalCase(featureName);

    // Remote data source
    await _writeFile(
      path.join(featureDir, 'data/datasources/remote/${featureName}_remote_data_source.dart'),
      baseTemplates.remoteDataSourceTemplate(featureName, className),
    );

    // Local data source
    await _writeFile(
      path.join(featureDir, 'data/datasources/local/${featureName}_local_data_source.dart'),
      baseTemplates.localDataSourceTemplate(featureName, className),
    );

    // Model
    await _writeFile(
      path.join(featureDir, 'data/models/${featureName}_model.dart'),
      baseTemplates.modelTemplate(featureName, className),
    );

    // Repository implementation
    await _writeFile(
      path.join(featureDir, 'data/repositories/${featureName}_repository_impl.dart'),
      baseTemplates.repositoryImplTemplate(featureName, className),
    );
  }

  Future<void> _generateDomainLayer(
    String featureDir,
    String featureName,
    bool generateCrud,
  ) async {
    final baseTemplates = BaseTemplates(config);
    final className = _toPascalCase(featureName);

    // Entity
    await _writeFile(
      path.join(featureDir, 'domain/entities/$featureName.dart'),
      baseTemplates.entityTemplate(featureName, className),
    );

    // Repository interface
    await _writeFile(
      path.join(featureDir, 'domain/repositories/${featureName}_repository.dart'),
      baseTemplates.repositoryTemplate(featureName, className, generateCrud),
    );

    // Use cases
    if (generateCrud) {
      await _writeFile(
        path.join(featureDir, 'domain/usecases/create_$featureName.dart'),
        baseTemplates.createUseCaseTemplate(featureName, className),
      );

      await _writeFile(
        path.join(featureDir, 'domain/usecases/get_$featureName.dart'),
        baseTemplates.getUseCaseTemplate(featureName, className),
      );

      await _writeFile(
        path.join(featureDir, 'domain/usecases/update_$featureName.dart'),
        baseTemplates.updateUseCaseTemplate(featureName, className),
      );

      await _writeFile(
        path.join(featureDir, 'domain/usecases/delete_$featureName.dart'),
        baseTemplates.deleteUseCaseTemplate(featureName, className),
      );
    } else {
      await _writeFile(
        path.join(featureDir, 'domain/usecases/get_$featureName.dart'),
        baseTemplates.getUseCaseTemplate(featureName, className),
      );
    }
  }

  Future<void> _generatePresentationLayer(
    String featureDir,
    String featureName,
    StateManagement stateManagement,
    bool generateCrud,
  ) async {
    final className = _toPascalCase(featureName);

    // Generate state management specific files
    switch (stateManagement) {
      case StateManagement.bloc:
        final blocTemplates = BlocTemplates(config, featureName, className);
        await _writeFile(
          path.join(featureDir, 'presentation/bloc/${featureName}_bloc.dart'),
          blocTemplates.blocFile(generateCrud),
        );
        await _writeFile(
          path.join(featureDir, 'presentation/bloc/${featureName}_event.dart'),
          blocTemplates.eventFile(generateCrud),
        );
        await _writeFile(
          path.join(featureDir, 'presentation/bloc/${featureName}_state.dart'),
          blocTemplates.stateFile,
        );
        break;

      case StateManagement.cubit:
        final cubitTemplates = CubitTemplates(config, featureName, className);
        await _writeFile(
          path.join(featureDir, 'presentation/cubit/${featureName}_cubit.dart'),
          cubitTemplates.cubitFile(generateCrud),
        );
        await _writeFile(
          path.join(featureDir, 'presentation/cubit/${featureName}_state.dart'),
          cubitTemplates.stateFile,
        );
        break;

      case StateManagement.riverpod:
        final riverpodTemplates = RiverpodTemplates(config, featureName, className);
        await _writeFile(
          path.join(featureDir, 'presentation/providers/${featureName}_provider.dart'),
          riverpodTemplates.providerFile(generateCrud),
        );
        break;

      case StateManagement.provider:
        final providerTemplates = ProviderTemplates(config, featureName, className);
        await _writeFile(
          path.join(featureDir, 'presentation/providers/${featureName}_provider.dart'),
          providerTemplates.providerFile(generateCrud),
        );
        break;

      case StateManagement.getx:
        final getxTemplates = GetXTemplates(config, featureName, className);
        await _writeFile(
          path.join(featureDir, 'presentation/controllers/${featureName}_controller.dart'),
          getxTemplates.controllerFile(generateCrud),
        );
        break;

      case StateManagement.mobx:
        final mobxTemplates = MobXTemplates(config, featureName, className);
        await _writeFile(
          path.join(featureDir, 'presentation/stores/${featureName}_store.dart'),
          mobxTemplates.storeFile(generateCrud),
        );
        break;

      case StateManagement.none:
        break;
    }

    // Generate page
    await _writeFile(
      path.join(featureDir, 'presentation/pages/${featureName}_page.dart'),
      _pageTemplate(featureName, className, stateManagement),
    );

    // Generate widget
    await _writeFile(
      path.join(featureDir, 'presentation/widgets/${featureName}_widget.dart'),
      _widgetTemplate(featureName, className),
    );
  }

  String _pageTemplate(String featureName, String className, StateManagement sm) {
    // Implementation depends on state management
    return '''
import 'package:flutter/material.dart';

class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$className'),
      ),
      body: const Center(
        child: Text('$className Page'),
      ),
    );
  }
}
''';
  }

  String _widgetTemplate(String featureName, String className) {
    return '''
import 'package:flutter/material.dart';

class ${className}Widget extends StatelessWidget {
  const ${className}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('$className Widget'),
    );
  }
}
''';
  }

  Future<void> _writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  String _toPascalCase(String text) {
    return text.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join('');
  }
}