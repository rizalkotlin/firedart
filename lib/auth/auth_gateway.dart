import 'dart:convert';

import 'package:firedart/auth/client.dart';
import 'package:firedart/auth/token_provider.dart';

import 'user_gateway.dart';

class AuthGateway {
  final KeyClient client;
  final TokenProvider tokenProvider;

  AuthGateway(this.client, this.tokenProvider);

  Future<User> signUp(String email, String password) async =>
      _auth('signUp', email, password);

  Future<User> signIn(String email, String password) async =>
      _auth('signInWithPassword', email, password);

  Future<void> resetPassword(String email) => _post('sendOobCode', {
        'requestType': 'PASSWORD_RESET',
        'email': email,
      });

  Future<User> _auth(String method, String email, String password,
      {bool secureToken = true}) async {
    var body = {
      'email': email,
      'password': password,
      'returnSecureToken': '$secureToken',
    };

    var map = await _post(method, body);
    tokenProvider.setToken(map);
    return User.fromMap(map);
  }

  Future<Map<String, dynamic>> _post(
      String method, Map<String, String> body) async {
    var requestUrl =
        'https://identitytoolkit.googleapis.com/v1/accounts:$method';
    var response = await client.post(
      requestUrl,
      body: body,
    );

    // print('method $method');
    // print('body $body url $requestUrl');
    // print('response code ${response.statusCode}');
    // print('response body ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode}: ${response.reasonPhrase}');
    }
//     print('response ${json.decode(response.body)['idToken']}');
    return json.decode(response.body);
  }
}
