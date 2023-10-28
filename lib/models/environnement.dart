import 'dart:io';

import 'package:dart_datasource_models/dart_datasource_models.dart';

class Environnement extends EnvironnementAbstractClass {
  const Environnement._({
    required super.httpClient,
    required super.apiEndpoint,
  });

  factory Environnement.fromEnv() {
    return Environnement._(
      httpClient: HttpClient(
        persistentConnection: false,
        authInterceptor: HomebridgeAuthInterceptor.instance,
      ),
      apiEndpoint: Platform.environment['HOMEBRIDGE_URI']!,
    );
  }
}

class HomebridgeAuthInterceptor extends AuthorizationHeaderAuthInterceptor {
  HomebridgeAuthInterceptor() : super(prefix: 'Bearer');
  static final HomebridgeAuthInterceptor instance = HomebridgeAuthInterceptor();

  set authToken(String? newAuthToken) {
    _authToken = newAuthToken;
  }

  String? _authToken;

  @override
  Future<String> loadAuthToken() async {
    if (_authToken == null) {
      throw Exception('Auth token not defined');
    }
    return _authToken!;
  }
}
