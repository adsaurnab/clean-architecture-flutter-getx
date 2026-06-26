import 'package:getx_customized_clean_project_structure/app/core/constants/app_constant.dart';

enum Environment { dev, prod }

class EnvConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool showDebugBanner;

  EnvConfig._internal({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.showDebugBanner,
  });

  static late EnvConfig _instance;

  static EnvConfig get instance => _instance;

  static void initialize({required Environment environment}) {
    switch (environment) {
      case Environment.dev:
        _instance = EnvConfig._internal(
          environment: environment,
          apiBaseUrl: 'https://api-dev.example.com',
          appName: 'App (Dev)',
          showDebugBanner: true,
        );
        break;
      case Environment.prod:
        _instance = EnvConfig._internal(
          environment: environment,
          apiBaseUrl: AppConstant.apiBaseUrl,
          appName: AppConstant.appName,
          showDebugBanner: false,
        );
        break;
    }
  }
}
