import 'package:logger/logger.dart';
import 'globals.dart' as globals;

Logger getLogger() {
  return Logger(
    level: globals.logLevel,
    printer: PrettyPrinter(
      printEmojis: true,
      printTime: true,
      lineLength: 100,
      colors: true,
      methodCount: 3,
      errorMethodCount: 5,
    ),
  );
}
