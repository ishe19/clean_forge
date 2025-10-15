class Validators {
  static bool isValidFeatureName(String name) {
    // Feature names should be lowercase, use underscores, no spaces
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name);
  }

  static bool isValidPackageName(String name) {
    // Package names should follow Dart package naming conventions
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name);
  }

  static bool isValidOrganizationName(String name) {
    // Organization names should be reverse domain notation
    final regex = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$');
    return regex.hasMatch(name);
  }
}