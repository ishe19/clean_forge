String toPascalCase(String text) {
  return text
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join('');
}

String toCamelCase(String text) {
  final parts = text.split('_');
  return parts[0] +
      parts
          .skip(1)
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join('');
}

String toSnakeCase(String text) {
  return text
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      )
      .replaceFirst('_', '');
}
