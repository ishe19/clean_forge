# 🔥 Clean Forge - Next-Gen Clean Architecture CLI for Flutter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-3.9+-blue.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)](https://flutter.dev)

> A powerful CLI tool for generating production-ready Clean Architecture features with comprehensive testing, DI, and multiple state management options.

## 📋 Table of Contents

- [✨ Features](#-features)
- [🚀 Installation](#-installation)
- [🎯 Quick Start](#-quick-start)
- [📖 Commands](#-commands)
- [🏗️ Supported Technologies](#️-supported-technologies)
- [⚙️ Configuration](#️-configuration)
- [🧪 Testing](#-testing)
- [🧹 Cleanup & Maintenance](#-cleanup--maintenance)
- [🔧 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## ✨ Features

- **🏗️ Clean Architecture Structure**: Automatically generates complete Clean Architecture layers (Data, Domain, Presentation)
- **🎯 7 State Management Options**: Bloc, Cubit, Riverpod, Provider, GetX, MobX, or None
- **💉 5 Dependency Injection Options**: GetIt, Injectable, Riverpod, Provider, or None
- **🧪 Comprehensive Testing**: Unit, Integration, and Widget tests generation
- **🔄 CRUD Scaffolding**: Full Create, Read, Update, Delete operations
- **⚙️ Project Configuration**: Interactive setup with persistent configuration
- **🧹 Safe Cleanup**: Remove features or reset project structure safely
- **🎨 Interactive CLI**: Beautiful prompts and progress indicators

## 🚀 Installation

### Prerequisites

- **Dart SDK**: `^3.9.0` or higher
- **Flutter**: `^3.0.0` or higher (for Flutter projects)

### Install from pub.dev

```bash
dart pub global activate clean_forge
```

### Verify Installation

```bash
clean_forge --version
```

You should see:
```
clean_forge version: ![Version](https://img.shields.io/github/v/release/ishe19/clean_forge)
```

### Add to PATH (Optional)

If you encounter command not found errors, add the pub cache bin directory to your PATH:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## 🎯 Quick Start

1. **Navigate to your Flutter project**:
   ```bash
   cd your_flutter_project
   ```

2. **Initialize Clean Forge**:
   ```bash
   clean_forge init
   ```
   This creates the core Clean Architecture structure and configuration.

3. **Generate your first feature**:
   ```bash
   clean_forge feature user_auth
   ```

4. **Add required dependencies** to your `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_bloc: ^9.1.1 
     get_it: ^8.2.0
     equatable: ^2.0.7
     dartz: ^0.10.1
     dio: ^5.9.0
     internet_connection_checker: ^3.0.1
   ```

5. **Run tests**:
   ```bash
   flutter test test/features/user_auth/
   ```

That's it! You now have a complete, production-ready feature following Clean Architecture principles.

## 📖 Commands

### `init` - Initialize Project Structure

Sets up the core Clean Architecture foundation for your Flutter project.

```bash
# Interactive setup (recommended)
clean_forge init

# Non-interactive with custom options
clean_forge init --state-management=riverpod --di=getIt --no-tests

# Force interactive mode
clean_forge init -i
```

**Options:**
- `--interactive, -i`: Interactive setup with prompts
- `--state-management, -s`: Default state management [bloc, cubit, riverpod, provider, getx, mobx, none]
- `--di`: Default dependency injection [getIt, injectable, riverpod, provider, none]
- `--[no-]tests`: Generate test files (default: enabled)
- `--[no-]freezing`: Use Freezing for immutable models (default: disabled)
- `--[no-]equatable`: Use Equatable for value equality (default: enabled)
- `--[no-]dartz`: Use Dartz for functional programming (default: enabled)

### `feature` - Generate Complete Features

Creates a fully functional feature with Clean Architecture structure and state management.

```bash
# Basic feature with default settings
clean_forge feature user_auth

# Feature with full CRUD operations
clean_forge feature product --crud

# Override state management
clean_forge feature auth --state-management=getx

# Preview what would be generated
clean_forge feature payment --dry-run
```

**Options:**
- `--state-management, -s`: Override project's default state management
- `--crud`: Generate CRUD operations (Create, Read, Update, Delete)
- `--[no-]tests`: Generate test files (respects project config)
- `--dry-run`: Show what would be generated without creating files

**Generated Structure:**
```
lib/features/<feature_name>/
├── data/
│   ├── datasources/
│   │   ├── <feature_name>_remote_data_source.dart
│   │   └── <feature_name>_local_data_source.dart
│   ├── models/
│   │   └── <feature_name>_model.dart
│   └── repositories/
│       └── <feature_name>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <feature_name>.dart
│   ├── repositories/
│   │   └── <feature_name>_repository.dart
│   └── usecases/
│       ├── get_<feature_name>.dart
│       └── [create|update|delete]_<feature_name>.dart (if --crud)
└── presentation/
    ├── [bloc|cubit|providers|controllers|stores]/
    ├── pages/
    │   └── <feature_name>_page.dart
    └── widgets/
        └── <feature_name>_widget.dart
```

### `config` - Manage Configuration

View, update, and reset your Clean Forge configuration.

```bash
# View current configuration
clean_forge config --show

# Change default state management
clean_forge config --state-management=riverpod

# Update multiple settings
clean_forge config --di=getIt --no-tests

# Reset to defaults
clean_forge config --reset
```

**Options:**
- `--state-management, -s`: Set default state management
- `--di`: Set default dependency injection
- `--[no-]tests`: Enable/disable test generation
- `--[no-]freezing`: Enable/disable Freezing
- `--[no-]equatable`: Enable/disable Equatable
- `--[no-]dartz`: Enable/disable Dartz
- `--show`: Display current configuration
- `--reset`: Reset configuration to defaults

### `clean` - Cleanup Operations

Safely remove generated files and directories.

```bash
# Remove specific feature
clean_forge clean --feature=user_auth

# Preview full cleanup
clean_forge clean --all --dry-run

# Force full cleanup (dangerous!)
clean_forge clean --all --force

# Interactive cleanup menu
clean_forge clean
```

**Options:**
- `--feature=<name>`: Clean a specific feature
- `--all`: Clean everything (core, features, config)
- `--force, -f`: Skip confirmation prompts
- `--dry-run`: Show what would be cleaned without doing it

## 🏗️ Supported Technologies

### State Management

| Framework | Description | Dependencies |
|-----------|-------------|--------------|
| **Bloc** | Event-driven state management with events and states | `flutter_bloc` |
| **Cubit** | Simplified Bloc (Cubit only, no events) | `flutter_bloc` |
| **Riverpod** | Modern reactive state management | `flutter_riverpod` |
| **Provider** | Simple dependency injection and state | `provider` |
| **GetX** | Lightweight reactive framework | `get` |
| **MobX** | Observable-based state management | `mobx`, `flutter_mobx` |
| **None** | Manual state management | - |

### Dependency Injection

| Solution | Description | Dependencies |
|----------|-------------|--------------|
| **GetIt** | Lightweight service locator | `get_it` |
| **Injectable** | Code generation for GetIt | `get_it`, `injectable` |
| **Riverpod** | Provider-based DI | `flutter_riverpod` |
| **Provider** | InheritedWidget-based DI | `provider` |
| **None** | Manual dependency management | - |

### Additional Libraries

| Library | Purpose | Default |
|---------|---------|---------|
| **Equatable** | Value equality comparisons | Enabled |
| **Dartz** | Functional programming (Either, Option) | Enabled |
| **Freezed** | Immutable model generation | Disabled |

## ⚙️ Configuration

Clean Forge stores configuration in `clean_forge.json` in your project root:

```json
{
  "defaultStateManagement": "bloc",
  "defaultDi": "getIt",
  "generateTests": true,
  "generateIntegrationTests": false,
  "useFreezing": false,
  "useEquatable": true,
  "useDartz": true
}
```

### Configuration Options

- **defaultStateManagement**: Default state management for new features
- **defaultDi**: Default dependency injection solution
- **generateTests**: Whether to generate test files automatically
- **generateIntegrationTests**: Whether to generate integration tests
- **useFreezing**: Use Freezed for immutable model generation
- **useEquatable**: Use Equatable for value equality comparisons
- **useDartz**: Use Dartz for functional programming

## 🧪 Testing

Clean Forge generates comprehensive tests for all features:

### Test Structure
```
test/features/<feature_name>/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    └── [bloc|cubit|providers|controllers|stores]/
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests for specific feature
flutter test test/features/user_auth/

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Test Types Generated

- **Unit Tests**: For entities, use cases, repositories, and data sources
- **Widget Tests**: For presentation layer components
- **Integration Tests**: For complete feature workflows (when enabled)

## 🧹 Cleanup & Maintenance

### Safe Cleanup

```bash
# Remove specific feature
clean_forge clean --feature=user_auth

# Preview cleanup
clean_forge clean --all --dry-run

# Interactive cleanup
clean_forge clean
```

### What Gets Cleaned

- **Feature Directories**: `lib/features/<feature_name>/`
- **Test Directories**: `test/features/<feature_name>/`
- **Core Structure**: `lib/core/`, `lib/features/`, `lib/injection/`
- **Configuration**: `clean_forge.json`

⚠️ **Warning**: The `--all` option removes ALL generated content and cannot be undone. Always use `--dry-run` first.

## 🔧 Troubleshooting

### Common Issues

#### Command Not Found
```bash
# Add pub cache to PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Or reinstall
dart pub global activate clean_forge
```

#### No lib/ Directory Found
```
❌ No lib/ directory found. Are you in a Flutter project?
```
**Solution**: Ensure you're in the root directory of a Flutter project with a `lib/` folder.

#### Feature Already Exists
```
❌ Feature "user_auth" already exists!
```
**Solution**: Choose a different feature name or remove the existing feature:
```bash
clean_forge clean --feature=user_auth
```

#### Configuration Not Found
```
❌ Not initialized. Run: clean_forge init
```
**Solution**: Initialize Clean Forge first:
```bash
clean_forge init
```

### Getting Help

```bash
# General help
clean_forge --help

# Command-specific help
clean_forge init --help
clean_forge feature --help
clean_forge config --help
clean_forge clean --help
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ishe19/clean_forge.git
   cd clean_forge
   ```

2. **Install dependencies**:
   ```bash
   dart pub get
   ```

3. **Run tests**:
   ```bash
   dart test
   ```

4. **Activate locally**:
   ```bash
   dart pub global activate --source path .
   ```

### Code Style

This project follows the [Dart style guide](https://dart.dev/guides/language/effective-dart/style).

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Repository**: [https://github.com/ishe19/clean_forge](https://github.com/ishe19/clean_forge)

**Author**: Isheanesu Gwangwanyu

**Version**: ![pub.dev](https://img.shields.io/pub/v/clean_forge)

---

*Made with ❤️ for the Flutter community*
