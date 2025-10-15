import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:interact/interact.dart';
import 'package:path/path.dart' as path;
import '../models/config_model.dart';
import '../generators/folder_generator.dart';
import '../generators/file_generator.dart';

class InitCommand extends Command<int> {
  final Logger logger;

  InitCommand(this.logger) {
    argParser
      ..addFlag('interactive', abbr: 'i', negatable: false)
      ..addOption('state-management', abbr: 's', defaultsTo: 'bloc')
      ..addOption('di', defaultsTo: 'get_it')
      ..addFlag('tests', defaultsTo: true)
      ..addFlag('freezing', defaultsTo: false)
      ..addFlag('equatable', defaultsTo: true)
      ..addFlag('dartz', defaultsTo: true);
  }

  @override
  String get description => '''
Initialize Clean Architecture project structure with interactive configuration.

This command sets up the core Clean Architecture foundation for your Flutter project,
including error handling, network utilities, dependency injection, and base use cases.

The command will:
• Create the standard Clean Architecture folder structure
• Generate core files (exceptions, failures, use cases, network info)
• Set up dependency injection container based on your choice
• Create a clean_forge.json configuration file
• Provide guidance on required dependencies

OPTIONS:
  --interactive, -i          Interactive setup with prompts (recommended for first-time use)
  --state-management, -s     Default state management [bloc, cubit, riverpod, provider, getx, mobx, none]
  --di                       Default dependency injection [getIt, injectable, riverpod, provider, none]
  --[no-]tests               Generate test files (default: enabled)
  --[no-]freezing            Use Freezing for immutable models (default: disabled)
  --[no-]equatable           Use Equatable for value equality (default: enabled)
  --[no-]dartz               Use Dartz for functional programming (default: enabled)

EXAMPLES:
  clean_forge init                           # Interactive setup
  clean_forge init --state-management=bloc   # Non-interactive with Bloc
  clean_forge init -i                        # Force interactive mode

After initialization, use 'clean_forge feature <name>' to create your first feature.
''';

  @override
  String get name => 'init';

  @override
  Future<int> run() async {
    final interactive = argResults!['interactive'] as bool;
    final currentDir = Directory.current.path;
    final libDir = path.join(currentDir, 'lib');

    if (!Directory(libDir).existsSync()) {
      logger.err('❌ No lib/ directory found. Are you in a Flutter project?');
      return ExitCode.usage.code;
    }

    final pubspecFile = File(path.join(currentDir, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      logger.err('❌ No pubspec.yaml found. Are you in a Flutter project?');
      return ExitCode.usage.code;
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    final nameLine = pubspecContent.split('\n').firstWhere(
      (line) => line.trim().startsWith('name:'),
      orElse: () => 'name: unknown',
    );
    final packageName = nameLine.split(':')[1].trim();

    final configFile = File(path.join(currentDir, 'clean_forge.json'));
    if (configFile.existsSync()) {
      final confirm = Confirm(
        prompt: 'clean_forge.json exists. Reinitialize?',
        defaultValue: false,
      ).interact();
      if (!confirm) return ExitCode.success.code;
    }

    final config = interactive ? await _interactiveSetup(packageName) : _parseFromArgs(packageName);
    config.saveToFile();
    logger.info('💾 Configuration saved');

    final progress = logger.progress('🏗️  Generating core structure');

    try {
      final folderGen = FolderGenerator(libDir, config);
      await folderGen.generateCoreStructure();

      final fileGen = FileGenerator(config);
      await fileGen.generateCoreFiles(libDir);

      progress.complete('✅ Core structure created!');

      _displayCreatedStructure();
      _displayNextSteps(config);

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed: $e');
      return ExitCode.software.code;
    }
  }

  Future<CleanForgeConfig> _interactiveSetup(String packageName) async {
    logger.info('🚀 Interactive Setup\n');

    final stateManagement = Select(
      prompt: 'Choose state management:',
      options: StateManagement.values.map((e) => e.displayName).toList(),
    ).interact();

    final di = Select(
      prompt: 'Choose dependency injection:',
      options: DependencyInjection.values.map((e) => e.displayName).toList(),
    ).interact();

    final generateTests = Confirm(
      prompt: 'Generate test files?',
      defaultValue: true,
    ).interact();

    final useFreezing = Confirm(
      prompt: 'Use Freezing for immutable models?',
      defaultValue: false,
    ).interact();

    final useEquatable = Confirm(
      prompt: 'Use Equatable for value equality?',
      defaultValue: true,
    ).interact();

    final useDartz = Confirm(
      prompt: 'Use Dartz for functional programming (Either, Option)?',
      defaultValue: true,
    ).interact();

    return CleanForgeConfig(
      defaultStateManagement: StateManagement.values[stateManagement],
      defaultDi: DependencyInjection.values[di],
      generateTests: generateTests,
      useFreezing: useFreezing,
      useEquatable: useEquatable,
      useDartz: useDartz,
      packageName: packageName,
    );
  }

  CleanForgeConfig _parseFromArgs(String packageName) {
    return CleanForgeConfig(
      defaultStateManagement: StateManagement.values.firstWhere(
        (e) => e.name == argResults!['state-management'],
        orElse: () => StateManagement.bloc,
      ),
      defaultDi: DependencyInjection.values.firstWhere(
        (e) => e.displayName == argResults!['di'],
        orElse: () => DependencyInjection.getIt,
      ),
      generateTests: argResults!['tests'] as bool,
      useFreezing: argResults!['freezing'] as bool,
      useEquatable: argResults!['equatable'] as bool,
      useDartz: argResults!['dartz'] as bool,
      packageName: packageName,
    );
  }

  void _displayCreatedStructure() {
    logger.info('\n📁 Created structure:');
    final structure = '''
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── usecases/
│   │   └── usecase.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── utils/
│   └── constants/
├── features/
└── injection_container.dart
''';
    logger.info(structure);
  }

  void _displayNextSteps(CleanForgeConfig config) {
    logger.info('\n📝 Next steps:');
    logger.info('  1. Run: clean_forge feature <name> to create a feature');
    logger.info('  2. Add required dependencies to pubspec.yaml:');

    final deps = <String>[];
    if (config.useEquatable) deps.add('equatable');
    if (config.useDartz) deps.add('dartz');
    if (config.useFreezing) deps.add('freezed_annotation');

    switch (config.defaultStateManagement) {
      case StateManagement.bloc:
      case StateManagement.cubit:
        deps.add('flutter_bloc');
        break;
      case StateManagement.riverpod:
        deps.add('flutter_riverpod');
        break;
      case StateManagement.provider:
        deps.add('provider');
        break;
      case StateManagement.getx:
        deps.add('get');
        break;
      case StateManagement.mobx:
        deps.addAll(['mobx', 'flutter_mobx']);
        break;
      case StateManagement.none:
        break;
    }

    if (config.defaultDi == DependencyInjection.getIt) {
      deps.add('get_it');
    } else if (config.defaultDi == DependencyInjection.injectable) {
      deps.addAll(['get_it', 'injectable']);
    }

    deps.add('dio'); // For network calls
    deps.add('internet_connection_checker');

    for (final dep in deps) {
      logger.info('     - $dep');
    }
  }
}