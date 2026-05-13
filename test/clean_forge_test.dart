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

    test('copyWith overrides specific fields', () {
      final original = FeatureConfig(
        featureName: 'test',
        generateCrud: false,
        generateTests: true,
      );
      final updated = original.copyWith(
        generateCrud: true,
        generateTests: false,
      );
      expect(updated.featureName, equals('test'));
      expect(updated.generateCrud, isTrue);
      expect(updated.generateTests, isFalse);
    });
  });

  group('Config JSON serialization', () {
    test('toJson produces correct map', () {
      final config = CleanForgeConfig(
        defaultStateManagement: StateManagement.riverpod,
        defaultDi: DependencyInjection.getIt,
        generateTests: false,
        useFreezing: true,
        useEquatable: false,
        useDartz: false,
        packageName: 'my_app',
      );
      final json = config.toJson();
      expect(json['defaultStateManagement'], equals('riverpod'));
      expect(json['defaultDi'], equals('getIt'));
      expect(json['generateTests'], isFalse);
      expect(json['useFreezing'], isTrue);
      expect(json['useEquatable'], isFalse);
      expect(json['useDartz'], isFalse);
      expect(json['packageName'], equals('my_app'));
    });

    test('fromJson restores config correctly', () {
      final json = {
        'defaultStateManagement': 'cubit',
        'defaultDi': 'riverpod',
        'generateTests': false,
        'generateIntegrationTests': true,
        'useFreezing': true,
        'useEquatable': false,
        'useDartz': false,
        'packageName': 'test_app',
      };
      final config = CleanForgeConfig.fromJson(json);
      expect(config.defaultStateManagement, equals(StateManagement.cubit));
      expect(config.defaultDi, equals(DependencyInjection.riverpod));
      expect(config.generateTests, isFalse);
      expect(config.generateIntegrationTests, isTrue);
      expect(config.useFreezing, isTrue);
      expect(config.useEquatable, isFalse);
      expect(config.useDartz, isFalse);
      expect(config.packageName, equals('test_app'));
    });

    test('round-trip JSON serialization preserves all fields', () {
      final original = CleanForgeConfig(
        defaultStateManagement: StateManagement.mobx,
        defaultDi: DependencyInjection.injectable,
        generateTests: false,
        generateIntegrationTests: true,
        useFreezing: true,
        useEquatable: false,
        useDartz: true,
        packageName: 'my_flutter_app',
        organizationName: 'com.example',
      );
      final json = original.toJson();
      final restored = CleanForgeConfig.fromJson(json);
      expect(
        restored.defaultStateManagement,
        equals(original.defaultStateManagement),
      );
      expect(restored.defaultDi, equals(original.defaultDi));
      expect(restored.generateTests, equals(original.generateTests));
      expect(
        restored.generateIntegrationTests,
        equals(original.generateIntegrationTests),
      );
      expect(restored.useFreezing, equals(original.useFreezing));
      expect(restored.useEquatable, equals(original.useEquatable));
      expect(restored.useDartz, equals(original.useDartz));
      expect(restored.packageName, equals(original.packageName));
      expect(restored.organizationName, equals(original.organizationName));
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final config = CleanForgeConfig.fromJson(json);
      expect(config.defaultStateManagement, equals(StateManagement.bloc));
      expect(config.defaultDi, equals(DependencyInjection.getIt));
      expect(config.generateTests, isTrue);
      expect(config.useFreezing, isFalse);
      expect(config.useEquatable, isTrue);
      expect(config.useDartz, isTrue);
      expect(config.packageName, equals('unknown'));
    });
  });

  group('Enum display names', () {
    test('StateManagement displayName is uppercase', () {
      expect(StateManagement.bloc.displayName, equals('BLOC'));
      expect(StateManagement.getx.displayName, equals('GETX'));
      expect(StateManagement.none.displayName, equals('NONE'));
    });

    test('DependencyInjection getIt displayName is get_it', () {
      expect(DependencyInjection.getIt.displayName, equals('get_it'));
      expect(DependencyInjection.injectable.displayName, equals('injectable'));
    });
  });

  group('Validators', () {
    test('isValidPackageName accepts valid package names', () {
      expect(Validators.isValidPackageName('flutter_app'), isTrue);
      expect(Validators.isValidPackageName('a'), isTrue);
    });

    test('isValidPackageName rejects invalid package names', () {
      expect(Validators.isValidPackageName('FlutterApp'), isFalse);
      expect(Validators.isValidPackageName('flutter-app'), isFalse);
    });

    test('isValidOrganizationName accepts valid names', () {
      expect(Validators.isValidOrganizationName('com.example'), isTrue);
      expect(Validators.isValidOrganizationName('org.example.app'), isTrue);
    });

    test('isValidOrganizationName rejects invalid names', () {
      expect(Validators.isValidOrganizationName('Example'), isFalse);
      expect(Validators.isValidOrganizationName('com.example.app!'), isFalse);
    });
  });

  group('CleanForgeLogger', () {
    test('creates logger instance without error', () {
      final logger = CleanForgeLogger();
      expect(logger, isNotNull);
    });
  });
}
