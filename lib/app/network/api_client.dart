import 'package:dio/dio.dart';
import '../env/env.dart';

part 'api_client_usage.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({List<Interceptor>? externalInterceptors}) {
    final BaseOptions options = BaseOptions(
      baseUrl: EnvConfig.instance.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    _addInternalInterceptors();

    if (externalInterceptors != null) {
      _dio.interceptors.addAll(externalInterceptors);
    }
  }

  void _addInternalInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-App-Env'] = EnvConfig.instance.environment.name;
          return handler.next(options);
        },
      ),
    );

    if (EnvConfig.instance.environment == Environment.dev) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  void addInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
}
