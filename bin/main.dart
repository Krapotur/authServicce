import 'dart:io';
import 'package:auth/auth.dart';
import 'package:conduit_core/conduit_core.dart';

void main(List<String> arguments) {
  final int port = int.parse(Platform.environment["PORT"] ?? "8080");
  final service = Application<AppService>()..options.port = port;

  service.start(numberOfInstances: 3, consoleLogging: true);
}
