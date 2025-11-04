import 'dart:io';

abstract class AppConst {
  AppConst._();

  static final String secretKey =
      Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';
  static final String accessToken = "accessToken";
  static final String refreshToken = "refreshToken";
}
