import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

enum StateManagement {
  bloc,
  cubit,
  riverpod,
  provider,
  getx,
  mobx,
  none;

  String get displayName => name.toUpperCase();
}

enum DependencyInjection {
  getIt,
  injectable,
  riverpod,
  provider,
  none;

  String get displayName => name == 'getIt' ? 'get_it' : name;
}

class CleanForgeConfig {
  final StateManagement defaultStateManagement;
  final DependencyInjection defaultDi;
  final bool generateTests;
  final bool generateIntegrationTests;
  final bool useFreezing;
  final bool useEquatable;
  final bool useDartz;
  final String? organizationName;
  final Map<String, dynamic> customPaths;
  final String packageName;

  CleanForgeConfig({
    this.defaultStateManagement = StateManagement.bloc,
    this.defaultDi = DependencyInjection.getIt,
    this.generateTests = true,
    this.generateIntegrationTests = false,
    this.useFreezing = false,
    this.useEquatable = true,
    this.useDartz = true,
    this.organizationName,
    this.customPaths = const {},
    this.packageName = 'unknown',
  });

  factory CleanForgeConfig.fromJson(Map<String, dynamic> json) {
    return CleanForgeConfig(
      defaultStateManagement: StateManagement.values.firstWhere(
        (e) => e.name == json['defaultStateManagement'],
        orElse: () => StateManagement.bloc,
      ),
      defaultDi: DependencyInjection.values.firstWhere(
        (e) => e.name == json['defaultDi'],
        orElse: () => DependencyInjection.getIt,
      ),
      generateTests: json['generateTests'] ?? true,
      generateIntegrationTests: json['generateIntegrationTests'] ?? false,
      useFreezing: json['useFreezing'] ?? false,
      useEquatable: json['useEquatable'] ?? true,
      useDartz: json['useDartz'] ?? true,
      organizationName: json['organizationName'],
      customPaths: json['customPaths'] ?? {},
      packageName: json['packageName'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultStateManagement': defaultStateManagement.name,
      'defaultDi': defaultDi.name,
      'generateTests': generateTests,
      'generateIntegrationTests': generateIntegrationTests,
      'useFreezing': useFreezing,
      'useEquatable': useEquatable,
      'useDartz': useDartz,
      'organizationName': organizationName,
      'customPaths': customPaths,
      'packageName': packageName,
    };
  }

  static CleanForgeConfig? loadFromFile() {
    final configFile = File(
      path.join(Directory.current.path, 'clean_forge.json'),
    );
    if (!configFile.existsSync()) return null;

    try {
      final jsonString = configFile.readAsStringSync();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CleanForgeConfig.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  void saveToFile() {
    final configFile = File(
      path.join(Directory.current.path, 'clean_forge.json'),
    );
    configFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(toJson()),
    );
  }
}
