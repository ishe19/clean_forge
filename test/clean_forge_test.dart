import 'package:clean_forge/clean_forge.dart';
import 'package:test/test.dart';

void main() {
  group('Validators', () {
    test('isValidFeatureName accepts valid names', () {
      expect(Validators.isValidFeatureName('user_auth'), isTrue);
      expect(Validators.isValidFeatureName('product_catalog'), isTrue);
      expect(Validators.isValidFeatureName('feature123'), isTrue);
    });

    test('isValidFeatureName rejects invalid names', () {
      expect(Validators.isValidFeatureName('UserAuth'), isFalse);
      expect(Validators.isValidFeatureName('user-auth'), isFalse);
      expect(Validators.isValidFeatureName('user auth'), isFalse);
      expect(Validators.isValidFeatureName('-feature'), isFalse);
    });
  });

  group('string_helpers', () {
    test('toPascalCase converts snake_case to PascalCase', () {
      expect(toPascalCase('user_auth'), equals('UserAuth'));
      expect(toPascalCase('product'), equals('Product'));
      expect(toPascalCase('my_long_feature_name'), equals('MyLongFeatureName'));
    });

    test('toCamelCase converts snake_case to camelCase', () {
      expect(toCamelCase('user_auth'), equals('userAuth'));
      expect(toCamelCase('product'), equals('product'));
    });

    test('toSnakeCase converts PascalCase to snake_case', () {
      expect(toSnakeCase('UserAuth'), equals('user_auth'));
      expect(toSnakeCase('Product'), equals('product'));
    });
  });

  group('CleanForgeConfig', () {
    test('creates with default values', () {
      final config = CleanForgeConfig();
      expect(config.defaultStateManagement, equals(StateManagement.bloc));
      expect(config.defaultDi, equals(DependencyInjection.getIt));
      expect(config.generateTests, isTrue);
      expect(config.useEquatable, isTrue);
      expect(config.useDartz, isTrue);
      expect(config.useFreezing, isFalse);
    });
  });

  group('FeatureConfig', () {
    test('effectiveStateManagement uses override when provided', () {
      final globalConfig = CleanForgeConfig();
      final featureConfig = FeatureConfig(
        featureName: 'test',
        stateManagementOverride: StateManagement.getx,
      );
      expect(
        featureConfig.effectiveStateManagement(globalConfig),
        equals(StateManagement.getx),
      );
    });

    test('effectiveStateManagement falls back to global config', () {
      final globalConfig = CleanForgeConfig(
        defaultStateManagement: StateManagement.riverpod,
      );
      final featureConfig = FeatureConfig(featureName: 'test');
      expect(
        featureConfig.effectiveStateManagement(globalConfig),
        equals(StateManagement.riverpod),
      );
    });
  });
}
