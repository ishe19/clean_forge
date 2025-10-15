import '../models/config_model.dart';

class MobXTemplates {
  final CleanForgeConfig config;
  final String featureName;
  final String className;

  MobXTemplates(this.config, this.featureName, this.className);

  String storeFile(bool generateCrud) {
    final crudMethods = generateCrud
        ? '''
  @action
  Future<void> create$className($className $featureName) async {
    isLoading = true;
    error = '';
    final result = await create$className(Create${className}Params($featureName));
    result.fold(
      (failure) {
        error = failure.message;
        isLoading = false;
      },
      ($featureName) {
        this.$featureName = $featureName;
        isLoading = false;
      },
    );
  }

  @action
  Future<void> update$className($className $featureName) async {
    isLoading = true;
    error = '';
    final result = await update$className(Update${className}Params($featureName));
    result.fold(
      (failure) {
        error = failure.message;
        isLoading = false;
      },
      ($featureName) {
        this.$featureName = $featureName;
        isLoading = false;
      },
    );
  }

  @action
  Future<void> delete$className(String id) async {
    isLoading = true;
    error = '';
    final result = await delete$className(Delete${className}Params(id));
    result.fold(
      (failure) {
        error = failure.message;
        isLoading = false;
      },
      (_) {
        this.$featureName = null;
        isLoading = false;
      },
    );
  }'''
        : '';

    return '''
import 'package:mobx/mobx.dart';
import '../../../domain/usecases/get_$featureName.dart';
${generateCrud ? "import '../../../domain/usecases/create_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/update_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/delete_$featureName.dart';" : ""}
import '../../../domain/entities/$featureName.dart';

part '${featureName}_store.g.dart';

class ${className}Store = _${className}Store with _\$${className}Store;

abstract class _${className}Store with Store {
  final Get$className get$className;
${generateCrud ? "  final Create$className create$className;" : ""}
${generateCrud ? "  final Update$className update$className;" : ""}
${generateCrud ? "  final Delete$className delete$className;" : ""}

  _${className}Store({
    required this.get$className,${generateCrud ? """
    required this.create$className,
    required this.update$className,
    required this.delete$className,""" : ""}
  }) {
    fetch$className();
  }

  @observable
  $className? $featureName;

  @observable
  bool isLoading = false;

  @observable
  String error = '';

  @action
  Future<void> fetch$className() async {
    isLoading = true;
    error = '';
    final result = await get$className(NoParams());
    result.fold(
      (failure) {
        error = failure.message;
        isLoading = false;
      },
      ($featureName) {
        this.$featureName = $featureName;
        isLoading = false;
      },
    );
  }$crudMethods
}
''';
  }
}