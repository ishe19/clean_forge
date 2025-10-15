import '../models/config_model.dart';

class BlocTemplates {
  final CleanForgeConfig config;
  final String featureName;
  final String className;

  BlocTemplates(this.config, this.featureName, this.className);

  String blocFile(bool generateCrud) {
    final events = generateCrud
        ? '''
    on<Create${className}Event>(_onCreate$className);
    on<Update${className}Event>(_onUpdate$className);
    on<Delete${className}Event>(_onDelete$className);'''
        : '';

    final methods = generateCrud
        ? '''
  Future<void> _onCreate$className(
    Create${className}Event event,
    Emitter<${className}State> emit,
  ) async {
    emit(${className}Loading());
    final result = await create$className(Create${className}Params(event.$featureName));
    result.fold(
      (failure) => emit(${className}Error(failure.message)),
      ($featureName) => emit(${className}Loaded($featureName)),
    );
  }

  Future<void> _onUpdate$className(
    Update${className}Event event,
    Emitter<${className}State> emit,
  ) async {
    emit(${className}Loading());
    final result = await update$className(Update${className}Params(event.$featureName));
    result.fold(
      (failure) => emit(${className}Error(failure.message)),
      ($featureName) => emit(${className}Loaded($featureName)),
    );
  }

  Future<void> _onDelete$className(
    Delete${className}Event event,
    Emitter<${className}State> emit,
  ) async {
    emit(${className}Loading());
    final result = await delete$className(Delete${className}Params(event.id));
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
import '${featureName}_event.dart';
import '${featureName}_state.dart';

class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  final Get$className get$className;
${generateCrud ? "  final Create$className create$className;" : ""}
${generateCrud ? "  final Update$className update$className;" : ""}
${generateCrud ? "  final Delete$className delete$className;" : ""}

  ${className}Bloc({
    required this.get$className,${generateCrud ? """
    required this.create$className,
    required this.update$className,
    required this.delete$className,""" : ""}
  }) : super(${className}Initial()) {
    on<Get${className}Event>(_onGet$className);$events
  }

  Future<void> _onGet$className(
    Get${className}Event event,
    Emitter<${className}State> emit,
  ) async {
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

  String eventFile(bool generateCrud) {
    final events = generateCrud
        ? '''
class Create${className}Event extends ${className}Event {
  final $className $featureName;

  const Create${className}Event(this.$featureName);

  @override
  List<Object?> get props => [$featureName];
}

class Update${className}Event extends ${className}Event {
  final $className $featureName;

  const Update${className}Event(this.$featureName);

  @override
  List<Object?> get props => [$featureName];
}

class Delete${className}Event extends ${className}Event {
  final String id;

  const Delete${className}Event(this.id);

  @override
  List<Object?> get props => [id];
}'''
        : '';

    return '''
import 'package:equatable/equatable.dart';
import '../../../domain/entities/$featureName.dart';

abstract class ${className}Event extends Equatable {
  const ${className}Event();

  @override
  List<Object?> get props => [];
}

class Get${className}Event extends ${className}Event {
  const Get${className}Event();
}$events
''';
  }

  String get stateFile => '''
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