import 'dart:io';

import 'package:auth/models/response_model.dart';
import 'package:auth/models/user.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties(
          (table) => [table.id, table.salt, table.hashPassword],
        );
      final findUser = await qFindUser.fetchOne();

      if (findUser == null) {
        throw QueryException.input("Пользователь не найден", []);
      }

      final requestHasPassword = generatePasswordHash(
        user.password ?? "",
        findUser.salt ?? "",
      );

      if (requestHasPassword == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);
        final newUser = await managedContext.fetchObjectWithID<User>(
          findUser.id,
        );
        return Response.ok(
          ResModel(
            data: newUser?.backing.contents,
            message: 'Авторизация прошла успешно!',
          ),
        );
      } else {
        throw QueryException.input("Пароль неверный", []);
      }
    } on QueryException catch (error) {
      return Response.serverError(body: ResModel(message: error.message));
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.username == null || user.password == null || user.email == null) {
      return Response.badRequest(
        body: ResModel(message: 'Поля username, password, email обзательны!'),
      );
    }

    print('--------------Запрос: ${user.backing.contents}');
    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);

    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qFindUser = Query<User>(transaction)
          ..where((x) => x.username).equalTo(user.username);

        final findUser = await qFindUser.fetchOne();

        print('---------------Пользователь: ${findUser?.backing.contents}');

        if (findUser?.username == user.username) {
          throw QueryException.input(
            "Пользователь c таким логином уже существует, придумайте другой логин!",
            [],
          );
        }

        if (findUser?.email == user.email) {
          throw QueryException.input(
            "Пользователь c таким email уже существует!",
            [],
          );
        }

        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;

        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()['id'];

        await _updateTokens(id, transaction);
      });
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return Response.ok(
        ResModel(
          data: userData?.backing.contents,
          message: 'Регистрация прошла успешно!',
        ),
      );
    } on QueryException catch (error) {
      return Response.serverError(body: ResModel(message: error.message));
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    Map<String, dynamic> tokens = _getTokens(id: id);
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens['accessToken']
      ..values.refreshToken = tokens['refreshToken'];
    await qUpdateTokens.updateOne();
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
    @Bind.path("refresh") String refreshToken,
  ) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);

      await _updateTokens(id, managedContext);
      final user = await managedContext.fetchObjectWithID<User>(id);

      return Response.ok(
        ResModel(
          data: user?.backing.contents,
          message: 'Успешное обновление токенов!',
        ),
      );
    } catch (error) {
      return Response.serverError(body: ResModel(message: error.toString()));
    }
  }

  Map<String, dynamic> _getTokens({required int id}) {
    //TODO REMOVE WHEN RELEASE
    final key = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';
    final accessClaimset = JwtClaim(
      maxAge: Duration(hours: 1),
      otherClaims: {'id': id},
    );
    final refreshClaimset = JwtClaim(otherClaims: {'id': id});
    final tokens = <String, dynamic>{};
    tokens['accessToken'] = issueJwtHS256(accessClaimset, key);
    tokens['refreshToken'] = issueJwtHS256(refreshClaimset, key);
    return tokens;
  }
}
