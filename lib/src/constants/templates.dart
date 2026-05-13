const String cachedKeyPrefix = 'CACHED_';

const String defaultApiPath = '/api/v1';

const String equatableImport = 'package:equatable/equatable.dart';

const String dartzImport = 'package:dartz/dartz.dart';

String featureImport(String packageName, String featureName, String path) {
  return "import 'package:$packageName/features/$featureName/$path';";
}

String coreImport(String packageName, String path) {
  return "import 'package:$packageName/core/$path';";
}
