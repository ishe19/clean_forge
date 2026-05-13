import '../models/config_model.dart';

class BaseTemplates {
  final CleanForgeConfig config;

  BaseTemplates(this.config);

  String get exceptionsTemplate => '''
import 'package:equatable/equatable.dart';

abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => '\$runtimeType: \$message';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred', super.code]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred', super.code]);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred', super.code]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation error occurred', super.code]);
}
''';

  String get failuresTemplate => '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred', super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred', super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred', super.code]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error occurred', super.code]);
}
''';

  String get useCaseTemplate => '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
''';

  String networkInfoTemplate(bool useInjectable) =>
      '''
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

${useInjectable ? '@singleton' : ''}
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl({required this.connectionChecker});

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
''';

  String get getItContainerTemplate => '''
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectionChecker: sl()));
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Features will be registered here
}
''';

  String get utilsExtensionsTemplate => '''
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isSmallScreen => screenSize.width < 600;
}

extension StringExtensions on String {
  String get capitalize => isEmpty ? this : '\${this[0].toUpperCase()}\${substring(1)}';
  String? get nullIfEmpty => isEmpty ? null : this;
}

extension DateTimeExtensions on DateTime {
  String get formatted => '\${year.toString().padLeft(4, '0')}-\${month.toString().padLeft(2, '0')}-\${day.toString().padLeft(2, '0')}';
}
''';

  String get utilsValidatorsTemplate => '''
abstract class InputValidators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}\$');
    if (!phoneRegex.hasMatch(value)) return 'Please enter a valid phone number';
    return null;
  }

  static String? minLength(int min) => (String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (value.length < min) return 'Must be at least \$min characters';
    return null;
  };

  static String? maxLength(int max) => (String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.length > max) return 'Must be at most \$max characters';
    return null;
  };
}
''';

  String get constantsApiTemplate => '''
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/api/v1';
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User endpoints
  static const String users = '/users';
  static String user(String id) => '/users/\$id';
  static String userProfile(String id) => '/users/\$id/profile';

  // Generic CRUD endpoints
  static String list(String resource) => '/\$resource';
  static String detail(String resource, String id) => '/\$resource/\$id';
  static String create(String resource) => '/\$resource';
  static String update(String resource, String id) => '/\$resource/\$id';
  static String delete(String resource, String id) => '/\$resource/\$id';
}
''';

  String get constantsAppTemplate => '''
class AppConstants {
  AppConstants._();

  static const String appName = 'MyApp';
  static const String appVersion = '1.0.0';
  static const int skeletonDelay = 500;
  static const int debounceDuration = 300;
  static const int pageSize = 20;
  static const int maxRetries = 3;
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}
''';

  String get injectableContainerTemplate => '''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../core/network/network_info.dart';
import 'injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: r'\$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() => \$initGetIt(sl);
''';

  String remoteDataSourceTemplate(String featureName, String className) =>
      '''
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:${config.packageName}/core/error/exceptions.dart';
import '../models/${featureName}_model.dart';

abstract class ${className}RemoteDataSource {
  Future<${className}Model> get$className();
  Future<${className}Model> create$className(${className}Model $featureName);
  Future<${className}Model> update$className(${className}Model $featureName);
  Future<void> delete$className(String id);
}

class ${className}RemoteDataSourceImpl implements ${className}RemoteDataSource {
  final Dio client;

  ${className}RemoteDataSourceImpl({required this.client});

  @override
  Future<${className}Model> get$className() async {
    try {
      final response = await client.get('/${featureName}s');
      return ${className}Model.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    }
  }

  @override
  Future<${className}Model> create$className(${className}Model $featureName) async {
    try {
      final response = await client.post('/${featureName}s', data: $featureName.toJson());
      return ${className}Model.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    }
  }

  @override
  Future<${className}Model> update$className(${className}Model $featureName) async {
    try {
      final response = await client.put('/${featureName}s/\${$featureName.id}', data: $featureName.toJson());
      return ${className}Model.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    }
  }

  @override
  Future<void> delete$className(String id) async {
    try {
      await client.delete('/${featureName}s/\$id');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
''';

  String localDataSourceTemplate(String featureName, String className) =>
      '''
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:${config.packageName}/core/error/exceptions.dart';
import '../models/${featureName}_model.dart';

abstract class ${className}LocalDataSource {
  Future<${className}Model> get$className();
  Future<void> cache$className(${className}Model ${featureName}ToCache);
}

class ${className}LocalDataSourceImpl implements ${className}LocalDataSource {
  final SharedPreferences sharedPreferences;
  static const cached${className}Key = 'CACHED_${className.toUpperCase()}';

  ${className}LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<${className}Model> get$className() async {
    final jsonString = sharedPreferences.getString(cached${className}Key);
    if (jsonString != null) {
      return ${className}Model.fromJson(json.decode(jsonString));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cache$className(${className}Model ${featureName}ToCache) async {
    sharedPreferences.setString(
      cached${className}Key,
      json.encode(${featureName}ToCache.toJson()),
    );
  }
}
''';

  String modelTemplate(String featureName, String className) =>
      '''
import 'package:equatable/equatable.dart';
import 'package:${config.packageName}/features/$featureName/domain/entities/$featureName.dart';

class ${className}Model extends Equatable {
  final String id;
  final String name;
  final String? description;

  const ${className}Model({
    required this.id,
    required this.name,
    this.description,
  });

  factory ${className}Model.fromJson(Map<String, dynamic> json) {
    return ${className}Model(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  $className toEntity() {
    return $className(
      id: id,
      name: name,
      description: description,
    );
  }

  @override
  List<Object?> get props => [id, name, description];
}
''';

  String repositoryImplTemplate(String featureName, String className) =>
      '''
import 'package:dartz/dartz.dart';
import 'package:${config.packageName}/core/error/exceptions.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/network/network_info.dart';
import '../../domain/entities/$featureName.dart';
import '../../domain/repositories/${featureName}_repository.dart';
import '../datasources/local/${featureName}_local_data_source.dart';
import '../datasources/remote/${featureName}_remote_data_source.dart';
import '../models/${featureName}_model.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  final ${className}RemoteDataSource remoteDataSource;
  final ${className}LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ${className}RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, $className>> get$className() async {
    if (await networkInfo.isConnected) {
      try {
        final remote$className = await remoteDataSource.get$className();
        localDataSource.cache$className(remote$className);
        return Right(remote$className.toEntity());
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final local$className = await localDataSource.get$className();
        return Right(local$className.toEntity());
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, $className>> create$className($className $featureName) async {
    final ${featureName}Model = ${className}Model(
      id: $featureName.id,
      name: $featureName.name,
      description: $featureName.description,
    );

    try {
      final result = await remoteDataSource.create$className(${featureName}Model);
      return Right(result.toEntity());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, $className>> update$className($className $featureName) async {
    final ${featureName}Model = ${className}Model(
      id: $featureName.id,
      name: $featureName.name,
      description: $featureName.description,
    );

    try {
      final result = await remoteDataSource.update$className(${featureName}Model);
      return Right(result.toEntity());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> delete$className(String id) async {
    try {
      await remoteDataSource.delete$className(id);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
''';

  String entityTemplate(String featureName, String className) =>
      '''
import 'package:equatable/equatable.dart';

class $className extends Equatable {
  final String id;
  final String name;
  final String? description;

  const $className({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
''';
  String repositoryTemplate(
    String featureName,
    String className,
    bool generateCrud,
  ) {
    final crudMethods = generateCrud
        ? '''

Future<Either<Failure, $className>> create$className($className $featureName);
Future<Either<Failure, $className>> update$className($className $featureName);
Future<Either<Failure, void>> delete$className(String id);
'''
        : '';

    return '''
import 'package:dartz/dartz.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import '../entities/$featureName.dart';

abstract class ${className}Repository {
  Future<Either<Failure, $className>> get$className();$crudMethods
}
''';
  }

  String createUseCaseTemplate(String featureName, String className) =>
      '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/usecases/usecase.dart';
import '../entities/$featureName.dart';
import '../repositories/${featureName}_repository.dart';

class Create$className implements UseCase<$className, Create${className}Params> {
  final ${className}Repository repository;

  Create$className(this.repository);

  @override
  Future<Either<Failure, $className>> call(Create${className}Params params) async {
    return await repository.create$className(params.$featureName);
  }
}

class Create${className}Params extends Equatable {
  final $className $featureName;

  const Create${className}Params(this.$featureName);

  @override
  List<Object?> get props => [$featureName];
}
''';

  String getUseCaseTemplate(String featureName, String className) =>
      '''
import 'package:dartz/dartz.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/usecases/usecase.dart';
import '../entities/$featureName.dart';
import '../repositories/${featureName}_repository.dart';

class Get$className implements UseCase<$className, NoParams> {
  final ${className}Repository repository;

  Get$className(this.repository);

  @override
  Future<Either<Failure, $className>> call(NoParams params) async {
    return await repository.get$className();
  }
}
''';

  String updateUseCaseTemplate(String featureName, String className) =>
      '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/usecases/usecase.dart';
import '../entities/$featureName.dart';
import '../repositories/${featureName}_repository.dart';

class Update$className implements UseCase<$className, Update${className}Params> {
  final ${className}Repository repository;

  Update$className(this.repository);

  @override
  Future<Either<Failure, $className>> call(Update${className}Params params) async {
    return await repository.update$className(params.$featureName);
  }
}

class Update${className}Params extends Equatable {
  final $className $featureName;

  const Update${className}Params(this.$featureName);

  @override
  List<Object?> get props => [$featureName];
}
''';

  String deleteUseCaseTemplate(String featureName, String className) =>
      '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:${config.packageName}/core/error/failures.dart';
import 'package:${config.packageName}/core/usecases/usecase.dart';
import '../repositories/${featureName}_repository.dart';

class Delete$className implements UseCase<void, Delete${className}Params> {
  final ${className}Repository repository;

  Delete$className(this.repository);

  @override
  Future<Either<Failure, void>> call(Delete${className}Params params) async {
    return await repository.delete$className(params.id);
  }
}

class Delete${className}Params extends Equatable {
  final String id;

  const Delete${className}Params(this.id);

  @override
  List<Object?> get props => [id];
}
''';
}
