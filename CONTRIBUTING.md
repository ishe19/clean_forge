# Contributing to Clean Forge

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/ishe19/clean_forge.git
   cd clean_forge
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Activate locally for testing:
   ```bash
   dart pub global activate --source path .
   ```

## Code Style

This project follows the [Dart style guide](https://dart.dev/guides/language/effective-dart/style). Run the analyzer before submitting:

```bash
dart analyze
```

## Testing

Run all tests:
```bash
dart test
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Release Process

1. Update `CHANGELOG.md`
2. Update version in `pubspec.yaml` and `bin/clean_forge.dart`
3. Tag the release: `git tag v<version>`
4. Push tags: `git push --tags`
