import 'package:auth/utils/app_env.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final key = AppEnv.secretKey;
      final jwtClaim = verifyJwtHS256Signature(token, key);
      return int.parse(jwtClaim['id'].toString());
    } catch (_) {
      rethrow;
    }
  }

  static int getIdFromHeader(String header) {
    try {
      final token = AuthorizationBearerParser().parse(header);
      final id = getIdFromToken(token ?? '');
      return id;
    } catch (_) {
      rethrow;
    }
  }
}
