import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/config_model.dart';

class DiGenerator {
  final CleanForgeConfig config;

  DiGenerator(this.config);

  Future<void> updateInjectionContainer(String featureName) async {
    final libPath = Directory.current.path;
    final injectionContainerPath = path.join(libPath, 'lib', 'injection_container.dart');

    if (!File(injectionContainerPath).existsSync()) {
      return; // No injection container to update
    }

    final content = await File(injectionContainerPath).readAsString();
    final className = _toPascalCase(featureName);

    // Add feature registrations based on DI system
    String updatedContent = content;

    if (config.defaultDi == DependencyInjection.getIt) {
      // Add GetIt registrations
      updatedContent = _addGetItRegistrations(updatedContent, featureName, className);
    } else if (config.defaultDi == DependencyInjection.injectable) {
      // For injectable, we need to regenerate the config file
      // This would require running build_runner, but we'll add a comment for now
      updatedContent = _addInjectableComment(updatedContent, featureName);
    }

    await File(injectionContainerPath).writeAsString(updatedContent);
  }

  String _addGetItRegistrations(String content, String featureName, String className) {
    // Find the "Features will be registered here" comment and add registrations
    final featureComment = '  // Features will be registered here';
    if (!content.contains(featureComment)) {
      return content;
    }

    final registrations = '''

  // $featureName feature
  sl.registerLazySingleton<${className}Repository>(
    () => ${className}RepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<${className}RemoteDataSource>(
    () => ${className}RemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<${className}LocalDataSource>(
    () => ${className}LocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton(() => Get$className(sl()));
''';

    return content.replaceFirst(featureComment, '$featureComment$registrations');
  }

  String _addInjectableComment(String content, String featureName) {
    // Add a comment indicating that injectable config needs to be regenerated
    final comment = '''
  // TODO: Run "flutter pub run build_runner build" to regenerate injection_container.config.dart
  // after adding @injectable annotations to $featureName feature classes
''';

    // Add at the end of the init function
    return content.replaceFirst(
      '  // Features will be registered here',
      '  // Features will be registered here$comment',
    );
  }

  String _toPascalCase(String text) {
    return text.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join('');
  }
}