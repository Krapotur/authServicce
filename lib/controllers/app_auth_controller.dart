import 'package:auth/models/response_model.dart';
import 'package:conduit_core/conduit_core.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn() async {
    return Response.ok(
      ResModel(
        data: {
          "id": "1",
          "refreshToken": "refreshToken",
          "accessToken": "accessToken",
        },
        message: "Все четко! Авторизовался",
      ).toJson(),
    );
  }

  @Operation.put()
  Future<Response> signUp() async {
    return Response.ok(
      ResModel(
        data: {
          "id": "1",
          "refreshToken": "refreshToken",
          "accessToken": "accessToken",
        },
        message: "Все четко! Зарегался",
      ).toJson(),
    );
  }

  @Operation.post("refresh")
  Future<Response> refreshToken() async {
    return Response.ok(
      ResModel(error: "token is not valid", message: "Token шляпа?!").toJson(),
    );
  }
}
