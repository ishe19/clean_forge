import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import '../models/config_model.dart';
import '../generators/folder_generator.dart';
import '../generators/file_generator.dart';
import '../generators/test_generator.dart';
import '../generators/di_generator.dart';
import '../utils/validators.dart';

class FeatureCommand extends Command<int> {
  final Logger logger;

  FeatureCommand(this.logger) {
    argParser
      ..addOption(
        'state-management',
        abbr: 's',
        help: 'Override default state management for this feature',
      )
      ..addFlag(
        'crud',
        help: 'Generate CRUD operations (Create, Read, Update, Delete)',
        negatable: false,
      )
      ..addFlag(
        'tests',
        help: 'Generate test files',
      )
      ..addFlag(
        'dry-run',
        help: 'Show what would be generated without creating files',
        negatable: false,
      );
  }

  @override
  String get description => '''
Generate a complete feature with Clean Architecture structure and state management.

This command creates a fully functional feature following Clean Architecture principles,
including data layer, domain layer, presentation layer, and comprehensive testing.

The command generates:
• 📁 Complete folder structure for the feature
• 🔄 Data sources (remote and local) with Dio integration
• 📊 Models with JSON serialization
• 🏛️  Domain entities and repository interfaces
• ⚡ Use cases with proper error handling
• 🎨 Presentation layer with your chosen state management
• 🧪 Comprehensive unit and integration tests

SUPPORTED STATE MANAGEMENT:
  • Bloc/Cubit - Event-driven state management with flutter_bloc
  • Riverpod - Modern reactive state management with providers
  • Provider - Simple dependency injection and state management
  • GetX - Lightweight reactive framework with controllers
  • MobX - Observable-based state management with stores
  • None - No state management (manual implementation)

OPTIONS:
  --state-management, -s    Override project's default state management
  --crud                    Generate full CRUD operations (Create, Read, Update, Delete)
  --[no-]tests              Generate test files (respects project config)
  --dry-run                 Preview what would be generated without creating files

FEATURE NAMING:
  Use lowercase with underscores: user_auth, product_catalog, shopping_cart
  Invalid: UserAuth, userAuth, user-auth

EXAMPLES:
  clean_forge feature user_auth                    # Basic feature with default settings
  clean_forge feature product --crud               # Feature with full CRUD operations
  clean_forge feature auth --state-management=getx # Override state management
  clean_forge feature payment --dry-run            # Preview generation

The generated code includes proper error handling, dependency injection setup,
and follows Flutter best practices. After generation, implement your business
logic in the data sources and customize the UI in the presentation layer.
''';

  @override
  String get name => 'feature';

  @override
  Future<int> run() async {
    if (argResults!.rest.isEmpty) {
      logger.err('❌ Feature name required');
      logger.info('Usage: clean_forge feature <feature_name>');
      return ExitCode.usage.code;
    }

    final featureName = argResults!.rest.first;

    // Validate feature name
    if (!Validators.isValidFeatureName(featureName)) {
      logger.err('❌ Invalid feature name. Use lowercase with underscores.');
      logger.info('Example: user_auth, product_catalog');
      return ExitCode.usage.code;
    }

    // Load config
    final config = CleanForgeConfig.loadFromFile();
    if (config == null) {
      logger.err('❌ Not initialized. Run: clean_forge init');
      return ExitCode.usage.code;
    }

    final currentDir = Directory.current.path;
    final featuresDir = path.join(currentDir, 'lib', 'features');
    final featureDir = path.join(featuresDir, featureName);

    // Check if feature exists
    if (Directory(featureDir).existsSync()) {
      logger.err('❌ Feature "$featureName" already exists!');
      return ExitCode.usage.code;
    }

    // Get state management (override or default)
    StateManagement stateManagement = config.defaultStateManagement;
    if (argResults!.wasParsed('state-management')) {
      stateManagement = StateManagement.values.firstWhere(
        (e) => e.name == argResults!['state-management'],
      );
    }

    final generateCrud = argResults!['crud'] as bool;
    final generateTests = argResults!['tests'] ?? config.generateTests;
    final dryRun = argResults!['dry-run'] as bool;

    if (dryRun) {
      _showDryRun(featureName, stateManagement, generateCrud);
      return ExitCode.success.code;
    }

    // Generate feature
    final progress = logger.progress('🚀 Generating feature: $featureName');

    try {
      // Create folders
      final folderGen = FolderGenerator(path.join(currentDir, 'lib'), config);
      await folderGen.generateFeatureStructure(featureName, stateManagement);

      // Generate files
      final fileGen = FileGenerator(config);
      await fileGen.generateFeatureFiles(
        featureDir,
        featureName,
        stateManagement,
        generateCrud: generateCrud,
      );

      // Generate tests
      if (generateTests) {
        final testGen = TestGenerator(config);
        await testGen.generateFeatureTests(featureName);
      }

      // Update DI container
      final diGen = DiGenerator(config);
      await diGen.updateInjectionContainer(featureName);

      progress.complete('✅ Feature "$featureName" generated!');

      _displaySummary(featureName, stateManagement, generateCrud, generateTests);

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed: $e');
      return ExitCode.software.code;
    }
  }

  void _showDryRun(
    String featureName,
    StateManagement stateManagement,
    bool crud,
  ) {
    logger.info('\n🔍 Dry run - would generate:\n');
    logger.info('Feature: $featureName');
    logger.info('State Management: ${stateManagement.displayName}');
    logger.info('CRUD: ${crud ? "Yes" : "No"}\n');

    logger.info('Files:');
    final files = [
      'data/datasources/${featureName}_remote_data_source.dart',
      'data/datasources/${featureName}_local_data_source.dart',
      'data/models/${featureName}_model.dart',
      'data/repositories/${featureName}_repository_impl.dart',
      'domain/entities/$featureName.dart',
      'domain/repositories/${featureName}_repository.dart',
    ];

    if (crud) {
      files.addAll([
        'domain/usecases/create_$featureName.dart',
        'domain/usecases/get_$featureName.dart',
        'domain/usecases/update_$featureName.dart',
        'domain/usecases/delete_$featureName.dart',
      ]);
    } else {
      files.add('domain/usecases/get_$featureName.dart');
    }

    files.addAll([
      'presentation/pages/${featureName}_page.dart',
      'presentation/widgets/${featureName}_widget.dart',
    ]);

    switch (stateManagement) {
      case StateManagement.bloc:
        files.addAll([
          'presentation/bloc/${featureName}_bloc.dart',
          'presentation/bloc/${featureName}_event.dart',
          'presentation/bloc/${featureName}_state.dart',
        ]);
        break;
      case StateManagement.cubit:
        files.addAll([
          'presentation/cubit/${featureName}_cubit.dart',
          'presentation/cubit/${featureName}_state.dart',
        ]);
        break;
      case StateManagement.riverpod:
      case StateManagement.provider:
        files.add('presentation/providers/${featureName}_provider.dart');
        break;
      case StateManagement.getx:
        files.add('presentation/controllers/${featureName}_controller.dart');
        break;
      case StateManagement.mobx:
        files.add('presentation/stores/${featureName}_store.dart');
        break;
      case StateManagement.none:
        break;
    }

    for (final file in files) {
      logger.info('  ✓ features/$featureName/$file');
    }
  }

  void _displaySummary(
    String featureName,
    StateManagement stateManagement,
    bool crud,
    bool tests,
  ) {
    logger.info('\n📊 Summary:');
    logger.info('  Feature: $featureName');
    logger.info('  State Management: ${stateManagement.displayName}');
    logger.info('  CRUD Operations: ${crud ? "✓" : "✗"}');
    logger.info('  Tests Generated: ${tests ? "✓" : "✗"}');
    logger.info('\n📝 Next steps:');
    logger.info('  1. Implement data sources in data/datasources/');
    logger.info('  2. Define your entity properties in domain/entities/');
    logger.info('  3. Add UI logic in presentation/');
    logger.info('  4. Run tests: flutter test test/features/$featureName/');
  }
}