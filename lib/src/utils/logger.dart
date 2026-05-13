import 'package:mason_logger/mason_logger.dart';

class CleanForgeLogger {
  final Logger _logger;

  CleanForgeLogger() : _logger = Logger();

  void info(String message) => _logger.info(message);

  void success(String message) => _logger.success(message);

  void warn(String message) => _logger.warn(message);

  void err(String message) => _logger.err(message);

  Progress progress(String message) => _logger.progress(message);

  void detail(String message) => _logger.detail(message);

  void blank() => _logger.info('');
}
