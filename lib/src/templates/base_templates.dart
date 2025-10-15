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

  String get networkInfoTemplate => '''
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // TODO: Implement network connectivity check
    // Use internet_connection_checker package
    return true;
  }
}
''';

  String get getItContainerTemplate => '''
import 'package:get_it/get_it.dart';
import 'core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Features will be registered here
}
''';

  String get injectableContainerTemplate => '''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: r'\$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() => \$initGetIt(sl);
''';

  String remoteDataSourceTemplate(String featureName, String className) => '''
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
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

  String localDataSourceTemplate(String featureName, String className) => '''
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
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

  String modelTemplate(String featureName, String className) => '''
import 'package:equatable/equatable.dart';
import '../../domain/entities/$featureName.dart';

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

  String repositoryImplTemplate(String featureName, String className) => '''
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
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

  String entityTemplate(String featureName, String className) => '''
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

  String repositoryTemplate(String featureName, String className, bool generateCrud) {
    final crudMethods = generateCrud ? '''
  Future<Either<Failure, $className>> create$className($className $featureName);
  Future<Either<Failure, $className>> update$className($className $featureName);
  Future<Either<Failure, void>> delete$className(String id);
''' : '';

    return '''
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/$featureName.dart';

abstract class ${className}Repository {
  Future<Either<Failure, $className>> get$className();$crudMethods
}
''';
  }

  String createUseCaseTemplate(String featureName, String className) => '''
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
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

  String getUseCaseTemplate(String featureName, String className) => '''
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
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

  String updateUseCaseTemplate(String featureName, String className) => '''
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
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

  String deleteUseCaseTemplate(String featureName, String className) => '''
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
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