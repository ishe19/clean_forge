import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:clean_forge/src/commands/init_command.dart';
import 'package:clean_forge/src/commands/feature_command.dart';
import 'package:clean_forge/src/commands/config_command.dart';
import 'package:clean_forge/src/commands/clean_command.dart';

const version = '0.1.0';

Future<void> main(List<String> args) async {
  final logger = Logger();

  final runner =
      CommandRunner<int>(
          'clean_forge',
          '''
🔥 Clean Forge - Next-Gen Clean Architecture CLI for Flutter

Clean Forge is a comprehensive CLI tool that generates production-ready Clean Architecture
features with full state management support, dependency injection, and comprehensive testing.

FEATURES:
• 🏗️  Clean Architecture structure generation
• 🎯 7 State Management Options (Bloc, Cubit, Riverpod, Provider, GetX, MobX, None)
• 💉 5 Dependency Injection Options (GetIt, Injectable, Riverpod, Provider, None)
• 🧪 Comprehensive test generation (Unit, Integration, Widget tests)
• 🔄 CRUD scaffolding for full feature development
• ⚙️  Project-level configuration management
• 🧹 Safe cleanup and reset operations
• 🎨 Interactive setup with beautiful CLI prompts

QUICK START:
  clean_forge init                    # Initialize project with interactive setup
  clean_forge feature user_auth       # Generate a complete user authentication feature
  clean_forge config --show           # View current configuration
  clean_forge clean --feature=user_auth # Remove a specific feature

SUPPORTED STATE MANAGEMENT:
  • Bloc/Cubit - flutter_bloc with events and states
  • Riverpod - Modern reactive state management
  • Provider - Simple dependency injection and state
  • GetX - Lightweight reactive framework
  • MobX - Observable-based state management

For detailed help on any command, use: clean_forge <command> --help
''',
        )
        ..addCommand(InitCommand(logger))
        ..addCommand(FeatureCommand(logger))
        ..addCommand(ConfigCommand(logger))
        ..addCommand(CleanCommand(logger))
        ..argParser.addFlag(
          'version',
          abbr: 'v',
          negatable: false,
          help: 'Print the current version.',
        );

  try {
    final argResults = runner.parse(args);

    if (argResults['version'] == true) {
      logger.info('clean_forge version: $version');
      return;
    }

    final exitCode = await runner.run(args) ?? ExitCode.success.code;
    exit(exitCode);
  } on UsageException catch (e) {
    logger
      ..err(e.message)
      ..info('')
      ..info(e.usage);
    exit(ExitCode.usage.code);
  } catch (e) {
    logger.err('$e');
    exit(ExitCode.software.code);
  }
}
