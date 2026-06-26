
part of 'api_client.dart';

final apiClient = ApiClient(
  externalInterceptors: [
    // AuthInterceptor(), // Custom external class
  ],
);