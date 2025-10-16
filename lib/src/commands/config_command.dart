import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:interact/interact.dart';
import '../models/config_model.dart';

class ConfigCommand extends Command<int> {
  final Logger logger;

  ConfigCommand(this.logger) {
    argParser
      ..addOption(
        'state-management',
        abbr: 's',
        help: 'Set default state management',
        allowed: StateManagement.values.map((e) => e.name),
      )
      ..addOption(
        'di',
        help: 'Set default dependency injection',
        allowed: DependencyInjection.values.map((e) => e.name),
      )
      ..addFlag('tests', help: 'Enable/disable test generation')
      ..addFlag(
        'freezing',
        help: 'Enable/disable Freezing for immutable models',
      )
      ..addFlag(
        'equatable',
        help: 'Enable/disable Equatable for value equality',
      )
      ..addFlag(
        'dartz',
        help: 'Enable/disable Dartz for functional programming',
      )
      ..addFlag('show', help: 'Show current configuration', negatable: false)
      ..addFlag(
        'reset',
        help: 'Reset configuration to defaults',
        negatable: false,
      );
  }

  @override
  String get description => '''
Manage Clean Forge project configuration and settings.

This command allows you to view, update, and reset your Clean Forge configuration.
The configuration is stored in clean_forge.json in your project root and controls
default behavior for feature generation.

CONFIGURATION OPTIONS:
  State Management:     Default state management for new features
  Dependency Injection: Default DI solution for the project
  Generate Tests:       Whether to generate test files automatically
  Use Freezing:         Use Freezed for immutable model generation
  Use Equatable:        Use Equatable for value equality comparisons
  Use Dartz:            Use Dartz for functional programming (Either, Option)

AVAILABLE STATE MANAGEMENT:
  • bloc - flutter_bloc with events and states
  • cubit - flutter_bloc simplified (Cubit only)
  • riverpod - Modern reactive state management
  • provider - Simple dependency injection and state
  • getx - Lightweight reactive framework
  • mobx - Observable-based state management
  • none - No state management (manual implementation)

AVAILABLE DEPENDENCY INJECTION:
  • getIt - Lightweight service locator
  • injectable - Code generation for get_it
  • riverpod - Provider-based DI
  • provider - InheritedWidget-based DI
  • none - Manual dependency management

OPTIONS:
  --state-management, -s    Set default state management
  --di                       Set default dependency injection
  --[no-]tests               Enable/disable test generation
  --[no-]freezing            Enable/disable Freezing
  --[no-]equatable           Enable/disable Equatable
  --[no-]dartz               Enable/disable Dartz
  --show                     Display current configuration
  --reset                    Reset to default configuration

EXAMPLES:
  clean_forge config --show                          # View current config
  clean_forge config --state-management=riverpod     # Change state management
  clean_forge config --di=getIt --no-tests           # Change DI and disable tests
  clean_forge config --reset                         # Reset to defaults

Configuration changes only affect newly generated features. Existing features
remain unchanged. Use 'clean_forge init' to set up initial configuration.
''';

  @override
  String get name => 'config';

  @override
  Future<int> run() async {
    if (argResults!['show'] as bool) {
      return _showConfig();
    }

    if (argResults!['reset'] as bool) {
      return _resetConfig();
    }

    // Load existing config or create default
    CleanForgeConfig config =
        CleanForgeConfig.loadFromFile() ?? CleanForgeConfig();

    // Update config based on flags
    bool hasChanges = false;

    if (argResults!.wasParsed('state-management')) {
      final stateManagement = StateManagement.values.firstWhere(
        (e) => e.name == argResults!['state-management'],
      );
      config = config.copyWith(defaultStateManagement: stateManagement);
      hasChanges = true;
    }

    if (argResults!.wasParsed('di')) {
      final di = DependencyInjection.values.firstWhere(
        (e) => e.name == argResults!['di'],
      );
      config = config.copyWith(defaultDi: di);
      hasChanges = true;
    }

    if (argResults!.wasParsed('tests')) {
      config = config.copyWith(generateTests: argResults!['tests'] as bool);
      hasChanges = true;
    }

    if (argResults!.wasParsed('freezing')) {
      config = config.copyWith(useFreezing: argResults!['freezing'] as bool);
      hasChanges = true;
    }

    if (argResults!.wasParsed('equatable')) {
      config = config.copyWith(useEquatable: argResults!['equatable'] as bool);
      hasChanges = true;
    }

    if (argResults!.wasParsed('dartz')) {
      config = config.copyWith(useDartz: argResults!['dartz'] as bool);
      hasChanges = true;
    }

    if (!hasChanges) {
      logger.info('No configuration changes specified.');
      logger.info('Use --help to see available options.');
      return ExitCode.usage.code;
    }

    // Interactive mode if no specific options provided
    if (!argResults!.wasParsed('state-management') &&
        !argResults!.wasParsed('di') &&
        !argResults!.wasParsed('tests') &&
        !argResults!.wasParsed('freezing') &&
        !argResults!.wasParsed('equatable') &&
        !argResults!.wasParsed('dartz')) {
      config = await _interactiveConfig(config);
    }

    config.saveToFile();
    logger.info('✅ Configuration updated successfully!');

    _displayConfig(config);

    return ExitCode.success.code;
  }

  Future<CleanForgeConfig> _interactiveConfig(
    CleanForgeConfig currentConfig,
  ) async {
    logger.info('🔧 Interactive Configuration\n');

    final stateManagement = Select(
      prompt: 'Choose default state management:',
      options: StateManagement.values.map((e) => e.displayName).toList(),
      initialIndex: StateManagement.values.indexOf(
        currentConfig.defaultStateManagement,
      ),
    ).interact();

    final di = Select(
      prompt: 'Choose default dependency injection:',
      options: DependencyInjection.values.map((e) => e.displayName).toList(),
      initialIndex: DependencyInjection.values.indexOf(currentConfig.defaultDi),
    ).interact();

    final generateTests = Confirm(
      prompt: 'Generate test files?',
      defaultValue: currentConfig.generateTests,
    ).interact();

    final useFreezing = Confirm(
      prompt: 'Use Freezing for immutable models?',
      defaultValue: currentConfig.useFreezing,
    ).interact();

    final useEquatable = Confirm(
      prompt: 'Use Equatable for value equality?',
      defaultValue: currentConfig.useEquatable,
    ).interact();

    final useDartz = Confirm(
      prompt: 'Use Dartz for functional programming (Either, Option)?',
      defaultValue: currentConfig.useDartz,
    ).interact();

    return CleanForgeConfig(
      defaultStateManagement: StateManagement.values[stateManagement],
      defaultDi: DependencyInjection.values[di],
      generateTests: generateTests,
      useFreezing: useFreezing,
      useEquatable: useEquatable,
      useDartz: useDartz,
    );
  }

  int _showConfig() {
    final config = CleanForgeConfig.loadFromFile();
    if (config == null) {
      logger.err('❌ No configuration found. Run: clean_forge init');
      return ExitCode.usage.code;
    }

    logger.info('📋 Current Configuration:');
    _displayConfig(config);
    return ExitCode.success.code;
  }

  int _resetConfig() {
    final confirm = Confirm(
      prompt: 'Reset configuration to defaults?',
      defaultValue: false,
    ).interact();

    if (!confirm) return ExitCode.success.code;

    final defaultConfig = CleanForgeConfig();
    defaultConfig.saveToFile();

    logger.info('✅ Configuration reset to defaults!');
    _displayConfig(defaultConfig);

    return ExitCode.success.code;
  }

  void _displayConfig(CleanForgeConfig config) {
    logger.info(
      '  State Management: ${config.defaultStateManagement.displayName}',
    );
    logger.info('  Dependency Injection: ${config.defaultDi.displayName}');
    logger.info('  Generate Tests: ${config.generateTests ? "✓" : "✗"}');
    logger.info('  Use Freezing: ${config.useFreezing ? "✓" : "✗"}');
    logger.info('  Use Equatable: ${config.useEquatable ? "✓" : "✗"}');
    logger.info('  Use Dartz: ${config.useDartz ? "✓" : "✗"}');
  }
}

extension on CleanForgeConfig {
  CleanForgeConfig copyWith({
    StateManagement? defaultStateManagement,
    DependencyInjection? defaultDi,
    bool? generateTests,
    bool? generateIntegrationTests,
    bool? useFreezing,
    bool? useEquatable,
    bool? useDartz,
    String? organizationName,
    Map<String, dynamic>? customPaths,
  }) {
    return CleanForgeConfig(
      defaultStateManagement:
          defaultStateManagement ?? this.defaultStateManagement,
      defaultDi: defaultDi ?? this.defaultDi,
      generateTests: generateTests ?? this.generateTests,
      generateIntegrationTests:
          generateIntegrationTests ?? this.generateIntegrationTests,
      useFreezing: useFreezing ?? this.useFreezing,
      useEquatable: useEquatable ?? this.useEquatable,
      useDartz: useDartz ?? this.useDartz,
      organizationName: organizationName ?? this.organizationName,
      customPaths: customPaths ?? this.customPaths,
    );
  }
}
