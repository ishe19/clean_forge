import '../models/config_model.dart';

class CubitTemplates {
  final CleanForgeConfig config;
  final String featureName;
  final String className;

  CubitTemplates(this.config, this.featureName, this.className);

  String cubitFile(bool generateCrud) {
    final methods = generateCrud
        ? '''
  Future<void> create$className($className $featureName) async {
    emit(${className}Loading());
    final result = await create$className(Create${className}Params($featureName));
    result.fold(
      (failure) => emit(${className}Error(failure.message)),
      ($featureName) => emit(${className}Loaded($featureName)),
    );
  }

  Future<void> update$className($className $featureName) async {
    emit(${className}Loading());
    final result = await update$className(Update${className}Params($featureName));
    result.fold(
      (failure) => emit(${className}Error(failure.message)),
      ($featureName) => emit(${className}Loaded($featureName)),
    );
  }

  Future<void> delete$className(String id) async {
    emit(${className}Loading());
    final result = await delete$className(Delete${className}Params(id));
    result.fold(
      (failure) => emit(${className}Error(failure.message)),
      (_) => emit(${className}Deleted()),
    );
  }'''
        : '';

    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_$featureName.dart';
${generateCrud ? "import '../../../domain/usecases/create_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/update_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/delete_$featureName.dart';" : ""}
import '${featureName}_state.dart';

class ${className}Cubit extends Cubit<${className}State> {
  final Get$className get$className;
${generateCrud ? "  final Create$className create$className;" : ""}
${generateCrud ? "  final Update$className update$className;" : ""}
${generateCrud ? "  final Delete$className delete$className;" : ""}

  ${className}Cubit({
    required this.get$className,${generateCrud ? """
    required this.create$className,
    required this.update$className,
    required this.delete$className,""" : ""}
  }) : super(${className}Initial());

  Future<void> get$className() async {
    emit(${className}Loading());
    final result = await get$className(NoParams());
    result.fold(
      (failure) => emit(${className}Error(failure.message)),
      ($featureName) => emit(${className}Loaded($featureName)),
    );
  }$methods
}
''';
  }

  String get stateFile =>
      '''
import 'package:equatable/equatable.dart';
import '../../../domain/entities/$featureName.dart';

abstract class ${className}State extends Equatable {
  const ${className}State();

  @override
  List<Object?> get props => [];
}

class ${className}Initial extends ${className}State {}

class ${className}Loading extends ${className}State {}

class ${className}Loaded extends ${className}State {
  final $className $featureName;

  const ${className}Loaded(this.$featureName);

  @override
  List<Object?> get props => [$featureName];
}

class ${className}Error extends ${className}State {
  final String message;

  const ${className}Error(this.message);

  @override
  List<Object?> get props => [message];
}

class ${className}Deleted extends ${className}State {}
''';
}
