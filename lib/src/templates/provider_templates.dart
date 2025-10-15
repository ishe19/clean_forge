import '../models/config_model.dart';

class ProviderTemplates {
  final CleanForgeConfig config;
  final String featureName;
  final String className;

  ProviderTemplates(this.config, this.featureName, this.className);

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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/usecases/get_$featureName.dart';
${generateCrud ? "import '../../../domain/usecases/create_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/update_$featureName.dart';" : ""}
${generateCrud ? "import '../../../domain/usecases/delete_$featureName.dart';" : ""}
import '../../../domain/entities/$featureName.dart';

class ${className}Provider with ChangeNotifier {
  $className? _$featureName;
  bool _isLoading = false;
  String? _error;

  final Get$className get$className;
${generateCrud ? "  final Create$className create$className;" : ""}
${generateCrud ? "  final Update$className update$className;" : ""}
${generateCrud ? "  final Delete$className delete$className;" : ""}

  ${className}Provider({
    required this.get$className,${generateCrud ? """
    required this.create$className,
    required this.update$className,
    required this.delete$className,""" : ""}
  });

  $className? get $featureName => _$featureName;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetch$className() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await get$className(NoParams());
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      ($featureName) {
        _$featureName = $featureName;
        _isLoading = false;
        notifyListeners();
      },
    );
  }$crudMethods

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
''';
  }
}