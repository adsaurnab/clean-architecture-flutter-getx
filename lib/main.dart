import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/core/helper/storage_helper.dart';
import 'app/env/env.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.initialize(environment: Environment.dev);

  await StorageHelper().init();

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: EnvConfig.instance.showDebugBanner,
    ),
  );
}
