import '../models/config_model.dart';

class TestTemplates {
  final CleanForgeConfig config;
  final String featureName;
  final String className;

  TestTemplates(this.config, this.featureName, this.className);

  String get remoteDataSourceTest =>
      '''
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:${config.packageName}/features/$featureName/data/datasources/remote/${featureName}_remote_data_source.dart';
import 'package:${config.packageName}/features/$featureName/data/models/${featureName}_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ${className}RemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = ${className}RemoteDataSourceImpl(client: mockDio);
  });

  group('${className}RemoteDataSource', () {
    test('should return ${className}Model when the call is successful', () async {
      // Arrange
      final ${featureName}Model = ${className}Model(
        id: '1',
        name: 'Test $className',
        description: 'Test description',
      );

      when(() => mockDio.get('/${featureName}s')).thenAnswer(
        (_) async => Response(
          data: ${featureName}Model.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: '/${featureName}s'),
        ),
      );

      // Act
      final result = await dataSource.get$className();

      // Assert
      expect(result, equals(${featureName}Model));
      verify(() => mockDio.get('/${featureName}s')).called(1);
    });

    test('should throw ServerException when the call fails', () async {
      // Arrange
      when(() => mockDio.get('/${featureName}s')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/${featureName}s'),
          error: 'Server error',
        ),
      );

      // Act & Assert
      expect(() => dataSource.get$className(), throwsA(isA<ServerException>()));
    });
  });
}
''';

  String get localDataSourceTest =>
      '''
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:${config.packageName}/features/$featureName/data/datasources/local/${featureName}_local_data_source.dart';
import 'package:${config.packageName}/features/$featureName/data/models/${featureName}_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ${className}LocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = ${className}LocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('${className}LocalDataSource', () {
    test('should return ${className}Model from SharedPreferences when there is cached data', () async {
      // Arrange
      final ${featureName}Model = ${className}Model(
        id: '1',
        name: 'Test $className',
        description: 'Test description',
      );

      when(() => mockSharedPreferences.getString(any())).thenReturn(json.encode(${featureName}Model.toJson()));

      // Act
      final result = await dataSource.get$className();

      // Assert
      expect(result, equals(${featureName}Model));
      verify(() => mockSharedPreferences.getString('CACHED_${className.toUpperCase()}')).called(1);
    });

    test('should throw CacheException when there is no cached data', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      // Act & Assert
      expect(() => dataSource.get$className(), throwsA(isA<CacheException>()));
    });
  });
}
''';

  String get modelTest =>
      '''
import 'package:flutter_test/flutter_test.dart';
import 'package:${config.packageName}/features/$featureName/data/models/${featureName}_model.dart';
import 'package:${config.packageName}/features/$featureName/domain/entities/$featureName.dart';

void main() {
  const t${className}Model = ${className}Model(
    id: '1',
    name: 'Test $className',
    description: 'Test description',
  );

  test('should be a subclass of $className entity', () async {
    // Assert
    expect(t${className}Model, isA<$className>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is valid', () async {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'name': 'Test $className',
        'description': 'Test description',
      };

      // Act
      final result = ${className}Model.fromJson(jsonMap);

      // Assert
      expect(result, t${className}Model);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      // Act
      final result = t${className}Model.toJson();

      // Assert
      final expectedMap = {
        'id': '1',
        'name': 'Test $className',
        'description': 'Test description',
      };
      expect(result, expectedMap);
    });
  });
}
''';

  String get repositoryImplTest =>
      '''
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/network/network_info.dart';
import 'package:${config.packageName}/features/$featureName/data/datasources/local/${featureName}_local_data_source.dart';
import 'package:${config.packageName}/features/$featureName/data/datasources/remote/${featureName}_remote_data_source.dart';
import 'package:${config.packageName}/features/$featureName/data/models/${featureName}_model.dart';
import 'package:${config.packageName}/features/$featureName/data/repositories/${featureName}_repository_impl.dart';
import 'package:${config.packageName}/features/$featureName/domain/entities/$featureName.dart';

class MockRemoteDataSource extends Mock implements ${className}RemoteDataSource {}

class MockLocalDataSource extends Mock implements ${className}LocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ${className}RepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ${className}RepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('${className}RepositoryImpl', () {
    const t${className}Model = ${className}Model(
      id: '1',
      name: 'Test $className',
      description: 'Test description',
    );

    const t$className = $className(
      id: '1',
      name: 'Test $className',
      description: 'Test description',
    );

    group('get$className', () {
      test('should check if the device is online', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        // Act
        repository.get$className();

        // Assert
        verify(() => mockNetworkInfo.isConnected);
      });

      group('device is online', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test('should return remote data when the call to remote data source is successful', () async {
          // Arrange
          when(() => mockRemoteDataSource.get$className()).thenAnswer((_) async => t${className}Model);

          // Act
          final result = await repository.get$className();

          // Assert
          verify(() => mockRemoteDataSource.get$className());
          expect(result, equals(const Right(t$className)));
        });

        test('should cache the data locally when the call to remote data source is successful', () async {
          // Arrange
          when(() => mockRemoteDataSource.get$className()).thenAnswer((_) async => t${className}Model);

          // Act
          await repository.get$className();

          // Assert
          verify(() => mockRemoteDataSource.get$className());
          verify(() => mockLocalDataSource.cache$className(t${className}Model));
        });

        test('should return server failure when the call to remote data source is unsuccessful', () async {
          // Arrange
          when(() => mockRemoteDataSource.get$className()).thenThrow(ServerException());

          // Act
          final result = await repository.get$className();

          // Assert
          verify(() => mockRemoteDataSource.get$className());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(const Left(ServerFailure())));
        });
      });

      group('device is offline', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });

        test('should return last locally cached data when the cached data is present', () async {
          // Arrange
          when(() => mockLocalDataSource.get$className()).thenAnswer((_) async => t${className}Model);

          // Act
          final result = await repository.get$className();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.get$className());
          expect(result, equals(const Right(t$className)));
        });

        test('should return CacheFailure when there is no cached data present', () async {
          // Arrange
          when(() => mockLocalDataSource.get$className()).thenThrow(CacheException());

          // Act
          final result = await repository.get$className();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.get$className());
          expect(result, equals(const Left(CacheFailure())));
        });
      });
    });
  });
}
''';

  String get getUseCaseTest =>
      '''
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/usecases/usecase.dart';
import 'package:${config.packageName}/features/$featureName/domain/entities/$featureName.dart';
import 'package:${config.packageName}/features/$featureName/domain/repositories/${featureName}_repository.dart';
import 'package:${config.packageName}/features/$featureName/domain/usecases/get_$featureName.dart';

class Mock${className}Repository extends Mock implements ${className}Repository {}

void main() {
  late Get$className usecase;
  late Mock${className}Repository mock${className}Repository;

  setUp(() {
    mock${className}Repository = Mock${className}Repository();
    usecase = Get$className(mock${className}Repository);
  });

  const t$className = $className(
    id: '1',
    name: 'Test $className',
    description: 'Test description',
  );

  test('should get $featureName from the repository', () async {
    // Arrange
    when(() => mock${className}Repository.get$className()).thenAnswer((_) async => const Right(t$className));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, const Right(t$className));
    verify(() => mock${className}Repository.get$className());
    verifyNoMoreInteractions(mock${className}Repository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    when(() => mock${className}Repository.get$className()).thenAnswer((_) async => const Left(ServerFailure()));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, const Left(ServerFailure()));
    verify(() => mock${className}Repository.get$className());
    verifyNoMoreInteractions(mock${className}Repository);
  });
}
''';

  String get blocTest =>
      '''
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/usecases/usecase.dart';
import 'package:${config.packageName}/features/$featureName/domain/entities/$featureName.dart';
import 'package:${config.packageName}/features/$featureName/domain/usecases/get_$featureName.dart';
import 'package:${config.packageName}/features/$featureName/presentation/bloc/${featureName}_bloc.dart';

class MockGet$className extends Mock implements Get$className {}

void main() {
  late ${className}Bloc bloc;
  late MockGet$className mockGet$className;

  setUp(() {
    mockGet$className = MockGet$className();
    bloc = ${className}Bloc(get$className: mockGet$className);
  });

  const t$className = $className(
    id: '1',
    name: 'Test $className',
    description: 'Test description',
  );

  test('initial state should be ${className}Initial', () {
    expect(bloc.state, equals(${className}Initial()));
  });

  blocTest<${className}Bloc, ${className}State>(
    'should emit [Loading, Loaded] when data is gotten successfully',
    build: () {
      when(() => mockGet$className(any())).thenAnswer((_) async => const Right(t$className));
      return bloc;
    },
    act: (bloc) => bloc.add(Get${className}Event()),
    expect: () => [
      ${className}Loading(),
      ${className}Loaded(t$className),
    ],
    verify: (_) {
      verify(() => mockGet$className(NoParams()));
    },
  );

  blocTest<${className}Bloc, ${className}State>(
    'should emit [Loading, Error] when getting data fails',
    build: () {
      when(() => mockGet$className(any())).thenAnswer((_) async => const Left(ServerFailure()));
      return bloc;
    },
    act: (bloc) => bloc.add(Get${className}Event()),
    expect: () => [
      ${className}Loading(),
      ${className}Error('Server error occurred'),
    ],
    verify: (_) {
      verify(() => mockGet$className(NoParams()));
    },
  );
}
''';

  String get cubitTest =>
      '''
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/usecases/usecase.dart';
import 'package:${config.packageName}/features/$featureName/domain/entities/$featureName.dart';
import 'package:${config.packageName}/features/$featureName/domain/usecases/get_$featureName.dart';
import 'package:${config.packageName}/features/$featureName/presentation/cubit/${featureName}_cubit.dart';

class MockGet$className extends Mock implements Get$className {}

void main() {
  late ${className}Cubit cubit;
  late MockGet$className mockGet$className;

  setUp(() {
    mockGet$className = MockGet$className();
    cubit = ${className}Cubit(get$className: mockGet$className);
  });

  const t$className = $className(
    id: '1',
    name: 'Test $className',
    description: 'Test description',
  );

  test('initial state should be ${className}Initial', () {
    expect(cubit.state, equals(${className}Initial()));
  });

  blocTest<${className}Cubit, ${className}State>(
    'should emit [Loading, Loaded] when data is gotten successfully',
    build: () {
      when(() => mockGet$className(any())).thenAnswer((_) async => const Right(t$className));
      return cubit;
    },
    act: (cubit) => cubit.get$className(),
    expect: () => [
      ${className}Loading(),
      ${className}Loaded(t$className),
    ],
    verify: (_) {
      verify(() => mockGet$className(NoParams()));
    },
  );

  blocTest<${className}Cubit, ${className}State>(
    'should emit [Loading, Error] when getting data fails',
    build: () {
      when(() => mockGet$className(any())).thenAnswer((_) async => const Left(ServerFailure()));
      return cubit;
    },
    act: (cubit) => cubit.get$className(),
    expect: () => [
      ${className}Loading(),
      ${className}Error('Server error occurred'),
    ],
    verify: (_) {
      verify(() => mockGet$className(NoParams()));
    },
  );
}
''';

  String get riverpodTest =>
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/features/$featureName/domain/usecases/get_$featureName.dart';
import 'package:${config.packageName}/features/$featureName/presentation/providers/${featureName}_provider.dart';

class MockGet$className extends Mock implements Get$className {}

void main() {
  late MockGet$className mockGet$className;
  late ProviderContainer container;

  setUp(() {
    mockGet$className = MockGet$className();
    container = ProviderContainer(
      overrides: [
        get${className}Provider.overrideWithValue(mockGet$className),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('${className}Notifier initial state is AsyncValue.loading', () {
    final notifier = container.read(${featureName}Provider.notifier);
    expect(notifier.state, const AsyncValue<$className?>.loading());
  });
}
''';

  String get providerTest =>
      '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/features/$featureName/domain/usecases/get_$featureName.dart';
import 'package:${config.packageName}/features/$featureName/presentation/providers/${featureName}_provider.dart';

class MockGet$className extends Mock implements Get$className {}

void main() {
  late MockGet$className mockGet$className;
  late ${className}Provider provider;

  setUp(() {
    mockGet$className = MockGet$className();
    provider = ${className}Provider(get$className: mockGet$className);
  });

  test('${className}Provider initial state', () {
    expect(provider.$featureName, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
  });
}
''';

  String get getxTest =>
      '''
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/features/$featureName/domain/usecases/get_$featureName.dart';
import 'package:${config.packageName}/features/$featureName/presentation/controllers/${featureName}_controller.dart';

class MockGet$className extends Mock implements Get$className {}

void main() {
  late MockGet$className mockGet$className;
  late ${className}Controller controller;

  setUp(() {
    mockGet$className = MockGet$className();
    controller = ${className}Controller(get$className: mockGet$className);
  });

  tearDown(() {
    Get.reset();
  });

  test('${className}Controller initial state', () {
    expect(controller.$featureName.value, isNull);
    expect(controller.isLoading.value, isFalse);
    expect(controller.error.value, isEmpty);
  });
}
''';

  String get mobxTest =>
      '''
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:${config.packageName}/features/$featureName/domain/usecases/get_$featureName.dart';
import 'package:${config.packageName}/features/$featureName/presentation/stores/${featureName}_store.dart';

class MockGet$className extends Mock implements Get$className {}

void main() {
  late MockGet$className mockGet$className;
  late ${className}Store store;

  setUp(() {
    mockGet$className = MockGet$className();
    store = ${className}Store(get$className: mockGet$className);
  });

  test('${className}Store initial state', () {
    expect(store.$featureName, isNull);
    expect(store.isLoading, isFalse);
    expect(store.error, isEmpty);
  });
}
''';
}
