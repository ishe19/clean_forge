import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:interact/interact.dart';
import 'package:path/path.dart' as path;

class CleanCommand extends Command<int> {
  final Logger logger;

  CleanCommand(this.logger) {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Skip confirmation prompts',
        negatable: false,
      )
      ..addFlag(
        'dry-run',
        help: 'Show what would be cleaned without actually doing it',
        negatable: false,
      )
      ..addOption(
        'feature',
        help: 'Clean a specific feature (removes the entire feature directory)',
      )
      ..addFlag(
        'all',
        help: 'Clean everything (core structure, features, and config)',
        negatable: false,
      );
  }

  @override
  String get description => '''
Clean generated files and directories with safety confirmations.

This command provides safe cleanup operations for Clean Forge generated content.
Use with caution as these operations cannot be easily undone.

CLEANUP MODES:
  • Feature-specific: Remove individual features and their tests
  • Full cleanup: Remove all generated files, core structure, and configuration
  • Interactive: Guided cleanup with confirmation prompts

SAFETY FEATURES:
  • Confirmation prompts (unless --force is used)
  • Dry-run mode to preview what would be removed
  • Selective cleanup options
  • Clear feedback on what will be removed

OPTIONS:
  --feature=<name>       Clean a specific feature (removes feature directory and tests)
  --all                  Clean everything (core, features, config) - USE WITH CAUTION
  --force, -f            Skip confirmation prompts
  --dry-run              Show what would be cleaned without actually doing it

WHAT GETS CLEANED:
  • Feature directories: lib/features/<feature_name>/
  • Test directories: test/features/<feature_name>/
  • Core structure: lib/core/, lib/features/, lib/injection/
  • Configuration: clean_forge.json

EXAMPLES:
  clean_forge clean --feature=user_auth           # Remove specific feature
  clean_forge clean --all --dry-run               # Preview full cleanup
  clean_forge clean --all --force                 # Force full cleanup (dangerous!)
  clean_forge clean                               # Interactive cleanup menu

WARNING:
  The --all option removes ALL generated content including your configuration.
  This action cannot be undone. Always use --dry-run first to see what will be removed.

For safety, this command always shows what will be removed and asks for confirmation
unless the --force flag is used. Use --dry-run to preview without making changes.
''';

  @override
  String get name => 'clean';

  @override
  Future<int> run() async {
    final currentDir = Directory.current.path;
    final libDir = path.join(currentDir, 'lib');

    if (!Directory(libDir).existsSync()) {
      logger.err('❌ No lib/ directory found. Are you in a Flutter project?');
      return ExitCode.usage.code;
    }

    final dryRun = argResults!['dry-run'] as bool;
    final force = argResults!['force'] as bool;

    if (argResults!.wasParsed('feature')) {
      return _cleanFeature(argResults!['feature'] as String, dryRun, force);
    }

    if (argResults!['all'] as bool) {
      return _cleanAll(dryRun, force);
    }

    // Interactive mode - show menu
    return _interactiveClean(dryRun, force);
  }

  Future<int> _cleanFeature(String featureName, bool dryRun, bool force) async {
    final currentDir = Directory.current.path;
    final featureDir = Directory(path.join(currentDir, 'lib', 'features', featureName));
    final testDir = Directory(path.join(currentDir, 'test', 'features', featureName));

    if (!featureDir.existsSync()) {
      logger.err('❌ Feature "$featureName" does not exist!');
      return ExitCode.usage.code;
    }

    if (!force && !dryRun) {
      final confirm = Confirm(
        prompt: 'Remove feature "$featureName" and all its files?',
        defaultValue: false,
      ).interact();

      if (!confirm) return ExitCode.success.code;
    }

    final progress = logger.progress('🧹 Cleaning feature: $featureName');

    try {
      if (dryRun) {
        logger.info('\n🔍 Would remove:');
        _listDirectoryContents(featureDir);
        if (testDir.existsSync()) {
          _listDirectoryContents(testDir);
        }
      } else {
        await featureDir.delete(recursive: true);
        if (testDir.existsSync()) {
          await testDir.delete(recursive: true);
        }
      }

      progress.complete(dryRun ? '✅ Dry run completed' : '✅ Feature "$featureName" cleaned!');
      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed: $e');
      return ExitCode.software.code;
    }
  }

  Future<int> _cleanAll(bool dryRun, bool force) async {
    if (!force && !dryRun) {
      final confirm = Confirm(
        prompt: 'Remove ALL generated files and configuration? This cannot be undone!',
        defaultValue: false,
      ).interact();

      if (!confirm) return ExitCode.success.code;
    }

    final progress = logger.progress('🧹 Cleaning everything');

    try {
      final currentDir = Directory.current.path;
      final configFile = File(path.join(currentDir, 'clean_forge.json'));

      if (dryRun) {
        logger.info('\n🔍 Would remove:');
        if (configFile.existsSync()) {
          logger.info('  📄 clean_forge.json');
        }

        final libDir = Directory(path.join(currentDir, 'lib'));
        if (libDir.existsSync()) {
          _listGeneratedDirectories(libDir);
        }

        final testDir = Directory(path.join(currentDir, 'test'));
        if (testDir.existsSync()) {
          _listGeneratedDirectories(testDir);
        }
      } else {
        // Remove config file
        if (configFile.existsSync()) {
          await configFile.delete();
        }

        // Remove generated directories
        await _removeGeneratedDirectories(path.join(currentDir, 'lib'));
        await _removeGeneratedDirectories(path.join(currentDir, 'test'));
      }

      progress.complete(dryRun ? '✅ Dry run completed' : '✅ Everything cleaned!');
      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed: $e');
      return ExitCode.software.code;
    }
  }

  Future<int> _interactiveClean(bool dryRun, bool force) async {
    final currentDir = Directory.current.path;
    final featuresDir = Directory(path.join(currentDir, 'lib', 'features'));

    logger.info('🧹 Clean Options:\n');

    final options = ['Clean specific feature', 'Clean everything'];

    // Check if there are features to clean
    final hasFeatures = featuresDir.existsSync() &&
        featuresDir.listSync().whereType<Directory>().isNotEmpty;

    if (!hasFeatures) {
      options.removeAt(0);
    }

    final choice = Select(
      prompt: 'What would you like to clean?',
      options: options,
    ).interact();

    if (options[choice] == 'Clean specific feature') {
      final featureDirs = featuresDir
          .listSync()
          .whereType<Directory>()
          .map((dir) => path.basename(dir.path))
          .toList();

      final featureChoice = Select(
        prompt: 'Select feature to clean:',
        options: featureDirs,
      ).interact();

      return _cleanFeature(featureDirs[featureChoice], dryRun, force);
    } else {
      return _cleanAll(dryRun, force);
    }
  }

  void _listDirectoryContents(Directory dir) {
    try {
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File) {
          logger.info('  📄 ${path.relative(entity.path, from: Directory.current.path)}');
        } else if (entity is Directory) {
          logger.info('  📁 ${path.relative(entity.path, from: Directory.current.path)}/');
        }
      }
    } catch (e) {
      // Ignore errors when listing contents
    }
  }

  void _listGeneratedDirectories(Directory baseDir) {
    final generatedDirs = [
      path.join(baseDir.path, 'core'),
      path.join(baseDir.path, 'features'),
      path.join(baseDir.path, 'injection'),
    ];

    for (final dirPath in generatedDirs) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        _listDirectoryContents(dir);
      }
    }
  }

  Future<void> _removeGeneratedDirectories(String basePath) async {
    final generatedDirs = [
      path.join(basePath, 'core'),
      path.join(basePath, 'features'),
      path.join(basePath, 'injection'),
    ];

    for (final dirPath in generatedDirs) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    }
  }
}