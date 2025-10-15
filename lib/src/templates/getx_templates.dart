import '../models/config_model.dart';

class GetXTemplates {
  final CleanForgeConfig config;
  final String featureName;
  final String className;

  GetXTemplates(this.config, this.featureName, this.className);

  String controllerFile(bool generateCrud) {
    final crudMethods = generateCrud
        ? '''
  Future<void> create$className($className $featureName) async {
    isLoading(true);
    error.value = '';
    final result = await create$className(Create${className}Params($featureName));
    result.fold(
      (failure) {
        error.value = failure.message;
        isLoading(false);
      },
      ($featureName) {
        this.$featureName.value = $featureName;
        isLoading(false);
      },
    );
  }

  Future<void> update$className($className $featureName) async {
    isLoading(true);
    error.value = '';
    final result = await update$className(Update${className}Params($featureName));
    result.fold(
      (failure) {
        error.value = failure.message;
        isLoading(false);
      },
      ($featureName) {
        this.$featureName.value = $featureName;
        isLoading(false);
      },
    );
  }

  Future<void> delete$className(String id) async {
    isLoading(true);
    error.value = '';
    final result = await delete$className(Delete${className}Params(id));
    result.fold(
      (failure) {
        error.value = failure.message;
        isLoading(false);
      },
      (_) {
        this.$featureName.value = null;
        isLoading(false);
      },
    );
  }'''
        : '';

    return '''
import 'package:get/get.dart';
import '../../../domain/usecases/get_$featureName.dart';
${generateCrud ? "import '../../../domain/usecases/create_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/update_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/delete_$featureName.dart';" : ""}
import '../../../domain/entities/$featureName.dart';

class ${className}Controller extends GetxController {
  final Get$className get$className;
${generateCrud ? "  final Create$className create$className;" : ""}
${generateCrud ? "  final Update$className update$className;" : ""}
${generateCrud ? "  final Delete$className delete$className;" : ""}

  final $featureName = Rx<$className?>(null);
  final isLoading = false.obs;
  final error = ''.obs;

  ${className}Controller({
    required this.get$className,${generateCrud ? """
    required this.create$className,
    required this.update$className,
    required this.delete$className,""" : ""}
  });

  @override
  void onInit() {
    super.onInit();
    fetch$className();
  }

  Future<void> fetch$className() async {
    isLoading(true);
    error.value = '';
    final result = await get$className(NoParams());
    result.fold(
      (failure) {
        error.value = failure.message;
        isLoading(false);
      },
      ($featureName) {
        this.$featureName.value = $featureName;
        isLoading(false);
      },
    );
  }$crudMethods
}
''';
  }
}