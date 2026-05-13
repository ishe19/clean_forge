import 'config_model.dart';

class FeatureConfig {
  final String featureName;
  final StateManagement? stateManagementOverride;
  final bool generateCrud;
  final bool generateTests;
  final Map<String, String> customPaths;

  const FeatureConfig({
    required this.featureName,
    this.stateManagementOverride,
    this.generateCrud = false,
    this.generateTests = true,
    this.customPaths = const {},
  });

  FeatureConfig copyWith({
    StateManagement? stateManagementOverride,
    bool? generateCrud,
    bool? generateTests,
    Map<String, String>? customPaths,
  }) {
    return FeatureConfig(
      featureName: featureName,
      stateManagementOverride:
          stateManagementOverride ?? this.stateManagementOverride,
      generateCrud: generateCrud ?? this.generateCrud,
      generateTests: generateTests ?? this.generateTests,
      customPaths: customPaths ?? this.customPaths,
    );
  }

  StateManagement effectiveStateManagement(CleanForgeConfig globalConfig) {
    return stateManagementOverride ?? globalConfig.defaultStateManagement;
  }
}
