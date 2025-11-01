import 'package:auth/models/response_model.dart';
import 'package:auth/models/user.dart';
import 'package:conduit_core/conduit_core.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.username == null || user.password == null) {
      return Response.badRequest(
        body: ResModel(message: 'Поля username и password обзательны!'),
      );
    }

    final User fetchedUser = User();

    return Response.ok(
      ResModel(
        data: {
          "id": fetchedUser.id,
          "refreshToken": fetchedUser.refreshToken,
          "accessToken": fetchedUser.accessToken,
        },
        message: "Все четко! Авторизовался",
      ).toJson(),
    );
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.username == null || user.password == null || user.email == null) {
      return Response.badRequest(
        body: ResModel(message: 'Поля username, password, email обзательны!'),
      );
    }

    final User fetchedUser = User();

    return Response.ok(
      ResModel(
        data: {
          "id": fetchedUser.id,
          "refreshToken": fetchedUser.refreshToken,
          "accessToken": fetchedUser.accessToken,
        },
        message: "Все четко! Зарегался",
      ).toJson(),
    );
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
    @Bind.path("refresh") String refreshToken,
  ) async {
    final User fetchedUser = User();

    return Response.ok(
      ResModel(
        data: {
          "id": fetchedUser.id,
          "refreshToken": fetchedUser.refreshToken,
          "accessToken": fetchedUser.accessToken,
        },
        message: "Токен успешн обновлен!",
      ).toJson(),
    );
  }
}
