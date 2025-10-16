import '../models/config_model.dart';

class RiverpodTemplates {
  final CleanForgeConfig config;
  final String featureName;
  final String className;

  RiverpodTemplates(this.config, this.featureName, this.className);

  String providerFile(bool generateCrud) {
    final crudMethods = generateCrud
        ? '''
  Future<$className?> create$className($className $featureName) async {
    final result = await create$className(Create${className}Params($featureName));
    return result.fold(
      (failure) => throw Exception(failure.message),
      ($featureName) => $featureName,
    );
  }

  Future<$className?> update$className($className $featureName) async {
    final result = await update$className(Update${className}Params($featureName));
    return result.fold(
      (failure) => throw Exception(failure.message),
      ($featureName) => $featureName,
    );
  }

  Future<void> delete$className(String id) async {
    final result = await delete$className(Delete${className}Params(id));
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }'''
        : '';

    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/get_$featureName.dart';
${generateCrud ? "import '../../../domain/usecases/create_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/update_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/delete_$featureName.dart';" : ""}
import '../../../domain/entities/$featureName.dart';

class ${className}Notifier extends StateNotifier<AsyncValue<$className?>> {
  final Get$className get$className;
${generateCrud ? "  final Create$className create$className;" : ""}
${generateCrud ? "  final Update$className update$className;" : ""}
${generateCrud ? "  final Delete$className delete$className;" : ""}

  ${className}Notifier({
    required this.get$className,${generateCrud ? """
    required this.create$className,
    required this.update$className,
    required this.delete$className,""" : ""}
  }) : super(const AsyncValue.loading()) {
    fetch$className();
  }

  Future<void> fetch$className() async {
    state = const AsyncValue.loading();
    final result = await get$className(NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      ($featureName) => AsyncValue.data($featureName),
    );
  }$crudMethods
}

final ${featureName}Provider = StateNotifierProvider<${className}Notifier, AsyncValue<$className?>>(
  (ref) => ${className}Notifier(
    get$className: ref.watch(get${className}Provider),
${generateCrud ? "    create$className: ref.watch(create${className}Provider)," : ""}
${generateCrud ? "    update$className: ref.watch(update${className}Provider)," : ""}
${generateCrud ? "    delete$className: ref.watch(delete${className}Provider)," : ""}
  ),
);

final get${className}Provider = Provider<Get$className>((ref) => throw UnimplementedError());
${generateCrud ? "final create${className}Provider = Provider<Create$className>((ref) => throw UnimplementedError());" : ""}
${generateCrud ? "final update${className}Provider = Provider<Update$className>((ref) => throw UnimplementedError());" : ""}
${generateCrud ? "final delete${className}Provider = Provider<Delete$className>((ref) => throw UnimplementedError());" : ""}
''';
  }
}
